# Portfolio 4: NoSQL Implementation — LabTrack LIMS

## 1. Introduction

This portfolio demonstrates the implementation of a document-oriented NoSQL database for LabTrack, a simulated Laboratory Information Management System (LIMS). MongoDB Atlas was used to host the cloud database, and MongoDB Shell (mongosh) is
used to run queries, updates, aggregation pipelines, indexing commands
and database checks.

The implementation focuses on specimen tracking and the storage of
specimen workflow history. It demonstrates how a document database can complement a relational database when an application needs to retain a sequence of events associated with an individual specimen.

### Technology stack

- **Database:** MongoDB
- **Cloud environment:** MongoDB Atlas
- **Database interface:** MongoDB Shell (`mongosh`)
- **Database name:** `labtrack_nosql`
- **Collection:** `specimen_history`
- **Data format:** JSON-compatible MongoDB documents

## 2. NoSQL Data Model

The `specimen_history` collection stores specimen records as individual documents i.e one document per specimen. Each document contains identifying information, the specimen type, its current processing status, the receipt timestamp and a nested `history` array.

Each history entry records an event, timestamp, staff and a note.

The document model was selected because specimen events naturally belong to a specimen and are retrieved together. Instead of storing each event in a separate relational table and joining it to the specimen, MongoDB can return the specimen and its embedded history in a single document retrieval.

### Main document fields

| Field | Purpose |
|---|---|
| `specimen_id` | Unique business identifier used to locate a specimen |
| `order_id` | Links the specimen to its associated laboratory order |
| `specimen_type` | Identifies the type of specimen received |
| `status` | Stores the specimen's current processing state |
| `received_at` | Records when the specimen was received, or `null` if not yet received |
| `history` | Array of events documenting the specimen's processing history |

The history array supports events such as `REGISTERED`, `RECEIVED`, `IN_ANALYSIS`, `COMPLETED` and `REJECTED`.

## 3. Application to LIMS Functions

MongoDB supports several specimen-management functions in the LabTrack workflow.

### 3.1 Specimen registration

When a registration officer registers a specimen, the application creates a document containing the specimen identifier, order reference, specimen type, initial status and a `REGISTERED` history event.

The document structure keeps the specimen's identity and initial event together.

### 3.2 Specimen receipt and tracking

After registeration, when a specimen arrives at the laboratory, the application can update its current status to `RECEIVED` and append a receipt event to the history array.

The history can help laboratory staff establish when the specimen was received and review its recorded progression. Specimens that have not yet been received can be identified through their status and a `received_at` value of `null`.

### 3.3 Work-in-progress monitoring

Filtering by status allows laboratory personnel to retrieve specimens currently in analysis or awaiting processing.

For example:

```javascript
db.specimen_history.find({
  status: "IN_ANALYSIS"
})
```

This query could be used as a worklist for laboratory scientists. The same approach can retrieve rejected specimens, received specimens or specimens of a particular type.

In a production LIMS, these worklists should also apply appropriate staff permissions, laboratory location filters and operational rules.

### 3.4 Specimen rejection and quality management

A rejected specimen can have its current status as `REJECTED` and a history event that records the rejection reason. 

For example, a rejection note might record an unsuitable collection container. This information can support specimen-quality reviews, rejection-rate monitoring and communication with the requesting facility.

### 3.5 Analysis completion and result workflow

When testing is completed, the application changes the specimen's status and append a `COMPLETED` event. 

However, specimen completion must not automatically mean that a laboratory result is authorised for release. LabTrack's relational workflow separately distinguishes result entry, validation and pathologist verification. MongoDB specimen tracking complements that workflow rather than bypass its authorisation controls.

## 4. Filtering and Aggregation

### 4.1 Filtering by current status

The collection was queried using filters for specimens in analysis, received specimens and rejected specimens. These queries demonstrate retrieval based on the current status field.

Example:

```javascript
db.specimen_history.find({
  status: "REJECTED"
})
```

### 4.2 Filtering by specimen type

The collection was also queried for serum specimens:

```javascript
db.specimen_history.find({
  specimen_type: "SERUM"
})
```

These filters demonstrate how a LIMS can retrieve targeted specimen worklists without returning every document in the collection.

### 4.3 Aggregating specimens by status

An aggregation pipeline groups documents by their current status and counts the documents in each group.

```javascript
db.specimen_history.aggregate([
  {
    $group: {
      _id: "$status",
      specimen_count: { $sum: 1 }
    }
  }
])
```

The `$group` stage creates one output group for each distinct status. The `_id` field in the output represents the grouping key, while `$sum: 1` increments the count for every document in the group.

This aggregation could support operational dashboards showing the distribution of specimens across processing states. The output should be interpreted as a count of specimens in each current status, not as a count of individual history events.

### 4.4 Aggregating recorded events by staff member

```javascript
db.specimen_history.aggregate([
  { $unwind: "$history" },
  {
    $group: {
      _id: "$history.performed_by",
      total_events_handled: { $sum: 1 },
      event_types: { $addToSet: "$history.event" }
    }
  },
  { $sort: { total_events_handled: -1 } }
])
```

