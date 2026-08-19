-- ============================================
-- Section F: CASE WHEN
-- Name: Benjamin Ochieng
-- Date: [20-07-2026]
-- ============================================


--SECTION F - CASE WHEN
/*Q29. Write a query using CASE WHEN to label each exam result with a grade description:
•	'Distinction' if marks >= 80
•	'Merit' if marks >= 60
•	'Pass' if marks >= 40
•	'Fail' if marks below 40
New column: performance.
*/
select
er.result_id,
er.marks,
case 
	when er.marks>=80 then 'Distinction'
	when er.marks>=60 then 'Merit'
	when er.marks>=40 then 'Pass'
	else 'Fail'
end as performace
from greenwood_academy.exam_results er;

/*Q30. Write a query using CASE WHEN to label each student as:
•	'Senior' if they are in Form 3 or Form 4
•	'Junior' if they are in Form 2 or Form 1
Call the new column student_level. Show the student's first name, last name, class, and student_level in your result.
*/
select
first_name,
last_name,
class,
case
	when class = 'Form 3' or class = 'Form 4' then 'Senior'
	when class = 'Form 2' or class = 'Form 1' then 'Junior'
end as stedent_level
from greenwood_academy.students s ;
