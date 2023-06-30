/**
Data Structure Types refers file storage structures for data 
such as Structured (txt,csv), Semi-Structured (json,xml), and Unstructured (media files)
**/

--========CREATE new database, schema --======================
create database ZENAS_ATHLEISURE_DB;
show schemas;
drop schema ZENAS_ATHLEISURE_DB.public;
show schemas;
create schema PRODUCTS;
USE schema PRODUCTS
;
--========= create an s3 stages for three s3 folders
CREATE OR REPLACE STAGE 
 ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING
  URL = 's3://uni-klaus/clothing';

-- list the items from stage
list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

-- create an s3 stage table
CREATE OR REPLACE STAGE 
 ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_ZMD
  URL = 's3://uni-klaus/zenas_metadata';

  -- list the items from stage
list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_ZMD;


-- create an s3 stage table
CREATE OR REPLACE STAGE 
 ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_SNEAKERS 
  URL = 's3://uni-klaus/sneakers/';

list  @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_SNEAKERS ;


---=============Review Unloaded data ===================

select $1
from @uni_klaus_zmd;

select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt;

---====== Provide ownership to sysadmin =================
GRANT OWNERSHIP ON STAGE zenas_athleisure_db.products.UNI_KLAUS_CLOTHING TO ROLE sysadmin;
GRANT OWNERSHIP ON STAGE zenas_athleisure_db.products.UNI_KLAUS_ZMD TO ROLE sysadmin;
GRANT OWNERSHIP ON STAGE zenas_athleisure_db.products.UNI_KLAUS_ZMD TO ROLE sysadmin;

---====== Provide ownership to sysadmin =================
