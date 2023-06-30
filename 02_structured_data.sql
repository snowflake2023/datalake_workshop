---=============product_coordination_suggestions.txt ====================

create file format zmd_file_format_1
RECORD_DELIMITER = '^';

select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_1);

create file format zmd_file_format_2
FIELD_DELIMITER = '^'; 

select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_2);

create file format zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^';


select $1,$2,$3
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

---=========sweatsuit_sizes.txt =======================================

list @UNI_KLAUS_ZMD/sweatsuit_sizes.txt;

SELECT $1 from @UNI_KLAUS_ZMD/sweatsuit_sizes.txt;

create or replace file format zmd_file_format_1
RECORD_DELIMITER = ';'
;

SELECT $1
from @UNI_KLAUS_ZMD/sweatsuit_sizes.txt
(file_format => zmd_file_format_1);


----================swt_product_line/txt ==================================

SELECT $1 from @UNI_KLAUS_ZMD/swt_product_line.txt;

create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER =';'
TRIM_SPACE=True;

SELECT $1, $2, $3 from @UNI_KLAUS_ZMD/swt_product_line.txt
(file_format => zmd_file_format_2);

SELECT REPLACE($1,char(13)||char(10)) as sizes_available , $2, $3 from @UNI_KLAUS_ZMD/swt_product_line.txt
(file_format => zmd_file_format_2);

SELECT REPLACE($1,char(13)||char(10)) as sizes_available from @UNI_KLAUS_ZMD/sweatsuit_sizes.txt
(file_format => zmd_file_format_2)
WHERE sizes_available <> '';

---==============create sweat_sized into a view ===========

CREATE OR REPLACE VIEW zenas_athleisure_db.products.SWEATSUIT_SIZES as
SELECT REPLACE($1,char(13)||char(10)) as sizes_available from @UNI_KLAUS_ZMD/sweatsuit_sizes.txt
(file_format => zmd_file_format_2)
WHERE sizes_available <> '';

select * from SWEATSUIT_SIZES;

---=========== swt_product_line.txt ===========

SELECT REPLACE($1,char(13)||char(10)) as PRODUCT_CODE,
       $2 as HEADBAND_DESCRIPTION,
       $3 as WRISTBAND_DESCRIPTION
from @UNI_KLAUS_ZMD/swt_product_line.txt
(file_format => zmd_file_format_2);


CREATE VIEW zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as 
SELECT REPLACE($1,char(13)||char(10)) as PRODUCT_CODE,
       $2 as HEADBAND_DESCRIPTION,
       $3 as WRISTBAND_DESCRIPTION
from @UNI_KLAUS_ZMD/swt_product_line.txt
(file_format => zmd_file_format_2);

select * from SWEATBAND_PRODUCT_LINE;


---=========== product_coordination_suggestions ===========
CREATE OR REPLACE VIEW zenas_athleisure_db.products.SWEATBAND_COORDINATION as 
select REPLACE($1,char(13)||char(10)) as PRODUCT_CODE ,
       REPLACE($2,char(13)||char(10)) as HAS_MATCHING_SWEATSUIT 
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);


SELECT * FROM zenas_athleisure_db.products.SWEATSUIT_SIZES;


---=========ownership==========
GRANT OWNERSHIP ON VIEW zenas_athleisure_db.products.SWEATBAND_COORDINATION TO ROLE sysadmin;
GRANT OWNERSHIP ON VIEW zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE TO ROLE sysadmin;
GRANT OWNERSHIP ON VIEW zenas_athleisure_db.products.SWEATSUIT_SIZES TO ROLE sysadmin;

GRANT OWNERSHIP ON file format zenas_athleisure_db.products.zmd_file_format_1 TO ROLE sysadmin;
GRANT OWNERSHIP ON file format  zenas_athleisure_db.products.zmd_file_format_2 TO ROLE sysadmin;
GRANT OWNERSHIP ON file format  zenas_athleisure_db.products.zmd_file_format_3 TO ROLE sysadmin;
----==========checks ==========


        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
        where length(product_code) > 7 ;
        
        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
        where LEFT(sizes_available,2) = char(13)||char(10) ;
