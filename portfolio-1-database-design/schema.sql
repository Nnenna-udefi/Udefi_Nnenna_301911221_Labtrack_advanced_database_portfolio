CREATE DATABASE IF NOT EXISTS labtrack_db;
USE labtrack_db;

CREATE TABLE staff (
    staff_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    staff_number VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(160) NOT NULL,
    staff_role VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_staff_role
    CHECK (
        staff_role IN (
            'FRONT_DESK_PERSONNEL',
            'LAB_SCIENTIST',
            'PATHOLOGIST',
            'REQUESTING_CLINICIAN'
        )
    )
);

CREATE TABLE patients (
    patient_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    patient_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    date_of_birth DATE,
    sex VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registered_by INT UNSIGNED NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_patients_registered_by
        FOREIGN KEY (registered_by)
        REFERENCES staff(staff_id)
);


CREATE TABLE lab_tests (
    test_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    test_code VARCHAR(20) NOT NULL UNIQUE,
    test_name VARCHAR(120) NOT NULL,
    specimen_type VARCHAR(60) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE lab_orders (
    order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    patient_id INT UNSIGNED NOT NULL,
    ordering_clinician_id INT UNSIGNED NOT NULL,
    ordered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    entered_by INT UNSIGNED NOT NULL,
    entered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_entered_by
        FOREIGN KEY (entered_by)
        REFERENCES staff(staff_id),

    CONSTRAINT fk_orders_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_orders_clinician
        FOREIGN KEY (ordering_clinician_id)
         REFERENCES staff(staff_id),

    CONSTRAINT chk_order_status
        CHECK (status IN (
            'PENDING', 'IN_PROGRESS',
            'COMPLETED', 'CANCELLED'
        ))
);

CREATE TABLE specimens (
    specimen_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    specimen_number VARCHAR(30) NOT NULL UNIQUE,
    order_id INT UNSIGNED NOT NULL,
    specimen_type VARCHAR(60) NOT NULL,
    collected_at DATETIME,
    received_at DATETIME,
    status VARCHAR(20) NOT NULL DEFAULT 'RECEIVED',

    CONSTRAINT fk_specimens_order
        FOREIGN KEY (order_id)
        REFERENCES lab_orders(order_id),

    CONSTRAINT chk_specimen_status
        CHECK (status IN (
            'EXPECTED', 'RECEIVED',
            'REJECTED', 'PROCESSED'
        )),

    CONSTRAINT chk_specimen_dates
        CHECK (
            collected_at IS NULL
            OR received_at IS NULL
            OR received_at >= collected_at
        )
);

CREATE TABLE order_tests (
    order_test_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    test_id INT UNSIGNED NOT NULL,
    specimen_id INT UNSIGNED,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    CONSTRAINT uq_order_test
        UNIQUE (order_id, test_id),

    CONSTRAINT fk_order_tests_order
        FOREIGN KEY (order_id)
        REFERENCES lab_orders(order_id),

    CONSTRAINT fk_order_tests_test
        FOREIGN KEY (test_id)
        REFERENCES lab_tests(test_id),

    CONSTRAINT fk_order_tests_specimen
        FOREIGN KEY (specimen_id)
        REFERENCES specimens(specimen_id),

    CONSTRAINT chk_order_test_status
        CHECK (status IN (
            'PENDING', 'IN_PROGRESS',
            'COMPLETED', 'CANCELLED'
        ))
);


CREATE TABLE test_results (
    result_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_test_id INT UNSIGNED NOT NULL UNIQUE,
    result_value VARCHAR(255) NOT NULL,
    units VARCHAR(40),
    reference_range VARCHAR(100),
    interpretation VARCHAR(40),

    status VARCHAR(20) NOT NULL DEFAULT 'ENTERED',

    entered_by INT UNSIGNED NOT NULL,
    entered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    validated_by INT UNSIGNED,
    validated_at DATETIME,

    authorised_by INT UNSIGNED,
    authorised_at DATETIME,

    released_at DATETIME,

    CONSTRAINT fk_results_order_test
        FOREIGN KEY (order_test_id)
        REFERENCES order_tests(order_test_id),

    CONSTRAINT fk_results_entered_by
        FOREIGN KEY (entered_by)
        REFERENCES staff(staff_id),

    CONSTRAINT fk_results_validated_by
        FOREIGN KEY (validated_by)
        REFERENCES staff(staff_id),

    CONSTRAINT fk_results_authorised_by
        FOREIGN KEY (authorised_by)
        REFERENCES staff(staff_id),

    CONSTRAINT chk_result_status
        CHECK (
            status IN (
                'ENTERED',
                'VALIDATED',
                'AUTHORISED',
                'RELEASED',
                'AMENDED'
            )
        ),

    CONSTRAINT chk_validation_details
        CHECK (
            (validated_by IS NULL AND validated_at IS NULL)
            OR
            (validated_by IS NOT NULL AND validated_at IS NOT NULL)
        ),

    CONSTRAINT chk_authorisation_details
        CHECK (
            (authorised_by IS NULL AND authorised_at IS NULL)
            OR
            (authorised_by IS NOT NULL AND authorised_at IS NOT NULL)
        ),

    CONSTRAINT chk_release_details
        CHECK (
            status <> 'RELEASED'
            OR (
                authorised_by IS NOT NULL
                AND authorised_at IS NOT NULL
                AND released_at IS NOT NULL
            )
        )
);


-- Initial indexes for common lookups
CREATE INDEX idx_orders_patient_date
    ON lab_orders(patient_id, ordered_at);

CREATE INDEX idx_orders_status_date
    ON lab_orders(status, ordered_at);

CREATE INDEX idx_specimens_order
    ON specimens(order_id);

CREATE INDEX idx_order_tests_status
    ON order_tests(status);
