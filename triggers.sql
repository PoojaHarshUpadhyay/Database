--[1]TRIGGER TO UPDATE QOH in [PRODUCTS] AND LAST_VISIT_DATE,VISITS_MADE IN [CUSTOMERS] if a [PURCHASES] is DELETED
create or replace trigger del_pur
before delete on purchases
for each row
begin
	update products p set p.qoh = p.qoh + :old.qty where p.pid = :old.pid;
	update customers s set s.visits_made = s.visits_made + 1,s.last_visit_date = sysdate
	where s.cid = :old.cid;
end;
/



--[2]TRIGGER TO INSERT NEW TUPLE in [LOGS] if a NEW [CUSTOMERS] is INSERTED
create or replace trigger cus_log_entry
after insert on customers
for each row
begin
insert into logs 
values(logs_seq.nextval,user,'insert',current_timestamp,'customers',:new.cid);
end;
/

--[3]TRIGGER TO INSERT NEW TUPLE in [LOGS] if LAST_VISIT_DATE IN [CUSTOMERS] is UPDATED
create or replace trigger cus_log_update
after update of last_visit_date on customers
for each row
begin
insert into logs values
(logs_seq.nextval,user,'update',current_timestamp,'customers',:new.cid);
end;
/

--[4]TRIGGER TO INSERT NEW TUPLE in [LOGS] if a NEW [PURCHASES] is INSERTED
--[5]TRIGGER TO UPDATE QOH in [PRODUCTS] AND LAST_VISIT_DATE,VISITS_MADE IN [CUSTOMERS] if a [PURCHASES] is INSERTED
create or replace trigger pur_log_entry
after insert on purchases
for each row
begin
	insert into logs values
	(logs_seq.nextval,user,'insert',current_timestamp,'purchases',:new.pur#);
	--update products p set p.qoh = p.qoh - :new.qty where p.pid = :new.pid;
	update customers s set s.visits_made = s.visits_made + 1,
	s.last_visit_date = sysdate
	where s.cid = :new.cid;
end;
/

--[6]TRIGGER TO INSERT NEW TUPLE in [LOGS] if QOH IN [PRODUCTS] is UPDATED
create or replace trigger prod_log_update
after update of qoh on products
for each row
declare
	s_sid supplies.sid%type;
	M number;
begin 
	insert into logs values
	(logs_seq.nextval,user,'update',current_timestamp,'products',:new.pid);
end;
/

--[7]TRIGGER TO INSERT NEW TUPLE in [LOGS] if a NEW [SUPPLIES] is INSERTED
create or replace trigger supplies_log_entry
after insert on supplies
for each row
declare
	q_qoh products.qoh%type;
begin
	insert into logs values(logs_seq.nextval,user,'insert',current_timestamp,'supplies',:new.sup#);
	--update products set qoh = qoh + :new.quantity where pid = :new.pid;
	select qoh into q_qoh from products where pid = :new.pid;
	dbms_output.put_line('New QOH of Product '||:new.pid||' is '||q_qoh);
end;
/
