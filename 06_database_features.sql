USE hospital_management;

-- ============================================
-- VIEWS
-- ============================================

CREATE OR REPLACE VIEW patient_appointments AS
SELECT
    a.appointment_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    a.appointment_date,
    a.reason,
    a.status
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN departments dep
    ON d.department_id = dep.department_id;


CREATE OR REPLACE VIEW patient_admissions AS
SELECT
    a.admission_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.doctor_name,
    dep.department_name,
    r.room_number,
    r.room_type,
    a.admission_date,
    a.discharge_date,
    a.diagnosis,
    a.status
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN departments dep
    ON d.department_id = dep.department_id
JOIN rooms r
    ON a.room_id = r.room_id;


CREATE OR REPLACE VIEW patient_billing AS
SELECT
    b.bill_id,
    b.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    b.bill_date,
    b.total_amount,
    b.discount,
    b.final_amount,
    b.payment_status,
    COALESCE(SUM(pay.amount), 0) AS amount_paid,
    b.final_amount - COALESCE(SUM(pay.amount), 0) AS amount_due
FROM bills b
JOIN patients p
    ON b.patient_id = p.patient_id
LEFT JOIN payments pay
    ON b.bill_id = pay.bill_id
GROUP BY
    b.bill_id,
    b.patient_id,
    p.first_name,
    p.last_name,
    b.bill_date,
    b.total_amount,
    b.discount,
    b.final_amount,
    b.payment_status;


-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_appointments_patient
ON appointments(patient_id);

CREATE INDEX idx_appointments_doctor
ON appointments(doctor_id);

CREATE INDEX idx_appointments_date
ON appointments(appointment_date);

CREATE INDEX idx_bills_patient
ON bills(patient_id);

CREATE INDEX idx_bills_date
ON bills(bill_date);

CREATE INDEX idx_admissions_patient
ON admissions(patient_id);


-- ============================================
-- STORED PROCEDURE
-- ============================================

DELIMITER //

CREATE PROCEDURE GetPatientAppointments(
    IN p_patient_id INT
)
BEGIN
    SELECT
        a.appointment_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        d.doctor_name,
        dep.department_name,
        a.appointment_date,
        a.reason,
        a.status
    FROM appointments a
    JOIN patients p
        ON a.patient_id = p.patient_id
    JOIN doctors d
        ON a.doctor_id = d.doctor_id
    JOIN departments dep
        ON d.department_id = dep.department_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date DESC;
END //

DELIMITER ;


-- ============================================
-- DOCTOR WORKLOAD PROCEDURE
-- ============================================

DELIMITER //

CREATE PROCEDURE GetDoctorWorkload(
    IN p_doctor_id INT
)
BEGIN
    SELECT
        d.doctor_id,
        d.doctor_name,
        dep.department_name,
        COUNT(a.appointment_id) AS total_appointments,
        SUM(a.status = 'Completed') AS completed_appointments,
        SUM(a.status = 'Cancelled') AS cancelled_appointments,
        SUM(a.status = 'No-Show') AS no_show_appointments
    FROM doctors d
    JOIN departments dep
        ON d.department_id = dep.department_id
    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id
    WHERE d.doctor_id = p_doctor_id
    GROUP BY
        d.doctor_id,
        d.doctor_name,
        dep.department_name;
END //

DELIMITER ;


-- ============================================
-- PATIENT BILLING PROCEDURE
-- ============================================

DELIMITER //

CREATE PROCEDURE GetPatientBilling(
    IN p_patient_id INT
)
BEGIN
    SELECT
        patient_id,
        patient_name,
        SUM(final_amount) AS total_billed,
        SUM(amount_paid) AS total_paid,
        SUM(amount_due) AS total_due
    FROM patient_billing
    WHERE patient_id = p_patient_id
    GROUP BY
        patient_id,
        patient_name;
END //

DELIMITER ;


-- ============================================
-- STORED FUNCTION
-- ============================================

DELIMITER //

CREATE FUNCTION CalculateAge(
    birth_date DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        birth_date,
        CURDATE()
    );
END //

DELIMITER ;


-- ============================================
-- TRIGGER
-- ============================================

DELIMITER //

CREATE TRIGGER after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN

    DECLARE total_paid DECIMAL(10,2);
    DECLARE bill_total DECIMAL(10,2);

    SELECT
        COALESCE(SUM(amount), 0)
    INTO total_paid
    FROM payments
    WHERE bill_id = NEW.bill_id;

    SELECT
        final_amount
    INTO bill_total
    FROM bills
    WHERE bill_id = NEW.bill_id;

    IF total_paid >= bill_total THEN

        UPDATE bills
        SET payment_status = 'Paid'
        WHERE bill_id = NEW.bill_id;

    ELSE

        UPDATE bills
        SET payment_status = 'Partially Paid'
        WHERE bill_id = NEW.bill_id;

    END IF;

END //

DELIMITER ;