--Composite Data Types
/*
- All composite variables are stored in PGA (Program Global Area) which is inmem and has facter reach than database.
- Composite data types hold multiple values in one box. The types are:
    - Records: singular but can store one row multiple values. Generally used to store same or different data types in one row as related data.

*/

-- employees.salary%type

-- r_name table_name%rowtype; all of the column types of the row in the record 'r_name'.(to create a record with the rowtype)
-- type type_name is record(variable_name variable_type, [variable_name variable_type,][....]); (to create a custom record)

declare
 r_emp employees_copy%rowtype;
 begin
 --   only one record should be returned since record can hold only one row. Go for collection for multiple rows.
  select * into r_emp from employees_copy where employee_id = '101';
  dbms_output.put_line(r_emp.salary);
  r_emp.salary:= 2000;
  dbms_output.put_line(r_emp.first_name|| ' '|| r_emp.last_name || ' earns ' ||r_emp.salary);
  dbms_output.put_line(r_emp.salary);
end;

declare
-- r_emp employees_copy%rowtype;
 type t_emp is record(first_name varchar2(50), last_name employees_copy.last_name%type, salary employees_copy.salary%type, hire_date date);
 r_emp t_emp;
 begin
    r_emp.first_name := 'Tanmay';
    r_emp.salary := 3425;
    r_emp.hire_date := '01-JAN-22';
    dbms_output.put_line(r_emp.first_name|| ' '|| r_emp.last_name || 'earns ' ||r_emp.salary || ' hired on date ' || r_emp.hire_date);
end;
--
declare
  --r_emp employees%rowtype;
  type t_emp is record (first_name varchar2(50),
                        last_name employees_copy.last_name%type,
                        salary employees_copy.salary%type);
  r_emp t_emp;
begin
  select first_name,last_name,salary into r_emp 
        from employees_copy where employee_id = '102';
 /* r_emp.first_name := 'Alex';
  r_emp.salary := 2000;
  r_emp.hire_date := '01-JAN-20'; */
  dbms_output.put_line(r_emp.first_name||' '||r_emp.last_name|| ' earns '||r_emp.salary);
end;

-- A record can be of one type. But one type can have multiple types. To have multiple records in one record, create another type and put in one record.

-- Creating a new table with only employee_copy columns and populating/inserting one record.
 create table retired_employees as select * from employees_copy where 1 = 2;  -- New Table only with columns created
 select * from retired_employees;
 
declare
  r_emp employees_copy%rowtype;
begin
   select * into r_emp from employees_copy where employee_id =104;
   r_emp.salary := 0;
   --insert into retired_employees values r_emp;
   update retired_employees set row = r_emp where employee_id = 104;
end;

-------------------------COLLECTIONS-------------------
/*
- collection is a collection of multiple records in key value pairs.
- Use collections when the number of records is not known.
- Collections have a list of the same type.
- Collections: can store multiple row values. It has 3 types [key-value pair in one variable]:
  - Nested Tables (unbounded, starts with index 1) [c_emp_names]
  - Varrays (variable sized arrays): (bounded, starts with index 1) [c_emp_names]
  - Associated Arrays (unbounded, no constraints for index) [c_emp_names]
  - In Memory Tables
- 
*/
-- creating a hard coded list of employees and printing it.
--------------- VARRAYS --------------------
/*
- Upper limit is certain.
- they are bounded.
- index starts from 1
- 1 Dimensional arrays
- varrays are null by default so initialize it.
*/

declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list;
begin
 employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 for i in 1..3 loop
  dbms_output.put_line(employees_copy(i));
 end loop;
end;

declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list;
begin
 employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 for i in 1..employees_copy.count() loop
  dbms_output.put_line(employees_copy(i));
 end loop;
end;

declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list;
begin
 employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 for i in employees_copy.first()..employees_copy.last() loop
  dbms_output.put_line(employees_copy(i));
 end loop;
end; 

declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list;
begin
 employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 for i in 1..3 loop
  if employees_copy.exists(i) then
   dbms_output.put_line(employees_copy(i));
  end if;
 end loop;
end;

declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list;
begin
 employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 dbms_output.put_line(employees_copy.limit());
end;


declare
 type e_list is varray(5) of varchar2(50);
 employees_copy e_list := e_list('Tanmay', 'Tim', 'Steve');
begin
 --employees_copy := e_list('Tanmay', 'Tim', 'Steve');
 dbms_output.put_line(employees_copy.limit());
end;

-- Create a collection and populate data from a table
declare
 type e_list is varray(15) of varchar2(50);
 employees e_list := e_list();
 idx number := 1;
