-- created Table for student employees
drop table admin;

create table admin
(
SUID numeric primary key,
password varchar(20) not null
)

select *from admin;

drop table student_employees;
create table student_employees
(
   Student_id numeric not null foreign key references admin(SUID),
   student_name varchar(50) not null,
   student_phone int not null,
   student_address varchar(100) not null,
   student_gender char not null,
   student_email varchar(20) unique not null,
   citizenship Varchar(20) not null,
   student_workplace_id numeric not null foreign key references workplace(workplace_id),
   student_employment_id varchar not null foreign key references Employment_type(employment_id)
   )

  select * from student_employees;

  drop table Employment_type
  Create table Employment_type
  (
  employment_id varchar Primary key,
  role_of_employee varchar(50) not null ,
  pay_per_hour numeric not null
  )
  select * from Employment_type

  drop table workplace;
   create table Workplace
(
Workplace_id numeric Primary key,
Name_of_Place Varchar(100) not null,
Phone_no int not null,
Manager_Name Varchar(100) not null,
)

select * from Workplace;

drop table shifts;
create table shifts
(Shift_id numeric primary key,
Stime time not null,
Etime time not null,
Shift_day varchar(20) not null,
shift_workplace_id numeric not null foreign key references workplace(workplace_id),
shift_availability char not null
)

select * from shifts;

drop table payroll;
create table payroll
(payment_id numeric primary key,
method_details varchar(50) not null,
payment_student_id numeric not null foreign key references admin(SUID),
total_pay numeric not null
)
select * from payroll;

---Student shifts
drop table student_shifts;
create table student_shifts
(
netid varchar,
student_shift_id numeric not null foreign key references shifts(Shift_id)
); 


--Stored procedure for login
drop procedure login_proc
create procedure login_proc
@Username varchar(20),
@Password varchar(20),
@Role varchar(25) OUTPUT
AS
   SET NOCOUNT ON
BEGIN

    If Not Exists (Select 1 From admin Where netid = @UserName) Set @Role = 'Incorrect UserName'
    Else If Not Exists (Select 1 From admin Where passwords = @Password) Set @Role = 'Incorrect Password'
    Else Set @Role = 'Logged in Successfully' 

    Select @Role

	END
	select * from shifts


	--procedure for employee_limit
	drop procedure employee_limit
	create procedure employee_limit
	@count int output
	as
	SET NOCOUNT ON
BEGIN
            declare @limit int='10'
	begin try
	set @count=(select sum(DATEDIFF(HOUR,stime,etime)) as total_time from shifts join Workplace
	on  shifts.shift_workplace_id=Workplace.Workplace_id join student_employees
	on shifts.shift_id=student_employees.student_shift_id where shift_availability='Y' 
	group by student_employees.Student_id) ;
	end try
	begin catch

	If @count<@limit
	update student_employees
	set student_shift_id=shifts.Shift_id from shifts 
	where student_employees.student_shift_id=shifts.Shift_id
	else
	ROLLBACK TRANSACTION
        SELECT ERROR_NUMBER(), ERROR_MESSAGE();
   END CATCH
	end
	--function to calculate the payroll of an employee
	drop function total_pay_func
	create function total_pay_func
	(@ret numeric)
	returns numeric   
AS   
-- Returns the total pay of a student employee  
BEGIN   
    SELECT @ret = e.pay_per_hour *p.total_pay
	from Employment_type e join payroll p on
	e.employment_id=p.payment_student_id; 
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END 
