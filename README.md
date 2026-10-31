# LabTrack — Advanced Database Systems Portfolio

**Course:** MIT 8103 — Advanced Database Systems  
**Programme:** Master of Information Technology  
**Institution:** Miva Open University  
**Academic Session:** 2026/2027  
**Project Type:** Individual Practical Database Portfolio  
**Primary Database:** MySQL  
**NoSQL Database:** MongoDB  

---

## 1. Project Overview

LabTrack is a simulated Laboratory Information Management System (LIMS) developed as a practical project for the MIT 8103 Advanced Database Systems course.

The project models essential diagnostic laboratory workflows, including patient registration, laboratory test requests, specimen tracking, result entry, validation, authorisation, and release.

LabTrack uses a **polyglot persistence approach** for academic demonstration: MySQL manages the core relational records, while MongoDB is used to explore document-oriented storage for specimen processing history.

The project applies advanced database concepts, including relational modelling, normalisation, query optimisation, transaction management, concurrency control, NoSQL data modelling, and distributed database architecture.

All records used in the project are synthetic. LabTrack is an academic prototype, not a production clinical system.

## 2. Problem Statement

Diagnostic laboratories manage interconnected data involving patients, laboratory orders, requested tests, specimens, and test results. Inadequate database design can cause duplicate requests, inconsistent relationships, inefficient queries, and difficulties maintaining reliable records.

LabTrack addresses these challenges through relational constraints, structured queries, transaction testing, and appropriate database modelling. It also explores whether a document-oriented database can represent evolving specimen processing histories without forcing every event into a fixed relational structure.

## 3. Project Objectives

The project aims to:

- Design and implement a relational database using MySQL.
- Model laboratory entities, relationships, and business rules using an ER diagram.
- Apply normalisation and enforce data integrity.
- Develop and optimise SQL queries using execution plans and indexing.
- Demonstrate transaction management and concurrency control.
- Implement a MongoDB document model for specimen processing history.
- Compare relational and document-oriented data models.
- Evaluate distributed and cloud database architectures for a multi-branch laboratory.
- Document practical evidence, testing results, design decisions, and technical lessons learned.

## 4. Scope and Business Requirements

The system covers the following core relational entities:

| Entity | Purpose |
|---|---|
| `staff` | Stores staff identifiers, roles, and active status. |
| `patients` | Stores patient identifiers and registration information. |
| `lab_tests` | Maintains the laboratory test catalogue. |
| `lab_orders` | Records laboratory requests for patients. |
| `specimens` | Tracks specimens associated with laboratory orders. |
| `order_tests` | Connects laboratory orders to requested tests. |
| `test_results` | Stores results and their validation, authorisation, and release details. |

### Key business rules

1. Every patient must have a unique patient number.
2. Every laboratory order must have a unique order number.
3. Every laboratory test must have a unique test code.
4. A particular test may appear only once within the same laboratory order.
5. A patient may request the same test again in a separate order.
6. Each order must reference an existing patient and requesting clinician.
7. Each ordered test must reference an existing laboratory test.
8. Each result must reference an existing ordered test.
9. Specimen relationships and result workflow timestamps must satisfy defined integrity rules.
10. Result validation, authorisation, and release must follow the appropriate workflow requirements.

The duplicate-test rule is enforced by a unique constraint on `(order_id, test_id)` in the MySQL `order_tests` table.

## 5. Technology Stack

| Technology | Purpose |
|---|---|
| MySQL | Primary relational database for operational records. |
| MongoDB | Document-oriented storage for specimen processing history. |
| SQL | Schema creation, data manipulation, querying, and transaction testing. |
| MongoDB Query Language (MQL) | Document insertion, retrieval, filtering, and updates. |
| JSON | Representation of specimen processing events. |
| Git and GitHub | Version control and portfolio submission. |
| Mermaid | Relational schema visualisation. |
| MySQL `EXPLAIN` | Query execution plan analysis. |

## 6. Database Architecture

LabTrack separates its data responsibilities between the two database models.

### MySQL: Core operational records

MySQL is the system's primary relational database. It stores the entities and relationships that require structured schemas, referential integrity, and relational querying.

Its responsibilities include:

- Patient and staff records.
- Laboratory orders and requested tests.
- Specimen identifiers and order relationships.
- Test results and workflow statuses.
- Referential integrity and uniqueness enforcement.
- Transactions and query performance analysis.

### MongoDB: Specimen processing history

MongoDB is used to demonstrate document-oriented modelling for the sequence of events associated with a specimen.

A processing history may include:

- Specimen collection and receipt.
- Processing milestones and timestamps.
- Rejection or exception events.
- Processing methods and batch references.
- Additional event-specific metadata.

These events can be represented as nested documents within a specimen history document, allowing different event types to carry different fields where appropriate.

MongoDB is an additional NoSQL exercise; the core laboratory entities remain in MySQL. The initial implementation does not assume automatic synchronisation between the two databases. Any proposed integration or synchronisation mechanism will be documented separately.

### Illustrative architecture

