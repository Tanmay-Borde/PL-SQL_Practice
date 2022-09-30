-- FUNCTIONS AND STORED PROCEDURES
/*
- Reusability is important
- Difference betn anonymous blocks and sub-programs(functions & procedures):
    - Stored in the DB with names.
    - Compiled only once.
    - can be called by another block or application.
    - Functions can return values, but proedure cannot.
    - can take parameters.
    - Can be given access privilege.
*/

-----------------An anonymous block example
declare
    cursor c_emps is select * from employees_copy for update;
    v_salary_increase number:= 1.10;
    v_old_salary number;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary*v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
end;
-----------------An anonymous block example 2 
declare
    cursor c_emps is select * from employees_copy for update;
    v_salary_increase number:= 1.10;
    v_old_salary number;
    v_new_salary number;
    v_salary_max_limit pls_integer := 20000;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      --check salary area
      v_new_salary := r_emp.salary*v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      if v_new_salary > v_salary_max_limit then
       RAISE_APPLICATION_ERROR(-20000, 'The new salary of '||r_emp.first_name|| ' cannot be higher than '|| v_salary_max_limit);
      end if;
      r_emp.salary := r_emp.salary*v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      ----------
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
end;


-- Creating & using stored procedures:
/*
- CREATE [OR REPLACE] PROCEDURE procudere_name
    [(parameter_name[IN | OUT | IN OUT] type [, ...]{IS | AS})]
    .... --declarative section
begin
    ....
exception
    ....
end;
*/

create procedure increase_salaries AS
    cursor c_emps is select * from employees_copy for update;
    v_salary_increase pls_integer := 1.10;
    v_old_salary pls_integer;
