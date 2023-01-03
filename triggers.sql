/*
- Triggers are PL/SQL blocks that executed before or after or instead of a specific event.
- Triggers are executed automatically by the DB server.
- Triggers are defined on tables, views, schemas, DB.
- Triggers are fired when one of these occurs:
    - When a DML(insert, update, delete) occurs.
    - When a DDL(create, alter, drop) occurs.
    - When some db operations occurs(logon, startup, servererror,...)
    - These are called as DB triggers
- Application triggers are related with some applictaions like Oracle forms,...
- Why to use triggers?
    - Security
    - Auditing
    - Data Integrity
    - Table Logging
    - Synchronous Table replication
    - Event Logging
    - Derived Data
- Types of Triggers:
    - DML Triggers : has 3 branches - before trigger, after trigger and instead trigger.
    - Compound Triggers
    - Non-DML Triggers : has 2 branches - DDL event triggers and DB event triggers.
- Summary: We use triggers to test the data before the DML, or secure the data and DB from the wrong usages, or copy, duplicate data for log tables etc.
    It can be used for before, after and instead of logic.
*/
-------------------------------- DML TRIGGERS --------------------------------
/* DML triggers are bounded to a table of view.
Syntax:
    CREATE [OR REPLACE] TRIGGER trigger_name
        timing = BEFORE | AFTER | INSTEAD OF
        EVENT = INSERT | UPDATE | DELETE | UPDATE OF column_list ON object_name
        [REFERENCING OLD AS old NEW AS new]
        [FOR EACH ROW]
        [DECLARE variables, types, etc]
    BEGIN
        trigger_body
        [EXCEPTION]
    END;

- Timing : 
    - BEFORE     : can allow or reject the specified action. Can specify default values for the columns. Can validate complex business rules.
    - After      : Make some after checks. Duplicate tables or add log records.
    - INSTEAD OF : runs the trigger instead of running the event.
    - Multiple triggers with the same timing points can be applied to a table or view depending on the order of operation.
    - If order of operation of a particular timing condition has precedence, then it should be writtedn within a single trigger.
*/


create or replace trigger "secure_employees"
    before insert or update or delete on employees_copy
BEGIN
    secure_dml;
end secure_employees;

create or replace trigger first_trigger 
before insert or update on employees_copy 
begin
  print('An insert or update occured in the employees_copy table.');
end;

update employees_copy set salary = salary + 100;
select * from employees_copy;
delete from employees_copy;
select * from employees_copy;

-- Statement level and row level trigger

-- Flow of trigger execution:
    -- Before statement triggers
    -- Before row trigger for each row
    -- after row trigger for each row
    -- after statement triggers

-- Statement level trigger is executed only once. Since statement-level trigger fires on the execution of whole statement, it does not have old and new values of the columns.
-- Row level trigger is executed on each row and the old and new values are stored in the implicitly created records.
-- Table and view can have both statement and row-level triggers together with different triggers.

create or replace trigger before_statement_emp_cpy
    before insert or update on employees_copy
    begin
        print('before statement trigger is fired!');
    end;

create or replace trigger after_statement_emp_cpy
    after insert or update on employees_copy
    begin
        print('after statement trigger is fired!');
    end;

create or replace trigger after_row_emp_cpy
    after insert or update on employees_copy
    for each row
    begin
        print('after row trigger is fired!');
    end;

create or replace trigger before_row_emp_cpy
    before insert or update on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
    end;

update employees_copy set salary = salary + 100;

update employees_copy set salary = salary + 100 where employee_id = 100;    -- both statement and row triggers fired once.

update employees_copy set salary = salary + 100 where employee_id = 99;     -- 99 is not present, so only statment triggers fired.

update employees_copy set salary = salary + 100 where department_id = 30;   -- statement trigger fired once, row triggers fired for each row.

