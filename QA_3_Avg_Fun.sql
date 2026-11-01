/*SQL Interview Series*/
------------------------
-- 1. SQL AVG() – NULL vs STRING?
create table tblStudent(
Marks int
)

Insert into tblStudent(Marks) Values(100)
Insert into tblStudent(Marks) Values(200)
Insert into tblStudent(Marks) Values(null)
Insert into tblStudent(Marks) Values('')

select * from tblStudent;

select Avg(Marks) as "Avg_marks" from tblStudent;

