# LabTrack: Database Design Requirements

## 1. Project Overview

LabTrack is a simulated Laboratory Information Management System (LIMS) for a clinical diagnostic laboratory. It manages patient records, laboratory test orders, test catalogues, specimens, and laboratory results.

The project focuses on designing a relational database that supports data integrity, traceability, efficient retrieval, and reliable laboratory workflows.

All data used for development and testing will be synthetic.

## 2. Business Objectives

The database should:

1. Maintain unique records for patients and ordering clinicians.
2. Record laboratory orders requested for patients.
3. Maintain a catalogue of available laboratory tests.
4. Support orders containing multiple tests.
5. Track specimens received for laboratory orders.
6. Associate each ordered test with its relevant specimen.
7. Store test results and their verification details.
8. Prevent invalid references and duplicate patient identifiers.
9. Support queries for patient history, pending tests, specimen tracking, and reported results.

## 3. Scope

### In scope
- Patient registration
- Clinician registration
- Laboratory order management
- Laboratory test catalogue management
- Specimen registration and tracking
- Test result recording and verification
- Referential integrity and data validation

### Out of scope for the initial version
- Billing and payment processing
- Instrument connectivity
- Electronic health record integration
- User authentication and access-control implementation
- Automated result transmission to external healthcare systems

## 4. Business Rules

1. Each patient must have a unique patient identifier.
2. A patient may have zero or many laboratory orders.
3. Each laboratory order belongs to exactly one patient.
4. Each laboratory order must be associated with one ordering clinician.
5. Each order must contain at least one ordered test.
6. A laboratory test may appear in many orders.
7. An order may contain multiple tests; therefore, orders and tests have a many-to-many relationship resolved through an order-test junction table.
8. Each specimen belongs to one laboratory order.
9. A specimen may support multiple ordered tests.
10. Each ordered test may be associated with at most one result in the initial design.
11. A result may be recorded before verification, but it must not be treated as verified until the verification requirements are satisfied.
12. Every verified result must record the verifying clinician and verification timestamp.
13. Foreign keys must prevent references to nonexistent patients, orders, tests, specimens, or clinicians.
14. Patient identifiers, order identifiers, specimen identifiers, and test identifiers must be unique.
15. Dates, statuses, and required fields must be validated according to their intended use.
16. Records must not be silently deleted when doing so would break laboratory traceability.

## 5. Assumptions

- LabTrack represents one simulated laboratory.
- Each order is placed by one clinician.
- The first version supports one recorded result per ordered test.
- Each ordered test is linked to one specimen.
- The initial system uses MySQL 8.0 or another compatible version specified by the assessment.
- Sample patients and clinicians are fictional.

## 6. Quality Requirements

The design should aim for:
- First, second, and third normal form where appropriate.
- Primary and foreign key integrity.
- Appropriate NOT NULL, UNIQUE, CHECK, and other constraints.
- Indexes that support common queries.
- Clear documentation of design decisions and limitations.
- Reproducible SQL tests and documented evidence.
