## Backlog Calculation Query

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