```text
                 LabTrack
                    |
          +---------+---------+
          |                   |
          v                   v
       MySQL                MongoDB
   Core relational      Specimen processing
       records              history
          |                   |
          v                   v
   Orders, patients,      Nested events,
   tests and results     timestamps, metadata
```

This represents the intended logical design, not a claim that a complete application or live database integration has already been implemented.

## 7. Relational Database Design

The relational database is named `labtrack_db`.

The schema uses surrogate primary keys, unique business identifiers, foreign keys, controlled status values, and indexes.

Initial indexes include:

- `idx_orders_patient_date` on `(patient_id, ordered_at)`.
- `idx_orders_status_date` on `(status, ordered_at)`.
- `idx_specimens_order` on `specimens(order_id)`.
- `idx_order_tests_status` on `order_tests(status)`.

These indexes will be assessed against representative queries and execution plans.

### Normalisation

The design aims for Third Normal Form (3NF), subject to verification of candidate keys and functional dependencies.

- **1NF:** Attributes contain individual values rather than lists of repeating values.
- **2NF:** Non-key attributes depend on the whole of each relevant candidate key.
- **3NF:** Non-key attributes do not depend transitively on candidate keys.


## 8. MongoDB Data Model

The MongoDB component uses a collection such as `specimen_history`.

A document contains a specimen identifier, its related laboratory order number, and an array of processing events.

Example:

```json
{
    "specimen_id": "SPCG000451",
    "order_id": 451,
    "specimen_type": "SERUM",
    "status": "IN_ANALYSIS",
    "received_at": {
      "$date":"2026-06-01T08:15:00Z"
    },
    "history": [
      {
        "event": "REGISTERED",
        "timestamp": {"$date": "2026-06-01T08:00:00Z"},
        "performed_by": "STF001",
        "notes": "Specimen registered"
      },
      {
        "event": "RECEIVED",
        "timestamp": {"$date":"2026-06-01T08:15:00Z"},
        "performed_by": "STF002",
        "notes": "Specimen received in the laboratory"
      },
      {
        "event": "IN_ANALYSIS",
        "timestamp": {"$date":"2026-06-01T08:45:00Z"},
        "performed_by": "STF003",
        "notes": "Testing commenced"
      }
    ]
}
```

### MongoDB exercises

- Create a database and collection.
- Insert specimen history documents.
- Query documents by specimen and order identifiers.
- Filter documents based on processing events.
- Update a document to add a new processing event.
- Demonstrate retrieval of nested event information.
- Compare the document model with the corresponding relational design.

### Relational and NoSQL comparison

| Consideration | MySQL | MongoDB |
|---|---|---|
| Data model | Tables and relationships | Documents and collections |
| Schema | Structured relational schema | Flexible document structure |
| Relationships | Foreign keys and joins | Embedded documents or references |
| Integrity | Relational constraints and transactions | Document validation and supported transaction mechanisms |
| Example use in LabTrack | Orders, tests, patients, and results | Specimen processing history |
| Main learning objective | Relational integrity and query optimisation | Document modelling and flexible event representation |

The comparison is based on implemented exercises and documented observations rather than assumptions that one database is universally better than the other.

## 9. Portfolio Structure

### Portfolio 1 — Database Design and Modelling

- Define system requirements and business rules.
- Develop the ER diagram.
- Implement the MySQL schema.
- Create synthetic seed data.
- Document normalisation and constraints.

### Portfolio 2 — Query Processing and Optimisation

- Develop queries for common laboratory operations.
- Apply joins, filtering, aggregation, and subqueries.
- Inspect execution plans using `EXPLAIN`.
- Evaluate indexes and query alternatives.
- Document performance observations.

### Portfolio 3 — Transactions and Concurrency

- Demonstrate transaction boundaries, commit, and rollback.
- Test consistency constraints.
- Explore concurrent updates and transaction isolation.
- Document observed conflicts and corrective controls.

### Portfolio 4 — NoSQL and Advanced Data Models

- Implement the specimen processing history model in MongoDB.
- Insert and query nested documents.
- Demonstrate updates to processing events.
- Compare MongoDB's document model with MySQL's relational model.
- Discuss data ownership, consistency, and the implications of maintaining related records in two databases.

### Portfolio 5 — Distributed and Cloud Database Exercise

- Propose an architecture for a multi-branch diagnostic laboratory.
- Discuss replication, availability, consistency, and data distribution.
- Evaluate network latency and connectivity failures.
- Consider backup, disaster recovery, and cloud or hybrid deployment.
- Explain how the relational and NoSQL components could be deployed and managed if the architecture were extended.


## 10. Repository Structure

The repository is planned to follow this structure:

