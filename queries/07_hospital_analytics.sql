USE hospital_management;

-- ============================================
-- 1. HOSPITAL OVERVIEW
-- ============================================

SELECT
    (SELECT COUNT(*) FROM patients) AS total_patients,
    (SELECT COUNT(*) FROM doctors) AS total_doctors,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT COUNT(*) FROM admissions) AS total_admissions,
    (SELECT COUNT(*) FROM prescriptions) AS total_prescriptions,
    (SELECT COUNT(*) FROM bills) AS total_bills;


-- ============================================
-- 2. APPOINTMENT STATUS BREAKDOWN
-- ============================================

SELECT
    status,
    COUNT(*) AS total_appointments,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM appointments),
        2
    ) AS percentage
FROM appointments
GROUP BY status
ORDER BY total_appointments DESC;


-- ============================================
-- 3. PATIENT DEMOGRAPHICS
-- ============================================

SELECT
    gender,
    COUNT(*) AS patients,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM patients),
        2
    ) AS percentage
FROM patients
GROUP BY gender
ORDER BY patients DESC;


-- ============================================
-- 4. DOCTOR WORKLOAD
-- ============================================

SELECT
    d.doctor_id,
    d.doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    dep.department_name
ORDER BY total_appointments DESC;


-- ============================================
-- 5. DOCTOR COMPLETION RATE
-- ============================================

SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.status = 'Completed') AS completed,
    ROUND(
        100.0 * SUM(a.status = 'Completed') /
        COUNT(a.appointment_id),
        2
    ) AS completion_rate
FROM doctors d
JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name
ORDER BY completion_rate DESC;


-- ============================================
-- 6. TOP 10 BUSIEST DOCTORS
-- ============================================

SELECT
    d.doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) AS appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    dep.department_name
ORDER BY appointments DESC
LIMIT 10;


-- ============================================
-- 7. DOCTORS WITH NO APPOINTMENTS
-- ============================================

SELECT
    d.doctor_id,
    d.doctor_name,
    dep.department_name
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
WHERE a.appointment_id IS NULL;


-- ============================================
-- 8. DEPARTMENT PERFORMANCE
-- ============================================

SELECT
    dep.department_name,
    COUNT(DISTINCT d.doctor_id) AS doctors,
    COUNT(DISTINCT a.appointment_id) AS appointments,
    COUNT(DISTINCT ad.admission_id) AS admissions
FROM departments dep
LEFT JOIN doctors d
    ON dep.department_id = d.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
LEFT JOIN admissions ad
    ON d.doctor_id = ad.doctor_id
GROUP BY
    dep.department_id,
    dep.department_name
ORDER BY appointments DESC;


-- ============================================
-- 9. DEPARTMENT APPOINTMENT SHARE
-- ============================================

SELECT
    dep.department_name,
    COUNT(a.appointment_id) AS appointments,
    ROUND(
        100.0 * COUNT(a.appointment_id) /
        (SELECT COUNT(*) FROM appointments),
        2
    ) AS appointment_share
FROM departments dep
JOIN doctors d
    ON dep.department_id = d.department_id
JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    dep.department_id,
    dep.department_name
ORDER BY appointment_share DESC;


-- ============================================
-- 10. DEPARTMENT REVENUE
-- ============================================

SELECT
    dep.department_name,
    COUNT(DISTINCT ad.admission_id) AS admissions,
    COALESCE(SUM(b.final_amount), 0) AS revenue
FROM departments dep
JOIN doctors d
    ON dep.department_id = d.department_id
JOIN admissions ad
    ON d.doctor_id = ad.doctor_id
LEFT JOIN bills b
    ON ad.admission_id = b.admission_id
GROUP BY
    dep.department_id,
    dep.department_name
ORDER BY revenue DESC;


-- ============================================
-- 11. TOP PATIENTS BY SPENDING
-- ============================================

SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    SUM(b.final_amount) AS total_spent
FROM patients p
JOIN bills b
    ON p.patient_id = b.patient_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================
-- 12. MOST FREQUENT PATIENT VISITS
-- ============================================

SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(a.appointment_id) AS visits
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
ORDER BY visits DESC
LIMIT 10;


-- ============================================
-- 13. PATIENTS WITH NO APPOINTMENTS
-- ============================================

SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name
FROM patients p
LEFT JOIN appointments a
    ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;


-- ============================================
-- 14. MULTIPLE ADMISSIONS
-- ============================================

SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(a.admission_id) AS admissions
FROM patients p
JOIN admissions a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.first_name,
    p.last_name
HAVING COUNT(a.admission_id) > 1
ORDER BY admissions DESC;


-- ============================================
-- 15. TOTAL BILLED VS COLLECTED
-- ============================================

SELECT
    (SELECT SUM(final_amount)
     FROM bills) AS total_billed,

    (SELECT COALESCE(SUM(amount), 0)
     FROM payments) AS total_collected,

    (SELECT SUM(final_amount)
     FROM bills)
    -
    (SELECT COALESCE(SUM(amount), 0)
     FROM payments) AS outstanding_amount;


-- ============================================
-- 16. PAYMENT STATUS DISTRIBUTION
-- ============================================

SELECT
    payment_status,
    COUNT(*) AS number_of_bills,
    SUM(final_amount) AS total_amount
FROM bills
GROUP BY payment_status
ORDER BY total_amount DESC;


-- ============================================
-- 17. OUTSTANDING BILLS
-- ============================================

SELECT
    bill_id,
    patient_name,
    final_amount,
    amount_paid,
    amount_due
FROM patient_billing
WHERE amount_due > 0
ORDER BY amount_due DESC;


-- ============================================
-- 18. TOP OUTSTANDING AMOUNTS
-- ============================================

