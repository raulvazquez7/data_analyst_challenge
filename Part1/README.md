## 1. Backlog Calculation Query

[See query here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part1/Queries/backlog_calculation.sql)
[See csv result here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part1/Data/backlog_calculation.csv)

### Explanation

The query calculates the number of tickets in the backlog (tickets in ‘New’ or ‘Open’ status) at 07:00 AM and 00:00 AM each day from April 15, 2024, to April 30, 2024. It includes tickets that started before the extraction period.

**Key Components:**

1. status_intervals **CTE:**
    - Creates intervals for each ticket’s status by using the LEAD function to get the end time of each status.
    - Partitions the data by ticket_id and orders by created_at to identify consecutive status changes.
2. relevant_intervals **CTE:**
    - Filters the intervals to include only those where the status is ‘New’ or ‘Open’.
    - Handles tickets without an end time (i.e., the last status change) by setting end_time to '2024-04-30 23:59:59'.
3. timepoints **CTE:**
    - Generates all the required timepoints (dates) at 00:00 and 07:00 AM within the specified date range.
    - Uses GENERATE_ARRAY and UNNEST to create combinations of days and times.
4. **Main Query:**
    - Performs a LEFT JOIN between timepoints and relevant_intervals to associate tickets that are in ‘New’ or ‘Open’ status during each timepoint.
    - The join condition t.date >= r.start_time AND t.date < r.end_time ensures that we only count tickets that were active in the specified status at the exact timepoint.
    - Aggregates the data to count tickets in ‘New’ and ‘Open’ statuses separately, as well as the total number of tickets.

**Assumptions and Notes:**

- Tickets can change statuses multiple times, and we’re interested in intervals where tickets are in ‘New’ or ‘Open’ status.
- If a ticket’s status interval extends beyond the extraction period, it’s considered up to '2024-04-30 23:59:59'.
- Timepoints are generated for each day at 00:00 and 07:00 AM, and the tickets are counted at these exact moments.
- The query includes tickets that started before the extraction period but were in ‘New’ or ‘Open’ status during it.

**How Tickets are Counted:**

- **Timepoints:** Specific moments (00:00 and 07:00 each day) where we assess the backlog.
- **Counting Logic:** For each timepoint, we count tickets whose ‘New’ or ‘Open’ status intervals encompass that timepoint.
- **Status Differentiation:** We separately tally tickets in ‘New’ and ‘Open’ statuses to provide detailed backlog information.

This approach ensures an accurate calculation of the backlog at the specified times, considering all relevant tickets within and before the extraction period.


## 2. Average Time Mettics

[See query here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part1/Queries/avg_time_metrics.sql)
[See csv result here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part1/Data/avg_time_metrics.csv)

### Explanation

The query calculates the average durations in minutes for three key metrics per day when tickets were solved:

1. **Total Time:** The duration from when a ticket enters the ‘New’ status to when it first reaches ‘Solved’ or ‘Closed’.
2. **Waiting Time:** The total time a ticket spends in ‘New’, ‘Open’, or ‘Hold’ statuses.
3. **First Reply Time (FRT):** The time from ‘New’ status to the next status change where the updater is different, ensuring it’s a company reply and not the user.

**Key Steps:**

1. **Data Preparation:**
    - ticket_statuses**:** Collects all status changes per ticket, along with the next status and updater information.
    - ticket_list**:** Lists all unique ticket IDs.
2. **Determine Creation and Solved Dates:**
    - ticket_creation_dates**:** Finds the creation date (first ‘New’ status) for each ticket or sets it to ‘2024-04-14 13:00:00’ if missing.
    - ticket_solved_dates**:** Finds the first ‘Solved’ or ‘Closed’ status after the creation date or sets it to ‘2024-05-01 13:00:00’ if missing.
3. **Calculate Total Time:**
    - ticket_total_times**:** Computes the total time in minutes from creation to solved date for each ticket.
4. **Calculate Waiting Time:**
    - ticket_status_durations**:** Calculates durations for each status segment, adjusting start and end times within the ticket’s lifecycle.
    - ticket_waiting_times**:** Sums durations in ‘New’, ‘Open’, or ‘Hold’ statuses to get the waiting time per ticket.
5. **Calculate First Reply Time (FRT):**
    - ticket_new_statuses**:** Identifies ‘New’ status entries per ticket.
    - ticket_next_statuses**:** Lists all subsequent status changes.
    - ticket_frt**:** Finds the next status change where the updater is different from the ‘New’ status updater.
    - ticket_frt_times**:** Calculates FRT in minutes.
6. **Filter and Calculate Averages:**
    - ticket_metrics**:** Combines all metrics per ticket.
    - ticket_metrics_filtered**:** Excludes tickets where any metric is less than 1 hour (60 minutes).
    - **Final SELECT:** Groups the data by the date tickets were solved and calculates average values for each metric.

**Assumptions and Notes:**

- Tickets without a ‘New’ status have their creation date set to ‘2024-04-14 13:00:00’.
- Tickets without a ‘Solved’ or ‘Closed’ status have their solved date set to ‘2024-05-01 13:00:00’.
- Only tickets with all metrics equal to or exceeding 1 hour are considered in the averages.
- The query outputs the averages per solved_date as required.

This query ensures accurate calculation of the average durations for the specified metrics, considering the special handling of missing creation or solved dates and the exclusion of short-duration tickets.