This pipeline counts the recorded history events associated with each
staff identifier and lists the distinct event types. The result should
be described as event counts, not a definitive measure of staff
productivity: it does not account for task complexity, time spent,
workload differences or the quality of work.

## 5. Updating Specimen History

MongoDB's `updateOne()` method was used to demonstrate updating the current status and appending a new event to a specimen's history.

The operation used `$set` to change the current status and `$push` to append a `COMPLETED` event to the existing history array.

```javascript
db.specimen_history.updateOne(
  { specimen_id: "SPCG000451" },
  {
    $set: { status: "COMPLETED" },
    $push: {
      history: {
        event: "COMPLETED",
        timestamp: ISODate("2026-06-01T10:00:00Z"),
        performed_by: "STF003",
        notes: "Analysis completed"
      }
    }
  }
)
```

MongoDB returned a matched document count of one and a modified document count of one when the update was executed successfully.

The operation illustrates how a current state and its associated history can be updated together. The history array also provides a sequence of recorded specimen events.


## 6. Indexing and Query Execution Analysis

An ascending index was created on `specimen_id`:

```javascript
db.specimen_history.createIndex({
  specimen_id: 1
})
```

This index is intended to support lookups by specimen identifier, such as retrieving a specimen when a staff member enters its laboratory number.



```javascript
db.specimen_history.createIndex({
  "history.performed_by": 1
})
```

The history.performed_by index is a multikey index because it
  indexes values from objects within the history array. It can
  support suitable queries on staff identifiers in the embedded
  history.

Indexes can be inspected using:

```javascript
db.specimen_history.getIndexes()
```
Query-plan analysis performed with:

```javascript
db.specimen_history
  .find({ specimen_id: "SPCG000665" })
  .explain("executionStats")
```
The execution plan used the `specimen_id_1` index, with an `IXSCAN` stage followed by a `FETCH` stage. The `IXSCAN` stage examined one index key and identified one matching record. The subsequent `FETCH` stage retrieved the corresponding document from the collection. The execution statistics reported one document returned, one index key examined, one document examined, and an execution time of 3 ms.

These results demonstrate that MongoDB selected the specimen ID index and successfully retrieved the matching document in this execution. However, the recorded execution time alone does not establish a measurable performance improvement over an unindexed query. Since the dataset is small, performance conclusions is not advised.
The execution statistics help establish whether MongoDB uses the index and how many keys and documents are examined. Since the demonstration dataset is small, the existence of an index alone is not sufficient evidence of a measurable performance improvement.

## 7. Data Quality and Validation

A reliable specimen-tracking database should maintain consistent identifiers, valid status values and consistent event records.
Data-quality checks for this implementation include:

- Ensuring each specimen has a valid `specimen_id`.
- Restricting status values to the defined workflow states.
- Confirming that required fields are present.
- Checking that timestamps are BSON Date and are in chronological order.
- Ensuring the current status is consistent with the latest relevant history event.
- Preventing unintended duplicate specimen identifiers and duplicate event appends.

A JSON Schema validator enforces document structure and permitted
values.

8. MySQL and MongoDB: Why Both Models Are Used
LabTrack uses the two database models for different needs. MySQL remains
appropriate for structured, related records and workflows that require
relational constraints. MongoDB is used here to demonstrate a flexible
document model for specimen metadata and embedded event history.

| Consideration | MySQL (Relational) | MongoDB (Document-Oriented NoSQL) |
| --- | --- | --- |
| **Data Organisation** | Tables with rows and defined columns | Collections containing flexible documents |
| **Relationships** | Foreign keys and joins can enforce and query relationships | References can be stored in documents, but cross-database relationships are not automatically enforced as SQL foreign keys |
| **Specimen History** | Could be modelled in a separate event table linked to a specimen | Can embed a specimen's events in a history array |
| **Schema** | Defined table schema and data types | Flexible document structure, with optional schema validation |
| **Best Fit in LabTrack Design** | Orders, staff roles, test records, and result verification where relationships and constraints matter | Specimen tracking documents and event history that are often read together |
| **Important Consideration** | Relational constraints and transactions help maintain consistency across related records | Embedded updates can be convenient, but the application must still enforce workflow rules and avoid duplicate events |
The database choice depends on access patterns, consistency requirements, relationships and operational needs.


## 8. Evidence Collected

Screenshots should be included for the following operations, where available:

1. Specimen documents in the Atlas collection.
2. Filtering by `IN_ANALYSIS`, `SERUM`, `REJECTED` and `RECEIVED`.
3. The aggregation pipeline and its output.
4. The specimen document before and after the history update.
5. The successful update result.
6. The created index and index listing.
7. Query execution statistics showing index usage, if captured.
8. Schema validation rules and a validation test, if implemented.

The evidence should distinguish between operations performed in the Atlas interface and operations performed through `mongosh`. Both interfaces access the same cloud database when connected to the same Atlas cluster and database.


## 10. Conclusion

The portfolio demonstrates how MongoDB's document model can support specimen tracking through embedded history, filtering, aggregation, document updates and indexing.

The approach is particularly useful when a specimen and its associated processing events need to be retrieved together. In the wider LabTrack design, MongoDB can complement the relational database by supporting flexible specimen-history records, while structured orders, user roles and result-verification rules remain governed by the appropriate relational and application-level controls.


