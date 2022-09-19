----------------- CURSORS -----------------
/*
- The Oracle DB has two engines:
    - PL/SQL Engine executes PL/SQL code.
    - SQL Engine executes SQL code.
- The execution switches between the two engines depending on the code.
- The small resultset is stored in the PGA (Program Global Area) which is private only to the session.
- Cursors are pointers to the data. It is used for select queries to fetch data from the memory. Types are:
    - Implicit Cursor: is created for every select query by the database server and managed automatically including termination.
    - Explicit Cursor: is created by us and can be controlled by us. It helps to iterate on the resultset. It is effecient and faster.
- Collections V/s Cursors:
    - Collections can have memory limitation.
    - Cursor can be faster and more efficient than collections for large data.

---------------- Explicit Cusrors -----------
Steps to create a cursor:
- Declare   : with select query, allocate some area in the memory for the result set.
- Open      : opens ad stores the data in the result set.
- Fetch     : returns the current row from the active set of rows by pointing to the next row.
- Check     : method to check if the iteration on the cursor is finished.
- Close     : closing cursor properly.

- syntax:
    declare
        cursor name is select_statement;
    begin
        open cursor_name; -- if not opened then causes exception.
        fetch cursor_name into varibles, records etc.;
        close cursor_name; -- if not closed then causes memory wastage and error.
    end;

- Cursors with parameters:
    - can be used multiple times
    - syntax:
        declare
            cursor cursor_name(parameter_name datatype,...) is select_statement;
        begin
            open cursor_name(parameter_values);
            fetch cursor_name into variables, records etc;
            close cursor_name;
        end;
*/

declare
    cursor c_emps (p_dept_id number) is select first_name, last_name, department_name
        from employees_copy join departments using (department_id)
        where department_id = p_dept_id;
    v_emps c_emps%rowtype;
begin
    open c_emps(20);
    fetch c_emps into v_emps;
    dbms_output.put_line('The employees in department og '||v_emps.department_name||' are : ');
    close c_emps;
    
    open c_emps(20);
        loop
            fetch c_emps into v_emps;
            exit when c_emps%notfound;
            dbms_output.put_line(v_emps.first_name||' '||v_emps.last_name);
        end loop;
    close loop;
end;

-- finding employee by passign id as parameter to the cursor

declare
    cursor c_emps(id number) is select employee_id, first_name, last_name from employees_copy where employee_id = id;
    v_emps c_emps%rowtype;
begin
    open c_emps(202);
    fetch c_emps into v_emps;
    dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name);
    close c_emps;
end;

-- passing the id as bind variable. (opening the cursor with parameter)

declare
    cursor c_emps(id number) is select employee_id, first_name, last_name from employees_copy where employee_id = id;
    v_emps c_emps%rowtype;
begin
    open c_emps(:b_id);
    fetch c_emps into v_emps;
    dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name);
    close c_emps;
end;

-- passing multiple bind variables. (opening the cursor with parameter)

declare
    cursor c_emps(id number) is select employee_id, first_name, last_name, department_id
        from employees_copy where department_id = id;
    v_emps c_emps%rowtype;
begin
    open c_emps(:b_id);
    fetch c_emps into v_emps;
    dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name||' '||v_emps.department_id);
    close c_emps;

    open c_emps(:b_id2);
        loop
            fetch c_emps into v_emps;
            exit when c_emps%notfound;
            dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name||' '||v_emps.department_id);
        end loop;
    close c_emps;
end;

-- passing multiple bind variables. (for in clause)

declare
    cursor c_emps(id number) is select employee_id, first_name, last_name, department_id
        from employees_copy where department_id = id;
    v_emps c_emps%rowtype;
begin
    open c_emps(:b_id);
    fetch c_emps into v_emps;
    dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name||' '||v_emps.department_id);
    close c_emps;

    open c_emps(:b_id2);
        for i in c_emps(:b_id2)loop
            -- fetch c_emps into v_emps;
            -- exit when c_emps%notfound;
            dbms_output.put_line('Employee ID : '||i.employee_id||' has name :'||i.first_name||' '||i.last_name||' '||i.department_id);
        end loop;
    -- close c_emps;
end;

