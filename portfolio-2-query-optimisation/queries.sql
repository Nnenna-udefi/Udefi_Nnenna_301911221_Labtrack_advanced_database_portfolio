
-- ============================================================
-- LabTrack LIMS: Portfolio 2 - Query Optimisation
-- Database: labtrack_db
-- Engine: MySQL 8.0
-- ============================================================

USE labtrack_db;

-- ============================================================
-- QUERY 1: Patient Order History
-- Goal: Find one patient's orders within 2026.
-- Index tested: idx_orders_patient_date
-- ============================================================

-- Optimised version: uses a date range so the index can be used.
EXPLAIN ANALYZE
SELECT order_id, order_number, ordered_at, status
FROM lab_orders
WHERE patient_id = 200
  AND ordered_at >= '2026-01-01'
  AND ordered_at <  '2027-01-01';


-- Comparison: prevent use of the patient/date index (idx_orders_patient_date).
-- This tests the cost of scanning the table (table scan) instead.
EXPLAIN ANALYZE
SELECT order_id, order_number, ordered_at, status
FROM lab_orders IGNORE INDEX (idx_orders_patient_date)
WHERE patient_id = 200
  AND ordered_at >= '2026-01-01'
  AND ordered_at <  '2027-01-01';


-- ============================================================
-- QUERY 2: Pending Laboratory Orders
-- Goal: Find pending orders created during 2026.
-- Index tested: idx_orders_status_date
-- ============================================================

EXPLAIN ANALYZE
SELECT order_id, order_number, patient_id, ordered_at
FROM lab_orders
WHERE status = 'PENDING'
  AND ordered_at >= '2026-01-01'
  AND ordered_at <  '2027-01-01';

-- Comparison version
EXPLAIN ANALYZE
SELECT order_id, order_number, patient_id, ordered_at
FROM lab_orders IGNORE INDEX (PRIMARY, idx_orders_status_date)
WHERE status = 'PENDING'
    AND ordered_at >= '2026-01-01'
    AND ordered_at < '2027-01-01';


-- ============================================================
-- QUERY 3: Patient Order Search Using a JOIN
-- Goal: Find a patient's orders from 2026.
-- Indexes tested: uq_patient_number and
--                 idx_orders_patient_date
-- ============================================================

EXPLAIN ANALYZE
SELECT
    p.patient_number,
    p.first_name,
    p.last_name,
    o.order_number,
    o.ordered_at,
    o.status
FROM patients AS p
JOIN lab_orders AS o
    ON o.patient_id = p.patient_id
WHERE p.patient_number = 'PAT000456'
  AND o.ordered_at >= '2026-01-01'
  AND o.ordered_at <  '2027-01-01';


-- ============================================================
-- QUERY 4: Pending Test Worklist
-- Goal: Find tests that are still pending.
-- Index tested: idx_order_tests_status
-- ============================================================

-- This version using the status index if the optimiser chooses it.
EXPLAIN ANALYZE
SELECT order_test_id, order_id, test_id, status
FROM order_tests
WHERE status = 'PENDING';


-- Comparison: prevent use of the status index.
EXPLAIN ANALYZE
SELECT order_test_id, order_id, test_id, status
FROM order_tests IGNORE INDEX (idx_order_tests_status)
WHERE status = 'PENDING';


-- ============================================================
-- QUERY 5: Find Patients with Pending Orders
-- Goal: Return patients who have at least one pending order.
-- Technique tested: IN subquery and semi-join optimisation.
-- ============================================================

EXPLAIN ANALYZE
SELECT p.patient_id, p.first_name, p.last_name
FROM patients p
WHERE p.patient_id IN (
    SELECT o.patient_id
    FROM lab_orders o
    WHERE o.status = 'PENDING'
);

-- Alternative EXISTS query
EXPLAIN ANALYZE
SELECT p.patient_id, p.first_name, p.last_name
FROM patients p
WHERE EXISTS (
    SELECT 1
    FROM lab_orders o
    WHERE o.patient_id = p.patient_id
      AND o.status = 'PENDING'
);

-- ============================================================
-- QUERY 6: Daily Order Summary
-- Goal: Compare live aggregation with a pre-calculated summary.
-- The summary table is an additional table for this experiment.
-- ============================================================

-- Version A: calculate daily order counts from live records.
EXPLAIN ANALYZE
SELECT
    DATE(ordered_at) AS order_date,
    COUNT(*) AS total_orders
FROM lab_orders
WHERE ordered_at >= '2026-01-01'
  AND ordered_at <  '2026-02-01'
GROUP BY DATE(ordered_at);

-- Create the summary table if it does not already exist.
CREATE TABLE IF NOT EXISTS summary_daily_test_counts (
    summary_date DATE NOT NULL PRIMARY KEY,
    total_orders BIGINT UNSIGNED NOT NULL
);


-- Populate or refresh the January 2026 summary.
-- This makes the experiment repeatable if the data changes.
INSERT INTO summary_daily_test_counts (summary_date, total_orders)
SELECT
    DATE(ordered_at) AS summary_date,
    COUNT(*) AS total_orders
FROM lab_orders
WHERE ordered_at >= '2026-01-01'
  AND ordered_at <  '2026-02-01'
GROUP BY DATE(ordered_at)
ON DUPLICATE KEY UPDATE
    total_orders = VALUES(total_orders);


-- Version B: retrieve the pre-calculated daily counts.
EXPLAIN ANALYZE
SELECT summary_date, total_orders
FROM summary_daily_test_counts
WHERE summary_date >= '2026-01-01'
  AND summary_date <  '2026-02-01'
ORDER BY summary_date;
