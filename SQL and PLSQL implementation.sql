 alter SESSION set NLS_DATE_FORMAT = 'DD/MM/YYYY' 

DROP TABLE clients cascade constraints;
DROP TABLE products cascade constraints;
DROP TABLE orders cascade constraints;
DROP TABLE order_details cascade constraints;
DROP TABLE taxes cascade constraints;
DROP TABLE order_status cascade constraints;

DROP TRIGGER new_client_insert;
DROP TRIGGER new_product_insert;
DROP TRIGGER new_order_insert;
DROP TRIGGER new_orderDetails_insert;
DROP TRIGGER new_tax_insert;
DROP TRIGGER new_orderStatus_insert;
DROP TRIGGER check_os_dispatched_insert;
DROP SEQUENCE new_client_id;
DROP SEQUENCE new_product_id;
DROP SEQUENCE new_order_id;
DROP SEQUENCE new_orderdetails_id;
DROP SEQUENCE new_tax_id;
DROP SEQUENCE new_orderStatus_id;

--CLIENTS TABLE  
CREATE TABLE clients
(clientId NUMBER(6),
firstName varchar2(50),
lastName varchar2(50),
phone varchar2(15),
email varchar2(50),
country varchar2(50),
Province varchar2(2),
postalZip varchar2(10),
address varchar2(255),
CONSTRAINT clients_clientId_pk PRIMARY KEY (clientId)
);

-- SEQUENCE - to create ids for clients table
CREATE SEQUENCE new_client_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS
--trigger before insert primary key client_id
CREATE OR REPLACE TRIGGER new_client_insert
  BEFORE INSERT ON clients
  FOR EACH ROW
BEGIN
  SELECT new_client_id.nextval
  INTO :new.clientId
  FROM dual;
END;
/
--------------------------------------------------------------------------------

--PRODUCTS TABLE
CREATE TABLE products (
  productId NUMBER NOT NULL,
  productCategory varchar2(50),
  productType varchar2 (50),
  productStyle varchar2(50),
  visible_InStore varchar2(3),
  price NUMBER(20),

  CONSTRAINT products_productId_pk PRIMARY KEY (productId)
);

-- SEQUENCE PRODUCTS - to create ids for products table
CREATE SEQUENCE new_product_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS PRODUCTS
--trigger before insert primary key product_id
CREATE OR REPLACE TRIGGER new_product_insert
  BEFORE INSERT ON products
  FOR EACH ROW
BEGIN
  SELECT new_product_id.nextval
  INTO :new.productId
  FROM dual;
END;
/
--------------------------------------------------------------------------------

--ORDERS TABLE
CREATE TABLE orders
(orderId NUMBER,
clientId NUMBER,
orderTotal NUMBER (6,2),
orderDate DATE,
province VARCHAR2(2),

CONSTRAINT orders_orderId_pk PRIMARY KEY (orderId),
CONSTRAINT orders_clientId_fk FOREIGN KEY(clientId) REFERENCES clients (clientId)
);


-- SEQUENCE - to create ids for orders table
CREATE SEQUENCE new_order_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS
--trigger before insert primary key ordersId
CREATE OR REPLACE TRIGGER new_order_insert
  BEFORE INSERT ON orders
  FOR EACH ROW
BEGIN
  SELECT new_order_id.nextval
  INTO :new.orderId
  FROM dual;
END;
/
--------------------------------------------------------------------------------

--TAXES TABLE
CREATE TABLE taxes(
taxId NUMBER,
province VARCHAR2(2),
taxValue NUMBER (3,2),
taxExemptionDate1 Date,
taxExemptionDate2 Date,

CONSTRAINT taxes_taxId_pk PRIMARY KEY (taxId)
);

-- SEQUENCE - to create ids for taxes table
CREATE SEQUENCE new_tax_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS
--trigger before insert primary key taxesId
CREATE OR REPLACE TRIGGER new_tax_insert
  BEFORE INSERT ON taxes
  FOR EACH ROW
BEGIN
  SELECT new_tax_id.nextval
  INTO :new.taxId
  FROM dual;
END;
/
--------------------------------------------------------------------------------

--ORDER_DETAILS TABLE
CREATE TABLE order_details
(orderDetailsId NUMBER,
clientId NUMBER,
orderId NUMBER,
productId NUMBER,
taxId NUMBER,
tax NUMBER (3,2),
totalQuantity NUMBER,
orderTotal NUMBER(8,2),

CONSTRAINT order_details_oDetailsId_pk PRIMARY KEY (orderDetailsId),
CONSTRAINT order_details_clientId_fk FOREIGN KEY(clientId) REFERENCES clients (clientId),
CONSTRAINT order_details_orderId_fk FOREIGN KEY(orderId) REFERENCES orders (orderId),
CONSTRAINT order_details_taxId_fk FOREIGN KEY(taxId) REFERENCES taxes (taxId)
);