```text
labtrack-advanced-database-portfolio/
├── README.md
├── portfolio-1-database-design/
│   ├── requirements.md
│   ├── er-diagram.png
│   ├── schema.sql
│   ├── seed-data.sql
│   └── normalisation.md
├── portfolio-2-query-optimisation/
│   ├── expand-seed-data.sql
│   ├── queries.sql
│   ├── query-plans.md
│   └── performance-analysis.md
├── portfolio-3-transactions-concurrency/
│   ├── transactions.sql
│   ├── concurrency-tests.md
│   └── evidence/
├── portfolio-4-nosql/
│   ├── specimen-history.json
│   ├── schema-validation.js
│   ├── nosql-queries.js
│   ├── implementation.md
│   └── evidence/
├── portfolio-5-distributed-cloud/
│   ├── architecture.md
│   ├── replication.md
│   └── evidence/
└── final-summary.md
```

Files will be added as each exercise is implemented. The structure may be adjusted to reflect the final work.

## 11. Setup and Installation

### Prerequisites

- MySQL Server and a MySQL client.
- MongoDB Atlas.
- MongoDB Shell (`mongosh`).
- Git.

### Step 1: Clone the repository

```bash
git clone <https://github.com/Nnenna-udefi/Udefi_Nnenna_301911221_Labtrack_advanced_database_portfolio.git>
cd labtrack-advanced-database-portfolio
```

### Step 2: Check the MySQL version

Run in your MySQL client:

```sql
SELECT VERSION();
```

### Step 3: Create the relational database

Run the schema script from the MySQL client:

```sql
SOURCE /portfolio-1-database-design/schema.sql;
```


Verify the tables:

```sql
USE labtrack_db;
SHOW TABLES;
```

### Step 4: Connect to MongoDB

After installing MongoDB or configuring an accessible deployment, connect with `mongosh` using the connection method appropriate to your environment.

For a local MongoDB server, the command is typically:

```bash
mongosh
```

Create or switch to the project database:

```javascript
use labtrack_nosql
```

MongoDB creates the database when data is first written to it.

### Step 5: Insert a specimen history document

The following example creates a collection and inserts synthetic data:

```javascript
db.specimen_processing_history.insertOne({
  specimen_id_: "SPCG001001",
  order_id_: "1001",
  status: 'RECEIVED',

  history: [
     {
        "event": "REGISTERED",
        "timestamp": {"$date": "2026-06-01T08:00:00Z"},
        "performed_by": "STF001",
        "notes": "Specimen registered"
      },
      {
        "event": "RECEIVED",
        "timestamp": {"$date":"2026-06-01T08:15:00Z"},
        "performed_by": "STF002",
        "notes": "Specimen received in the laboratory"
      },
  ]
})
```

### Step 6: Query specimen history

```javascript
db.specimen_processing_history.findOne({
  specimen_id: "SPCG000451"
})
```

This example demonstrates a basic write and read operation. Further queries, update tests, and screenshots will be documented in Portfolio 4.

**Note:** MySQL and MongoDB are separate databases in this project. The example does not synchronise records between them.

## 12. Testing and Evidence

The portfolio will include reproducible tests and evidence for both database systems.

### MySQL tests

- Successful insertion of valid records.
- Rejection of duplicate business identifiers.
- Rejection of duplicate tests within one order.
- Enforcement of foreign-key relationships.
- Validation of status and timestamp constraints.
- Transaction rollback and concurrency behaviour.
- Query execution plan and indexing comparisons.

### MongoDB tests

- Successful insertion and retrieval of specimen history documents.
- Queries by specimen and order identifiers.
- Retrieval or filtering of processing events.
- Updating a document to add a processing event.
- Validation of the document structure where applicable.
- Comparison of document-based and relational retrieval.

Screenshots, outputs, query scripts, and notes will be saved in the corresponding portfolio folders.

## 13. Data Protection and Limitations

LabTrack uses synthetic data and must not contain real patient identifiers, clinical results, credentials, or confidential organisational information.

The project is an academic prototype. A clinical deployment would require additional security and governance measures, including access control, authentication, comprehensive audit trails, backup and recovery, monitoring, and compliance with applicable data protection and healthcare requirements.

Using two database systems introduces additional operational complexity. A production implementation would need a clearly defined source of truth, ownership of each data type, and a tested strategy for synchronisation and recovery if records were shared across systems. These concerns are design considerations, not functionality assumed to exist in the current prototype.

## 14. Version Control

Git will be used to track progress through meaningful commits, 
The commit history reflects project development.

## 15. Academic Integrity and AI Use

AI tools were used to support brainstorming, explanation, debugging, and documentation. This has been declared in the final submission in accordance with the course requirements.

The author was responsible for reviewing and understanding the implementation, validating the SQL and MongoDB operations, and ensuring that the final portfolio accurately represents the work completed.

## 16. Conclusion

LabTrack provides a practical setting for applying advanced database concepts to laboratory information management. MySQL supports the structured operational records and relational integrity requirements, while MongoDB provides an opportunity to explore flexible document modelling for specimen processing history.

Together, the two implementations support a comparative study of relational and NoSQL databases, alongside query optimisation, transactions, concurrency, and distributed database design.

---

**Author:** [Nnenna Udefi]  
**GitHub Repository:** [(https://github.com/Nnenna-udefi/Udefi_Nnenna_301911221_Labtrack_advanced_database_portfolio.git)]  
