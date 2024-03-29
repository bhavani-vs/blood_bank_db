CREATE TABLE HOSPITAL (
  H_ID NUMBER(20, 0) NOT NULL,
  USER_ID NUMBER(20, 0) NOT NULL,
  H_NAME VARCHAR2(80 BYTE) NOT NULL,
  H_ADDRESS VARCHAR2(50 BYTE) NOT NULL,
  H_PHONE VARCHAR2(20 BYTE) NOT NULL,
  CONSTRAINT H_ID PRIMARY KEY (H_ID)
);

select
  *
from
  HOSPITAL;

CREATE TABLE PATIENT (
  PT_ID NUMBER(20, 0) NOT NULL,
  USER_ID NUMBER(3, 0) NOT NULL,
  PT_FIRST_NAME VARCHAR2(20 BYTE) NOT NULL,
  PT_LAST_NAME VARCHAR2(20 BYTE),
  PT_ADDRESS VARCHAR2(50 BYTE) NOT NULL,
  PT_TYPE_ID NUMBER(3, 0) NOT NULL,
  PT_GENDER VARCHAR2(6 BYTE) NOT NULL,
  PT_AGE VARCHAR2(20 BYTE) NOT NULL,
  PT_BTYPE VARCHAR2(4 BYTE) NOT NULL,
  PT_STD VARCHAR2(5 BYTE) NOT NULL,
  PT_PHONE VARCHAR2(20 BYTE) NOT NULL,
  CONSTRAINT PT_ID PRIMARY KEY (PT_ID),
  CONSTRAINT USER_ID FOREIGN KEY (USER_ID) REFERENCES USER_CREDS (USER_ID),
  CONSTRAINT PATIENT_TYPE_ID FOREIGN KEY (PT_TYPE_ID) REFERENCES PATIENT_TYPE (PT_TYPE_ID)
);

SELECT
  *
FROM
  PATIENT;

CREATE TABLE INVENTORY (
  H_ID NUMBER(20, 0) NOT NULL,
  PT_BTYPE VARCHAR2(5 BYTE) NOT NULL,
  TOTAL_BLOOD_UNIT NUMBER(5, 0) NOT NULL,
  INVENTORY_ID NUMBER(20, 0) NOT NULL,
  CONSTRAINT INVENTORY_PK PRIMARY KEY (INVENTORY_ID),
  CONSTRAINT INVENTORY_FK1 FOREIGN KEY (H_ID),
  REFERENCES HOSPITAL (H_ID)
);

SELECT
  *
FROM
  INVENTORY;

CREATE TABLE USER_CREDS (
  USER_ID NUMBER NOT NULL,
  PASSWORD VARCHAR2(12 BYTE) NOT NULL,
  USERNAME VARCHAR2(80 BYTE) NOT NULL,
  USER_TYPE_ID NUMBER(3, 0) NOT NULL,
  CONSTRAINT USER_CREDS_PK PRIMARY KEY (USER_ID),
  CONSTRAINT FK FOREIGN KEY (USER_TYPE_ID) REFERENCES USER_TYPE (USER_TYPE_ID)
);

SELECT
  *
FROM
  USER_CREDS;

CREATE TABLE TRANS (
  TRANS_ID NUMBER(20, 0) NOT NULL,
  PT_ID NUMBER(20, 0) NOT NULL,
  T_DATE DATE NOT NULL,
  REQUEST_TYPE_ID NUMBER(20, 0) NOT NULL,
  PT_BTYPE VARCHAR2(4 BYTE) NOT NULL,
  BLOOD_UNIT NUMBER(3, 0) NOT NULL,
  H_ID NUMBER(20, 0) NOT NULL,
  INVENTORY_ID NUMBER(20, 0) NOT NULL,
  CONSTRAINT TRANS_PK PRIMARY KEY (TRANS_ID),
  CONSTRAINT TRANS_FK1 FOREIGN KEY (INVENTORY_ID) REFERENCES INVENTORY (INVENTORY_ID),
  CONSTRAINT TRANS_FK2 FOREIGN KEY (H_ID) REFERENCES HOSPITAL (H_ID),
  CONSTRAINT TRANS_FK3 FOREIGN KEY (REQUEST_TYPE_ID) REFERENCES REQUEST_TYPE (REQUEST_TYPE_ID)
);