-- SEQUENCE - to create ids for orderdetails
DROP  SEQUENCE new_orderdetails_id;
CREATE SEQUENCE new_orderdetails_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS
--trigger before insert primary key orderdetailsId
CREATE OR REPLACE TRIGGER new_orderdetails_insert
  BEFORE INSERT ON order_details
  FOR EACH ROW
  
BEGIN
  :new.orderDetailsId := new_orderdetails_id.nextval;
  
END;
/
--------------------------------------------------------------------------------

--order_status TABLE
CREATE TABLE order_status
(orderStatusId NUMBER,
clientId NUMBER,
orderId NUMBER,
delivered VARCHAR2(20),
dispatched VARCHAR2(20),
dateOfDelivery DATE,

CONSTRAINT order_status_orderStatusId_pk PRIMARY KEY (orderStatusId),
CONSTRAINT order_status_clientId_fk FOREIGN KEY(clientId) REFERENCES clients (clientId),
CONSTRAINT order_status_orderId_fk FOREIGN KEY(orderId) REFERENCES orders (orderId)
);

-- SEQUENCE - to create ids
CREATE SEQUENCE new_orderStatus_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOMAXVALUE;

--TRIGGERS
--trigger before insert primary key product_id
CREATE OR REPLACE TRIGGER new_orderStatus_insert
  BEFORE INSERT ON order_status
  FOR EACH ROW 
BEGIN
  SELECT new_orderStatus_id.nextval
  INTO :new.orderStatusId
  FROM dual;
  END;
/
--trigger with error exception - check before insert or update values before inserting. if delivery is YES then dispatch needs to be yes. 
CREATE OR REPLACE TRIGGER check_os_dispatched_insert 
  BEFORE INSERT OR UPDATE OF dispatched ON order_status
  FOR EACH ROW
  
DECLARE 
not_valid_dispatch_delivered EXCEPTION;
not_valid_dispatch_transit EXCEPTION;

BEGIN

  IF (:new.delivered = 'Yes' OR :old.delivered ='Yes') AND :new.dispatched = 'Yes' THEN
  RAISE not_valid_dispatch_delivered;
  ELSIF (:new.delivered = 'Yes' OR :old.delivered = 'Yes') AND :new.dispatched = 'On-Transit' THEN
  RAISE not_valid_dispatch_transit;
  END IF;

EXCEPTION
WHEN not_valid_dispatch_delivered THEN
DBMS_OUTPUT.PUT_LINE('If delivery already occured and it´s value is "Yes", the dispatch value cannot be "No".');
WHEN not_valid_dispatch_transit THEN 
DBMS_OUTPUT.PUT_LINE('If delivery already occured and it´s value is "Yes", the dispatch value cannot be "On-Transit".');

END;
/
--------------------------------------------------------------------------------
-- insert clients table 
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Macey','Dodson','1-240-563-3129','libero.dui@outlook.com','Canada','SK','35M 1G3','Ap #670-9103 Aliquam Avenue');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Merrill','Patel','1-191-344-4482','ac@hotmail.com','Canada','NT','S4P 3P9','P.O. Box 660, 3463 Cursus Rd.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Harlan','Dudley','1-720-735-8969','lacus.nulla@outlook.com','Canada','AB','61P 3K6','Ap #910-6314 Sed Rd.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Kennedy','Craig','1-839-873-8253','vitae.semper@hotmail.com','Canada','YT','R8S 8L2','Ap #702-1675 Et Avenue');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Olympia','Kennedy','1-864-935-8977','tristique.senectus@outlook.com','Canada','ON','45H 5X5','159-2789 In, St.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Cyrus','Gomez','1-541-994-1788','eu@outlook.com','Canada','PE','63V 7W5','P.O. Box 718, 1973 Eu Rd.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Xander','Jefferson','1-356-742-1842','imperdiet@outlook.com','Canada','QC','J7J 8C1','1470 Ut Ave');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Maggie','Stein','1-537-383-5482','penatibus.et@outlook.com','Canada','NU','T3L 1L0','162-7381 Id, Av.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Miranda','Mcguire','1-312-622-3351','ligula.aenean@outlook.com','Canada','BC','Y3P 4X8','Ap #745-7784 Mauris St.');
INSERT INTO CLIENTS (firstName,lastName,phone,email,country,Province,postalZip,address)
VALUES ('Cynthia','Meyer','1-794-515-8354','donec.est@hotmail.com','Canada','NB','A5W 8H9','1942 Fermentum Rd.');