-- using FOR..IN
declare
    cursor c_emps(id number) is select employee_id, first_name, last_name, department_id
        from employees_copy where department_id = id;
    v_emps c_emps%rowtype;
begin
    open c_emps(:b_id);
    fetch c_emps into v_emps;
    dbms_output.put_line('Employee ID : '||v_emps.employee_id||' has name :'||v_emps.first_name||' '||v_emps.last_name||' '||v_emps.department_id);
    close c_emps;

--    open c_emps(:b_id2);
        for i in c_emps(:b_id2)loop
            -- fetch c_emps into v_emps;
--             exit when c_emps%notfound;
            dbms_output.put_line('Employee ID : '||i.employee_id||' has name :'||i.first_name||' '||i.last_name||' '||i.department_id);
        end loop;
    -- close c_emps;
end;

-- Passing multiple parameters

declare
    cursor c_emps(p_id number, p_job_id varchar2) is select employee_id, first_name, last_name, job_id, department_id
        from employees_copy where department_id = p_id
        and job_id = p_job_id;
    v_emps c_emps%rowtype;
begin
    for i in c_emps(50,'ST_MAN') loop
        dbms_output.put_line(i.first_name||' '||i.last_name||' - '||i.job_id);
    end loop;
    dbms_output.put_line('-');
    for i in c_emps(80,'SA_MAN') loop
        dbms_output.put_line(i.first_name||' '||i.last_name||' - '||i.job_id);
    end loop;
end;

----------------- CURSOR ATTRIBUTES (FUNCTIONS) -------------
/*
- 4 cursor ATTRIBUTES:
    - %FOUND: RETURNS TRUE IF THE FETCH RETURNED A ROW.
    - %NOTFOUND : OPPOSITE OF %FOUND
    - %ISOPEN : RETURNS TRUE IF THE CURSOR IS OPEN.
    - %ROWCOUNT : RETURNS THE NUMBER OF FETCHED ROWS FETCHED UNTILL NOW.
*/

Declare
    cursor c_emps is select * from employees_copy where department_id = 20;
    v_emps c_emps%rowtype;
begin
    if not c_emps%ISOPEN then
        open c_emps;
        dbms_output.put_line('Hello Tanmmay....');
    end if;
    dbms_output.put_line(c_emps%ROWCOUNT);
    fetch c_emps into v_emps;
    dbms_output.put_line(c_emps%ROWCOUNT);
    dbms_output.put_line(c_emps%ROWCOUNT);
    fetch c_emps into v_emps;
    dbms_output.put_line(c_emps%ROWCOUNT);
    close c_emps;

    open c_emps;
        loop
            fetch c_emps into v_emps;
            exit when c_emps%notfound or c_emps%ROWCOUNT>5;
            dbms_output.put_line(c_emps%ROWCOUNT||' '||v_emps.first_name||' '||v_emps.last_name);
        end loop;
    close c_emps;
end;

-- FOR UPDATE CLAUSE --
/*
- When you update a row. it is locked to others.
- 'for update' clause locks the selected rows.
- nowait option will terminate execution if there is a lock.
- Default option is wait.
- 'for update' of clause locks only the selected tables.
SYNTAX:
    cursor cursor_name(parameter_name datatype, ...)
        is select_statement
        for update [of col(s)] [nowait | wait n]
*/

grant create session to my_user;
grant select any table to my_user;
grant update on hr.employees_copy to my_user;
grant update on hr.departments to my_user;
UPDATE EMPLOYEES_COPY SET PHONE_NUMBER = '1' WHERE EMPLOYEE_ID = 100;
declare
  cursor c_emps is select employee_id,first_name,last_name,department_name
      from employees_copy join departments using (department_id)
      where employee_id in (100,101,102)
      for update;
begin
  /* for r_emps in c_emps loop
    update employees_copy set phone_number = 3
      where employee_id = r_emps.employee_id; 
  end loop; */
  open c_emps;
end;
--------------- example of wait with second
declare
  cursor c_emps is select employee_id,first_name,last_name,department_name
      from employees_copy join departments using (department_id)
      where employee_id in (100,101,102)
      for update of employees_copy.phone_number, 
      departments.location_id wait 5;
begin
  /* for r_emps in c_emps loop
    update employees_copy set phone_number = 3
      where employee_id = r_emps.employee_id; 
  end loop; */
  open c_emps;