-- USING :NEW AND :OLD QUALIFIERS IN TRIGGERS
/*
- :NEW & :OLD qualifiers are used only for row level triggers.
- :old.column_name returns the old value of the column.
- :new.column_name returns the new value of the column.
- old and new values of the columns are implicitly stored by the oracle server in two different records based on the %rowtype.
- Alias can be assigned to :old and :new qualifiers.
- if data operation : INSERT -> OLD value = NULL -> NEW value = Inserted value
- if data operation : UPDATE -> OLD value = value before updation -> NEW value = updated value
- if data operation : UPDATE -> OLD value = value before deletion -> NEW value = NULL
- We can use old and new qualifiers to reach the columns.
- We can use old and new qualifiers in an SQL query in your trigger, or in a PL/SQL statement.
- Row level triggers may decrease the performance of your code if so may inserts, updates or deletes occurs.
- Colon prefix before the old and new qualifiers ar enot used in the when condition.
*/

alter table employees_copy disable all triggers;

create or replace trigger before_row_emp_cpy
    before insert or update on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
    end;

update employees_copy set salary = salary + 100 where department_id = 30;

create or replace trigger before_row_emp_cpy
    before insert or delete on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
    end;

delete from employees_copy;
insert into employees_copy select * from employees_copy;

-- USING REFERENCING ALIAS FOR OLD AND NEW QUALIFIERS

create or replace trigger before_row_emp_cpy
    before insert or delete on employees_copy
    referencing old as O new as N
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :O.employee_id || '-> Before : ' || :O.salary || '  After : '|| :N.salary);
    end;

alter table employees_copy enable all triggers;

-------- CONDITIONAL PREDICATES -----------------
/* 
- Even though multiple timely events can be created for a trigger, but at once, only one of them will be occuring, either it will be insert/update or delete.
- To condition the business logic inside the trigger as per the event, we can use conditional predicate like:
    - inserting
    - updating
    - deleting
*/

create or replace trigger before_row_emp_cpy
    before insert or delete on employees_copy
    referencing old as O new as N
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :O.employee_id || '-> Before : ' || :O.salary || '  After : '|| :N.salary);
        if inserting then
            print('An INSERT operation was done on employees_copy table.');
        elsif updating then
            print('An UPDATE operation was done on employees_copy table.');
        elsif deleting then
            print('A DELETE operation was done on employees_copy table.');
    end if;
end;

-- removing the reference alias of the old and new qualifiers
create or replace trigger before_row_emp_cpy
    before insert or delete on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
        if inserting then
            print('An INSERT operation was done on employees_copy table.');
        elsif updating then
            print('An UPDATE operation was done on employees_copy table.');
        elsif deleting then
            print('A DELETE operation was done on employees_copy table.');
    end if;
end;
-- Testing
select * from employees_copy;
delete from employees_copy;
insert into employees_copy select * from employees;


drop table employees_copy;
create table employees as select * from hr.employees where 1=2;
create table employees_copy as select * from employees where 1=2;
insert into employees select * from hr.employees;
insert into employees_copy select * from employees;
select * from employees_copy;

-- Using conditional predicates : inserting/updating/deleting
create or replace trigger before_row_emp_cpy
    before insert or delete on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
        if inserting then
            print('An INSERT operation was done on employees_copy table.');
        elsif updating then
            print('An UPDATE operation was done on employees_copy table.');
        elsif deleting then
            print('A DELETE operation was done on employees_copy table.');
    end if;
end;
-- Testing
select * from employees_copy;
delete from employees_copy;
insert into employees_copy select * from employees;

-- Conditional Predicate on specific column
create or replace trigger before_row_emp_cpy
    before insert or update or delete on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
        if inserting then
            print('An INSERT operation was done on employees_copy column.');
        elsif updating ('salary') then  -- conditional predicate on specific column
            print('An UPDATE operation was done on salary column.');
        elsif updating then  -- conditional predicate on any column
            print('An UPDATE operation was done on employees_copy table.');
        elsif deleting then
            print('A DELETE operation was done on employees_copy table.');
    end if;
end;

-- test
desc employees_copy;
select * from employees_copy;
update employees_copy set salary =  salary + 100 where department_id = 30;
update employees_copy set commission_pct = 0.8 where department_id = 30;

------------------------------ Using exceptions in Trigger --------------------------------------
raise_application_error(-20003, 'An application error is raised.')

