-- PACKAGES --
/*
- Most of the times all the objects (like fucntions, procedures, types stc.) work together for a particular schema.
- This makes an object crowd in a real work in time, and it becomes hard to maintain.
- Package is grouping all the subprograms, functions, procedures, types, variables, constants, exceptions, cursors and pragmas etc in one container.
- One more important reason for using package is "PERFORMANCE":
    - All your Objects like variables, functions, procedures, codes, packages etc. are stored in the storage of the DB.
    - All the user specific PGA (Program/Private Global Area) are stored in the DB Memory where all the objects are loaded from DB Storage, for execution when called.
    - Here each every object call will copy the object into PGAs and take up some space in the PGA and can cause unnecessary memory usage.
    - To avoid this, SGA (System/shared Global Area in the DB Memory) is where the package is loaded when called for the first time and is shared with all the users.
    - On first package call, the entire package gets loaded into the SGA and stays there until any changes are made in the package.
    - When any object from the package is called, it is executed from the SGA and not PGA. Then the code/object is run by the processor.
    - Only the variables are stored in the PGA which are private to the user and package objects are in the shared SGA which avoids the object duplication in the DB memory and increases performance.
    - The private variables are session specific to the user.
    - All your objects, variables, codes, packages etc are stored in the storage and loaded into the PGA/SGA when called for execution.
- Advantages:
    - Modularity: we can group logically related objects together in one package.
    - Easy Maintenance : since all the objects are related, its easier to understand, modify and maintain the objects.
    - Encapsulation & security : We can have public and private objects in the package. Package can also be encrypted.
    - Performance : The package is loaded into the SGA/memory for all the user so it avoids duplication and burden on I/O processing.
    - Functionality : persistency of public variables and cursors for an entire session.
    - Overloading : the subprograms in packages is easier, faster and beneficial.
- Package consists of 2 parts:
    - Package specification (spec) : declares global objects that are public and accessible to others.
    - Package Body (body) : has private objects.
- If the change or modification in either package spec or body is not affecting to either one of those, then only re-compile what is modified.
*/

-- Package Spec 
create or replace PACKAGE EMP AS --/IS
    v_salary_increase_rate number := 0.057;
    cursor cur_emps is select * from employees_copy;
    procedure increase_salaries;
    function get_avg_sal(p_dept_id int) return number;
END EMP;

-- Package Body
CREATE OR REPLACE
PACKAGE BODY EMP AS

  procedure increase_salaries AS
  BEGIN
    for r1 in cur_emps loop
        update employees_copy set salary = salary + v_salary_increase_rate;
    end loop;
  END increase_salaries;

  function get_avg_sal(p_dept_id int) return number AS
  v_avg_sal number := 0;
  BEGIN
    select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
    RETURN v_avg_sal;
  END get_avg_sal;

END EMP;

-- Call
exec emp.increase_salaries;
select * from employees_copy;

BEGIN
    print(emp.get_avg_sal(50));
    print(emp.v_salary_increase_rate);
end;

-- Visibility of Package Objects
/*
- An object is visible to the others only if it is declared in the package spec.
- Variables can be declared in:
  - Inside of the package spec between IS and END keywords. These variables and objects are public.
  - Inside of the package body between AS and END keywords. These are variables and objects are private.
*/
-- Package Spec 
create or replace PACKAGE EMP AS --/IS
    v_salary_increase_rate number := 0.057;
    cursor cur_emps is select * from employees_copy;
    procedure increase_salaries;
    function get_avg_sal(p_dept_id int) return number;
END EMP;

-- Package body
CREATE OR REPLACE
PACKAGE BODY EMP AS

v_sal_inc int := 500;

  procedure print_test is
  BEGIN
    print('Test : '||v_sal_inc);
  end;

  procedure increase_salaries AS
  BEGIN
    for r1 in cur_emps loop
        update employees_copy set salary = salary + v_salary_increase_rate;
    end loop;
  END increase_salaries;

  function get_avg_sal(p_dept_id int) return number AS
  v_avg_sal number := 0;    -- Local variable, accessible only within the subprogram
  BEGIN
    print_test;
    select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
    RETURN v_avg_sal;
  END get_avg_sal;

END EMP;

-- Visibility of variables in packages
---- Package Spec
create or replace package pkg_emp_spec AS
  v_salary_increase_rate number := 0.057;
  cursor cur_emps is select * from employees_copy;
  procedure increase_salaries;
  function get_avg_sal(p_dept_id int) return number;
END pkg_emp_spec;

