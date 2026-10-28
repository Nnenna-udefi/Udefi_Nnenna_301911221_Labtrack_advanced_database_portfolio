
USE labtrack_db;

-- Allow recursive CTEs to generate up to 20,000 rows.
SET SESSION cte_max_recursion_depth = 30000;

-- =====================================================
-- 1. GENERATE 10,000 ADDITIONAL PATIENTS
-- =====================================================


INSERT INTO patients
    (patient_number, first_name, last_name, date_of_birth,
     sex, registered_by, registered_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10000
)
SELECT
    CONCAT('PAT', LPAD((seq.n + 5), 6, '0')),
    CONCAT('FirstName', seq.n + 5),
    CONCAT('LastName', seq.n + 5),
    DATE_ADD('1960-01-01', INTERVAL MOD((seq.n + 5) * 37, 16000) DAY),
    CASE MOD(seq.n + 5, 2)
        WHEN 0 THEN 'FEMALE'
        WHEN 1 THEN 'MALE'
    END,
    reg.staff_id,
    DATE_ADD(
        '2026-01-01 08:00:00',
        INTERVAL MOD(seq.n, 300) DAY
    )
FROM seq
JOIN staff AS reg
    ON reg.staff_number = 'STF001'
WHERE NOT EXISTS (
    SELECT 1
    FROM patients AS p
    WHERE p.patient_number =
          CONCAT('PAT', LPAD(seq.n, 6, '0'))
);

-- =====================================================
-- 2. GENERATE 20,000 ADDITIONAL LAB ORDERS
-- =====================================================

