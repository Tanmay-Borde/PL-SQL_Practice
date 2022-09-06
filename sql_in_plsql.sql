--Using SQL in PL/SQL

/*
- SQL and PL/SQL code can coexist.
- SQL deals more with Data and PL/SQL deals more with logical and procedural operations on the data.
- You cannot use DDL commands directly in PL/SQL.
- Using SQL in PLSQL:(SYNTAX)
    SELECT COLUMNS|EXPRESSIONS
    INTO VARIABLES|RECORDS
    FROM TABLE|TABLES
    [WHERE CONDITION];
- 
*/
------------------------------OPERATING WITH SELECTED QUERIES--------------------------------
declare
 v_name varchar2(50);
 v_salary employees.salary%type;
begin
  select first_name ||' '|| last_name, salary into v_name, v_salary  from employees where employee_id = 130;
  dbms_output.put_line('The salary of '|| v_name || ' is : '|| v_salary);
end;
------------------------------
declare
 v_name varchar2(50);
 sysdates employees.hire_date%type;
begin
  select first_name ||' '|| last_name, sysdates into v_name, sysdates from employees where employee_id = 130;
  dbms_output.put_line('The salary of '|| v_name || ' is : '|| sysdates);
end;
------------------------------
declare
 v_name varchar2(50);
 v_sysdate employees.hire_date%type;
 employee_id employees.employee_id%type := 130;
begin
  select first_name ||' '|| last_name, sysdate into v_name, v_sysdate from employees where employee_id = employee_id;
  dbms_output.put_line('The salary of '|| v_name || ' is : '|| v_sysdate );
end;
------------------------------
declare
 v_name varchar2(50);
 v_salary employees.salary%type;
 v_employee_id employees.employee_id%type := 130;
begin
  select first_name ||' '|| last_name, salary into v_name, v_salary from employees where employee_id = v_employee_id;
  dbms_output.put_line('The salary of '|| v_name || ' is : '|| v_salary );
end;

------------------------------ DML OPERATIONS WITH PL/SQL----------------------------------------
create table employees_copy as select * from HR.EMP_DETAILS_VIEW;
declare
    v_employee_id pls_integer := 0;
    v_salary_increase number := 600;
begin
    for i in 200..205 loop
    insert into employees_copy
    (employee_id, first_name, last_name, city, job_id, salary, department_name, job_title)
    values(i, 'employee_id#'||i,'temp_emp','Pune', 'IT Prog',1000, 'IT', 'IT');
    update employees_copy
    set salary = salary + v_salary_increase
    where employee_id = i;
    end loop;
end;

--SEQUENCES--
/*
- Sequence is independent from tables which generates unique sequence of incrementing number values.
- In each call, the sequence increases.
- Must be a number.
- syntax: select sequence_name.nextval|currval into variable|column from table_name|dual;
- variable|column := sequence_name.nextval|currval;
*/
select * from employees_copy;

declare
 v_seq_num number;
begin
-- v_seq_num := employee_id_seq.nextval;
 dbms_output.put_line(employee_id_seq.nextval);
 dbms_output.put_line(employee_id_seq.currval);
end;

------------------------------OPERATING WITH SELECTED QUERIES--------------------------------

