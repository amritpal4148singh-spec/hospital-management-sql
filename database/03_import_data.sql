USE hospital_management;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/departments.csv'
INTO TABLE departments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/doctors.csv'
INTO TABLE doctors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/patients.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/rooms.csv'
INTO TABLE rooms
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/medicines.csv'
INTO TABLE medicines
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/appointments.csv'
INTO TABLE appointments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/admissions.csv'
INTO TABLE admissions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/prescriptions.csv'
INTO TABLE prescriptions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/prescription_items.csv'
INTO TABLE prescription_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/bills.csv'
INTO TABLE bills
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/amrit/Downloads/hospital_management_dataset/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