create or replace trigger before_row_emp_cpy
    before insert or update or delete on employees_copy
    for each row
    begin
        print('before row trigger is fired!');
        print('The Salary of employee '|| :old.employee_id || '-> Before : ' || :old.salary || '  After : '|| :new.salary);
        if inserting then
            if :new.hire_date > sysdate then
                raise_application_error(-20000,'You cannot enter a future hire...');
            end if;
            print('An INSERT operation was done on employees_copy column.');
        elsif updating ('salary') then  -- conditional predicate on specific column
            if :new.salary > 50000 then
                raise_application_error(-20002,'A salary cannot be higher than 50000');
            end if;
            print('An UPDATE operation was done on salary column.');
        elsif updating then  -- conditional predicate on any column
            print('An UPDATE operation was done on employees_copy table.');
        elsif deleting then
            print('A DELETE operation was done on employees_copy table.');
    end if;
end;
-- Testing
select * from employees_copy;
update employees_copy set salary = 80000 where employee_id = 184;

-- Raising application error to prevent updating a column value
create or replace trigger prevent_updates_of_constant_columns
    before update of hire_date on employees_copy
    for each row
    begin
        raise_application_error(-20005, 'You cannot modify the hire Date!');
    end;

-- TESTING
update employees_copy set hire_date = sysdate;

-- Raising application error to prevent updating ,ultiple column values
create or replace trigger prevent_updates_of_constant_columns
    before update of hire_date, salary on employees_copy
    for each row
    begin
        raise_application_error(-20005, 'You cannot modify the hire Date and Salary columns!');
    end;


create or replace trigger prevent_updates_of_constant_columns
    before update of hire_date, salary on employees_copy
    for each row
    begin
        raise_application_error(-20005, 'You cannot modify the hire Date and Salary columns!');
    end;

-- To gain performance for row level triggers, we can use trigger for specific event on specific column
create or replace trigger prevent_high_salary
    before insert or update of salary on employees_copy     -- putting clause for specific column, increases efficiency
    for each row
    when(new.salary > 50000)                                -- body will be executed only if true else not, so further increasing the efficiency.
begin
    raise_application_error(-20006,'A salary cannot be higher than 50000!');
END;

-- INSTEAD OF TRIGGERS
/*
- Simple Views enable DML operations, but complex views do not.
- 'Instead of' triggers are used to apply some DML statements on un-updatable views.
- Some important things about the instead of triggers:
    - Instead of triggers are used only with the views, especially with complex views.
    - If your view has a 'CHECK' option (usually applied on views for data integrity and security), it won't be enforced when you use the 'INSTEAD OF' triggers.
    - 'BEFORE' and 'AFTER' timing options are not valid for instead of triggers.
*/
create table departments_copy as select * from departments;
select * from departments_copy;

create or replace view vw_emp_details as
    select upper(department_name) dname, min(salary) min_sal, max(salary) max_sal
    from employees_copy join departments_copy
    using(department_id)
    group by department_name;       -- group by clause makes it a complex view, not modifiable by DML operations.

select * from vw_emp_details;

update vm_emp_details set dname = 'exec dept' where upper(dname) = 'EXECUTIVE';     -- THIS DML OPERATION WILL NOT WORK SINCE ITS A COMPLEX VIEW AND NOT SIMPLE VIEW

-- SINCE COMPLEX VIEWS CANNOT BE MODIFIED DUE TO INABILITY OF PERFORMING DML OPERATIONS ON COMPLEX VIEWS, TO COUNTER THIS WE CAN CREATE A TRIGGER USING 'INSTEAD OF' WHICH ENABLES US TO PERFORM DML OPERATIONS ON COMPLEX VIEWS, AS SHOWN BELOW.
create or replace trigger emp_details_vw_dml
    instead of insert or update or delete on vw_emp_details     -- TRIGGERS FOR DML OPERATIONS BEING PERFORMED ON THE COMPLEX VIEWS
    for each row
    DECLARE
        v_dept_id pls_integer;
    BEGIN
        if inserting then
            select max(department_id) + 10 into v_dept_id from departments_copy;
            insert into departments_copy values(v_dept_id, :new.dname);
        elsif deleting then
            delete from departments_copy where upper(department_name) = upper(:old.dname);
        elsif updating('DNAME') then
            update departments_copy set department_name = :new.dname where upper(department_name) = upper(:old.dname);
        else
            raise_application_error(-20007,'You cannot update any data other than department name!');
        end if;
    END;