INSERT INTO lab_orders
    (order_number, patient_id, ordering_clinician_id,
     ordered_at, status, entered_by, entered_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT
    CONCAT('ORDG', LPAD((seq.n + 5), 6, '0')),
    p.patient_id,
    clinician.staff_id,
    DATE_ADD(
        '2026-01-01 08:00:00',
        INTERVAL MOD((seq.n + 5), 300) DAY
    ),
    CASE MOD((seq.n + 5), 4)
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'IN_PROGRESS'
        WHEN 2 THEN 'PENDING'
        ELSE 'CANCELLED'
    END,
    reg.staff_id,
    DATE_ADD(
        DATE_ADD(
            '2026-01-01 08:00:00',
            INTERVAL MOD((seq.n + 5), 300) DAY
        ),
        INTERVAL 5 MINUTE
    )
FROM seq
JOIN patients AS p
    ON p.patient_number = CONCAT(
        'PAT',
        LPAD(MOD((seq.n + 5) - 1, 10000) + 1, 6, '0')
    )
JOIN staff AS clinician
    ON clinician.staff_number =
       CASE
           WHEN MOD((seq.n + 5), 2) = 0 THEN 'STF005'
           ELSE 'STF006'
       END
JOIN staff AS reg
    ON reg.staff_number = 'STF001'
WHERE NOT EXISTS (
    SELECT 1
    FROM lab_orders AS existing_order
    WHERE existing_order.order_number =
          CONCAT('ORDG', LPAD((seq.n + 5), 6, '0'))
);

-- =====================================================
-- 3. GENERATE ONE SPECIMEN FOR EACH GENERATED ORDER
-- =====================================================

INSERT INTO specimens
    (specimen_number, order_id, specimen_type,
     collected_at, received_at, status)
SELECT
    CONCAT(
        'SPCG',
        SUBSTRING(o.order_number, 5)
    ),
    o.order_id,
    t.specimen_type,

    CASE
        WHEN o.status = 'PENDING' THEN NULL
        ELSE DATE_ADD(
            o.ordered_at,
            INTERVAL -30 MINUTE
        )
    END,

    CASE
        WHEN o.status = 'PENDING' THEN NULL
        ELSE o.ordered_at
    END,

    CASE o.status
        WHEN 'COMPLETED' THEN 'PROCESSED'
        WHEN 'IN_PROGRESS' THEN 'RECEIVED'
        WHEN 'PENDING' THEN 'EXPECTED'
        ELSE 'REJECTED'
    END
FROM lab_orders AS o
JOIN lab_tests AS t
    ON t.test_code =
       CASE MOD(CAST(SUBSTRING(o.order_number, 5) AS UNSIGNED) - 1, 5)
           WHEN 0 THEN 'HBVDNA'
           WHEN 1 THEN 'HCVRNA'
           WHEN 2 THEN 'HIVRNA'
           WHEN 3 THEN 'HPVDNA'
           ELSE 'CTNG'
       END
WHERE o.order_number LIKE 'ORDG%'
  AND NOT EXISTS (
      SELECT 1
      FROM specimens AS s
      WHERE s.specimen_number =
            CONCAT('SPCG', SUBSTRING(o.order_number, 5))
  );

-- =====================================================
-- 4. GENERATE ONE ORDERED TEST FOR EACH GENERATED ORDER
-- =====================================================

INSERT INTO order_tests
    (order_id, test_id, specimen_id, status)
SELECT
    o.order_id,
    t.test_id,
    s.specimen_id,
    CASE o.status
        WHEN 'COMPLETED' THEN 'COMPLETED'
        WHEN 'IN_PROGRESS' THEN 'IN_PROGRESS'
        WHEN 'PENDING' THEN 'PENDING'
        ELSE 'CANCELLED'
    END
FROM lab_orders AS o
JOIN lab_tests AS t
    ON t.test_code =
       CASE MOD(CAST(SUBSTRING(o.order_number, 5) AS UNSIGNED) - 1, 5)
           WHEN 0 THEN 'HBVDNA'
           WHEN 1 THEN 'HCVRNA'
           WHEN 2 THEN 'HIVRNA'
           WHEN 3 THEN 'HPVDNA'
           ELSE 'CTNG'
       END
JOIN specimens AS s
    ON s.specimen_number =
       CONCAT('SPCG', SUBSTRING(o.order_number, 5))
WHERE o.order_number LIKE 'ORDG%'
  AND NOT EXISTS (
      SELECT 1
      FROM order_tests AS ot
      WHERE ot.order_id = o.order_id
        AND ot.test_id = t.test_id
  );

-- =====================================================
-- 5. GENERATE RESULTS FOR COMPLETED ORDERED TESTS
-- =====================================================

INSERT INTO test_results
    (order_test_id, result_value, units, reference_range,
     interpretation, status, entered_by, entered_at,
     validated_by, validated_at,
     authorised_by, authorised_at, released_at)
SELECT
    ot.order_test_id,
    'Not detected',
    NULL,
    'Not detected',
    'NEGATIVE',
    'RELEASED',
    scientist.staff_id,
    DATE_ADD(o.ordered_at, INTERVAL 2 HOUR),
    validator.staff_id,
    DATE_ADD(o.ordered_at, INTERVAL 2 HOUR) + INTERVAL 30 MINUTE,
    pathologist.staff_id,
    DATE_ADD(o.ordered_at, INTERVAL 3 HOUR),
    DATE_ADD(o.ordered_at, INTERVAL 3 HOUR) + INTERVAL 15 MINUTE
FROM order_tests AS ot
JOIN lab_orders AS o
    ON o.order_id = ot.order_id
JOIN staff AS scientist
    ON scientist.staff_number = 'STF002'
JOIN staff AS validator
    ON validator.staff_number = 'STF003'
JOIN staff AS pathologist
    ON pathologist.staff_number = 'STF004'
WHERE o.order_number LIKE 'ORDG%'
  AND o.status = 'COMPLETED'
  AND ot.status = 'COMPLETED'
  AND NOT EXISTS (
      SELECT 1
      FROM test_results AS r
      WHERE r.order_test_id = ot.order_test_id
  );
