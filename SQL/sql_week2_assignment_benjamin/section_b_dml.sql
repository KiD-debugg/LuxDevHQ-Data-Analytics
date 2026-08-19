-- ============================================
-- Section B: Filling the Database (DML: INSERT, UPDATE, DELETE)
-- Name: Benjamin Ochieng
-- Date: [20-07-2026]
-- ============================================


--Q8. Insert all 10 students into the students table 
insert into greenwood_academy.students (student_id, first_name, last_name,gender,date_of_birth, class, city )
values
(1,	'Amina', 'Wanjiku'	,'F'	,'2008-03-12',	'Form 3',	'Nairobi'),
(2,	'Brian', 'Ochieng'	,'M'	,'2007-07-25'	,'Form 4'	,'Mombasa'),
(3,	'Cynthia', 'Mutua',	'F',	'2008-11-05',	'Form 3',	'Kisumu'),
(4	,'David', 'Kamau'	,'M'	,'2007-02-18',	'Form 4',	'Nairobi'),
(5	,'Esther', 'Akinyi',	'F',	'2009-06-30',	'Form 2',	'Nakuru'),
(6	,'Felix', 'Otieno'	,'M'	,'2009-09-14',	'Form 2'	,'Eldoret'),
(7,	'Grace', 'Mwangi',	'F',	'2008-01-22',	'Form 3',	'Nairobi'),
(8,	'Hassan','Abdi', 'M','2007-04-09'	,'Form 4'	,'Mombasa'),
(9	,'Ivy', 'Chebet'	,'F'	,'2009-12-01'	,'Form 2',	'Nakuru'),
(10	,'James', 'Kariuki',	'M',	'2008-08-17',	'Form 3',	'Nairobi');


--Q9. Insert all 10 subjects into the subjects table 
insert into greenwood_academy.subjects (subject_id, subject_name , department, teacher_name, credit_hours)
values
(1,	'Mathematics',	'Sciences',	'Mr. Njoroge'	,4),
(2,	'English',	'Languages',	'Ms. Adhiambo'	,3),
(3,	'Biology',	'Sciences',	'Ms. Otieno'	,4),
(4,	'History',	'Humanities',	'Mr. Waweru'	,3),
(5,	'Kiswahili', 'Languages',	'Ms. Nduta'	,3),
(6,	'Physics', 'Sciences',	'Mr. Kamande'	,4),
(7,	'Geography', 'Humanities',	'Ms. Chebet'	,3),
(8,	'Chemistry', 'Sciences',	'Ms. Muthoni'	,4),
(9,	'Computer Studies',	'Sciences',	'Mr. Oduya'	,3),
(10,'Business Studies',	'Humanities',	'Ms. Wangari'	,3);



--Q10. Insert all 10 exam results into the exam_results table 
insert into greenwood_academy.exam_results (result_id,student_id,subject_id,marks,exam_date,grade)
values
(1,	1,	1,	78,	'2024-03-15',	'B'),
(2,	1,	2,	85,	'2024-03-16',	'A'),
(3,	2,	1,	92,	'2024-03-15',	'A'),
(4,	2,	3,	55,	'2024-03-17',	'C'),
(5,	3,	2,	49,	'2024-03-16',	'D'),
(6,	3,	4,	71,	'2024-03-18',	'B'),
(7,	4,	1,	88,	'2024-03-15',	'A'),
(8,	4,	6,	63,	'2024-03-19',	'C'),
(9,	5,	5,	39,	'2024-03-20',	'F'),
(10,	6,	9,	95,	'2024-03-21','A');




--Q11. After inserting the data, run a SELECT query to confirm all 10 rows exist in each of the three tables.
select * from greenwood_academy.exam_results;
select * from greenwood_academy.students s;
select * from greenwood_academy.subjects s; 


--Q12. Esther Akinyi has moved from Nakuru to Nairobi. 
--Write an UPDATE statement to change her city. (Her student_id is 5)
update greenwood_academy.students s 
set city ='Nakuru'
where s.student_id = 5;


--Q13. The marks for result_id 5 were entered incorrectly - the correct marks are 59, not 49. 
--Write an UPDATE to fix this.
update greenwood_academy.exam_results er 
set marks = 59
where er.result_id = 5;


--Q14. The exam result with result_id 9 has been cancelled by the school. 
--Write a DELETE statement to remove it from the exam_results table.
delete from greenwood_academy.exam_results 
where result_id = 9;