begin
 for i in 100..110 loop
  employees.extend;
  select first_name into employees(idx) from employees_copy where employee_id = i;
  idx := idx+1;
 end loop;
 for x in 1..employees.count() loop
 dbms_output.put_line(employees(x));
 end loop;
end;

/*
The ways to declare a 'type' are:
- declaring section: here the declared 'type' is stored in the memory and cleared after program execution.
- creating a type in database: retains the type and is stored in the database and the type is called schema lebel type.
*/
-- creating the 'type' in database:
create or replace type e_list is varray(20) of varchar2(100);
drop type e_list;

-----------------NESTED TABLES---------------
/*
- Similar to varrays.
- only positive index numbers. 
- has key-value pairs.(+ve integers of keys)
- 2 GB values at most.
- We can delete any values, unlike varrays.
- Unlike varray, it is not stored consecutively.
- Nested tables are unbounded.
- SYNTAX:
  - type type_name as table of value_data_type [NOT NULL]);
  - create or replace type type_name as table of value_data_type [NOT NULL]);
*/

declare
 type e_list is table of varchar2(50);
 emps e_list;
begin
 emps := e_list('tim', 'Steve', 'Tanmay');
 emps.extend(); -- to enable dynamic value insertion
 emps(2) := 'steve';
 emps(4) := 'steve';
 for i in 1..emps.count() loop
  dbms_output.put_line(emps(i));
 end loop;
end;


declare
 type e_list is table of varchar2(50);
 emps e_list := e_list();
 idx pls_integer := 1;    -- for key which starts with 1
begin
 for x in 100..110 loop
 emps.extend();
 select first_name into emps(idx) from employees_copy where employee_id = x;
 idx := idx+1;
 end loop;
  for i in 1..emps.count() loop
   dbms_output.put_line(emps(i));
  end loop;
end;


declare
 type e_list is table of employees_copy.first_name%type;
 emps e_list := e_list();
 idx pls_integer := 1;
begin
 for x in 100..110 loop
 emps.extend();
 select first_name into emps(idx) from employees_copy where employee_id = x;
 idx := idx+1;
 end loop;
 emps.delete(3);    -- dynamic deletion
  for i in 1..emps.count() loop
   if emps.exists(i) then   -- enables dynamic deletion to occur and then print
    dbms_output.put_line(emps(i));
   end if;
  end loop;
end;

--------------- ASSOCIATIVE ARRAYS (INDEX BY TABLES) -------------
/*
- We cannot create associative arrays at schema level
- The key can have a string.
- keys should be unique.
- no need to be sequential.
- can have scalar & record types.
- Do not initialize associative arrays.
- It has no upper limit for data.
- Associative arrays are indexed in memory and so are a bit faster.
- It has two indexing methods based on the key types:
 - varchar2 type key : indexed as b-tree index which improves traversing.
- Syntax:
 - type type_name as table of value_data_type [NOT NULL]
    index by {PLS_INTEGER | BINARY_INTEGER | VARCHAR2(size)};
*/

declare
 type e_list is table of employees_copy.first_name%type index by pls_integer;
 emps e_list;
BEGIN
  for x in 100..110 loop
    select first_name into emps(x) from employees_copy where employee_id = x;
   end loop;
   for i in emps.first..emps.last loop
    dbms_output.put_line(emps(i));
   end loop;
END;

declare
 type e_list is table of employees_copy.first_name%type index by pls_integer;
 emps e_list;
BEGIN
  emps(100) := 'Tanmay';
  emps(120) := 'Tim';
  for x in 100..110 loop
    select first_name into emps(x) from employees_copy where employee_id = x;
   end loop;
   for i in emps.first..emps.last loop
    dbms_output.put_line(i);
   end loop;
END;

declare
 type e_list is table of employees_copy.first_name%type index by pls_integer;
 emps e_list;
 idx pls_integer;
BEGIN
--  emps(100) := 'Tanmay';
--  emps(120) := 'Tim';
for x in 100..110 loop
 select first_name into emps(x) from employees_copy where employee_id = x;
 end loop;
  idx := emps.first;
  while idx is not null loop
   dbms_output.put_line(emps(idx));
   idx := emps.next(idx);
  end loop;
END;


--------------------------------------------------------------------------------------------------------------------
----------------------------------------------ASSOCIATIVE ARRAYS----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
---------------The first example
declare
  type e_list is table of employees_copy.first_name%type index by pls_integer;
  emps e_list;
begin
  for x in 100 .. 110 loop
    select first_name into emps(x) from employees_copy 
       where employee_id = x ;
  end loop;
  for i in emps.first()..emps.last() loop
    dbms_output.put_line(emps(i));
  end loop;
end;

