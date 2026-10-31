-- LabTrack: Seed Data
-- Database: labtrack_db
-- All records are fictional and intended for academic testing.

USE labtrack_db;

-- =========================================
-- 1. STAFF
-- =========================================

INSERT INTO staff
    (staff_number, full_name, staff_role, is_active)
VALUES
    ('STF001', 'Amaka Okoro', 'FRONT_DESK_PERSONNEL', TRUE),
    ('STF002', 'David Eze', 'LAB_SCIENTIST', TRUE),
    ('STF003', 'Ifeoma Bello', 'LAB_SCIENTIST', TRUE),
    ('STF004', 'Chidi Nwosu', 'PATHOLOGIST', TRUE),
    ('STF005', 'Tari Akin', 'REQUESTING_CLINICIAN', TRUE),
    ('STF006', 'Mariam Yusuf', 'REQUESTING_CLINICIAN', TRUE);

-- =========================================
-- 2. PATIENTS
-- =========================================

INSERT INTO patients
    (patient_number, first_name, last_name, date_of_birth, sex,
     registered_by, registered_at)
VALUES
    ('PAT001', 'Ada', 'James', '1995-04-12', 'FEMALE',
     1, '2026-10-20 08:30:00'),
    ('PAT002', 'Emeka', 'Obi', '1988-09-23', 'MALE',
     1, '2026-10-20 09:15:00'),
    ('PAT003', 'Zara', 'Cole', '2001-02-08', 'FEMALE',
     1, '2026-10-21 10:00:00'),
    ('PAT004', 'Daniel', 'George', '1979-11-17', 'MALE',
     1, '2026-10-21 11:20:00'),
    ('PAT005', 'Mina', 'Osei', '1992-07-05', 'FEMALE',
     1, '2026-10-22 08:45:00');

-- =========================================
-- 3. LABORATORY TEST CATALOGUE
-- =========================================

INSERT INTO lab_tests
    (test_code, test_name, specimen_type, is_active)
VALUES
    ('HBVDNA', 'Hepatitis B Viral DNA', 'SERUM', TRUE),
    ('HCVRNA', 'Hepatitis C Viral RNA', 'PLASMA', TRUE),
    ('HIVRNA', 'HIV Viral RNA', 'PLASMA', TRUE),
    ('HPVDNA', 'Human Papillomavirus DNA', 'CERVICAL_SWAB', TRUE),
    ('CTNG', 'Chlamydia and Gonorrhoea NAAT', 'URINE', TRUE);

-- =========================================
-- 4. LABORATORY ORDERS
-- =========================================

INSERT INTO lab_orders
    (order_number, patient_id, ordering_clinician_id, ordered_at,
     status, entered_by, entered_at)
VALUES
    ('ORD001', 1, 5, '2026-10-22 09:00:00', 'COMPLETED', 1,
     '2026-10-22 09:05:00'),
    ('ORD002', 2, 5, '2026-10-22 10:00:00', 'IN_PROGRESS', 1,
     '2026-10-22 10:05:00'),
    ('ORD003', 3, 6, '2026-10-23 08:30:00', 'PENDING', 1,
     '2026-10-23 08:35:00'),
    ('ORD004', 4, 6, '2026-10-23 11:00:00', 'COMPLETED', 1,
     '2026-10-23 11:05:00'),
    ('ORD005', 5, 5, '2026-10-24 09:15:00', 'IN_PROGRESS', 1,
     '2026-10-24 09:20:00');

-- =========================================
-- 5. SPECIMENS
-- =========================================

INSERT INTO specimens
    (specimen_number, order_id, specimen_type, collected_at,
     received_at, status)
VALUES
    ('SPC001', 1, 'SERUM', '2026-10-22 08:30:00',
     '2026-10-22 09:10:00', 'PROCESSED'),
    ('SPC002', 2, 'PLASMA', '2026-10-22 09:30:00',
     '2026-10-22 10:15:00', 'RECEIVED'),
    ('SPC003', 3, 'CERVICAL_SWAB', '2026-10-23 08:00:00',
     '2026-10-23 08:45:00', 'RECEIVED'),
    ('SPC004', 4, 'URINE', '2026-10-23 10:30:00',
     '2026-10-23 11:15:00', 'PROCESSED'),
    ('SPC005', 5, 'SERUM', '2026-10-24 08:45:00',
     '2026-10-24 09:30:00', 'RECEIVED');

-- =========================================
-- 6. ORDERED TESTS
-- =========================================

INSERT INTO order_tests
    (order_id, test_id, specimen_id, status)
VALUES
    (1, 1, 1, 'COMPLETED'),
    (2, 2, 2, 'IN_PROGRESS'),
    (3, 4, 3, 'PENDING'),
    (4, 5, 4, 'COMPLETED'),
    (5, 1, 5, 'IN_PROGRESS');

-- =========================================
-- 7. TEST RESULTS
-- =========================================

INSERT INTO test_results
    (order_test_id, result_value, units, reference_range,
     interpretation, status, entered_by, entered_at,
     validated_by, validated_at,
     authorised_by, authorised_at, released_at)
VALUES
    (1, 'Not detected', NULL, 'Not detected',
     'NEGATIVE', 'RELEASED', 2, '2026-10-22 12:00:00',
     3, '2026-10-22 12:30:00',
     4, '2026-10-22 13:00:00',
     '2026-10-22 13:15:00');