SELECT
  *
FROM
  TRANS;

---list of hospitals to donate or receive blood
select
  distinct h.h_name
from
  inventory i
  left join hospital h on i.h_id = h.h_id;

---list of total blood units received by a patient
select
  pt_id,
  sum(blood_unit) as "total_blood _received"
from
  trans
where
  request_type_id = 2
group by
  pt_id;

-----list of patients donating or receiving blood from respective hospitals( hospital wise transaction)
select
  h.h_name,
  sum(blood_unit) as "total_blood_donated"
from
  trans t
  left join hospital h on t.h_id = h.h_id
where
  request_type_id = 1
group by
  h.h_name;

------transactions between 2 dates
select
  *
from
  trans
where
  t_date between '01-may-2017'
  and '01-may-2018';

---total transactions done by population with age <20;
select
  p.pt_age,
  count(pt_age)
from
  trans t
  inner join patient p on t.pt_id = p.pt_id
where
  p.pt_age < 20
group by
  p.pt_age;

--blood type search by location
CREATE
OR REPLACE VIEW BLOOD_TYPE_SEARCH (H_NAME, PT_BTYPE, TOTAL_BLOOD_UNIT) AS
SELECT
  H.H_NAME,
  I.PT_BTYPE,
  I.TOTAL_BLOOD_UNIT
FROM
  HOSPITAL H
  INNER JOIN INVENTORY I ON H.H_ID = I.H_ID;

select
  *
from
  Blood_type_search;

-------Stored Procedure ( Determining the inventory_ID for coresponding H_id and PT_btype)
create
or replace PROCEDURE GET_INV_ID (
  INPUT_H_ID IN NUMBER,
  INPUT_PT_BTYPE IN VARCHAR2,
  OUTPUT_INV_ID OUT NUMBER
) AS BEGIN
SELECT
  INVENTORY_ID INTO OUTPUT_INV_ID
FROM
  INVENTORY
WHERE
  h_id = INPUT_H_ID
  AND pt_btype = INPUT_PT_BTYPE;

END GET_INV_ID;

--------------------------------------------------------------------------------------------------------------------------------------------------------  
CREATE
or replace TRIGGER my_trigger
AFTER
INSERT
  ON TRANS FOR EACH ROW
  when (new.request_type_id = 1) BEGIN
UPDATE
  INVENTORY
SET
  TOTAL_BLOOD_UNIT = TOTAL_BLOOD_UNIT + :NEW.BLOOD_UNIT
WHERE
  PT_BTYPE = :NEW.PT_BTYPE
  AND INVENTORY_ID = :NEW.INVENTORY_ID;

END;

insert into
  trans
values
  (42, 14, '13-apr-2019', 1, 'A+', 10, 1, 1);

---------------------------------------------------------------------------------------------
CREATE
or replace TRIGGER my_trigger_1
AFTER
INSERT
  ON TRANS FOR EACH ROW
  when (new.request_type_id = 2) BEGIN
UPDATE
  INVENTORY
SET
  TOTAL_BLOOD_UNIT = TOTAL_BLOOD_UNIT - :NEW.BLOOD_UNIT
WHERE
  PT_BTYPE = :NEW.PT_BTYPE
  AND INVENTORY_ID = :NEW.INVENTORY_ID;

END;

insert into
  trans
values
  (
    TRANS_SEQ.NEXTVAL,
    14,
    '13-apr-2019',
    2,
    'A+',
    10,
    1,
    1
  );

--------------------------------------------------------------------------------------------
create sequence trans_seq minvalue 1 maxvalue 1000 start with 41 increment by 1 cache 50;

INSERT INTO
  TRANS
VALUES
  (
    TRANS_SEQ.NEXTVAL,
    14,
    '12-APR-2017',
    1,
    'A+',
    10,
    1,
    1
  );

----------------------------------------------------------------------------------------------
CREATE SEQUENCE BILLING_SEQ MINVALUE 1 MAXVALUE 1000 START WITH 1 INCREMENT BY 1 CACHE 50;

------------------------------------------------------------------------------------------------------
create
or replace PROCEDURE GET_INV_ID (
  INPUT_H_ID IN NUMBER,
  INPUT_PT_BTYPE IN VARCHAR2,
  OUTPUT_INV_ID OUT NUMBER
) AS BEGIN
SELECT
  INVENTORY_ID INTO OUTPUT_INV_ID