end;
---------------example of nowait
declare
  cursor c_emps is select employee_id,first_name,last_name,department_name
      from employees_copy join departments using (department_id)
      where employee_id in (100,101,102)
      for update of employees_copy.phone_number, 
      departments.location_id nowait;
begin
  /* for r_emps in c_emps loop
    update employees_copy set phone_number = 3
      where employee_id = r_emps.employee_id; 
  end loop; */
  open c_emps;
end;

-- 'WHERE CURRENT OF' CLAUSE--
-- Used together with update clause
-- fetching the data by primary key index is fast, but fetching by rowid ('where current of' clause) indexing is faster for one by one update & delete queries.
-- NOTE: 'WHERE CURRENT OF' clause CANNOT be used with joins, group functions etc., since different tables don't have identical rowids.

SELECT * FROM employees_copy where department_id = 30;

select * from employees_copy;

declare
  cursor c_emps is select * from employees_copy 
                    where department_id = 30 for update;
begin
  for r_emps in c_emps loop
    update employees_copy set salary = salary + 60
          where current of c_emps;
  end loop;  
end;
---------------Wrong example of using where current of clause
declare
  cursor c_emps is select e.* from employees_copy e, departments d
                    where 
                    e.department_id = d.department_id
                    and e.department_id = 30 for update;
begin
  for r_emps in c_emps loop
    update employees_copy set salary = salary + 60
          where current of c_emps;
  end loop;  
end;
---------------An example of using rowid like where current of clause
declare
  cursor c_emps is select e.rowid,e.salary from employees_copy e, departments d
                    where 
                    e.department_id = d.department_id
                    and e.department_id = 30 for update;
begin
  for r_emps in c_emps loop
    update employees_copy set salary = salary + 60
          where rowid = r_emps.rowid;
  end loop;  
end;

-------------------- REFERENCE CURSORS ---------------------------
/*
- Ref cursors are generic cursors which are pointers to the actual cursors.
- It can be sent to another platform as well.
- It is not typed to any cursor or query.
- You can use a ref cursor for multiple queries.
- We cannot:
    - assign null values
    - Use in table-view creation
    - store in collections
    - compare ref cursors
- Types of ref cursors:
    - Strong (restrictive) cursors  : return type is there for ref cursor, so less prone to error.
    - Weak (nonrestrictive) cursors : return type is not there for ref cursor, so more prone to error.

SYNTAX:
    type cursor_type_name is ref cursor [return return_type]
    open cursor_variable_name for query;
*/

declare
    type t_emps is ref cursor return employees_copy%rowtype;
    rc_emps t_emps;
    r_emps employees_copy%rowtype;
begin
    open rc_emps for select * from employees_copy;  --cursor opened
    loop --using for loop will reopen the cursor and cause error so using loop instead
        fetch rc_emps into r_emps;
        exit when rc_emps%notfound;
        dbms_output.put_line(r_emps.first_name||' '||r_emps.last_name);
    end loop;
close rc_emps;
end;

--

declare
    type t_emps is ref cursor return employees_copy%rowtype;
    rc_emps t_emps;
    r_emps employees_copy%rowtype;
begin
    open rc_emps for select * from retired_employees;  --cursor opened
    loop --using for loop will reopen the cursor and cause error so using loop instead
        fetch rc_emps into r_emps;
        exit when rc_emps%notfound;
        dbms_output.put_line(r_emps.first_name||' '||r_emps.last_name);
    end loop;
close rc_emps;

dbms_output.put_line('----------------------------------');

    open rc_emps for select * from employees_copy where job_id = 'IT_PROG';  --cursor opened
    loop --using for loop will reopen the cursor and cause error so using loop instead
        fetch rc_emps into r_emps;
        exit when rc_emps%notfound;
        dbms_output.put_line(r_emps.first_name||' '||r_emps.last_name);
    end loop;
close rc_emps;
end;

/*
- If we are using a table type as a return type of the cursor, then %rowtype.
- If we are using a record type of table type as a return type of the cursor, then %type.
- If we are using a manually created record type as a return type of the cursor, then <name of the record>.
- Strong ref cursor cannot have dynamic query.
- For dynamic queries use weak ref cursor type, since it has no return type.
- Weak cursors can have bind variables.
- For better cross platofrm support, use in-built 'sys_refcursor'.
*/

