--sequence to add value for purchase number
CREATE SEQUENCE purchases_seq
MAXVALUE 999999
START WITH 100015
INCREMENT BY 1
ORDER
NOCACHE
NOCYCLE;

--sequence to add value for supplies ID
CREATE SEQUENCE supplies_seq
MAXVALUE 9999
START WITH 1010
INCREMENT BY 1
ORDER
NOCACHE
NOCYCLE;

--sequence to add value for log number
CREATE SEQUENCE logs_seq
MAXVALUE 99999
START WITH 10001
INCREMENT BY 1
ORDER
NOCACHE
NOCYCLE;