SELECT
    bill_id,
    patient_name,
    amount_due
FROM patient_billing
WHERE amount_due > 0
ORDER BY amount_due DESC
LIMIT 10;


-- ============================================
-- 19. MOST PRESCRIBED MEDICINES
-- ============================================

SELECT
    m.medicine_name,
    SUM(pi.quantity) AS total_quantity
FROM medicines m
JOIN prescription_items pi
    ON m.medicine_id = pi.medicine_id
GROUP BY
    m.medicine_id,
    m.medicine_name
ORDER BY total_quantity DESC
LIMIT 10;


-- ============================================
-- 20. LOW STOCK MEDICINES
-- ============================================

SELECT
    medicine_id,
    medicine_name,
    stock_quantity
FROM medicines
WHERE stock_quantity < 100
ORDER BY stock_quantity;


-- ============================================
-- 21. TOTAL INVENTORY VALUE
-- ============================================

SELECT
    SUM(unit_price * stock_quantity) AS total_inventory_value
FROM medicines;


-- ============================================
-- 22. INVENTORY VALUE BY CATEGORY
-- ============================================

SELECT
    category,
    SUM(unit_price * stock_quantity) AS inventory_value
FROM medicines
GROUP BY category
ORDER BY inventory_value DESC;


-- ============================================
-- 23. AVERAGE LENGTH OF STAY
-- ============================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                discharge_date,
                admission_date
            )
        ),
        2
    ) AS average_stay_days
FROM admissions
WHERE discharge_date IS NOT NULL;


-- ============================================
-- 24. LONGEST HOSPITAL STAYS
-- ============================================

SELECT
    a.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    a.admission_date,
    a.discharge_date,
    DATEDIFF(
        a.discharge_date,
        a.admission_date
    ) AS stay_days
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
WHERE a.discharge_date IS NOT NULL
ORDER BY stay_days DESC
LIMIT 10;


-- ============================================
-- 25. MOST COMMON DIAGNOSES
-- ============================================

SELECT
    diagnosis,
    COUNT(*) AS cases
FROM admissions
GROUP BY diagnosis
ORDER BY cases DESC;


-- ============================================
-- 26. MONTHLY APPOINTMENTS
-- ============================================

SELECT
    DATE_FORMAT(
        appointment_date,
        '%Y-%m'
    ) AS month,
    COUNT(*) AS appointments
FROM appointments
GROUP BY month
ORDER BY month;


-- ============================================
-- 27. MONTHLY REVENUE
-- ============================================

SELECT
    DATE_FORMAT(
        bill_date,
        '%Y-%m'
    ) AS month,
    SUM(final_amount) AS revenue
FROM bills
GROUP BY month
ORDER BY month;


-- ============================================
-- 28. MONTHLY ADMISSIONS
-- ============================================

SELECT
    DATE_FORMAT(
        admission_date,
        '%Y-%m'
    ) AS month,
    COUNT(*) AS admissions
FROM admissions
GROUP BY month
ORDER BY month;


-- ============================================
-- 29. HOSPITAL KPI DASHBOARD
-- ============================================

SELECT
    (SELECT COUNT(*) FROM patients)
        AS total_patients,

    (SELECT COUNT(*) FROM doctors)
        AS total_doctors,

    (SELECT COUNT(*) FROM appointments)
        AS total_appointments,

    (SELECT COUNT(*)
     FROM appointments
     WHERE status = 'Completed')
        AS completed_appointments,

    (SELECT COUNT(*) FROM admissions)
        AS total_admissions,

    (SELECT ROUND(
        AVG(
            DATEDIFF(
                discharge_date,
                admission_date
            )
        ), 2)
     FROM admissions
     WHERE discharge_date IS NOT NULL)
        AS avg_stay_days,

    (SELECT SUM(final_amount)
     FROM bills)
        AS total_revenue,

    (SELECT COALESCE(SUM(amount), 0)
     FROM payments)
        AS total_collected,

    (SELECT SUM(final_amount)
     FROM bills)
    -
    (SELECT COALESCE(SUM(amount), 0)
     FROM payments)
        AS outstanding_amount;


-- ============================================
-- 30. DEPARTMENT REVENUE DASHBOARD
-- ============================================

WITH department_revenue AS (
    SELECT
        d.department_id,
        SUM(b.final_amount) AS revenue
    FROM doctors d
    JOIN admissions a
        ON d.doctor_id = a.doctor_id
    JOIN bills b
        ON a.admission_id = b.admission_id
    GROUP BY d.department_id
),
department_appointments AS (
    SELECT
        d.department_id,
        COUNT(a.appointment_id) AS appointments
    FROM doctors d
    JOIN appointments a
        ON d.doctor_id = a.doctor_id
    GROUP BY d.department_id
),
department_admissions AS (
    SELECT
        d.department_id,
        COUNT(ad.admission_id) AS admissions
    FROM doctors d
    JOIN admissions ad
        ON d.doctor_id = ad.doctor_id
    GROUP BY d.department_id
)
SELECT
    dep.department_name,
    COUNT(DISTINCT d.doctor_id) AS doctors,
    COALESCE(da.appointments, 0) AS appointments,
    COALESCE(dad.admissions, 0) AS admissions,
    COALESCE(dr.revenue, 0) AS revenue
FROM departments dep
LEFT JOIN doctors d
    ON dep.department_id = d.department_id
LEFT JOIN department_appointments da
    ON dep.department_id = da.department_id
LEFT JOIN department_admissions dad
    ON dep.department_id = dad.department_id
LEFT JOIN department_revenue dr
    ON dep.department_id = dr.department_id
GROUP BY
    dep.department_id,
    dep.department_name,
    da.appointments,
    dad.admissions,
    dr.revenue
ORDER BY revenue DESC;