-- testing
select * from departments_copy;
update vw_emp_details set dname = 'exec dept' where upper(dname) = 'EXECUTIVE';
select * from departments_copy;
delete from vw_emp_details where dname = 'EXEC DEPT';
insert into vw_emp_details values('Execution',null,null);

-- EXPLORING AND MANAGING THE TRIGGERS --
/*
- There are two data dictionary views for the triggers:
    - USER_OBJECTS
    - USER_TRIGGERS
- To enable or disable a trigger:
    - ALTER TRIGGER trigger_name ENABLE | DISABLE;
    - ALTER TABLE base_object_name [ENABLE | DISABLE] ALL TRIGGERS;     -- comes handy when we need to disable triggers on a table temporarily to perofrm any action.
    - ALTER TRIGGER trigger_name COMPILE;
    - DROP TRIGGER trigger_name;
- Four states of a trigger:
    - Invalid: trigger prevents the DMLs and needs to be validated as soon as posiible.
    - Valid: trigger allows the DMLs and works without any error.
    - Enabled: trigger is in action and will work as expected.
    - Disabled: trigger is not in action but still it does NOT prevent DML operations on table, user can do his/her job.
        - (Note: Disabling a trigger comes handy for few scenarios like copying the table data or making huges data loads faster etc.)
*/
select * from user_triggers;
-- Disabling a trigger
create or replace trigger prevent_high_salary
    before insert or update of salary on employees_copy     -- putting clause for specific column, increases efficiency
    for each row
    disable
    when(new.salary > 50000)                                -- body will be executed only if true else not, so further increasing the efficiency.
begin
    raise_application_error(-20006,'A salary cannot be higher than 50000!');
END;

-- Real world DML Triggers
select * from departments_copy;

create sequence seq_dep_cpy
    start with 290
    increment by 10;

create or replace trigger trg_before_insert_dept_cpy
    before insert on departments_copy
    for each row
    begin
        -- select seq_dep_cpy.nextval into :NEW.department_id from dual;
        -- OR
        :NEW.department_id := seq_dep_cpy.nextval;   -- alternative method
    END;

-- Testing
select * from departments_copy;
insert into departments_copy(department_name, manager_id, location_id)
    values('Security', 200, 1700);

-- Log table for trigger
/*
Log table of the trigger should contain:
- who made the modification
- when he/she did it
- what is the type of that DML operation
*/

desc departments_copy;
create table log_departments_copy(log_user varchar2(30), log_date date, dml_type varchar2(10),
old_department_id number(4), new_depafrtment_id number(4),
old_department_name varchar2(30), new_department_name varchar2(30));

desc log_departments_copy;

insert into departments_copy(department_name) values('Cyber Security');

create or replace trigger trg_departments_copy_log
    after insert or update or delete on departments_copy        -- using 'after' to avoid trigger rollback if insertion error occurs and to get nextval of sequence.
    for each row
    declare
        v_dml_type varchar2(10);
begin
    if inserting then
        v_dml_type := 'INSERT';
    elsif updating then
        v_dml_type := 'UPDATE';
    elsif deleting then
        v_dml_type := 'DELETE';
    end if;
    insert into log_departments_copy values
    (user, sysdate, v_dml_type,
    :old.department_id, :new.department_id,
    :old.department_name, :new.department_name);
end;
select * from log_departments_copy;
insert into departments_copy(department_name) values('Data Scientist');
update departments_copy set manager_id = 200 where department_name = 'Data Engineer';
deleet from departments_copy where department_name = 'Data Scientist';
-- try rolling back and then again check:
select * from log_departments_copy;

