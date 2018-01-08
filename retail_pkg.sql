--[1]START OF PACKAGE SPECIFICATION
create or replace package retail_pkge as

--[2]procedure declaration to delete purchase
procedure delete_purchase(pur_id  purchases.pur#%type,
out_message OUT varchar);

--[3]procedure declaration to add customer
procedure add_customer (
c_id in customers.cid%type, 
c_name in customers.name%type,
c_telephone# in customers.telephone#%type,
out_message OUT varchar);

--[4]procedure declaration to add purchase
procedure add_purchase(
e_id  purchases.eid%type,
p_id  purchases.pid%type,
c_id  purchases.cid%type,
pur_qty  purchases.qty%type,
out_message OUT varchar);

--[5]procedure declaration to show employee name
--This procedure is used to display Name before printing
--monthly activities table so as to avoid name duplicates.
procedure show_emp_name(
emp_id employees.eid%type, 
out_emp_name OUT varchar);

--[6]function declaration to return purchase saving  
function purchase_saving(pur_id number) return float;

--[7]function declaration to return employee's monthly sale activities 
function monthly_sale_activities(emp_id employees.eid%type) return sys_refcursor;

--[8]function declaration to show purchases table 
function show_purchases return sys_refcursor;

--[9]function declaration to show employees table
function show_employees  return sys_refcursor;

--[10]function declaration to show customers table
function show_customers return sys_refcursor;

--[11]function declaration to show products table
function show_products return sys_refcursor;

--[12]function declaration to show suppliers table
function show_suppliers return sys_refcursor;

--[13]function declaration to show supplies table
function show_supplies return sys_refcursor;

--[14]function declaration to show discounts table 
function show_discounts return sys_refcursor;

--[15]function declaration to show logs table
function show_logs return sys_refcursor;

end retail_pkge;
/
--[16]END OF PACKAGE SPECIFICATION

--[17]START OF PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY retail_pkge as

--[18]procedure definition to delete purchase
procedure delete_purchase(pur_id  purchases.pur#%type,
out_message OUT varchar) as
NO_VALUE Exception;
begin
  if pur_id is null then
    raise NO_VALUE;
    else
  delete from purchases where pur# = pur_id;
  out_message := 'success';
  end if;
  
exception
  when NO_VALUE then
    dbms_output.put_line('Purchase# not Passed');
    out_message := 'Purchase# not Passed';
end delete_purchase;

--[19]function definition to show purchases table
function show_purchases  return sys_refcursor as 
ret_cur sys_refcursor;
begin

open ret_cur for select * from purchases;
return ret_cur;
end show_purchases;

--[20]function definition to show employees table
function show_employees  return sys_refcursor as 
ret_cur sys_refcursor;
begin

open ret_cur for select * from employees;

return ret_cur;
end show_employees;

--[21]function definition to show customers table
function show_customers return sys_refcursor as 
ret_cur sys_refcursor;
begin

open ret_cur for select * from customers;

return ret_cur;
end show_customers;

--[22]function definition to show products table
function show_products return sys_refcursor as 
ret_cur sys_refcursor;
begin

open ret_cur for select * from products;

return ret_cur;
end show_products;

--[23]function definition to show suppliers table
function show_suppliers return sys_refcursor as
ret_cur sys_refcursor;
begin

open ret_cur for select * from suppliers;

return ret_cur;
end show_suppliers;

--[24]function definition to show supplies table
function show_supplies return sys_refcursor as
ret_cur sys_refcursor;
begin

open ret_cur for select * from supplies;

return ret_cur;
end show_supplies;

--[25]function definition to show discounts table
function show_discounts return sys_refcursor as
ret_cur sys_refcursor;
begin

open ret_cur for select * from discounts;

return ret_cur;
end show_discounts;

--[26]function definition to show logs table
function show_logs return sys_refcursor as
ret_cur sys_refcursor;
begin

open ret_cur for select * from logs;

return ret_cur;
end show_logs;

--[27]function definition to show purchase saving
function purchase_saving (pur_id in number) 
return float
is Saving float;
begin
Select ((products.original_price * purchases.qty ) - purchases.total_price) into Saving
from purchases inner join products on purchases.pid = products.pid and purchases.pur# = pur_id;
return(Saving);
end purchase_saving;


--[28]function definition to show employee's monthly activity
function monthly_sale_activities(emp_id
employees.eid%type)
return sys_refcursor 
as
mon_cur sys_refcursor;
e_name employees.name%type;
cnt number;
NO_VALUE Exception;