--insert products table
-- tax values are being managed in decimals for easy management purposes.
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','Shirt','Regular','No',10);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','Tie','Sport','No',79);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('Casual','Pant','Sport','No',34);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','Tie','Sport','No',50);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('Casual','Jacket','Sport','Yes',27);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('Casual','Coat','Sport','No',75);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','T-Shirt','Regular','No',55);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','Jacket','Sport','No',70);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('Casual','Pant','Sport','Yes',50);
INSERT INTO products (productCategory,productType,productStyle,visible_InStore,price) 
VALUES ('School uniforms','Jacket','Regular','No',78);

--insert order table
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (6,9,TO_DATE('12/06/2021','DD/MM/YYYY'),'ON');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (6,5,TO_DATE('25/04/2021','DD/MM/YYYY'),'ON');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (8,2,TO_DATE('09/03/2021','DD/MM/YYYY'),'ON');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (8,4,TO_DATE('26/04/2021','DD/MM/YYYY'),'ON');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (9,9,TO_DATE('30/05/2021','DD/MM/YYYY'),'BC');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (3,6,TO_DATE('27/08/2021','DD/MM/YYYY'),'QC');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (6,5,TO_DATE('25/04/2021','DD/MM/YYYY'),'NT');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (1,9,TO_DATE('04/01/2021','DD/MM/YYYY'),'AB');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (10,7,TO_DATE('16/12/2021','DD/MM/YYYY'),'SK');
INSERT INTO orders (clientId,orderId,orderDate,province)
VALUES (5,8,TO_DATE('24/04/2021','DD/MM/YYYY'),'NB');

