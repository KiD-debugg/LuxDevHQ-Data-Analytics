-- ============================================================
-- Afya Bora Clinic: sample data for CASE WHEN extra practice
-- ============================================================

CREATE SCHEMA IF NOT EXISTS clinic;
SET search_path TO clinic;

DROP TABLE IF EXISTS afya_appointments;
DROP TABLE IF EXISTS afya_patients;
DROP TABLE IF EXISTS afya_doctors;

-- ---------------------------
-- afya_patients
-- ---------------------------
CREATE TABLE clinic.afya_patients (
    patient_id   INT PRIMARY KEY,
    name         VARCHAR(50),
    age          INT,
    bill_amount  DECIMAL(10,2)
);

INSERT INTO clinic.afya_patients (patient_id, name, age, bill_amount) VALUES
(1,  'Amina Hassan',   8,  1200.00),
(2,  'James Otieno',   34, 3500.00),
(3,  'Grace Wanjiru',  67, 5200.00),
(4,  'Peter Kamau',    45, 2100.00),
(5,  'Faith Nyambura', 5,  800.00),
(6,  'David Mwangi',   72, 6800.00),
(7,  'Mary Akinyi',    29, 1500.00),
(8,  'Samuel Kiprop',  55, 4200.00),
(9,  'Ruth Chebet',    16, 900.00),
(10, 'John Mutua',     81, 7500.00),
(11, 'Linda Wambui',   38, 2800.00);

-- ---------------------------
-- afya_doctors
-- ---------------------------
CREATE TABLE clinic.afya_doctors (
    doctor_id  INT PRIMARY KEY,
    name       VARCHAR(50),
    specialty  VARCHAR(50)
);

INSERT INTO clinic.afya_doctors (doctor_id, name, specialty) VALUES
(1, 'Dr. Kimani',  'Pediatrics'),
(2, 'Dr. Achieng', 'Cardiology'),
(3, 'Dr. Njoroge', 'General Medicine'),
(4, 'Dr. Wafula',  'Orthopedics'),
(5, 'Dr. Cherop',  'Dermatology'),
(6, 'Dr. Otieno',  'Neurology');