begin
if emp_id is null then
raise NO_VALUE;
else
select count(*) into cnt from employees where employees.eid = emp_id;

if cnt = 0 then
dbms_output.put_line('Employee ID does not exist');
else
select employees.name into e_name from employees 
where employees.eid = emp_id;

open mon_cur for
select to_char(ptime,'MON') as Month,
to_char(ptime,'YYYY') as Year,
count(purchases.eid) as total_sales_made,
sum(qty) as total_qty_sold,
sum(total_price) as total_amt
from purchases,employees
where employees.eid = emp_id and purchases.eid = employees.eid
group by
employees.eid,employees.name,to_char(ptime,'MON'),to_char(ptime,'YYYY');
end if;
end if;
return mon_cur;

exception
when NO_VALUE then
dbms_output.put_line('Employee ID not entered');
end monthly_sale_activities;


--[29]procedure definition to show employee's name
procedure show_emp_name(
emp_id employees.eid%type,
 out_emp_name OUT varchar)
 as
e_name employees.name%type;
ln_count number;
NO_EXIST Exception;
begin
	select count(emp_id) into ln_count from employees where eid = emp_id;
	if (ln_count = 0) then
    		raise NO_EXIST;
    else
	select name into e_name from employees where eid = emp_id;
	dbms_output.put_line(e_name);
	out_emp_name := e_name;
	end if;
	
exception
  when NO_EXIST then
	out_emp_name := 'none';
    dbms_output.put_line('Employee ID does not exist');
end show_emp_name;




--[30]procedure definition to add customer
procedure add_customer (
c_id in customers.cid%type, 
c_name in customers.name%type,
c_telephone# in customers.telephone#%type,
out_message OUT varchar) 
as
v_count PLS_INTEGER := 0;
v_visits PLS_INTEGER := 1;

begin
select count(*) into v_count from customers where cid = c_id; 

if v_count = 0 
then
insert into customers values (c_id, c_name, c_telephone#, v_visits, sysdate);
out_message := 'Customer inserted successfully';

else
out_message := 'Customer already exists';

end if;
 end add_customer;



--[31]procedure definition to add purchase
procedure add_purchase(e_id  purchases.eid%type,
p_id  purchases.pid%type,
c_id  purchases.cid%type,
pur_qty  purchases.qty%type,
out_message OUT varchar
)  
as
  v_total_price    number(8, 2);
  v_pur_id          number(6);
  v_original_price number(6, 2);
  v_discnt_rate    number(3, 2);
  v_total_qoh      number(5);
  ln_qoh		   products.qoh%type;
  ln_qoh_threshold products.qoh_threshold%type;
  s_sid			   supplies.sid%type;
  M 			   number;
  ln_quantity      supplies.quantity%type;
begin
  select products.original_price, discounts.discnt_rate
  into v_original_price,v_discnt_rate
  from products
  join discounts
  on products.discnt_category = discounts.discnt_category
  and products.pid = p_id;
  
  v_total_price := (v_original_price * (1 - v_discnt_rate)) * pur_qty;
  
  select qoh into v_total_qoh from products where pid = p_id;

  if pur_qty < v_total_qoh then
    v_pur_id := purchases_seq.nextval;
	insert into purchases values
    (v_pur_id, e_id, p_id, c_id, pur_qty, SYSDATE, v_total_price);
    out_message := '1';
    dbms_output.put_line('Purchase inserted Successfully');
		update products p set p.qoh = p.qoh - pur_qty where p.pid = p_id;
		select qoh, qoh_threshold 
		into ln_qoh,ln_qoh_threshold
		from products 
		where pid = p_id;
		if ln_qoh < ln_qoh_threshold then
   		 out_message := '2';
		 dbms_output.put_line('The product QOH is below QOH_THRESHOLD');
		M := (ln_qoh_threshold - ln_qoh) + 1;
		select supplies.sid into s_sid from supplies where pid = p_id and rownum = 1 order by supplies.sid;
		insert into supplies values
		(supplies_seq.nextval,p_id,s_sid,sysdate, M+10+ln_qoh) returning quantity into ln_quantity;
		update products set qoh = qoh + ln_quantity where pid = p_id;
		 dbms_output.put_line('Required Product Order placed succesfully');
	end if;
  
  else
    out_message := '3';
    dbms_output.put_line('Insufficient quantity in stock');
  end if;
end add_purchase;

end retail_pkge;
/
--[32]END OF PACKAGE BODY




