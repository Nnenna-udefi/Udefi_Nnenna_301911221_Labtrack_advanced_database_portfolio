# Portfolio 3: Transaction and Concurrency Tests

**Project:** LabTrack Laboratory Information Management System (LIMS)  
**Database:** `labtrack_db`  
**DBMS:** MySQL 8.0.46  
**Storage Engine:** InnoDB

## 1. Introduction

This document describes the experiments carried out to understand how MySQL handles transactions and concurrent database operations in LabTrack.

The experiments examine how changes are saved or cancelled, how transactions read data while another transaction updates it, and how row locks prevent conflicting operations from running at the same time.

These behaviours are important in a laboratory information system because multiple staff members may access or update laboratory orders and results at the same time.

## 2. Test Environment

The experiments use MySQL with the InnoDB storage engine. Two separate database connections are used for the isolation and row-locking experiments.

| Item | Description |
|---|---|
| Database | `labtrack_db` |
| DBMS | MySQL 8.0.46 |
| Storage engine | InnoDB |
| SQL test file | `transaction.sql` |
| Documentation file | `concurrency-tests.md` |
| Sessions required | One session for basic transactions; two sessions for isolation and locking tests |

Before the experiments were run, the selected order and result records where confirmed to see if they exists and their original values were recorded so that changes can be checked and restored where necessary.

## 3. Experiment 1: COMMIT

### Objective

To demonstrate that transaction changes are saved when `COMMIT` is executed.

### Procedure

1. Read the current status of order id `4500`.
2. Start a transaction.
3. Change the order status to `IN_PROGRESS`.
4. Read the status again before committing.
5. Execute `COMMIT`.
6. Read the order status again.

### Result

Before the commit, the session sees the updated status within its transaction. After the commit, the change remains saved and is visible to other transactions that read the committed data.
**Actual Result:** The order status from `COMPLETED` to `IN_PROGRESS` and this change persisted.


### Interpretation

`COMMIT` makes the transaction's changes permanent. This is useful in LabTrack when an authorised workflow update must be saved reliably.


## 4. Experiment 2: ROLLBACK

### Objective

To demonstrate that uncommitted changes can be cancelled.

### Procedure

1. Read the current status of order `4500`.
2. Start a transaction.
3. Change the order status to `PENDING`.
4. Read the status before rollback.
5. Execute `ROLLBACK`.
6. Read the status again.

### Result

The session displayed `PENDING` before the rollback. After `ROLLBACK`, the status returned to the  value that was present when the transaction began.

### Interpretation

`ROLLBACK` cancels changes made in the current uncommitted transaction. This is useful when an incorrect order update must be cancelled before it is committed.



## 5. Experiment 3: Transaction Isolation with REPEATABLE READ

### Objective

To demonstrate how MySQL's `REPEATABLE READ` isolation level provides a consistent view of data during a transaction.

### Procedure

This experiment uses two separate database connections.

**Session A**

1. Set the transaction isolation level to `REPEATABLE READ`.
2. Start a transaction.
3. Read the interpretation of result `1`.
4. Keep the transaction open.

**Session B**

1. Start a transaction.
2. Update the interpretation of result `1` to `POSITIVE`.
3. Commit the transaction.

**Return to Session A**

1. Read the same result again before committing Session A.
2. Commit Session A.
3. Start a new transaction or perform a new read after the previous transaction has ended.

### Result

Session A's first read sees `NEGATIVE`:

- Session A's first read returns `NEGATIVE`.
- Session B updates the result to `POSITIVE` and commits.
- Session A's second consistent read still returns `NEGATIVE`, because its transaction continues to use the original consistent snapshot.
- After Session A commits, the new read returns `POSITIVE`.

### Interpretation

Under InnoDB's `REPEATABLE READ` isolation level, consistent reads within the same transaction generally continue to use the snapshot established by the first consistent read.

This prevents a transaction from seeing a different committed value on a later consistent read of the same row simply because another transaction committed an update in between.


## 6. Experiment 4: Concurrency and Row Locking

### Objective

To demonstrate how InnoDB handles two sessions attempting to update the same row.

### Procedure

This experiment uses two separate database connections.

**Session A**

1. Start a transaction.
2. Select order `5820` using `SELECT ... FOR UPDATE`.
3. Keep the transaction open.

**Session B**

1. Start a transaction.
2. Attempt to update order `5820` to `IN_PROGRESS`.
3. Observe whether the update waits while Session A holds the lock.

**Return to Session A**

1. Execute `COMMIT` to release the row lock.

**Return to Session B**

1. Allow the waiting update to complete.
2. Execute `COMMIT`.
3. Read the order status to verify the final value.

### Result

Session A successfully locks the row and keeps its transaction open, Session B's conflicting update waits for the lock to be released.

After Session A commits, Session B continues.

### Interpretation

InnoDB uses row-level locking to coordinate conflicting changes. This helps prevent simultaneous transactions from making incompatible updates to the same record.

In LabTrack, row locking can help coordinate concurrent changes to laboratory orders. Application-level permissions and workflow rules are still needed to ensure that only authorised staff can perform particular actions.


## 7. Summary of Experiments

| Experiment | Feature tested | Expected outcome |
|---|---|---|
| 1 | `COMMIT` | The updated order status remains saved. |
| 2 | `ROLLBACK` | The uncommitted order change is cancelled. |
| 3 | `REPEATABLE READ` | Session A sees its original snapshot until its transaction ends. |
| 4 | `Row locking` | Session B's conflicting update waits until Session A releases the lock. |


## 8. Conclusion

The experiments demonstrate important transaction and concurrency features provided by MySQL and InnoDB. `COMMIT` saves changes, `ROLLBACK` cancels uncommitted changes, `REPEATABLE READ` provides a consistent snapshot for reads, and row locks coordinate conflicting updates.

These features help protect data consistency when multiple users interact with the LabTrack database.