# MIT 8103 – Advanced Database Systems CA
## Final Portfolio Summary and Technical Reflection

**Name:** Nnenna Miriam Udefi  
**Email:** n.udefi1221@miva.edu.ng  
**Project:** LabTrack – Simulated Clinical Laboratory Information Management System (LIMS)  
**Selected Organisation:** LabTrack – Simulated Clinical Laboratory  
**Database Technologies:** MySQL 8.0, MongoDB Atlas  
**GitHub Repository:** https://github.com/Nnenna-udefi/labtrack-advanced-database-portfolio.git  
**Nature of the Database:** Patients, staff, lab orders, order tests, lab tests, specimens, test results, audit logs  
**Possible Database Operations:** Register patients, log test requests, track specimen collection/status, record and validate test results, generate clinical diagnostic transcripts  

---

## Project Overview

For this project, I designed and developed LabTrack, a simulated Laboratory Information Management System (LIMS), to demonstrate how database technologies can support the operations of a clinical diagnostic laboratory.

I selected this case study because laboratory operations involve several connected processes, including patient registration, laboratory requests, specimen tracking, test processing and result verification. These processes depend on accurate records, reliable relationships between data and appropriate access to information.

The project was developed progressively across five portfolios. I started with relational database design and gradually explored query optimization, transaction management, NoSQL databases and distributed database architecture.

---

## Summary

### Portfolio 1: Database Design and Modelling
I started by identifying the functional requirements of LabTrack and the information needed to support its laboratory workflow. Then designed a relational database consisting of seven core tables: staff, patients, lab_tests, lab_orders, specimens, order_tests and test_results.

Primary keys, foreign keys, unique constraints and appropriate data types were used to establish relationships and protect data integrity. I also applied normalisation principles, particularly by separating laboratory test information from individual test orders through the lab_tests and order_tests tables. The design was structured towards Third Normal Form (3NF), reducing unnecessary duplication while maintaining the relationships required by the system.

### Portfolio 2: Query Processing and Optimisation
After implementing the database, I studied how MySQL retrieves and processes information.

Test queries covering patient order history, pending laboratory worklists, joins, subqueries and daily reporting were created and EXPLAIN ANALYZE was used to examine execution plans and understand how indexes influenced query execution.

One important finding was that indexes do not automatically make every query faster or more cost-effective. The patient-history query benefited significantly from a composite index, while some pending worklist queries performed slightly better with a table scan.

From this portfolio, I understood that query optimisation involves examining the actual execution plan and measuring performance in order to select the most efficient means of executing a database query.

### Portfolio 3: Transactions and Concurrency
This portfolio focused on how MySQL's InnoDB engine handles simultaneous database operations. Four experiments were conducted covering COMMIT, ROLLBACK, transaction isolation using REPEATABLE READ and row-level locking with SELECT ... FOR UPDATE.

The experiments demonstrated how committed changes remain saved, how uncommitted changes can be cancelled, and how one transaction can maintain a consistent view of data while another transaction updates it. Two separate database connections were used to demonstrate how a conflicting update waits while another session holds a row lock.

These concepts are particularly relevant to LabTrack because multiple laboratory staff may access or update the same orders and results at the same time. Transaction management and concurrency controls help prevent conflicting changes and protect the integrity of laboratory records.

### Portfolio 4: NoSQL and Advanced Data Models
MongoDB Atlas was used to explore how a document-oriented database could complement the relational design. 

A specimen_history collection was created containing specimen information and an embedded history array. This ensured that each specimen and its associated processing events to be stored together. I implemented specimen filtering, document updates, aggregation pipelines and indexing. MongoDB's explain("executionStats") was used to examine how a specimen identifier index was used during retrieval.

This implementation showed that relational and document databases serve different purposes. MySQL remained appropriate for structured records and relationships, while MongoDB provided a flexible approach to storing specimen workflow history.

### Portfolio 5: Distributed and Cloud Databases
The final portfolio explored how LabTrack could support increased workloads and future expansion through distributed database architecture.

A proposed primary–replica architecture was designed and implemented through MySQL asynchronous replication which was deployed locally using two independent MySQL Server instances. The instances ran on the same Windows computer but had separate data directories, configuration files, Windows services, ports and server IDs.

The initial database was synchronised using mysqldump, configured replication and changes made on the primary were verified to automatically reflect on the replica.

Branch-based sharding, replication lag, availability, failover, consistency and possible cloud deployment using Amazon RDS for MySQL was discussed in the architecture document.

The replication exercise was implemented and tested locally, while sharding and cloud deployment remained proposed future strategies.

---

## Screenshots and Implementation Evidence

The GitHub repository contains the SQL scripts, database documentation, implementation files and supporting evidence for the five portfolios.

Some of the screenshots include:
* MySQL database schema and table relationships.
* Query execution plans and performance comparisons.
* Transaction and rollback results.
* Two-session isolation and row-locking demonstrations.
* MongoDB Atlas collection, aggregation and query execution evidence.
* Primary and replica MySQL server configurations.
* Successful replication status and matching records on both instances.

The screenshots are organised within the relevant portfolio evidence folders to support the documented implementation and test results.

---

## Individual Reflection

Through this hands on project, I have come to gain more practical understanding of database systems. At first, I had little experience working with SQL and database design, I understood basic queries but other technical concepts like functional dependencies, composite indexes, transaction isolation, query execution plans and replication were not so clear to me.

One of the things I learnt was that a technically valid solution is not always necessarily the most efficient one. For example, Indexes are known to improve query performance across the database but however from my experiments, it shows that a table scan could sometimes perform better depending on factors like, the number of matching records and the execution plan chosen by MySQL.

Through the transaction and concurrency experiments, I learnt the importance of protecting and handling data when multiple users work on the same system. In a clinical laboratory environment, and incorrect or conflicting update can affect the reliability of the information available to other staff and the patient.

The replication exercise took me beyond describing distributed databases to configuring independent MySQL services. Through troubleshooting, configuration, database synchronization and verifying of replicated records, I now have a practical understanding of how replication works and the relationship between the primary & replication servers and binary logs. Also, I learnt that replication doesn’t replace the need for backups because it replicates everything done on the primary server including deletion and corrupt data entry which makes it to be not and ideal method for data retrieval in case of server failure.

Overall, from this project I have learnt how to approach database problems systematically through design, implement, test, examining results and document limitations and I also have a better understanding of practical application of advanced database design.

---

## References

1. **MySQL.** MySQL 8.0 Reference Manual. https://dev.mysql.com/doc/refman/8.0/en/
2. **MongoDB.** MongoDB Manual. https://www.mongodb.com/docs/manual/
3. **MongoDB.** MongoDB Atlas Documentation. https://www.mongodb.com/docs/atlas/
4. **Miva Open University.** MIT 8103 – Advanced Database Systems: Course Materials and Lecture Notes.

---

## AI Use Declaration

ChatGPT was used as a learning and development support tool throughout this project. It assisted me in understanding database concepts, exploring alternative approaches, troubleshooting SQL and database configuration issues, reviewing documentation and improving the organisation of my technical reports. The database design decisions, commands, implementation activities, testing and verification were reviewed and carried out as part of my project work. 

I examined the execution outputs and implementation results before documenting them. AI assistance was used to support my learning and documentation, not as a substitute for understanding the database concepts or validating the work.
