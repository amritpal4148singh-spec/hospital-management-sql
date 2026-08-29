USE hospital_management;

-- ============================================
-- DOCTOR WORKLOAD
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
-- TOP 10 BUSIEST DOCTORS
-- ============================================

SELECT
    d.doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    dep.department_name
ORDER BY total_appointments DESC
LIMIT 10;


-- ============================================
-- ABOVE AVERAGE PATIENT SPENDING
-- ============================================

SELECT
    patient_id,
    SUM(final_amount) AS total_spent
FROM bills
GROUP BY patient_id
HAVING SUM(final_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT
            patient_id,
            SUM(final_amount) AS total_spent
        FROM bills
        GROUP BY patient_id
    ) AS patient_spending
)
ORDER BY total_spent DESC;


-- ============================================
-- ABOVE AVERAGE DOCTOR APPOINTMENTS
-- ============================================

SELECT
    doctor_id,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY doctor_id
HAVING COUNT(*) > (
    SELECT AVG(appointment_count)
    FROM (
        SELECT
            doctor_id,
            COUNT(*) AS appointment_count
        FROM appointments
        GROUP BY doctor_id
    ) AS doctor_stats
)
ORDER BY appointment_count DESC;


-- ============================================
-- CTE - DOCTOR STATISTICS
-- ============================================

WITH doctor_stats AS (
    SELECT
        doctor_id,
        COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY doctor_id
)
SELECT
    d.doctor_name,
    ds.total_appointments
FROM doctor_stats ds
JOIN doctors d
    ON ds.doctor_id = d.doctor_id
ORDER BY ds.total_appointments DESC;


-- ============================================
-- CTE - DEPARTMENT STATISTICS
-- ============================================

WITH department_stats AS (
    SELECT
        d.department_id,
        COUNT(a.appointment_id) AS total_appointments
    FROM doctors d
    JOIN appointments a
        ON d.doctor_id = a.doctor_id
    GROUP BY d.department_id
)
SELECT
    dep.department_name,
    ds.total_appointments
FROM department_stats ds
JOIN departments dep
    ON ds.department_id = dep.department_id
ORDER BY ds.total_appointments DESC;


-- ============================================
-- MONTHLY REVENUE CTE
-- ============================================

WITH monthly_revenue AS (
    SELECT
        YEAR(bill_date) AS year,
        MONTH(bill_date) AS month,
        SUM(final_amount) AS revenue
    FROM bills
    GROUP BY
        YEAR(bill_date),
        MONTH(bill_date)
)
SELECT *
FROM monthly_revenue
ORDER BY year, month;


-- ============================================
-- RANK DOCTORS
-- ============================================

SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments,
    RANK() OVER (
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS doctor_rank
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name;


-- ============================================
-- RANK DOCTORS WITHIN DEPARTMENT
-- ============================================

SELECT
    dep.department_name,
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments,
    RANK() OVER (
        PARTITION BY dep.department_id
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS department_rank
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY
    dep.department_id,
    dep.department_name,
    d.doctor_id,
    d.doctor_name;


-- ============================================
-- TOP 3 DOCTORS PER DEPARTMENT
-- ============================================

WITH ranked_doctors AS (
    SELECT
        dep.department_name,
        d.doctor_name,
        COUNT(a.appointment_id) AS total_appointments,
        RANK() OVER (
            PARTITION BY dep.department_id
            ORDER BY COUNT(a.appointment_id) DESC
        ) AS doctor_rank
    FROM doctors d
    JOIN departments dep
        ON d.department_id = dep.department_id
    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id
    GROUP BY
        dep.department_id,
        dep.department_name,
        d.doctor_id,
        d.doctor_name
)
SELECT *
FROM ranked_doctors
WHERE doctor_rank <= 3
ORDER BY department_name, doctor_rank;


-- ============================================
-- RUNNING REVENUE
-- ============================================

WITH daily_revenue AS (
    SELECT
        bill_date,
        SUM(final_amount) AS daily_revenue
    FROM bills
    GROUP BY bill_date
)
SELECT
    bill_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY bill_date
    ) AS running_revenue
FROM daily_revenue
ORDER BY bill_date;


-- ============================================
-- REVENUE CHANGE FROM PREVIOUS DAY
-- ============================================

WITH daily_revenue AS (
    SELECT
        bill_date,
        SUM(final_amount) AS daily_revenue
    FROM bills
    GROUP BY bill_date
)
SELECT
    bill_date,
    daily_revenue,
    LAG(daily_revenue) OVER (
        ORDER BY bill_date
    ) AS previous_day_revenue,
    daily_revenue -
    LAG(daily_revenue) OVER (
        ORDER BY bill_date
    ) AS revenue_difference
FROM daily_revenue
ORDER BY bill_date;


-- ============================================
-- PATIENT SPENDING RANK
-- ============================================

WITH patient_spending AS (
    SELECT
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        COALESCE(SUM(b.final_amount), 0) AS total_spent
    FROM patients p
    LEFT JOIN bills b
        ON p.patient_id = b.patient_id
    GROUP BY
        p.patient_id,
        p.first_name,
        p.last_name
)
SELECT
    patient_id,
    patient_name,
    total_spent,
    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS spending_rank
FROM patient_spending
ORDER BY spending_rank;