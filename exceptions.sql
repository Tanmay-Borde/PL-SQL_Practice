-- EXCEPTIONS --

/*
- Exceptions help to manage/handle run time exceptions
- There are two types of exceptions:
    - Implicit Exception (raised by oracle)
    - Explicit Exception
- It has 3 sections:
    - Declaration section
    - Begin-End section
    - Exception section
- Execution cannot go back to begin-end block from exception section.
- Ways to handle exceptions:
    - Trap.
    - Propagate.
    - Trap & Propagate.

- SYNTAX:
    declare
        ....
    begin
        {An exception occurs here}
    exception
        when exception_name then
            ....
        when others then
    end;
- Three types of exceptions:
    - Predefined Oracle Server Errors.
    - Nonpredefined Oracle Server Errors.
    - User-defined Errors.

- Error Codes:
    - sqlerrm : sql error msg.

NOTE: since the exception occurance throws the execution and stops, the rest of the code does not get executed. Therefore, in such case we can surround the statement with begin end
*/

declare
    v_name varchar2(40);
    v_department_name varchar2(100);
begin
    select first_name into v_name from employees_copy where employee_id = 100;
    select department_id into v_department_name from employees_copy where first_name = v_name;
    dbms_output.put_line('Testing'||v_name||'dept is: '||v_department_name);
exception
    when no_data_found then
    dbms_output.put_line('No employee data found!');
    when too_many_rows then
    dbms_output.put_line('Too many rows founnd.');
    when others then
    dbms_output.put_line('Unexpected Error.');
    dbms_output.put_line(sqlcode||'--> '||sqlerrm);
end;

-- Using begin and end block for the exception bound statement to continue the execution after exception.

declare
    v_name varchar2(40);
    v_department_name varchar2(100);
begin
    select first_name into v_name from employees_copy where employee_id = 100;
    begin
        select department_id into v_department_name from employees_copy where first_name = v_name;
    exception
        when too_many_rows then
        v_department_name := 'Error in dept';
    end;
    dbms_output.put_line('Testing'||v_name||'dept is: '||v_department_name);
exception
    when no_data_found then
    dbms_output.put_line('No employee data found!');
    when too_many_rows then
    dbms_output.put_line('Too many rows founnd.');
    when others then
    dbms_output.put_line('Unexpected Error.');
    dbms_output.put_line(sqlcode||'--> '||sqlerrm);
end;


-- Non-Predefined Exceptions
/*
- Unnamed Exceptions.
- We cannot trap with the error codes.
- We declare exceptions with error codes.
- syntax:
    exception_name EXCPTION;
    pragma exception_init(exception_name, error_code)
- Pragma: is a compiler directive which directs the compiler for exceptions.
- scope within the block
*/

select * from employees_copy;

desc employees_copy;

declare
    cannot_update_to_null exception;
    pragma exception_init(cannot_update_to_null, -01407);
begin
    update employees_copy set job_id = null where employee_id = 102;
exception
    when cannot_update_to_null then
        dbms_output.put_line('Cannot update a null value Tanmay');
end;


-- User defined exception and raising the exception
/*
- Need to handle some exceptions by raising the exception manually.
- These exceptions are not an error for the DB.
- Define user-defined exception and then raise it explicitely.
- Syntax:
    exception_name EXCEPTION;
    RAISE exception_name;
*/

declare
    too_high_salary exception;
    v_salary_check pls_integer;
begin
    select salary into v_salary_check from employees_copy where employee_id = 100;
    if v_salary_check > 20000 then
        raise too_high_salary;
    end if;
    dbms_output.put_line('Salary is accepted.')
exception
    when too_high_salary then
        dbms_output.put_line('This is salary is too high.');
end;

----------------- raising a predefined exception

declare
  too_high_salary exception;
  v_salary_check pls_integer;
begin
  select salary into v_salary_check from employees_copy where employee_id = 100;
  if v_salary_check > 20000 then
    raise invalid_number;
  end if;
  --we do our business if the salary is under 2000
  dbms_output.put_line('The salary is in an acceptable range');
exception
  when invalid_number then
    dbms_output.put_line('This salary is too high. You need to decrease it.');
end;


----------------- raising inside of the exception

declare
  too_high_salary exception;
  v_salary_check pls_integer;
begin
  select salary into v_salary_check from employees_copy where employee_id = 100;
  if v_salary_check > 20000 then
    raise invalid_number;
  end if;
  --we do our business if the salary is under 2000
  dbms_output.put_line('The salary is in an acceptable range');
exception
  when invalid_number then
    dbms_output.put_line('This salary is too high. You need to decrease it.');
 raise;
end;


-- RAISE_APPLICATION_ERROR Procedure
/*
- excption cannot go out of block, but this raises the error to the caller
- raise_appliucation_error() raises the error to the caller
- SYNTAX:
    raise_application_error(error_number, error_msg[,TRUE|FALSE]);
- Error Stack: multiple sub-programs can cause multiple exception raise, so a stack trace is maintained in error stack which is maintained by the TRUE/FALSE(default) paramter. True will append the current erorr in the error stack and false will remmove all the previous errors and only keep the current error in the stack.
- this stops the execution when raised so need to handle the this exception.
- Error numbers must be between -20000 and -20999.
- Msg should be a string upto 2048 byts long.
*/

declare
too_high_salary exception;
v_salary_check pls_integer;
begin
    select salary into v_salary_check from employees_copy where employee_id = 100;
    if v_salary_check > 20000 then
    --raise too high salary;
    raise_application_error(-20243, 'The Salary is too high for then employee.');
    end if;
    dbms_output.put_line('Salary is acceptable.');
exception
    when too_high_salary then
    dbms_output.put_line('This salary is too high, decrease it.');
end;