select * from employees_copy;
---------------Error example for the select into clause
declare
  type e_list is table of employees_copy.first_name%type index by pls_integer;
  emps e_list;
begin
  for x in 100 .. 110 loop
    select first_name into emps(x) from employees_copy 
       where employee_id = x and department_id = 50;
  end loop;
  for i in emps.first()..emps.last() loop
    dbms_output.put_line(i);
  end loop;
end;
---------------Error example about reaching the empty indexdeclare
  type e_list is table of employees_copy.first_name%type index by pls_integer;
  emps e_list;
begin
  emps(100) := 'Bob';
  emps(120) := 'Sue';
  for i in emps.first()..emps.last() loop
    dbms_output.put_line(emps(i));
  end loop;
end;
---------------An example of iterating in associative arrays with while loops
declare
  type e_list is table of employees_copy.first_name%type index by pls_integer;
  emps e_list;
  idx pls_integer;
begin
  emps(100) := 'Bob';
  emps(120) := 'Sue';
  idx := emps.first;
  while idx is not null  loop
    dbms_output.put_line(emps(idx));
    idx := emps.next(idx);
  end loop;
end;
---------------An example of using string based indexes with associative arrays
declare
  type e_list is table of employees_copy.first_name%type index by employees_copy.employee_id%type;
  emps e_list;
  idx employees_copy.employee_id%type;
  v_id employees_copy.employee_id%type;
  v_first_name employees_copy.first_name%type;
begin
    for x in 100 .. 110 loop
    select first_name,employee_id into v_first_name,v_id from employees_copy
       where employee_id = x;
    emps(v_id) := v_first_name;
  end loop;
  idx := emps.first;
  while idx is not null  loop
    dbms_output.put_line('The email of '|| emps(idx) ||' is : '|| idx);
    idx := emps.next(idx);
  end loop;
end;
---------------An example of using associative arrays with records
declare
  type e_list is table of employees%rowtype index by employees.email%type;
  emps e_list;
  idx employees.email%type;
begin
    for x in 100 .. 110 loop
    select * into emps(x) from employees
       where employee_id = x;
  end loop;
  idx := emps.first;
  while idx is not null  loop
    dbms_output.put_line('The email of '|| emps(idx).first_name 
          ||' '||emps(idx).last_name||' is : '|| emps(idx).email);
    idx := emps.next(idx);
  end loop;
end;
---------------An example of using associative arrays with record types
declare
  type e_type is record (first_name employees.first_name%type,
                         last_name employees.last_name%type,
                         email employees.email%type);
  type e_list is table of e_type index by employees.email%type;
  emps e_list;
  idx employees.email%type;
begin
    for x in 100 .. 110 loop
    select first_name,last_name,email into emps(x) from employees
       where employee_id = x;
  end loop;
  idx := emps.first;
  while idx is not null  loop
    dbms_output.put_line('The email of '|| emps(idx).first_name 
          ||' '||emps(idx).last_name||' is : '|| emps(idx).email);
    idx := emps.next(idx);
  end loop;
end;
---------------An example of printing from the last to the first
declare
  type e_type is record (first_name employees.first_name%type,
                         last_name employees.last_name%type,
                         email employees.email%type);
  type e_list is table of e_type index by employees.email%type;
  emps e_list;
  idx employees.email%type;
begin
    for x in 100 .. 110 loop
    select first_name,last_name,email into emps(x) from employees
       where employee_id = x;
  end loop;
  --emps.delete(100,104);
  idx := emps.last;
  while idx is not null  loop
    dbms_output.put_line('The email of '|| emps(idx).first_name 
          ||' '||emps(idx).last_name||' is : '|| emps(idx).email);
    idx := emps.prior(idx);
  end loop;
end;
---------------An example of inserting with associative arrays
create table employees_salary_history as select * from employees where 1=2;
alter table employees_salary_history add insert_date date;
select * from employees_salary_history;
/
declare
  type e_list is table of employees_salary_history%rowtype index by pls_integer;
  emps e_list;
  idx pls_integer;
begin
    for x in 100 .. 110 loop
    select e.*,'01-JUN-20' into emps(x) from employees e
       where employee_id = x;
  end loop;
  idx := emps.first;
  while idx is not null loop
    emps(idx).salary := emps(idx).salary + emps(idx).salary*0.2;
    insert into employees_salary_history values emps(idx);
    dbms_output.put_line('The employee '|| emps(idx).first_name 
                         ||' is inserted to the history table');
    idx := emps.next(idx);
  end loop;
end;
/
drop table employees_salary_history;


