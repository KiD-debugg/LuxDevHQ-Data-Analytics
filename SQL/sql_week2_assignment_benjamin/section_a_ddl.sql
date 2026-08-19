-- ============================================
-- Section A: Building the Database
-- Name: Benjamin Ochieng
-- Date: [20-07-2026]
-- ============================================


--Q1. Create a schema called greenwood_academy and make sure SQL is using it before you do anything else.
create schema if not exists greenwood_academy;


--Q2. Create the students table
create table greenwood_academy.students(
student_id INT primary key,
first_name VARCHAR(50)	not null,
last_name VARCHAR(50) not null,
gender VARCHAR(1),
date_of_birth DATE,
class VARCHAR(10),
city VARCHAR(50));


--Q3. Create the subjects table 
create table greenwood_academy.subjects (
subject_id int primary key,
subject_name varchar(100) not null unique,
department varchar,
teacher_name varchar(100),
credits int);


--Q4. Create the exam_results
create table greenwood_academy.exam_results(
result_id int not null,
student_id int not null,
subject_id int not null,
marks int not null,
exam_date date,
grade VARCHAR(2));


--Q5. After creating the students table, the school realises they forgot to include a phone number column. 
--Use ALTER TABLE to add a column called phone_number with data type VARCHAR(20).
alter table greenwood_academy.students 
add phone_number VARCHAR(20);


--Q6. The column credits in the subjects table needs to be renamed to credit_hours. 
--Write the SQL to rename it.
alter table greenwood_academy.subjects
rename column credits to credit_hours;


--Q7. The school decides they no longer need the phone_number column you added in Q5. 
--Write the SQL to remove it completely from the students table.
alter table greenwood_academy.students
drop column phone_number;