--insert taxes table
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('NT',0.07,TO_DATE('09/03/2021','DD/MM/YYYY'),TO_DATE('29/01/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('BC',0.08,TO_DATE('11/07/2021','DD/MM/YYYY'),TO_DATE('22/09/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('QC',0.08,TO_DATE('15/09/2021','DD/MM/YYYY'),TO_DATE('04/11/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('ON',0.13,TO_DATE('26/04/2021','DD/MM/YYYY'),TO_DATE('17/07/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('SK',0.09,TO_DATE('15/02/2021','DD/MM/YYYY'),TO_DATE('21/08/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('AB',0.13,TO_DATE('22/01/2021','DD/MM/YYYY'),TO_DATE('05/04/2021','DD/MM/YYYY'));
INSERT INTO taxes (province,taxValue,taxExemptionDate1,taxExemptionDate2)
VALUES ('NB',0.13,TO_DATE('08/05/2021','DD/MM/YYYY'),TO_DATE('08/06/2021','DD/MM/YYYY'));

--insert order_details table
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (6,9,4,4,20);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (6,5,3,1,5);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (8,2,5,7,15);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (8,4,4,7,12);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (9,9,9,2,18);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (3,6,5,1,30);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (6,5,4,4,3);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (1,9,3,1,9);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (10,7,6,5,40);
INSERT INTO order_details (clientId,orderId,productId,taxId, totalQuantity)
VALUES (5,8,3,2,25);
--insert order_status table

INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (4,8,'No','On-Transit',TO_DATE('05/08/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (5,1,'Yes','Yes',TO_DATE('07/11/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (3,5,'No','No',TO_DATE('22/06/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (3,9,'Yes','Yes',TO_DATE('15/08/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (9,1,'Yes','Yes',TO_DATE('02/07/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (3,4,'No','On-Transit',TO_DATE('30/03/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (10,5,'No','On-Transit',TO_DATE('31/07/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (10,3,'No','No',TO_DATE('13/04/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (2,7,'Yes','On-Transit',TO_DATE('21/01/2021','DD/MM/YYYY'));
INSERT INTO order_status (clientId,orderId,delivered,dispatched,dateOfDelivery)
VALUES (5,3,'No','No',TO_DATE('29/06/2021','DD/MM/YYYY'));

--------------------------------------------------------------------
--PROCEDURE1
/* input order in anonymous block to be inserted later in the orders table, orderTotal Column for an specific orderID.
Their initial value is set as null and it should be populated
*/

DROP PROCEDURE calc_totalsOrders;
CREATE OR REPLACE PROCEDURE calc_totalsOrders
(product IN products.productType%TYPE,
unit_price IN products.price%TYPE,
quantity IN order_details.totalQuantity%TYPE,
tOrder OUT order_details.totalQuantity%TYPE)

IS
rec_products products%ROWTYPE;

BEGIN
tOrder := unit_price * quantity;

IF product = 'jacket' THEN
UPDATE orders
SET orderTotal = tOrder WHERE orderId = 5;
END IF;
END;
-------
--ANNONYMOUS BLOCK
--EXECUTE alter trigger before executing procedure to avoid creation of new id fields in tables
Alter trigger new_orderdetails_insert disable;
Alter trigger new_order_insert disable;

set SERVEROUTPUT on 
cl scr
DECLARE
product products.productType%TYPE := 'jacket';
price products.price%TYPE := 60;
quantity order_details.totalQuantity%TYPE := 4;
tOrder Number;

BEGIN
calc_totalsOrders(product, price, quantity, tOrder);
DBMS_OUTPUT.PUT_LINE('The total price for ' ||  quantity || ' ' || product ||'´s '|| 'is ' ||'$'|| tOrder);
END;

--ENABLE triggers again after procedure is executed to restore functionality.
Alter trigger new_orderdetails_insert enable;
Alter trigger new_order_insert enable;
----------------------------------------------------------------------------------
--PROCEDURE2
-- IF DATE OF ORDER OF SPECIFIC ORDERID MATCHES THE DAY OF TAX EXEMPTION THEN TAX IS DIFFERENT.
-- THIS ONE I wasn't able to make it work as intended..
create or replace PROCEDURE TAX_change

IS 
new_tax NUMBER (3,2);
cursor tax_ex1 is 
SELECT orders.orderDate, taxes.taxExemptionDate1, taxes.taxExemptionDate2 FROM orders, taxes WHERE taxes.province = 'ON' AND orders.orderDate = taxes.taxExemptionDate1;
rec_ex1 tax_ex1%ROWTYPE;
cursor tax_ex2 is 
SELECT orders.orderDate, taxes.taxExemptionDate1, taxes.taxExemptionDate2 FROM orders, taxes WHERE taxes.province = 'ON' AND orders.orderDate = taxes.taxExemptionDate2;
rec_ex2 tax_ex2%ROWTYPE;

BEGIN
new_tax := 0;
open tax_ex1;
open tax_ex2;
LOOP
FETCH tax_ex1 INTO rec_ex1;
FETCH tax_ex2 INTO rec_ex2;
IF tax_ex1%FOUND THEN
UPDATE order_details SET tax = new_tax;
ELSE 
    IF tax_ex2%FOUND THEN
    UPDATE order_details SET tax = new_tax;
    END IF;
END IF;
END LOOP;
close tax_ex1;
close tax_ex2;
END;

---ANONNYMOUS BLOCK
EXEC TAX_change;
SELECT * FROM order_details;

----------------------------------------------------------------------------------
--FUNCTION
/*procedure to check if a cheap product under 30 dollars is available in the store and if
it is visible or not*/

DROP FUNCTION cheap_prod_inStore;

CREATE OR REPLACE FUNCTION cheap_prod_inStore
(displayed IN products.visible_InStore%TYPE)
RETURN VARCHAR2

IS 
price_cproducts_txt VARCHAR2(255);
CURSOR prod_cursor is
SELECT price, productType FROM products WHERE price < 30;
rec_products prod_cursor%ROWTYPE;

BEGIN
OPEN prod_cursor;

IF displayed = 'Yes' THEN
LOOP
FETCH prod_cursor into rec_products;
EXIT WHEN prod_cursor%NOTFOUND;
price_cproducts_txt:= 'In Store: ' || displayed || 'product:' || rec_products.productType || 'Price: ' || rec_products.price;
END LOOP;
ELSE 
LOOP
FETCH prod_cursor into rec_products;
EXIT WHEN prod_cursor%NOTFOUND;
price_cproducts_txt:= 'Not In Store: ' || displayed ||'product: ' || rec_products.productType || 'Price: ' || rec_products.price;
END LOOP;
END IF;
DBMS_OUTPUT.PUT_LINE(price_cproducts_txt);
RETURN price_cproducts_txt;
close prod_cursor;
END;

-------
--find cheap products displayed in the store:
set SERVEROUTPUT on 
cl scr
--type Yes as a parameter to find cheap products under $30 dollars.
--type No to get the products out of store that are under $30 dollars.

DECLARE 
displayed products.visible_InStore%TYPE := 'Yes';
display_txt varchar2(255);

BEGIN
display_txt := cheap_prod_inStore(displayed);
END;

------------------------------------------------------------------------------