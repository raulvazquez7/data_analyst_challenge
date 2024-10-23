-- Create intervals for each ticket's status duration
WITH status_intervals AS (
  SELECT
    ticket_id,
    value_status,
    created_at AS start_time,
    LEAD(created_at) OVER (PARTITION BY ticket_id ORDER BY created_at) AS end_time
  FROM `burnished-flare-384310.bitpanda.tickets`
),

-- Filter intervals where status is 'new' or 'open' and set end_time if null
relevant_intervals AS (
  SELECT
    ticket_id,
    value_status,
    start_time,
    IFNULL(end_time, TIMESTAMP('2024-04-30 23:59:59')) AS end_time
  FROM status_intervals
  WHERE value_status IN ('new', 'open')
),

-- Generate timepoints at 00:00 and 07:00 each day within the date range
timepoints AS (
  SELECT
    TIMESTAMP(DATE_ADD(DATE '2024-04-15', INTERVAL day_offset DAY) + time_offset * INTERVAL 7 HOUR) AS date
  FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF('2024-04-30', '2024-04-15', DAY))) AS day_offset,
       UNNEST([0, 1]) AS time_offset  -- 0 for 00:00, 1 for 07:00
)

-- Calculate the number of tickets in 'new' or 'open' status at each timepoint
SELECT
  t.date,
  SUM(CASE WHEN r.value_status = 'open' THEN 1 ELSE 0 END) AS tickets_open,
  SUM(CASE WHEN r.value_status = 'new' THEN 1 ELSE 0 END) AS tickets_new,
  COUNT(DISTINCT r.ticket_id) AS total
FROM timepoints t
LEFT JOIN relevant_intervals r
  ON t.date >= r.start_time AND t.date < r.end_time
GROUP BY t.date
ORDER BY t.date
