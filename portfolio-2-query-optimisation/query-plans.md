# Portfolio 2: Query Execution Plans

**Course:** MIT 8103 – Advanced Database Systems  
**Project:** LabTrack Laboratory Information Management System (LIMS)  
**Database engine:** MySQL 8.0

## 1. Purpose

This document records how MySQL executes selected LabTrack queries.

## 2. Query 1: Patient Order History

**Goal:** Find orders for patient ID `200` placed during 2026.

### Indexed version

MySQL used the composite index `idx_orders_patient_date`, which contains `patient_id` followed by `ordered_at`.

The index helps MySQL narrow the search to the selected patient and date range instead of reading every order.

**Recorded execution plan:**

```text
Index range scan on lab_orders using idx_orders_patient_date
(cost=1.16 rows=2)
(actual time=0.117..0.120 rows=2 loops=1)
```

### Full table scan comparison

The comparison query used `IGNORE INDEX` to prevent MySQL from using the patient/date index.

**Recorded plan:**

```text
Filter: patient_id = 200 and ordered_at is in the 2026 date range
(cost=2000.00 rows=222)
(actual time=0.237..18.400 rows=2 loops=1)

Table scan on lab_orders
(cost=2000.00 rows=19995)
(actual time=0.200..17.200 rows=19995 loops=1)
```

### Interpretation

The indexed version returned two rows in approximately 0.12 ms. The full table scan examined 19,995 rows and took approximately 18.4 ms in the recorded test.

This shows why an index that matches the search conditions can be useful when only a small number of rows are needed.

## 3. Query 2: Pending Order Worklist

**Goal:** Find orders with status `PENDING` that were created during 2026.

**Index tested:** `idx_orders_status_date`

**Indexed execution plan:**

```text
Index range scan on lab_orders using idx_orders_status_date
(cost=2250 rows=4999)
(actual time=10.9..29.2 rows=4999 loops=1)
```
**Forced table scan comparison:**

```text
Filter: status = 'PENDING' and ordered_at is in the 2026 date range
(cost=2000 rows=1)
(actual time=0.421..7.96 rows=4999 loops=1)

Table scan on lab_orders
(cost=2000 rows=19995)
(actual time=0.414..6.05 rows=19995 loops=1)
```

### Interpretation

MySQL used the index containing `status` and `ordered_at` to find matching orders.

Both queries returned 4,999 orders. However, the forced table scan was faster in this test.

The index did not provide an advantage for this particular workload. One possible reason is that many orders matched the filters, so MySQL still had to process a large number of records.

This result shows that an index should be evaluated against the actual query and data rather than assumed to improve performance.

## 4. Query 3: Patient Orders Using a JOIN

**Goal:** Find a patient's orders using the patient number `PAT000456`.

**Indexes involved:**
- `uq_patient_number` on the patient number.
- `idx_orders_patient_date` on the patient ID and order date.

**Recorded plan:**

```text
Nested loop inner join
(cost=2.32 rows=2)
(actual time=0.150..0.155 rows=2 loops=1)

Index lookup on patients using uq_patient_number
(cost=0.35 rows=1)
(actual time=0.019..0.021 rows=1 loops=1)

Index range scan on lab_orders using idx_orders_patient_date
(cost=1.97 rows=2)
(actual time=0.131..0.133 rows=2 loops=1)
```

### Interpretation

MySQL first used the unique patient-number index to find one patient. It then used the patient/date index to retrieve that patient's matching orders.

This avoids scanning all patients and orders to find the requested records. The recorded execution time was approximately 0.155 ms.

## 5. Query 4: Pending Test Worklist

**Goal:** Find test records whose status is `PENDING`.

**Index tested:** `idx_order_tests_status`

### Indexed version

```text
Index lookup on order_tests using idx_order_tests_status
(cost=501.00 rows=4999)
(actual time=0.799..16.300 rows=4999 loops=1)
```

### Table scan comparison

```text
Filter: order_tests.status = 'PENDING'
(cost=2000.00 rows=1.67)
(actual time=0.279..15.800 rows=4999 loops=1)

Table scan on order_tests
(cost=2000.00 rows=19995)
(actual time=0.275..5.860 rows=19995 loops=1)
```

### Interpretation

The index version took approximately 16.3 ms, while the forced table scan took approximately 15.8 ms in the recorded test.

The table scan was slightly faster in this comparison. One likely reason is that a large share of the records matched the status filter, so reading the index did not save much work.

This is an important finding: indexes are useful tools, but they should be tested rather than added automatically.

## 6. Query 5: Patients with Pending Orders

**Goal:** Find patients who have at least one laboratory order with a status of `PENDING`.

This experiment compares two SQL approaches: an `IN` subquery and an `EXISTS` subquery. Both queries return the patient's ID, first name, and last name.

### Version A: IN subquery

