-- This query searches for orders belonging to patient ID 200 throughout 2026.
-- It Evaluates query execulation plan and index usage for filtering lab orders by patient and date range.
EXPLAIN ANALYZE
SELECT order_id, order_number, ordered_at, status
FROM lab_orders
WHERE patient_id = 200
    AND ordered_at >= '2026-01-01'
    AND ordered_at < '2027-01-01';