---- COMPOUND TRIGGERS ----
/*
- Compound trigger is a single trigger on a table/view that allows us to specify actions for each DML trigger types.
- So they can share the variables, types etc among each other.
- Regular trigger approach has some cons including computing time.

- Earlier approach:
    CREATE OR REPLACE TRIGGER schema.trigger FOR dml_event_clause ON schema.table COMPOUND TRIGGER
    -- Initialization section
        -- Declaration area
        -- subprograms
    
    before statement is
    ...
    end before statement;

    after statement is
    ...
    end after statement;
    
    before each row is
    ...
    end before each row;

    after each row is
    ...
    end after each row;

- Why use the compound triggers?
    - Taking actions for various timing points by sharing the common data.
    - Making inserts to some other tables faster with bulk inserts.
    - Avoiding mutating table errors.
- Restrictions of Compound Triggers:
    - A compound trigger must be a DML trigger (and cannot be DDL trigger) defined on a table or view.
    - A compound trigger body must be a compound trigger block.
    - A compound trigger body cannot have an initialization block.
    - :OLD and :NEW cannot be used in the declaration or before or after statements.
    - The firing order of compound triggers is not guranteed if you don't use the follows clause.
    - There should be at least 1 DML type trigger section (before statement/after statement/before each row/after each row) in the compound trigger.
    - Syntax:
        CREATE [OR REPLACE] TRIGGER trigger_name
        FOR INSERT | UPDATE | DELETE | UPDATE OF column_list
            ON object_name
            [REFERENCING OLD AS old NEW AS new]
            [WHEN (condition)]
        COMPOUND TRIGGER
            [variables, types,etc]
            BEFORE STATEMENT IS
                PL/SQL BLOCK
            [EXCEPTION]
            END BEFORE STATEMENT;

            AFTER STATEMENT IS
                PL/SQL BLOCK
            [EXCEPTION]
            END AFTER STATEMENT;

            BEFORE EACH ROW IS
                PL/SQL BLOCK
            [EXCEPTION]
            END BEFORE EACH ROW;

            AFTER EACH ROW IS
                PL/SQL BLOCK
            [EXCEPTION]
            END AFTER EACH ROW;
        END;
*/

-- Create a compound trigger on 'employees_copy' which will combine all the trigger DML actions and have a shared common variable 'v_dml_type':
create or replace trigger trg_comp_emps
    for insert or update or delete on employees_copy
    compound trigger
        v_dml_type varchar2(10);
    before statement is
        BEGIN
            if inserting then
                v_dml_type := 'INSERT';
            elsif updating then
                v_dml_type := 'UPDATE';
            elsif deleting then
                v_dml_type := 'DELETE';
            end if;
            print('Before statement section is executed with the '||v_dml_type||' event.');
    end before statement;

    before each row is
        x number;
        begin
            print('Before each row section is executed with the '||v_dml_type||' event.');
    end before each row;

    after each row is
        begin
            print('After each row section is executed with the '||v_dml_type||' event.');
    end after each row;

    after statement is
    begin
        print('After statement section is executed with the '||v_dml_type||' event.');
    end after statement;
END;
-- Testing
delete from employees_copy where department_id = 30;

-- Create a trigger that will check the salary of the employee after the updates and inserts on the table. If the salary is greater than 15% of the avg salary of the departmnet
-- then this compound trigger will prevent the update or insert operation on the 'employees_copy' table.
CREATE OR REPLACE TRIGGER TRG_EMP_SAL_CHECK
    FOR INSERT OR UPDATE OR DELETE ON EMPLOYEES_COPY
    COMPOUND TRIGGER
        TYPE T_AVG_DEPT_SALARIES IS TABLE OF EMPLOYEES_COPY.SALARY%TYPE INDEX BY PLS_INTEGER;
        AVG_DEPT_SALARIES T_AVG_DEPT_SALARIES;

    BEFORE STATEMENT IS
        BEGIN
            FOR AVG_SAL IN (SELECT AVG(SALARY) SALARY, NVL(DEPARTMENT_ID, 999) DEPARTMENT_ID
                                FROM EMPLOYEES_COPY GROUP BY DEPARTMENT_ID)
            LOOP
                AVG_DEPT_SALARIES(AVG_SAL.DEPARTMENT_ID) := AVG_SAL.SALARY;
            END LOOP;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
        V_INTERVAL NUMBER := 15;
        BEGIN
            IF :NEW.SALARY > AVG_DEPT_SALARIES(:NEW.DEPARTMENT_ID)+AVG_DEPT_SALARIES(:NEW.DEPARTMENT_ID)*V_INTERVAL/100 THEN
            RAISE_APPLICATION_ERROR(-20005,'A raise cannot be '||V_INTERVAL||' percent higher than its departments average!');
            END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        PRINT('All the changes are done successfully!');
    END AFTER STATEMENT;