begin
    for r_emp  in c_emps loop
    v_old_salary := r_emp.salary;
    r_emp.salary := r_emp.salary*v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct, 0);
    update employees_copy set row = r_emp where current of c_emps;
    dbms_output.put_line('The salary of: '||r_emp.employee_id||' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
end;
execute increase_salaries;

begin
    dbms_output.put_line('Increasing the salaries...');
    increase_salaries;
    new_line;
    increase_salaries;
    new_line;
    increase_salaries;
    new_line;
    increase_salaries;
    new_line;
    dbms_output.put_line('all the salaries are successfully increased....!');
end;

create procedure new_line as
begin
    dbms_output.put_line('----------------------------------');
end;



----------------- Creating a procedure
create procedure increase_salaries as
    cursor c_emps is select * from employees_copy for update;
    v_salary_increase number := 1.10;
    v_old_salary number;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary * v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
end;
----------------- Multiple procedure usage
begin
  dbms_output.put_line('Increasing the salaries!...');
  INCREASE_SALARIES;
  INCREASE_SALARIES;
  INCREASE_SALARIES;
  INCREASE_SALARIES;
  dbms_output.put_line('All the salaries are successfully increased!...');
end;
----------------- Different procedures in one block
begin
  dbms_output.put_line('Increasing the salaries!...');
  INCREASE_SALARIES;
  new_line;
  INCREASE_SALARIES;
  new_line;
  INCREASE_SALARIES;
  new_line;
  INCREASE_SALARIES;
  dbms_output.put_line('All the salaries are successfully increased!...');
end;
-----------------Creating a procedure to ease the dbms_output.put_line procedure 
create procedure new_line as
begin
  dbms_output.put_line('------------------------------------------');
end;
-----------------Modifying the procedure with using the OR REPLACE command.
create or replace procedure increase_salaries as
    cursor c_emps is select * from employees_copy for update;
    v_salary_increase number := 1.10;
    v_old_salary number;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary * v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
    dbms_output.put_line('Procedure finished executing!');
end

-- Using IN & OUT parameters
/*
- Creating the procedures and functions with parameters
- IN    : means passign the value into the procedure. (default)
- OUT   : means a value will be returned to the caller after the procedure is executed.
- IN OUT: caller will both send and get value of the parameter.
- Syntax:
    CREATE [OR REPLACE] PROCEDURE procedure_name
    [(parameter_name [IN | OUT | IN OUT] type[, ...])] {IS | AS}
        .... --declarative section
    begin
        ....
    exception
        ....
    end;
*/

create procedure increase_salaries(v_salary_increase in number, v_department_id pls_integer) as
    cursor c_emps is select * from employees_copy for update;
    -- v_salary_increase number := 1.10;
    v_old_salary number;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary * v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
end;

begin
    increase_salaries(1.2, 60);
end;

create or replace print(text in varchar2) is
begin
    dbms_output.put_line(text);
end;

begin
    print('Testing print procedure...');
end;

-----------------Creating a procedure with the IN parameters
create or replace procedure increase_salaries (v_salary_increase in number, v_department_id pls_integer) as
    cursor c_emps is select * from employees_copy where department_id = v_department_id for update;
    v_old_salary number;
begin
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary * v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
    end loop;
    dbms_output.put_line('Procedure finished executing!');
end;

--Testing
begin
    increase_salaries
end;

exec increase_salaries;

----------------- Creating a procedure with the OUT parameters
create or replace procedure increase_salaries 
    (v_salary_increase in out number, v_department_id pls_integer, v_affected_employee_count out number) as
    cursor c_emps is select * from employees_copy where department_id = v_department_id for update;
    v_old_salary number;
    v_sal_inc number := 0;
begin
    v_affected_employee_count := 0;
    for r_emp in c_emps loop
      v_old_salary := r_emp.salary;
      r_emp.salary := r_emp.salary * v_salary_increase + r_emp.salary * nvl(r_emp.commission_pct,0);
      update employees_copy set row = r_emp where current of c_emps;
      dbms_output.put_line('The salary of : '|| r_emp.employee_id 
                            || ' is increased from '||v_old_salary||' to '||r_emp.salary);
      v_affected_employee_count := v_affected_employee_count + 1;
      v_sal_inc := v_sal_inc + v_salary_increase + nvl(r_emp.commission_pct,0);
    end loop;
    v_salary_increase := v_sal_inc / v_affected_employee_count;
    dbms_output.put_line('Procedure finished executing!');
end;
-----------------Another example of creating a procedure with the IN parameter 
CREATE OR REPLACE PROCEDURE PRINT(TEXT IN VARCHAR2) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(TEXT);
END;
-----------------Using the procedures that has the IN parameters 
begin
 PRINT('SALARY INCREASE STARTED!..');
 INCREASE_SALARIES(1.15,90);
 PRINT('SALARY INCREASE FINISHED!..');
end;
-----------------Using the procedure that has OUT parameters 
declare
  v_sal_inc number := 1.2;
  v_aff_emp_count number;
begin
 PRINT('SALARY INCREASE STARTED!..');
 INCREASE_SALARIES(v_sal_inc,80,v_aff_emp_count);
 PRINT('The affected employee count is : '|| v_aff_emp_count);
 PRINT('The average salary increase is : '|| v_sal_inc || ' percent!..');
 PRINT('SALARY INCREASE FINISHED!..');
end;

-- NAMED - MIXED NOTATIONS & DEFAULT OPTION
/*
- Skipping an IN parameter is accepatble, but there has to be some default value for 'OUT' or 'IN OUT'.
- Named notation allows to pass parameter independent from he position. Here parameter names in eclaration and call should be identical.
- If the parameter call has both position parameter and named parameter then it is called mixed notations.
- Named notations should be mentioned at the end.
- Syntax:
    create [or replace] procedure procedure_name
        [(parameter_name [IN | OUT | IN OUT] type (DEFAULT | := ) value | expression [, ...])] {IS | AS}
*/


create or replace procedure print (text in varchar2 default 'Default String') is
begin
    dbms_output.put_line(text);
end;
exec print();
exec print(null);   -- no output

-- NOTE: JOBS table need to be created

----------------- A standard procedure creation with a default value
create or replace PROCEDURE PRINT(TEXT IN VARCHAR2 := 'This is the print function!.') IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(TEXT);
END;
-----------------Executing a procedure without any parameter. It runs because it has a default value.
exec print();
-----------------Running a procedure with null value will not use the default value 
exec print(null);
-----------------Procedure creation of a default value usage
create or replace procedure add_job(job_id pls_integer, job_title varchar2, 
                                    min_salary number default 1000, max_salary number default null) is
begin
  insert into jobs values (job_id,job_title,min_salary,max_salary);
  print('The job : '|| job_title || ' is inserted!..');
end;
-----------------A standard run of the procedure
exec ADD_JOB('IT_DIR','IT Director',5000,20000); 
-----------------Running a procedure with using the default values
exec ADD_JOB('IT_DIR2','IT Director',5000); 
-----------------Running a procedure with the named notation
exec ADD_JOB('IT_DIR5','IT Director',max_salary=>10000); 
-----------------Running a procedure with the named notation example 2
exec ADD_JOB(job_title=>'IT Director',job_id=>'IT_DIR7',max_salary=>10000 , min_salary=>500);

-- FUNCTIONS
/*
- Functions are like procedures but only with mandatory return value.
- Functions MUST return a value.
- Functions can get IN and OUT parameters.
- Function can be used within a select statement.
- Function cna be assigned to a variable.
- Syntax:
    - CREATE [OR REPLACE] FUNCTION function_name
    [(parameter_name [IN | OUT | IN OUT] type DEFAULT value|expression [, ...]) RETURN return_data_type {IS | AS}]

    - drop function function_name;
- Recommended: to return multiple values, return a record and avoid using OUT.
- Functions are used within an SQL Query or assigned to some variable. But procedures are executed within a begin-end or execute cmd.
- Procedure cannot return a value without OUT, but functions always return a value.
- Limitations of using functions in SQL Expression:
    - Function must be compiled and stored in the DB.
    - Functions should not have an OUT parameter.
    - Must return a valid type of SQL data types only, records or collections are not allowed inside SQL expression.
    - Cannot be used in check clause of table creation or alteration.
    - cannot call a function that contains a DML statement.
    - cannot include commit, rollback or DDL statements.
    - if the function has a DML operation of the specified table.
    - need to have the related privilege.
*/

CREATE OR REPLACE FUNCTION get_avg_sal (p_dept_id departments.department_id%type) RETURN number AS 
v_avg_sal number;
BEGIN
  select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
  RETURN v_avg_sal;
END get_avg_sal;

----------------- using a function in begin-end block
declare
  v_avg_salary number;
begin
  v_avg_salary := get_avg_sal(50);
  dbms_output.put_line(v_avg_salary);
end;
----------------- using functions in a select clause
select employee_id,first_name,salary,department_id,get_avg_sal(department_id) avg_sal from employees_copy;
----------------- using functions in group by, order by, where clauses 
select get_avg_sal(department_id) from employees_copy
where salary > get_avg_sal(department_id)
group by get_avg_sal(department_id) 
order by get_avg_sal(department_id);
----------------- dropping a function
drop function get_avg_sal;


-- LOCAL SUBPROGRAMS
/*
- The stored procedures and functions are created in the DB / schema level which sometuimes is unnecessary, especially for one time use.
- We can create subprograms inside of an anonymous blocks or in another subprogram.
- Pros of local subprograms:
    - Reduce code repetition
    - Improve code readability
    - Need no more prvilege
- Cons of local subprograms:
    - The are accessible only in the blocks they are defined.
- We need to write the local subprogam in the declare area.
- Local subprograms should be written last in the declaration area.
*/

----------------- creating and using subprograms in anonymous blocks - false usage
create emps_high_paid as select * from employees_copy where 1 = 2;

declare
    procedure insert_high_paid_emp(emp_id employees_copy.employee_id%type) is emp  employees_copy%rowtype;
    begin
        emp := get_emp(emp_id);
        insert into emps_high_paid values emp;
    end;
    function get_emp(emp_num employees_copy.employee_id%type) return employees_copy%rowtype is emp employees_copy%rowtype;
    begin
        select * into emp from employees_copy where employee_id = emp_num;
        return emp;
    end;
begin
    for r_emp in (select * from employees_copy) loop
        if r_emp.salary > 15000 then
                insert_high_paid_emp(r_emp.employee_id);
        end if;
    end loop;
end;

----------------- creating and using subprograms in anonymous blocks - true usage
declare
  function get_emp(emp_num employees.employee_id%type) return employees%rowtype is
    emp employees%rowtype;
    begin
      select * into emp from employees where employee_id = emp_num;
      return emp;
    end;
  procedure insert_high_paid_emp(emp_id employees.employee_id%type) is 
    emp employees%rowtype;
    begin
      emp := get_emp(emp_id);
      insert into emps_high_paid values emp;
    end;
begin
  for r_emp in (select * from employees) loop
    if r_emp.salary > 15000 then
      insert_high_paid_emp(r_emp.employee_id);
    end if;
  end loop;
end;
----------------- The scope of emp record
declare
  procedure insert_high_paid_emp(emp_id employees.employee_id%type) is 
    emp employees%rowtype;
    e_id number;
    function get_emp(emp_num employees.employee_id%type) return employees%rowtype is
      begin
        select * into emp from employees where employee_id = emp_num;
        return emp;
      end;
    begin
      emp := get_emp(emp_id);
      insert into emps_high_paid values emp;
    end;
begin
  for r_emp in (select * from employees) loop
    if r_emp.salary > 15000 then
      insert_high_paid_emp(r_emp.employee_id);
    end if;
  end loop;
end;

-- OVERLOADING THE SUBPROGRAMS
/*
- Overoading means creating more than one subprogram with the same name.
- Overload the subprograms with same name but with different parameters.
- Overloading is pretty useful when using subprograms with packages.
- Overloading the subprograms:
    - Enables creating two or more subprograms with the same name.
    - We can build more flexible subprograms.
    - We can overload local subprograms and package subprograms, but not standalone subprograms.
    - Parameters must be different in data types or orders or numbers.
    - will not work if parameters are in the same fmily or subtype.
    - will not work if differentiating only the return type.
*/

declare
  procedure insert_high_paid_emp(p_emp employees_copy%rowtype) is emp employees_copy%rowtype;
    e_id number;
    function get_emp(emp_num employees_copy.employee_id%type) return employees_copy%rowtype is
      begin
        select * into emp from employees_copy where employee_id = emp_num;
        return emp;
      end
    
    function get_emp(emp_last_name employees_copy.last_name%type) return employees_copy%rowtype is
      begin
        select * into emp from employees_copy where last_name = emp_last_name;
        return emp;
      end;
    begin
      emp := get_emp(p_emp.employee_id);
      insert into emps_high_paid values emp;
    end;
  
  begin
    for r_emp in (select * from employees_copy) loop
      if r_emp.salary > 15000 then
        insert_high_paid_emp(r_emp);
      end if;
    end loop;
  end;
end;

select * from emps_high_paid;
truncate table emps_high_paid;


----------------- overloading with multiple usages
declare
  procedure insert_high_paid_emp(p_emp employees_copy%rowtype) is 
    emp employees_copy%rowtype;
    e_id number;
    function get_emp(emp_num employees_copy.employee_id%type) return employees_copy%rowtype is
      begin
        select * into emp from employees_copy where employee_id = emp_num;
        return emp;
      end;
--    function get_emp(emp_email employees_copy.email%type) return employees_copy%rowtype is
--      begin
--        select * into emp from employees_copy where email = emp_email;
--        return emp;
--      end;
    function get_emp(f_name varchar2, l_name varchar2) return employees_copy%rowtype is
      begin
        select * into emp from employees_copy where first_name = f_name and last_name = l_name;
        return emp;
      end;
    begin
      emp := get_emp(p_emp.employee_id);
      insert into emps_high_paid values emp;
--      emp := get_emp(p_emp.email);
--      insert into emps_high_paid values emp;
      emp := get_emp(p_emp.first_name,p_emp.last_name);
      insert into emps_high_paid values emp;
    end;
begin
  for r_emp in (select * from employees_copy) loop
    if r_emp.salary > 15000 then
      insert_high_paid_emp(r_emp);
    end if;
  end loop;
end;

-- Handling The Exceptions in Subprograms
/*
- We can have an exception section in all begin-end blocks.
- When an exception is raised, the control is passed to the exception section.
- If exceptions are not handled in the procedure or function, it will cause error in the caller sub program.
- You should handle all possible excepitons at the source.
*/

-- Function declaration
create or replace function get_emp(emp_num employees_copy.employee_id%type) return employees_copy%rowtype is
  emp employees_copy%rowtype;
  begin
    select * into emp from employees_copy where employee_id = emp_num;
    return emp;

exception
  when no_data_found then
    print('There is no employee whiyth the ID : '||emp_num);
    return null;
  when others then
    print('Something unexpectedly went wrong....');
    return null;
end;

-- Anonymous Block to call the function
declare
  v_emp employees_copy%rowtype;
begin
  dbms_output.put_line('Fetching the employee Data....');
  v_emp := get_emp(110);
  dbms_output.put_line('Some of the info of the employee are: ');
  dbms_output.put_line('The name of the employee is : '||v_emp.first_name);
  dbms_output.put_line('The name of the employee is : '||v_emp.last_name);
  dbms_output.put_line('The name of the employee is : '||v_emp.salary);
end;

-- Anonymous Block to call the function with exception
declare
  v_emp employees_copy%rowtype;
begin
  print('Fetching Employee Data....');
  v_emp := get_emp(10);
  print('First Name : '||v_emp.first_name)
  print('Last Name : '||v_emp.last_name)
  print('Salary : '||v_emp.salary)
end;

-- Filtering functions and procedures in SQL Developer for debugging
/*
- Right Click on the 'Functions' or 'procedures' tab and click on 'apply filter'
  OR
- query the user_source and find them:
  select * from user_source where name = 'GET_EMP';
- To drop the function or procedure
  drop function/procedure <function_name>;
- Dropping a function/procedure/sub-program will also remove the privileges of the sub-program. So using create or replace is advisable instead of dropping.
*/

-- REGULAR & PIPELINED TABLE FUNCTIONS
/*
- If you create a function that returns a collection of data/rows, then its called a table function.
- Table functions return a table of varray or nested tables.
- Regular table functions creates entire table in the memory and returns after fetching is completed. This can fill the PGA when data is huge.
- Pipelined functions return each row one by one. This minimizes the memory usage and returns the data faster.
- So when the data which needs to be fetched is too big, we can use pipelined table function for faster performance and memory efficiency.
- Especially for datawarehousing ETL Operations.
- A function which returns a collection of data is also called a table function.
*/

create type t_days as object(
  v_date date,
  v_date_number int
);

-- CREATING A NESTED TABLE TYPE
create type t_days_tab is table of t_days;

desc t_days;
desc t_days_tab;


-- CREATING A REGULAR TABLE FUNCTION
create or replace function f_get_days(p_start_date DATE, p_day_number INT)
  return t_days_tab IS v_days t_days_tab := t_days_tab();
  begin
    for i in 1..p_day_number loop
      v_days.extend();
      v_days(i) := t_days(p_start_date + i, to_number(to_char(p_start_date + i, 'DDD')));
    end loop;
    return v_days;
end;

-- Quering from a regular table function
select * from table(f_get_days(sysdate,1000000));

-- Querying from the regular table function without the table operator
select * from f_get_days(sysdate, 1000000);

-- creating a pipelined table function
create or replace function f_get_days_piped(p_start_date date, p_day_number int)
  return t_days_tab PIPELINED is
  begin
    for i in 1..p_day_number loop
      PIPE ROW(t_days(p_start_date + i, to_number(to_char(p_start_date + i, 'DDD'))));
  end loop;
  RETURN;
end;

select * from f_get_days_piped(sysdate, 1000000);