----------- STORING COLLECTIONS IN TABLES--------
/*
- We can store varrays and nested tables in database tables.
- They are stored with different methods.
- Storing a collection inside a table eliminates the need for table relational mapping and is easier and faster.
- For Ex.: employe table can have a column phone_number with collection of home and work type.
- Types must be schema level.
*/

create or replace type t_phone_number as object(p_type varchar2(10), p_number varchar2(50));


create or replace type v_phone_numbers as varray(3) of t_phone_number;


create table emps_with_phones(employee_id number, first_name varchar2(50), last_name varchar2(50), phone_number v_phone_numbers);


select * from emps_with_phones;

insert into emps_with_phones values(10, 'Tanmay', 'Borde', v_phone_numbers(
    t_phone_number('HOME', '1234'),
    t_phone_number('WORK', '123456'),
    t_phone_number('MOBILE', '123478')
));

insert into emps_with_phones values(11, 'Tanmay', 'Borde', v_phone_numbers(
    t_phone_number('HOME', '12'),
    t_phone_number('WORK', '1234')
));

select e.first_name, e.last_name, p.p_type, p.p_number from emps_with_phones e, table(e.phone_number) p;

-- Why nested tables instead of varrays in tables? because nested tables can spare, we can use as many variable as we want.

--------------------------------------------------------------------------------------------------------------------
---------------------------------------STORING COLLECTIONS IN TABLES------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
---------------Storing Varray Example
create or replace type t_phone_number as object (p_type varchar2(10), p_number varchar2(50));
/
create or replace type v_phone_numbers as varray(3) of t_phone_number;
/
create table emps_with_phones (employee_id number,
                               first_name varchar2(50),
                               last_name varchar2(50),
                               phone_number v_phone_numbers);
/
select * from emps_with_phones;
/
insert into emps_with_phones values (10,'Alex','Brown',v_phone_numbers(
                                                                t_phone_number('HOME','111.111.1111'),
                                                                t_phone_number('WORK','222.222.2222'),
                                                                t_phone_number('MOBILE','333.333.3333')
                                                                ));
insert into emps_with_phones values (11,'Bob','Green',v_phone_numbers(
                                                                t_phone_number('HOME','000.000.000'),
                                                                t_phone_number('WORK','444.444.4444')
                                                                ));                                                                
/
---------------Querying the varray example
select e.first_name,last_name,p.p_type,p.p_number from emps_with_phones e, table(e.phone_number) p;
---------------The codes for the storing nested table example
create or replace type n_phone_numbers as table of t_phone_number;
/
create table emps_with_phones2 (employee_id number,
                               first_name varchar2(50),
                               last_name varchar2(50),
                               phone_number n_phone_numbers)
                               NESTED TABLE phone_number STORE AS phone_numbers_table;
/
select * from emps_with_phones2;
/
insert into emps_with_phones2 values (10,'Alex','Brown',n_phone_numbers(
                                                                t_phone_number('HOME','111.111.1111'),
                                                                t_phone_number('WORK','222.222.2222'),
                                                                t_phone_number('MOBILE','333.333.3333')
                                                                ));
insert into emps_with_phones2 values (11,'Bob','Green',n_phone_numbers(
                                                                t_phone_number('HOME','000.000.000'),
                                                                t_phone_number('WORK','444.444.4444')
                                                                ));      
/
select e.first_name,last_name,p.p_type,p.p_number from emps_with_phones2 e, table(e.phone_number) p;
---------------new insert and update
insert into emps_with_phones2 values (11,'Bob','Green',n_phone_numbers(
                                                                t_phone_number('HOME','000.000.000'),
                                                                t_phone_number('WORK','444.444.4444'),
                                                                t_phone_number('WORK2','444.444.4444'),
                                                                t_phone_number('WORK3','444.444.4444'),
                                                                t_phone_number('WORK4','444.444.4444'),
                                                                t_phone_number('WORK5','444.444.4444')
                                                                ));    
select * from emps_with_phones2;
update emps_with_phones2 set phone_number = n_phone_numbers(
                                                                t_phone_number('HOME','000.000.000'),
                                                                t_phone_number('WORK','444.444.4444'),
                                                                t_phone_number('WORK2','444.444.4444'),
                                                                t_phone_number('WORK3','444.444.4444'),
                                                                t_phone_number('WORK4','444.444.4444'),
                                                                t_phone_number('WORK5','444.444.4444')
                                                                )
where employee_id = 11;
---------------Adding a new value into the nested table inside of a table
declare
  p_num n_phone_numbers;
begin
  select phone_number into p_num from emps_with_phones2 where employee_id = 10;
  p_num.extend;
  p_num(5) := t_phone_number('FAX','999.99.9999');
  UPDATE emps_with_phones2 set phone_number = p_num where employee_id = 10;
end;