---- Package Body
create or replace package body pkg_emp_body AS
  v_sal_inc int := 500;
  v_sal_inc2 int := 500;

  procedure print_test is
  BEGIN
    print('Test : '||v_sal_inc);
  end;

  procedure increase_salaries AS
  BEGIN
    for r1 in cur_emps loop
      update employees_copy set salary = salary * v_salary_increase_rate;
    end loop;
  end increase_salaries;

  function get_avg_sal(p_dept_id int) return number AS
  v_avg_sal number := 0;
  BEGIN
    print_test;
    select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
    return v_avg_sal;
  END get_avg_sal;
END pkg_emp_body;


-- PACKAGE INITIALIZATION
/*
- A package is loaded into the memory on first call.
- Then uninitialized variables are set to null by default. Hence initialization is done to avoid null excpeitons.
- There is one more way called "Package Initialization" to initialize variables like constructors of other PL.
- The initialized variables will be overridden.
- Package initialization is done in the last begin-end block of the package.
- NOTE : It runs only once in one session
*/

create table logs(log_source varchar2(100), log_message varchar2(1000), log_date date);

create or replace package body pkg_emp_body AS
  v_sal_inc int := 500;
  v_sal_inc2 int := 500;

  procedure print_test is
  BEGIN
    print('Test : '||v_sal_inc);
  end;

  procedure increase_salaries AS
  BEGIN
    for r1 in cur_emps loop
      update employees_copy set salary = salary * v_salary_increase_rate;
    end loop;
  end increase_salaries;

  function get_avg_sal(p_dept_id int) return number AS
  v_avg_sal number := 0;
  BEGIN
    print_test;
    select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
    return v_avg_sal;
  END get_avg_sal;
begin   -- package initialization
  insert into logs values('EMP_PKS', 'Package Initialized!', sysdate);
END pkg_emp_body;

select * from logs;
begin
    print(pkg_emp.get_avg_sal(50));
    print(pkg_emp.v_salary_increase_rate);
end;

exec print(pkg_emp.get_avg_sal(50));
exec print(pkg_emp.v_salary_increase_rate);


-- PERSISTENT STATE OF PACKAGES
/*
- We have 2 types of memory areas in the DB:
  - PGA/UGA: stores the objects, variables, codes of a single user in a session which is private and accessible to that user only.
  - SGA: stores sub-programs, objects, codes, packages etc. among all the users.
- The required variables are copied SGA to the PGA to make it available for user specific session for modifications. This ensures that the changes/modifications are local and user specific to the user in their respective PGAs while still retaining the initial values in SGA.
- For ex. the variable x = 10 of a package is copied to the user's PGA, here s/he can make required modifications on x locally, specific to the session. The value x=10 is retained in the SGA.
- A package is loaded into the memory at the first reference.
- Variables and objects are stored in your PGA.
- These variables are persistent and unique for your session.
- Subprograms of the packages are stored in the SGA.
- But, we can change the persistent state of varibale as well to use less space.
- We can store the varibales only in SGA and not PGA so it will be accessible to all the users, but the state of the variables won't be saved.
- To do this we declare package as PRAGME SERIALLY_REUSABLE
- But SERIALLY_REUSABLE packages cannot be accessed from:
  - Triggers
  - Subprograms called from SQL statements.
- Commit and rollbacks are for insertion, updation and deletion. Value overriding happens locally only in the PGA inspite of commit, the initial value retained in the SGA for all the other users.
- Serially_reusable packages stores all the objects, variables etc in the SGA.
*/
-- Managing package access using grant and revoke for different users. (usually done by DBA)
--SYNTAX: grant execute on <package_name> to <user/schema>
grant execute on constants_pkg to system_user;
grant execute on constants_pkg to hr;

--SYNTAX: revoke execute on <package_name> from <user/schema>
revoke execute on constants_pkg from system_user;
revoke execute on constants_pkg from hr;

---------------------------------------------------------------------------------------------
----------------------------------PERSISTENT STATE OF PACKAGES-------------------------------
--------------------------------------------------------------------------------------------- 
----------------- 
execute dbms_output.put_line(constants_pkg.v_salary_increase);
grant execute on constants_pkg to my_user;
revoke execute on constants_pkg from my_user;
----------------- 
----------------- 
begin
  constants_pkg.v_company_name := 'ACME';
  dbms_output.put_line(constants_pkg.v_company_name);
  dbms_lock.sleep(20); 
end;
exec dbms_output.put_line(constants_pkg.v_company_name);
----------------- 
create or replace package constants_pkg is
PRAGMA SERIALLY_REUSABLE;
  v_salary_increase constant number:= 0.04;
  cursor cur_emps is select * from employees;
  t_emps_type employees%rowtype;
  v_company_name varchar2(20) := 'ORACLE';