END;
-- testing
alter trigger prevent_updates_of_constant_columns disable;
update employees_copy set salary = salary + 5 where employee_id = 154;
update employees_copy set salary = salary + 16000 where employee_id = 154;

/*
- MUTATING TABLE ERRORS
    - Mutating table error is deliberately thrown by oracle to prevent concurrent/parallel data manipulation on a row, and enable data consistency.
    - A table that is being modified or a table that is being updated with the DELETE CASCADE is called a mutating table.
    - Row level (before row or after row) triggers cannot query or modify a mutating table.
    - This restriction prevents inconsistent data changes.
    - Views being modified by the instead of triggers are not considered as mutating.
    - To handle mutating table errors:
        - Store related data in another table.
        - Store related data in a paackage.
        - use compound triggers.
        - Write the DML query in the 'before statement' or 'after statment' only and not in 'before row' or 'after row'.
    - Do not use a DML query same as the trigger action type and on same table, will cause an error due to recursive trigger call within the same trigger.
*/
-- create a trigger which will cause mutating table error for insert and update.
-- THIS TRIGGER WILL CAUSE MUTATING TABLE ERROR AND RECURSIVE TRIGGER CALL ERROR.
CREATE OR REPLACE TRIGGER trg_mutating_emps
    BEFORE INSERT OR UPDATE ON employees_copy
    FOR EACH ROW
    DECLARE
        v_interval NUMBER := 15;
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary) INTO v_avg_salary FROM employees_copy WHERE department_id = :NEW.department_id;
        UPDATE EMPLOYEES_COPY SET 
        IF :NEW.salary > v_avg_salary + v_avg_salary*v_interval/100 THEN
            raise_application_error(-20005,'A raise cannot be '||v_interval||' percent higher than its department''s avg');
        END IF;
END;
-- testing
alter table employees_copy disable all triggers;
update employees_copy set salary = salary + 1000 where employee_id = 154;


-- Modifying TRG_COMP_EMPS to solve the above mutating table error issue:
create or replace TRIGGER TRG_EMP_SAL_CHECK
    FOR INSERT OR UPDATE ON EMPLOYEES_COPY
    COMPOUND TRIGGER
        TYPE T_AVG_DEPT_SALARIES IS TABLE OF EMPLOYEES_COPY.SALARY%TYPE INDEX BY PLS_INTEGER;
        AVG_DEPT_SALARIES T_AVG_DEPT_SALARIES;

    BEFORE STATEMENT IS
        BEGIN
            DELETE FROM EMPLOYEES_COPY WHERE EMPLOYEE_ID = 100;
            FOR AVG_SAL IN (SELECT AVG(SALARY) SALARY, NVL(DEPARTMENT_ID, 999) DEPARTMENT_ID
                                FROM EMPLOYEES_COPY GROUP BY DEPARTMENT_ID)
            LOOP
                AVG_DEPT_SALARIES(AVG_SAL.DEPARTMENT_ID) := AVG_SAL.SALARY;
            END LOOP;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
        V_INTERVAL NUMBER := 15;
        BEGIN
            IF :NEW.SALARY > AVG_DEPT_SALARIES(:NEW.DEPARTMENT_ID)+AVG_DEPT_SALARIES(:NEW.DEPARTMENT_ID)*V_INTERVAL/100 THEN
            RAISE_APPLICATION_ERROR(-20005,'A raise cannot be '||V_INTERVAL||' percent higher than its departments average!');
            END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        DELETE FROM EMPLOYEES_COPY WHERE EMPLOYEE_ID = 100;
        PRINT('All the changes are done successfully!');
    END AFTER STATEMENT;
END;