FROM
  INVENTORY
WHERE
  h_id = INPUT_H_ID
  AND pt_btype = INPUT_PT_BTYPE;

END GET_INV_ID;

----------------------------------------------------------------------------------------------------------------
CREATE
OR REPLACE VIEW "BLOOD_TYPE_SEARCH" ("H_NAME", "PT_BTYPE", "TOTAL_BLOOD_UNIT") AS
SELECT
  H.H_NAME,
  I.PT_BTYPE,
  I.TOTAL_BLOOD_UNIT
FROM
  HOSPITAL H
  INNER JOIN INVENTORY I ON H.H_ID = I.H_ID;

-------------------------------------------------------------------------------------------------------------------------
CREATE
or replace TRIGGER TR_BILLING_1
AFTER
INSERT
  ON TRANS FOR EACH ROW
  when (new.request_type_id = 2) BEGIN
INSERT INTO
  BILLING
VALUES
  (
    billing_seq.nextval,
    :new.pt_id,
    :new.blood_unit * 210,
    :new.trans_id,
    :new.t_date
  );

END;

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------
--  File created - Monday-April-15-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table INVENTORY
--------------------------------------------------------
CREATE TABLE INVENTORY (
  H_ID NUMBER(20, 0),
  PT_BTYPE VARCHAR2(5 BYTE),
  TOTAL_BLOOD_UNIT NUMBER(5, 0),
  INVENTORY_ID NUMBER(20, 0)
);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'A+', 1802, 1);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'A-', 1433, 2);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'B+', 776, 3);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'B-', 1947, 4);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'AB+', 1678, 5);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (1, 'A-', 1926, 6);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'A+', 1849, 9);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'A-', 1179, 10);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'B+', 1972, 11);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'A-', 898, 14);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'O+', 695, 15);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (2, 'O-', 565, 16);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (3, 'A-', 815, 22);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (3, 'O+', 1205, 23);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (3, 'O-', 619, 24);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'A+', 1018, 25);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'A-', 568, 26);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'B+', 192, 27);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'B-', 1972, 28);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'AB+', 1209, 29);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (4, 'A-', 909, 30);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'A+', 1083, 33);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'A-', 986, 34);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'B+', 1632, 35);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'B-', 1275, 36);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'AB+', 1481, 37);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'A-', 220, 38);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'O+', 1055, 39);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (5, 'O-', 1697, 40);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (6, 'A+', 1850, 41);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (6, 'A-', 545, 42);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (6, 'B+', 204, 43);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (6, 'O-', 1898, 48);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (7, 'A+', 301, 49);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (7, 'A-', 526, 50);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (7, 'B+', 1989, 51);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (7, 'B-', 205, 52);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (7, 'O-', 1349, 56);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (8, 'A+', 512, 57);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (8, 'A-', 1504, 58);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (8, 'B+', 1840, 59);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (8, 'B-', 192, 60);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (9, 'A+', 123, 65);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (9, 'A-', 595, 66);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (9, 'B+', 1211, 67);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (9, 'O-', 616, 72);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (10, 'A+', 778, 73);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (10, 'A-', 729, 74);

Insert into
  INVENTORY (H_ID, PT_BTYPE, TOTAL_BLOOD_UNIT, INVENTORY_ID)
values
  (10, 'B+', 1591, 75);

--------------------------------------------------------
--  DDL for Index INVENTORY_PK
--------------------------------------------------------
CREATE UNIQUE INDEX INVENTORY_PK ON INVENTORY (INVENTORY_ID);

--------------------------------------------------------
--  Constraints for Table INVENTORY
--------------------------------------------------------
ALTER TABLE
  INVENTORY
MODIFY
  (H_ID NOT NULL);

ALTER TABLE
  INVENTORY
MODIFY
  (PT_BTYPE NOT NULL);

ALTER TABLE
  INVENTORY
MODIFY
  (TOTAL_BLOOD_UNIT NOT NULL);

ALTER TABLE
  INVENTORY
MODIFY
  (INVENTORY_ID NOT NULL);

ALTER TABLE
  INVENTORY
ADD
  CONSTRAINT INVENTORY_PK PRIMARY KEY (INVENTORY_ID);