-- ---------------------------
-- afya_appointments
-- ---------------------------
CREATE TABLE clinic.afya_appointments (
    appointment_id  INT PRIMARY KEY,
    patient_id      INT,
    doctor_id       INT,
    status          VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES afya_patients(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES afya_doctors(doctor_id)
);

INSERT INTO clinic.afya_appointments (appointment_id, patient_id, doctor_id, status) VALUES
(1,  1,  1, 'Completed'),
(2,  2,  2, 'Completed'),
(3,  2,  3, 'Completed'),
(4,  3,  2, 'Completed'),
(5,  4,  3, 'Cancelled'),
(6,  4,  4, 'Completed'),
(7,  4,  3, 'Completed'),
(8,  7,  5, 'Completed'),
(9,  8,  2, 'Completed'),
(10, 11, 3, 'Pending');

-- ---------------------------
-- Quick sanity check
-- ---------------------------

SELECT * FROM clinic.afya_patients;
SELECT * FROM clinic.afya_doctors;
SELECT * FROM clinic.afya_appointments;


--Searched CASE - Minor or Adult
--Label every patient 'Minor' (under 18) or 'Adult' (18 and above).
select 
name,
age,
case 
	when age < 18 then 'Minor'
	else 'Adult'
end as adulthood
from clinic.afya_patients
order by age;

--. Searched CASE - Age Bracket
--Label every patient's age as 'Child' (under 12), 'Teen' (12–19), 'Adult' (20–59), or 'Senior' (60+).
select 
name,
age,
case 
	when age <12 then 'Child'
	when age between 12 and 19 then 'Teen'
	when age between 20 and 59 then 'Adult'
	else 'Senior'
end as age_bracket
from clinic.afya_patients
order by age;

--Searched CASE - Bill Tier
--Label every patient's bill_amount as 'Affordable' (under 2000), 'Standard' (2000–5000), or 'Expensive' (over 5000).
select 	
name,
age,
bill_amount,
case 
	when bill_amount < 2000 then 'Affordable'
	when bill_amount between 2000 and 5000 then 'Standard'
	else 'Expensive'
end as bill_bracket
from clinic.afya_patients ap
order by ap.bill_amount;

--Simple CASE - Department Code
--Give each doctor a short department code from their specialty - e.g. Pediatrics → 'PED', Cardiology → 'CARD' (pick your own codes for the rest).
select 
name,
specialty,
case specialty
	when 'Pediatrics' then 'PED'
	when 'Cardiology' then 'CARD'
	when 'General Medicine' then 'GM'
	when 'Orthopedics' then 'OP'
	when 'Dermatology' then 'DERMA'
	when 'Neurology' then 'NEU'
end
from clinic.afya_doctors
order by specialty 

--Order-of-WHEN Bug
--Below is a broken query. Predict what it will output for all 11 patients before running it - then explain, in one sentence, why it's wrong.
-- WRONG — predict the output first
/*SELECT patient_name, bill_amount,
CASE
  WHEN bill_amount > 1000 THEN 'Not Affordable'
  WHEN bill_amount < 2000 THEN 'Affordable'
  ELSE 'Expensive'
END AS wrong_tier
FROM afya_patients
ORDER BY bill_amount;

Errors:
1. The column name patient_name does not exist. 
2. If that will be resolved:
Amina Hassan - Not Affordable
James Otieno - Not Affordable
Grace Wanjiru - Not Affordable
Peter Kamau - Not Affordable
Faith Nyambura - Affordable
David Mwangi - Not Affordable
Mary Akinyi - Not Affordable
Samuel Kiprop - Not Affordable
Ruth Chebet - Affordable
John Mutua - Not Affordable
Linda Wambui - Not Affordable

the code is wrong becasuse of the logical error:
the code basically outputs anything below 2000 will be 'Affordable', even the ones below 1000 and anything above 1000 will be 'Not Affordable' even the ones above 2000. 
Then the ones ranging between 1000 and 2000 will be categorized as 'Not affordable'. 
*/
SELECT name, bill_amount,
CASE
  WHEN bill_amount < 1000 THEN 'Affordable'
  WHEN bill_amount between 1000 and 2000 THEN 'Standard'
  ELSE 'Expensive'
END AS cash_tier
FROM clinic.afya_patients
ORDER BY bill_amount;


/*Conditional Counting - Age Groups
Using SUM(CASE...), count how many patients fall into each age bracket from Exercise 2 - Child, Teen, Adult, Senior - all in one row.
*/
select
sum(case when age <12 then 1 else 0 end) as Child,
sum(case when age between 12 and 19 then 1 else 0 end) as Teen,
sum(case when age between 20 and 59 then 1 else 0 end) as Adult,
sum(case when age >=60 then 1 else 0 end) as Senior
from clinic.afya_patients ap;

/*Conditional Counting - Appointment Status
Using SUM(CASE...), count how many appointments are 'Completed', 'Cancelled', and 'Pending' - all in one row.
*/
select 
sum(case when status = 'Completed' then 1 else 0 end) as Completed,
sum(case when status = 'Pending' then 1 else 0 end) as Pending,
sum(case when status = 'Cancelled' then 1 else 0 end) as Cancelled
from clinic.afya_appointments;

/*. CASE + LEFT JOIN + GROUP BY - Patient Visit Tier
For every patient, count their total appointments (LEFT JOIN so patients with zero appointments still show up), then label them
0 appointments  	-> 'New Patient'
1-2 appointments	-> 'Regular'
3+ appointments 	-> 'Frequent'
*/
select
ap.patient_id,
ap.name, 
ap.bill_amount,
--count(ap.patient_id) as tots,
case 
	when count(app.appointment_id) = 0 then 'New Patient'
	when count(app.appointment_id) between 1 and 2 then 'Regular'
	else 'Frequent'
end as patient_tier
from  clinic.afya_patients ap 
left join clinic.afya_appointments app on ap.patient_id = app.patient_id 
group by ap.patient_id ;

SELECT * FROM clinic.afya_patients;
SELECT * FROM clinic.afya_doctors;
SELECT * FROM clinic.afya_appointments;
