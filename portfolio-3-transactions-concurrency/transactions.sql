-- LabTrack Portfolio 3: Transactions and Concurrency
-- Database: labtrack_db
-- DBMS: MySQL / InnoDB

-- =========================================================
-- EXPERIMENT 1: COMMIT
-- Goal: To demonstrate that committed changes persist.
-- =========================================================

-- Checks the existing record.
SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;

-- begins the transaction
START TRANSACTION;

-- changes the lab_order from COMPLETED to IN_PROGRESS
UPDATE lab_orders
SET status = 'IN_PROGRESS'
WHERE order_id = 4500;

-- Inspects the change before committing.
SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;

-- saves the change.
COMMIT;

-- Verifies that the committed change persists.
SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;


-- =========================================================
-- EXPERIMENT 2: ROLLBACK
-- Goal: Demonstrate that uncommitted changes are cancelled.
-- =========================================================

SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;

START TRANSACTION;

UPDATE lab_orders
SET status = 'PENDING'
WHERE order_id = 4500;

-- The temporary status displays PENDING.
SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;

ROLLBACK;

-- The original status is restored after the rollback.
SELECT order_id, order_number, status
FROM lab_orders
WHERE order_id = 4500;


-- =========================================================
-- EXPERIMENT 3: TRANSACTION ISOLATION
-- Goal: To demonstrate REPEATABLE READ using two seperate sessions (mysql connections).
-- =========================================================

-- The initial result interpretation of result_id 1 is NEGATIVE
-- SESSION A: Execute in Connection A.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- This is Session A's first consistent read.
SELECT result_id, interpretation
FROM test_results
WHERE result_id = 1;

-- The transaction is left open

-- SESSION B: Executed in Connection B and saved.
START TRANSACTION;

UPDATE test_results
SET interpretation = 'POSITIVE'
WHERE result_id = 1;

COMMIT;

-- Returns to SESSION A and end its transaction.
COMMIT;

-- A new read should now see the committed update (POSITIVE interpretation).
SELECT result_id, interpretation
FROM test_results
WHERE result_id = 1;


-- =========================================================
-- EXPERIMENT 4: CONCURRENCY AND ROW LOCKING
-- Goal: To demonstrate that a conflicting update waits for a lock.
-- =========================================================

-- SESSION A: Execute in Connection A.
START TRANSACTION;

SELECT order_id, status
FROM lab_orders
WHERE order_id = 5820
FOR UPDATE;

-- This transaction is kept open while running Session B

-- SESSION B: Execute in Connection B.
START TRANSACTION;

UPDATE lab_orders
SET status = 'IN_PROGRESS'
WHERE order_id = 5820;

-- The UPDATE waits because Session A holds the row lock.


-- SESSION A: Executed in Connection A to release the lock.
COMMIT;

-- SESSION B: Once its UPDATE finishes, execute:
COMMIT;

-- The final status in either sessions is verified.
SELECT order_id, status
FROM lab_orders
WHERE order_id = 5820;