end;
----------------- 
begin
  constants_pkg.v_company_name := 'ACME';
  dbms_output.put_line(constants_pkg.v_company_name);
  dbms_lock.sleep(20); 
end;
----------------- 
declare
v_emp employees%rowtype;
begin
 open constants_pkg.cur_emps;
 fetch constants_pkg.cur_emps into v_emp;
 dbms_output.put_line(v_emp.first_name);
 close constants_pkg.cur_emps;
end;
----------------- 
declare
v_emp employees%rowtype;
begin
 fetch constants_pkg.cur_emps into v_emp;
 dbms_output.put_line(v_emp.first_name);
end;

-- COLLECTIONS IN PACKAGE
/*
- Associative arrays are most useful collection type if data is not needed to be stored in the table.
- 
*/
-- Package Spec
create or replace package EMP_PKG2 as
  type emp_table_type is table of employees_copy%rowtype index by pls_integer;
  v_salary_increase_rate number := 1000;
  v_min_employee_salary number := 5000;
  cursor cur_emps is select * from employees_copy;

  procedure increase_salaries;
  function get_avg_sal(p_dept_id int) return number;
  v_test int := 4;
  function get_employees return emp_table_type;
  function get_employees_tobe_incremented return emp_table_type;
  procedure increase_low_salaries;
  function arrange_for_min_salary(v_emp employees_copy%rowtype) return employees_copy%rowtype;
end EMP_PKG2;

-- Package Body
create or replace package body emp_pkg2 as
  v_sal_inc int := 500;
  v_sal_inc2 int := 500;
  function get_sal(e_id employees_copy.employee_id%type) return number;
  procedure print_test is
  begin
    print('Test : '||v_sal_inc);
    print('Test salary : '||get_sal(102));
  end;

  procedure increase_salaries as
  begin
    for r1 in cur_emps loop
      update employees_copy set salary = salary + salary*v_salary_increase_rate
        where employee_id = r1.employee_id;
    end loop;
  end increase_salaries;

  function get_avg_sal(p_dept_id int) return number as v_avg_sal number := 0;
  begin
    print_testl
    select avg(salary) into v_avg_sal from employees_copy where department_id = p_dept_id;
    return v_avg_sal;
  end get_avg_sal;

  function get_sal(e_id employees_copy.employee_id%type) return number is v_sal number := 0;
  begin
    select salary into v_sal from employees_copy where employee_id = e_id;
    return v_sal;
  END;

  -- This function returns all the employees in employee table
  function get_employees return emp_table_type is v_emps emp_table_type;
    begin
      for cur_emps in (select * from employees_copy) loop
        v_emps(cur_emps.employee_id) := cur_emps;
      end loop;
      retun v_emps;
    end; -- check
  end;

  -- This function returns he employees which are under the minimum salary of company standards and to be incremented by new min salary

  function get_employees_tobe_incremented return emp_table_type is v_emps emp_table_type;
    i employees_copy.employee_id%type;
    begin
      v_emps := get_employees;
      i := v_emps.first;
        while i is not null loop
          if v_emps(i).salary > v_min_employee_salary then
            v_emps.delete(i);
          end if;
          i := v_emps.next(i);
        end loop;
        return v_emps;
    end;

    -- This procedure increases the salary of the empoyees who has a less salary thean the company standard

      procedure increase_low_salaries as
      v_emps emp_table_type;
      v_emp employees%rowtype;
      i employees.employee_id%type;
      begin
      v_emps := get_employees_tobe_incremented;
        i := v_emps.first;
        while i is not null loop
        v_emp := arrange_for_min_salary(v_emps(i));
          update employees_copy set row = v_emp    
            where employee_id = i;
        i := v_emps.next(i);
        end loop;
      end increase_low_salaries;
      /*
        This function returns the employee by arranging the salary based on the 
        company standard.
      */
      function arrange_for_min_salary(v_emp in out employees%rowtype) return employees%rowtype is
      begin
        v_emp.salary := v_emp.salary + v_salary_increase_rate;
        if v_emp.salary < v_min_employee_salary then
          v_emp.salary := v_min_employee_salary;
        end if;
        return v_emp;
      end;
      /**********************************************/
    BEGIN
      v_salary_increase_rate := 500;
      insert into logs values ('EMP_PKG','Package initialized!',sysdate);
  end emp_pkg2;

  -- Finding the package
select * from user_source;

select * from user_source
where type = 'PACKAGE BODY'
and name = 'PKG_EMP';

select * from user_objects;
select * from user_objects
where object_type = 'PACKAGE BODY'
and object_name = 'PKG_EMP';

select * from user_objects
where status = 'INVALID';