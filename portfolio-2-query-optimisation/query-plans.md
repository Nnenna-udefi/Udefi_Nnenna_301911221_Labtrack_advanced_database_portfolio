# Query Execution Plans

## Query 1: Retrieve a Patient's Laboratory Orders

### Objective
Retrieve laboratory orders for patient ID 200 within the 2026 calendar year.

### SQL Query
```sql
SELECT order_id, order_number, ordered_at, status
FROM lab_orders
WHERE patient_id = 200
  AND ordered_at >= '2026-01-01'
  AND ordered_at < '2027-01-01';
```

### EXPLAIN ANALYZE Findings

MySQL used an **index range scan** through `idx_orders_patient_date`, which indexes `patient_id` and `ordered_at`.

- **Estimated rows:** 2
- **Actual rows:** 2
- **Estimated cost:** 1.16
- **Reported actual execution time:** approximately 0.12 ms

### Interpretation

The execution plan shows that MySQL used the composite index to search for the specified patient's orders within the date range. The estimated number of rows matched the actual number of rows returned.

This indicates that the index is suitable for the query's filtering conditions. However, a comparison with an alternative execution plan is required to establish the performance benefit of using the index.