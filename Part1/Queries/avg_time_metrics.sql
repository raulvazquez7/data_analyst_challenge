-- CTE to get all status changes per ticket with next status information
WITH ticket_statuses AS (
  SELECT
    ts.ticket_id,
    ts.value_status,
    ts.updater_id,
    ts.created_at,
    LEAD(ts.value_status) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at) AS next_status,
    LEAD(ts.created_at) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at) AS next_created_at,
    LEAD(ts.updater_id) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at) AS next_updater_id
  FROM `burnished-flare-384310.bitpanda.tickets` ts
),

-- Get the list of all ticket IDs
ticket_list AS (
  SELECT DISTINCT ticket_id FROM ticket_statuses
),

-- Determine the creation date for each ticket
ticket_creation_dates AS (
  SELECT
    l.ticket_id,
    IFNULL(MIN(CASE WHEN s.value_status = 'New' THEN s.created_at END), TIMESTAMP('2024-04-14 13:00:00')) AS created_at
  FROM ticket_list l
  LEFT JOIN ticket_statuses s ON l.ticket_id = s.ticket_id
  GROUP BY l.ticket_id
),

-- Determine the solved date for each ticket
ticket_solved_dates AS (
  SELECT
    l.ticket_id,
    IFNULL(
      MIN(s.created_at),
      TIMESTAMP('2024-05-01 13:00:00')
    ) AS solved_at
  FROM ticket_list l
  LEFT JOIN ticket_statuses s ON l.ticket_id = s.ticket_id
  JOIN ticket_creation_dates c ON l.ticket_id = c.ticket_id
  WHERE s.value_status IN ('Solved', 'Close') AND s.created_at >= c.created_at
  GROUP BY l.ticket_id
),

-- Calculate total time from 'New' to 'Solved' or 'Closed' per ticket
ticket_total_times AS (
  SELECT
    c.ticket_id,
    c.created_at,
    s.solved_at,
    TIMESTAMP_DIFF(s.solved_at, c.created_at, MINUTE) AS total_time_minutes,
    DATE(s.solved_at) AS solved_date
  FROM ticket_creation_dates c
  JOIN ticket_solved_dates s ON c.ticket_id = s.ticket_id
),

-- Calculate durations for each status per ticket
ticket_status_durations AS (
  SELECT
    ts.ticket_id,
    ts.value_status,
    ts.updater_id,
    ts.created_at AS start_time,
    LEAD(ts.created_at) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at) AS end_time,
    c.created_at AS ticket_created_at,
    s.solved_at,
    -- Adjust start and end times within ticket's life cycle
    GREATEST(ts.created_at, c.created_at) AS adj_start_time,
    LEAST(IFNULL(LEAD(ts.created_at) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at), s.solved_at), s.solved_at) AS adj_end_time,
    TIMESTAMP_DIFF(
      LEAST(IFNULL(LEAD(ts.created_at) OVER (PARTITION BY ts.ticket_id ORDER BY ts.created_at), s.solved_at), s.solved_at),
      GREATEST(ts.created_at, c.created_at),
      MINUTE
    ) AS duration_minutes
  FROM ticket_statuses ts
  JOIN ticket_creation_dates c ON ts.ticket_id = c.ticket_id
  JOIN ticket_solved_dates s ON ts.ticket_id = s.ticket_id
  WHERE ts.created_at >= c.created_at AND ts.created_at <= s.solved_at
),

-- Sum durations in 'New', 'Open', or 'Hold' statuses per ticket
ticket_waiting_times AS (
  SELECT
    ticket_id,
    SUM(duration_minutes) AS waiting_time_minutes
  FROM ticket_status_durations
  WHERE value_status IN ('New', 'Open', 'Hold')
  GROUP BY ticket_id
),

-- Identify 'New' status entries per ticket
ticket_new_statuses AS (
  SELECT
    ts.ticket_id,
    ts.created_at AS new_created_at,
    ts.updater_id AS new_updater_id
  FROM ticket_statuses ts
  WHERE ts.value_status = 'New'
),

-- Get all subsequent status changes per ticket
ticket_next_statuses AS (
  SELECT
    ts.ticket_id,
    ts.created_at AS status_created_at,
    ts.updater_id AS status_updater_id
  FROM ticket_statuses ts
),

-- Calculate First Reply Time (FRT) per ticket
ticket_frt AS (
  SELECT
    n.ticket_id,
    n.new_created_at,
    n.new_updater_id,
    IFNULL(MIN(s.status_created_at), TIMESTAMP('2024-05-01 13:00:00')) AS next_status_created_at
  FROM ticket_new_statuses n
  LEFT JOIN ticket_next_statuses s ON n.ticket_id = s.ticket_id
    AND s.status_created_at > n.new_created_at
    AND s.status_updater_id != n.new_updater_id
  GROUP BY n.ticket_id, n.new_created_at, n.new_updater_id
),

-- Calculate FRT in minutes per ticket
ticket_frt_times AS (
  SELECT
    ticket_id,
    TIMESTAMP_DIFF(next_status_created_at, new_created_at, MINUTE) AS frt_minutes
  FROM ticket_frt
),

-- Combine all metrics per ticket
ticket_metrics AS (
  SELECT
    tt.ticket_id,
    tt.solved_date,
    tt.total_time_minutes,
    wt.waiting_time_minutes,
    ft.frt_minutes
  FROM ticket_total_times tt
  LEFT JOIN ticket_waiting_times wt ON tt.ticket_id = wt.ticket_id
  LEFT JOIN ticket_frt_times ft ON tt.ticket_id = ft.ticket_id
),

-- Exclude tickets with metrics less than 1 hour
ticket_metrics_filtered AS (
  SELECT
    *
  FROM ticket_metrics
  WHERE total_time_minutes >= 60
    AND waiting_time_minutes >= 60
    AND frt_minutes >= 60
)

-- Calculate average metrics per solved date
SELECT
  solved_date,
  AVG(total_time_minutes) AS avg_total_time,
  AVG(waiting_time_minutes) AS avg_waiting_time,
  AVG(frt_minutes) AS avg_frt
FROM ticket_metrics_filtered
GROUP BY solved_date
ORDER BY solved_date
