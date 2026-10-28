# Portfolio 2: Query Performance Analysis

**Course:** MIT 8103 – Advanced Database Systems  
**Project:** LabTrack Laboratory Information Management System (LIMS)  
**Database:** MySQL 8.0 / InnoDB

## 1. Introduction

The aim of this project is to understand how MySQL retrieves and summarises laboratory data, and how query performance can be improved.

The tests cover patient history searches, pending worklists, table joins, subqueries and daily reporting. They compare index use, table scans and pre-calculated summaries.

The results are based on the execution-plan outputs recorded in `query-plans.md`. Some queries still need a matching baseline test before their performance improvement can be confirmed.

## 2. Summary of Results

| Query | Operation | Recorded comparison | Main finding |
|---|---|---|---|
| 1 | Patient order history | Index: 0.12 ms; table scan: 18.40 ms | The indexed query was much faster. |
| 2 | Pending orders | Index: 29.2 ms; table scan: 7.96 ms | The table scan was faster in this test. |
| 3 | Patient order join | Indexed join: 0.155 ms | The indexes helped locate the patient and orders. |
| 4 | Pending test worklist | Index: 16.30 ms; table scan: 15.80 ms | The table scan was slightly faster. |
| 5 | Patients with pending orders | `IN`: 0.103 ms; `EXISTS` comparison: 0.117 ms | The `IN` version was faster in these recorded runs |
| 6 | Daily order summary | Live aggregation: 7.47 ms; summary lookup: 0.0235 ms | The pre-calculated summary lookup was much faster. |

**Important:** These times are from recorded executions. MySQL's timings can change between runs due to caching, system load, and other conditions. The Query 5 comparison is not a pure comparison of `IN` and `EXISTS`, because the `EXISTS` version disables an index.

## 3. Detailed Analysis

### 3.1 Query 1: Patient Order History

The first query retrieves a patient's orders within a date range.

The composite index `idx_orders_patient_date` contains `patient_id` followed by `ordered_at`. This matches the query's filtering conditions.

The indexed query took approximately 0.12 ms, compared with 18.40 ms for the forced table scan. Both returned two rows.

This result demonstrates how an index can reduce the number of records that MySQL needs to examine.

**Recommendation:** Keep the index while patient history searches remain an important workload.

### 3.2 Query 2: Pending Order Worklist

The second query finds pending orders created during 2026.

The index `idx_orders_status_date` contains `status` followed by `ordered_at`, matching the query's filters. However, the indexed version took approximately 29.2 ms, while the forced table scan took 7.96 ms. Both returned 4,999 rows.

One possible explanation is that many records matched the filters, reducing the benefit of using the index. The actual plan and timings should be checked again before deciding whether to change the index design.

**Recommendation:** Do not assume this index is always the fastest option. Test it using realistic workloads and consider its use by other queries before removing or changing it.

### 3.3 Query 3: Patient Order Search Using a JOIN

This query combines patient details with the patient's laboratory orders.

MySQL used the unique patient-number index to find the patient, then used the patient/date index to find matching orders. The recorded execution time was approximately 0.155 ms for two rows.

This shows how well-matched indexes can reduce the work required for a join.

**Recommendation:** Retain these indexes if patient lookups and order-history searches are common in the application.

### 3.4 Query 4: Pending Test Worklist

This query searches for tests with a `PENDING` status.

The indexed query took approximately 16.30 ms, while the forced table scan took 15.80 ms. Both returned 4,999 rows.

The table scan was slightly faster in this test. When many rows match a filter, the cost of using an index may outweigh its benefit.

**Recommendation:** Repeat the test before changing the index. Also consider how the index supports other queries and how it affects data inserts and updates.


### 3.5 Query 5: Patients with Pending Orders

This experiment compares two ways of finding patients who have at least one pending laboratory order: an `IN` subquery and an `EXISTS` subquery.

Both queries returned 2,500 patients and used the same execution strategy: a nested loop semijoin with `FirstMatch`. MySQL scanned 10,005 patient records and used the `idx_orders_patient_date` index to look up each patient's orders.

The `IN` version reported a final execution-plan time of approximately 103 ms, while the `EXISTS` version reported approximately 117 ms.

The `IN` version was faster in this recorded run. However, this difference alone does not establish that `IN` is generally faster than `EXISTS`. The timings may vary between runs, and MySQL transformed both queries into the same type of execution plan.

**Recommendation:** Choose the query form that is clearest for the application, confirm that both return the same results, and repeat the performance test before drawing a general conclusion.

### 3.6 Query 6: Daily Order Summary

The live query calculates daily order counts from `lab_orders`. Its recorded execution time was approximately 7.47 ms.

The execution plan shows a covering index scan that processed all 19,995 index entries before filtering the records by date. The composite index used in this scan starts with `patient_id`, so it is not ideally ordered for a date-only search.

The summary query retrieves 31 pre-calculated daily totals and took approximately 0.0235 ms.

This is a substantial difference in the recorded run. The summary query has less work to do because the daily counts have already been calculated.


## 4. Key Lessons

### Indexes should match the query

The order of columns in a composite index matters. An index beginning with `patient_id` is useful for patient-based searches but is not ideally suited to filtering only by date.

### An index does not always improve performance

Queries 2 and 4 show that a table scan can be faster when many rows match the filter. Performance should be measured rather than assumed.


### Pre-calculated summaries can speed up reporting

Summary tables can reduce the work needed for frequently used reports. Their accuracy depends on having a reliable process for refreshing their values.

### Execution plans provide evidence

The `EXPLAIN ANALYZE` output helps identify the access method, number of rows processed and actual execution time. It is useful for explaining why a query may be slow and deciding what to test next.

## 5. Limitations

The tests have several limitations:

1. Execution times may change between runs and environments.
2. Some comparisons use different index conditions, which makes it difficult to attribute timing differences to one factor alone.
3. The dataset may not represent the workload of a large clinical laboratory.
4. A summary table requires maintenance to remain accurate.
5. Indexes consume storage and can increase the work needed for inserts, updates and deletes.

These limitations mean that the results should guide further testing rather than be treated as proof that one approach is always best.

## 6. Recommendations for LabTrack

1. Keep indexes that support important patient and order lookups.
2. Investigate the pending-order worklist, since the forced table scan was faster in the recorded test.
3. Compare subquery alternatives using equivalent conditions and access paths.
4. Test a date-leading index for reporting queries that filter only by `ordered_at`.
5. Use summary tables for frequent reports only when their refresh process is reliable.
6. Record execution plans and repeat measurements before making production database changes.

## 7. Conclusion

The LabTrack experiments show that query optimisation involves more than adding indexes. It requires understanding how MySQL retrieves the data, checking the execution plan and measuring the results.

The patient-history query benefited greatly from its composite index, while the pending-order and pending-test comparisons show that a table scan can sometimes be faster. The daily summary experiment also shows the potential benefit of pre-calculating frequently requested results.

Further tests using equivalent query versions and a larger, controlled dataset would provide stronger evidence for final index and reporting decisions.