USE hospital_management;

-- ============================================
-- BASIC SELECT / FILTERING
-- ============================================

SELECT *
FROM patients;

SELECT
    patient_id,
    first_name,
    last_name,
    gender,
    blood_group
FROM patients;

SELECT *
FROM doctors;

SELECT *
FROM patients
WHERE gender = 'Female';

SELECT
    patient_id,
    first_name,
    last_name,
    blood_group
FROM patients
WHERE blood_group = 'O+';

SELECT *
FROM doctors
WHERE department_id = 1;

SELECT
    medicine_name,
    unit_price
FROM medicines
WHERE unit_price > 200;

SELECT *
FROM rooms
WHERE status = 'Available';

SELECT *
FROM patients
WHERE registration_date >= '2025-01-01';

SELECT *
FROM appointments
WHERE status = 'Completed';


-- ============================================
-- COMPARISON OPERATORS
-- ============================================

SELECT
    medicine_name,
    unit_price
FROM medicines
WHERE unit_price BETWEEN 100 AND 300;

SELECT
    patient_id,
    first_name,
    last_name,
    date_of_birth
FROM patients
WHERE date_of_birth < '1990-01-01';

SELECT
    bill_id,
    patient_id,
    final_amount
FROM bills
WHERE final_amount > 50000;

SELECT *
FROM bills
WHERE payment_status = 'Pending';


-- ============================================
-- AND / OR / NOT
-- ============================================

SELECT *
FROM patients
WHERE gender = 'Female'
  AND blood_group = 'O+';

SELECT *
FROM patients
WHERE blood_group IN ('A+', 'B+');

SELECT *
FROM appointments
WHERE status <> 'Completed';


-- ============================================
-- IN / LIKE
-- ============================================

SELECT *
FROM patients
WHERE address IN ('Chandigarh', 'Mohali');

SELECT *
FROM doctors
WHERE doctor_name LIKE 'Dr. A%';

SELECT *
FROM patients
WHERE first_name LIKE 'S%';

SELECT *
FROM medicines
WHERE medicine_name LIKE '%Paracetamol%';


-- ============================================
-- ORDER BY / LIMIT / DISTINCT
-- ============================================

SELECT *
FROM medicines
ORDER BY unit_price DESC;

SELECT *
FROM bills
ORDER BY final_amount DESC;

SELECT *
FROM appointments
ORDER BY appointment_date DESC;

SELECT
    medicine_name,
    unit_price
FROM medicines
ORDER BY unit_price DESC
LIMIT 10;

SELECT DISTINCT blood_group
FROM patients;

SELECT DISTINCT specialization
FROM doctors;

SELECT DISTINCT payment_method
FROM payments;


-- ============================================
-- AGGREGATE FUNCTIONS
-- ============================================

SELECT COUNT(*) AS total_patients
FROM patients;

SELECT COUNT(*) AS total_doctors
FROM doctors;

SELECT COUNT(*) AS total_appointments
FROM appointments;

SELECT SUM(final_amount) AS total_revenue
FROM bills;

SELECT AVG(final_amount) AS average_bill
FROM bills;

SELECT MAX(final_amount) AS highest_bill
FROM bills;

SELECT MIN(final_amount) AS lowest_bill
FROM bills;

SELECT SUM(amount) AS total_collected
FROM payments;


-- ============================================
-- GROUP BY
-- ============================================

SELECT
    department_id,
    COUNT(*) AS doctor_count
FROM doctors
GROUP BY department_id;

SELECT
    gender,
    COUNT(*) AS patient_count
FROM patients
GROUP BY gender;

SELECT
    blood_group,
    COUNT(*) AS patient_count
FROM patients
GROUP BY blood_group
ORDER BY patient_count DESC;

SELECT
    status,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY status;

SELECT
    doctor_id,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY doctor_id
ORDER BY appointment_count DESC;

SELECT
    category,
    COUNT(*) AS medicine_count
FROM medicines
GROUP BY category
ORDER BY medicine_count DESC;


-- ============================================
-- HAVING
-- ============================================

SELECT
    doctor_id,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY doctor_id
HAVING COUNT(*) > 40
ORDER BY appointment_count DESC;

SELECT
    patient_id,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 5
ORDER BY appointment_count DESC;

SELECT
    category,
    AVG(unit_price) AS average_price
FROM medicines
GROUP BY category
HAVING AVG(unit_price) > 200;


-- ============================================
-- JOINS
-- ============================================

SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    dep.department_name
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id;


SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.doctor_name,
    a.appointment_date,
    a.reason,
    a.status
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id;


SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.doctor_name,
    dep.department_name,
    d.specialization,
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


SELECT
    a.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.doctor_name,
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
JOIN rooms r
    ON a.room_id = r.room_id;


-- ============================================
-- LEFT JOIN
-- ============================================

SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(a.appointment_id) AS appointment_count
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name
ORDER BY appointment_count DESC;


SELECT
    dep.department_id,
    dep.department_name,
    COUNT(d.doctor_id) AS doctor_count
FROM departments dep
LEFT JOIN doctors d
    ON dep.department_id = d.department_id
GROUP BY
    dep.department_id,
    dep.department_name
ORDER BY doctor_count DESC;


-- ============================================
-- CASE
-- ============================================

SELECT
    bill_id,
    final_amount,
    CASE
        WHEN final_amount < 10000 THEN 'Low'
        WHEN final_amount < 50000 THEN 'Medium'
        ELSE 'High'
    END AS bill_category
FROM bills;


SELECT
    appointment_id,
    status,
    CASE
        WHEN status = 'Completed' THEN 'Successful'
        WHEN status = 'Cancelled' THEN 'Cancelled'
        WHEN status = 'No-Show' THEN 'Patient No-Show'
        ELSE 'Upcoming'
    END AS appointment_category
FROM appointments;


-- ============================================
-- SUBQUERIES
-- ============================================

SELECT
    bill_id,
    patient_id,
    final_amount
FROM bills
WHERE final_amount > (
    SELECT AVG(final_amount)
    FROM bills
)
ORDER BY final_amount DESC;


SELECT
    medicine_name,
    unit_price
FROM medicines
WHERE unit_price = (
    SELECT MAX(unit_price)
    FROM medicines
);


SELECT
    patient_id,
    first_name,
    last_name
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM admissions
);


SELECT
    patient_id,
    first_name,
    last_name
FROM patients
WHERE patient_id NOT IN (
    SELECT patient_id
    FROM admissions
);


-- ============================================
-- DATE FUNCTIONS
-- ============================================

SELECT *
FROM appointments
WHERE YEAR(appointment_date) = 2026;


SELECT
    YEAR(appointment_date) AS appointment_year,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY YEAR(appointment_date)
ORDER BY appointment_year;


SELECT
    YEAR(appointment_date) AS year,
    MONTH(appointment_date) AS month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date)
ORDER BY
    year,
    month;