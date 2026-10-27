# LabTrack Database Normalisation

## First Normal Form (1NF)

Each table has a primary key and unique rows, and each column stores a single value with no repeated lists.

For example, a laboratory order should not store several test names in one field e.g `test_names = 'HBV DNA, HCV RNA, HIV RNA'`. Each requested test is instead represented by a separate row in `order_tests` table.

## Second Normal Form (2NF)

A table must first satisfy 1NF, and each non-key attribute must depend on the whole candidate key rather than only a part of it.

LabTrack uses surrogate primary keys for its main entities. The `order_tests` table also has a unique constraint on `(order_id, test_id)`, preventing the same test request from being added twice to one order.
E.g If a patient requests for FBC & MP tests and they have both being added, adding FBC again will not be allowed on the same order. Except a new order is created for the patient and another FBC request is added. This constraint prevents duplicate tests within the same order.

Test-specific attributes, such as the test name and test_code are stored in `lab_tests` table rather than being repeated in every order-test record.

## Third Normal Form (3NF)

A table must satisfy 2NF and avoid inappropriate transitive dependencies among non-key attributes.

For example, In LabTrack, patient attributes like names and dates of birth belong in `patients`, while laboratory tests catalogue attributes belong in `lab-tests`. Laboratory orders reference these entities through their foreign keys rather than duplicating their descriptive information.
e.g 
'''
patient_id → first_name, last_name, date_of_birth

test_id → test_code, test_name, specimen_type
''' 
These dependencies support keeping the patient and test catalogue information in their respective tables.

## Design Decisions and Limitations

- Surrogate integer keys simplify relationships.
- Unique business identifiers support traceability.
- Foreign keys protect referential integrity.
- Status and date constraints prevent some invalid records.
- The result model supports one result record per ordered test.
- The design will be reviewed against representative queries and the assessment requirements before being finalised.

### Validation Approach
Normalisation claims will be validated against the functional dependencies and candidate keys of the actual schema. 

- Identifying candidate keys and functional dependencies.
- Checking for repeating groups and non-atomic attributes.
- Evaluating partial dependencies for 2NF.
- Evaluating transitive dependencies and other 3NF violations.

Testing primary keys, unique constraints, foreign keys, and check constraints in MySql 8.0.

Reviewing the design against representative laboratory queries and documented business rules.