**Recorded execution plan:**

```text
Nested loop semijoin (FirstMatch)
(cost=2.5 rows=1.25)
(actual time=0.223..103 rows=2500 loops=1)

Table scan on p
(cost=0.75 rows=5)
(actual time=0.135..16.5 rows=10005 loops=1)

Filter: (o.`status` = 'PENDING')
(cost=0.0638 rows=0.25)
(actual time=0.00858..0.00858 rows=0.25 loops=10005)

Index lookup on o using idx_orders_patient_date
(patient_id = p.patient_id)
(cost=0.0638 rows=1)
(actual time=0.00801..0.00836 rows=1.75 loops=10005)
```

**Recorded final execution-plan time:** Approximately 103 ms.  
**Rows returned:** 2,500 patients.

### Version B: EXISTS subquery

**Recorded execution plan:**

```text
Nested loop semijoin (FirstMatch)
(cost=2.5 rows=1.25)
(actual time=0.148..117 rows=2500 loops=1)

Table scan on p
(cost=0.75 rows=5)
(actual time=0.075..27.3 rows=10005 loops=1)

Filter: (o.`status` = 'PENDING')
(cost=0.0638 rows=0.25)
(actual time=0.00882..0.00882 rows=0.25 loops=10005)

Index lookup on o using idx_orders_patient_date
(patient_id = p.patient_id)
(cost=0.0638 rows=1)
(actual time=0.00823..0.00859 rows=1.75 loops=10005)
```

**Recorded final execution-plan time:** Approximately 117 ms.  
**Rows returned:** 2,500 patients.

### Interpretation

Both queries returned 2,500 patients and used the same execution strategy: a nested loop semijoin with `FirstMatch`.

MySQL scanned 10,005 patient records and used the `idx_orders_patient_date` index to look up orders for each patient. The `FirstMatch` strategy allows MySQL to stop searching for further matching orders once it finds a qualifying pending order for a patient.

The `IN` version reported a final execution-plan time of approximately 103 ms, while the `EXISTS` version reported approximately 117 ms. The `IN` version was faster in these recorded runs, but this does not prove that it is always faster. Execution times can vary due to caching, system load, and other factors.

The plans also show that MySQL transformed both query forms into the same type of semijoin strategy. This demonstrates that the database engine can optimise different SQL expressions into similar execution plans.

**Conclusion:** Both query forms produced the same result count and used the same execution strategy. Based on these recorded measurements, `IN` was faster in this run. Repeated tests would be needed before drawing a general performance conclusion.


## 7. Query 6: Daily Order Summary

**Goal:** Count orders for each day in January 2026.

### Live aggregation

The first query calculates the daily counts directly from `lab_orders`.

**Recorded plan:**

```text
Table scan on <temporary>
(actual time=7.47..7.47 rows=31 loops=1)

Aggregate using temporary table
(actual time=7.47..7.47 rows=31 loops=1)

Filter: ordered_at is in the January 2026 date range
(cost=2000 rows=2221)
(actual time=1.53..6.94 rows=2071 loops=1)

Covering index scan on lab_orders using idx_orders_patient_date
(cost=2000 rows=19995)
(actual time=1.52..5.42 rows=19995 loops=1)
```
Interpretation of Version A

MySQL scanned the covering index and processed all 19,995 index entries before applying the date filter. It then grouped the matching records into 31 daily totals.

Although an index was used, the plan does not show a date-range scan. The existing composite index starts with patient_id, so it is not ideally ordered for filtering only by ordered_at.

A separate index beginning with ordered_at could be tested in a future experiment.

Version B: Pre-calculated summary

The summary table stores the daily counts so the report does not need to calculate them from all the underlying order records each time.

Recorded execution plan
```text
Filter: summary_date is in the January 2026 date range
(cost=6.47 rows=31)
(actual time=0.0164..0.0235 rows=31 loops=1)

Index range scan on summary_daily_test_counts using PRIMARY
(cost=6.47 rows=31)
(actual time=0.015..0.0191 rows=31 loops=1)
```

### Interpretation
The summary lookup was substantially faster in the recorded test because it read 31 pre-calculated totals instead of processing thousands of order records.

The summary table must be refreshed when the underlying data changes. Its totals should also be checked against the live aggregation to confirm that the two methods produce the same results.



## 8. Final Observations

The tests show that:

1. The patient/date index greatly reduced the work required for Query 1.
2. The table scan was faster than the indexed approach in Query 2.
3. The patient-number and patient/date indexes supported an efficient join in Query 3.
4. The status index did not improve the recorded timing for Query 4.
5. MySQL transformed the Query 5 subqueries into plans involving materialisation and deduplication.
6. The pre-calculated summary made Query 6 faster in the recorded test.

These findings should be interpreted in the context of the dataset and test environment. They do not establish that the same access method will always be fastest at larger scales.