-- ============================================
-- Section E:  COUNT
-- Name: Benjamin Ochieng
-- Date: [20-07-2026]
-- ============================================

select * from greenwood_academy.exam_results;
select * from greenwood_academy.students s;
select * from greenwood_academy.subjects s; 

--Q27. How many students are currently in Form 3? Write the query.
select 
count(student_id) as No_of_form_3
from greenwood_academy.students s 
where s."class" ='Form 3';

/*Key Concept: GROUP BY determines the granularity of your output.
Grouping by class combines all matching students into a single group, returning one summary row with the grand total.
Grouping by student_id keeps each student separate, returning multiple rows (a complete list) where the count is always 1 per individual.
*/

--Q28. How many exam results have a mark of 70 or above? Write the query.
select 
count(*) as Total_Grade_B
from greenwood_academy.exam_results er 
where er.marks >= 70;