--------------- in two different queries
declare
 type t_emps is ref cursor return employees_copy%rowtype;
 rc_emps t_emps;
 r_emps employees_copy%rowtype;
begin
  open rc_emps for select * from retired_employees;
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name);
    end loop;
  close rc_emps;
  
  dbms_output.put_line('--------------');
  
  open rc_emps for select * from employees_copy where job_id = 'IT_PROG';
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name);
    end loop;
  close rc_emps;
end;
---------------Example of using with %type when declaring records first
declare
  r_emps employees_copy%rowtype;
 type t_emps is ref cursor return r_emps%type;
 rc_emps t_emps;
 --type t_emps2 is ref cursor return rc_emps%rowtype;
begin
  open rc_emps for select * from retired_employees;
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name);
    end loop;
  close rc_emps;
  
  dbms_output.put_line('--------------');
  
  open rc_emps for select * from employees_copy where job_id = 'IT_PROG';
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name);
    end loop;
  close rc_emps;
end;
---------------manually declared record type with cursors example
declare
  type ty_emps is record (e_id number, 
                         first_name employees_copy.last_name%type, 
                         last_name employees_copy.last_name%type,
                         department_name departments.department_name%type);
 r_emps ty_emps;
 type t_emps is ref cursor return ty_emps;
 rc_emps t_emps;
begin
  open rc_emps for select employee_id,first_name,last_name,department_name 
                      from employees_copy join departments using (department_id);
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name|| 
            ' is at the department of : '|| r_emps.department_name );
    end loop;
  close rc_emps;
end;
---------------first example of weak ref cursors
declare
  type ty_emps is record (e_id number, 
                         first_name employees_copy.last_name%type, 
                         last_name employees_copy.last_name%type,
                         department_name departments.department_name%type);
 r_emps ty_emps;
 type t_emps is ref cursor;
 rc_emps t_emps;
 q varchar2(200);
begin
  q := 'select employee_id,first_name,last_name,department_name 
                      from employees_copy join departments using (department_id)';
  open rc_emps for q;
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name|| 
            ' is at the department of : '|| r_emps.department_name );
    end loop;
  close rc_emps;
end;
--------------- bind variables with cursors example
declare
  type ty_emps is record (e_id number, 
                         first_name employees_copy.last_name%type, 
                         last_name employees_copy.last_name%type,
                         department_name departments.department_name%type);
 r_emps ty_emps;
 type t_emps is ref cursor;
 rc_emps t_emps;
 r_depts departments%rowtype;
 --r t_emps%rowtype;
 q varchar2(200);
begin
  q := 'select employee_id,first_name,last_name,department_name 
                      from employees_copy join departments using (department_id)
                      where department_id = :t';
  open rc_emps for q using '50';
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name|| 
            ' is at the department of : '|| r_emps.department_name );
    end loop;
  close rc_emps;
  
  open rc_emps for select * from departments;
    loop
      fetch rc_emps into r_depts;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_depts.department_id|| ' ' || r_depts.department_name);
    end loop;
  close rc_emps;
end;
---------------sys_refcursor example
declare
  type ty_emps is record (e_id number, 
                         first_name employees_copy.last_name%type, 
                         last_name employees_copy.last_name%type,
                         department_name departments.department_name%type);
 r_emps ty_emps;
-- type t_emps is ref cursor;
 rc_emps sys_refcursor;
 r_depts departments%rowtype;
 --r t_emps%rowtype;
 q varchar2(200);
begin
  q := 'select employee_id,first_name,last_name,department_name 
                      from employees_copy join departments using (department_id)
                      where department_id = :t';
  open rc_emps for q using '50';
    loop
      fetch rc_emps into r_emps;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_emps.first_name|| ' ' || r_emps.last_name|| 
            ' is at the department of : '|| r_emps.department_name );
    end loop;
  close rc_emps;
  
  open rc_emps for select * from departments;
    loop
      fetch rc_emps into r_depts;
      exit when rc_emps%notfound;
      dbms_output.put_line(r_depts.department_id|| ' ' || r_depts.department_name);
    end loop;
  close rc_emps;
end;

