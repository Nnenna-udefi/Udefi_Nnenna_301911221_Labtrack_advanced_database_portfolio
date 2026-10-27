# LabTrack Database Normalisation

## First Normal Form (1NF)

Each table has a primary key, and each column stores a single value rather than a repeating list.

For example, a laboratory order must not store several test names in a field such as `test_names = 'HBV DNA, HCV RNA, HIV RNA'`. Each requested test is instead represented by a separate row in `order_tests`.

## Second Normal Form (2NF)

A table must first satisfy 1NF, and each non-key attribute must depend on the whole candidate key rather than only a part of it.

LabTrack uses surrogate primary keys for its main entities. The `order_tests` table also has a uniqueness constraint on `(order_id, test_id)`, preventing the same test request from being added twice to one order.

Test-specific attributes, such as the test name and specimen type defined by the catalogue, belong in `lab_tests` rather than being repeated in every order-test record.

## Third Normal Form (3NF)

A table must satisfy 2NF and avoid inappropriate transitive dependencies among non-key attributes.

For example, patient names and dates of birth belong in `patients`, while ordering clinician details belong in `clinicians`. Laboratory orders reference these entities through their foreign keys rather than duplicating their descriptive information.

Similarly, test names and catalogue codes are stored in `lab_tests`, while individual results reference the corresponding ordered test.

## Design Decisions and Limitations

- Surrogate integer keys simplify relationships.
- Unique business identifiers support traceability.
- Foreign keys protect referential integrity.
- Status and date constraints prevent some invalid records.
- The result model supports one result record per ordered test in the initial version.
- The design will be reviewed against representative queries and the assessment requirements before being finalised.

Normalisation claims must be validated against the functional dependencies and candidate keys of the actual schema. Passing 1NF, 2NF, or 3NF should not be asserted merely because tables have primary keys.
