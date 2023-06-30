-- list the items from stage
select current_database();
select current_schema();

CREATE OR REPLACE STAGE 
 ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING
  URL = 's3://uni-klaus/clothing';

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

-- ============== Querying returns invalid UTF error
select $1 FROM
@ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

select $1
from @uni_klaus_clothing/90s_tracksuit.png; 

--- Query the metadata table
select metadata$filename, metadata$file_row_number
from @uni_klaus_clothing/90s_tracksuit.png;

select metadata$filename, count(*)
from @uni_klaus_clothing
group by metadata$filename;


--===== Using Directory Tables ===================================

/*
A few important tips about Directory Tables to read unstructured data
They are attached to a Stage (internal or external).  
You have to enable them. 
You have to refresh them.
*/


--Directory Tables
select * from directory(@uni_klaus_clothing);

-- Oh Yeah! We have to turn them on, first
alter stage uni_klaus_clothing 
set directory = (enable = true);

--Now?
select * from directory(@uni_klaus_clothing);

--Oh Yeah! Then we have to refresh the directory table!
alter stage uni_klaus_clothing refresh;

--Now?
select * from directory(@uni_klaus_clothing);


---===========Playing around with directory tables ===========
/*
 We can define a column using the AS syntax,
 and then use that column name in the very next line of the same SELECT? 
*/
--testing UPPER and REPLACE functions on directory table
select UPPER(RELATIVE_PATH) as uppercase_filename
, REPLACE(uppercase_filename,'/') as no_slash_filename
, REPLACE(no_slash_filename,'_',' ') as no_underscores_filename
, REPLACE(no_underscores_filename,'.PNG') as just_words_filename
from directory(@uni_klaus_clothing);

select
REPLACE(REPLACE(REPLACE(UPPER(RELATIVE_PATH),'/'),'_',' '),'.PNG') as PRODUCT_NAME
from directory(@uni_klaus_clothing);


--========create an internal table for some sweat suit info============
create or replace TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (
	COLOR_OR_STYLE VARCHAR(25),
	DIRECT_URL VARCHAR(200),
	PRICE NUMBER(5,2)
);

--fill the new table with some data
insert into  ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
          (COLOR_OR_STYLE, DIRECT_URL, PRICE)
values
('90s', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/90s_tracksuit.png',500)
,('Burgundy', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/forest_green_sweatsuit.png',65)
,('Navy Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/navy_blue_sweatsuit.png',65)
,('Orange', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/orange_sweatsuit.png',65)
,('Pink', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/pink_sweatsuit.png',65)
,('Purple', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/purple_sweatsuit.png',65)
,('Red', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/red_sweatsuit.png',65)
,('Royal Blue',	'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/royal_blue_sweatsuit.png',65)
,('Yellow', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/yellow_sweatsuit.png',65);


--======= Join directory table and internal table ===============

select UPPER(REPLACE(SPLIT(SPLIT(RELATIVE_PATH,'.')[0],'_')[0],'/','')) as COLOR_OR_STYLE
from directory(@uni_klaus_clothing);

select * from sweatsuits;

SELECT COLOR_OR_STYLE, DIRECT_URL, PRICE, 
SIZE as IMAGE_SIZE,
LAST_MODIFIED as IMAGE_LAST_MODIFIED
FROM sweatsuits s
JOIN directory(@uni_klaus_clothing) u
ON UPPER(COLOR_OR_STYLE)=UPPER(REPLACE(SPLIT(SPLIT(RELATIVE_PATH,'.')[0],'_')[0],'/',''))
;

SELECT COLOR_OR_STYLE, DIRECT_URL, PRICE, 
SIZE as IMAGE_SIZE,
LAST_MODIFIED as IMAGE_LAST_MODIFIED,sizes_available
FROM sweatsuits s
JOIN directory(@uni_klaus_clothing) u
ON UPPER(COLOR_OR_STYLE)=UPPER(REPLACE(SPLIT(SPLIT(RELATIVE_PATH,'.')[0],'_')[0],'/',''))
CROSS JOIN SWEATSUIT_SIZES
;

CREATE OR REPLACE VIEW CATALOG as
SELECT COLOR_OR_STYLE, DIRECT_URL, PRICE, 
SIZE as IMAGE_SIZE,
LAST_MODIFIED as IMAGE_LAST_MODIFIED,
sizes_available
from sweatsuits 
join directory(@uni_klaus_clothing) 
on relative_path = SUBSTR(direct_url,54,50)
cross join sweatsuit_sizes;
;


SELECT * FROM zenas_athleisure_db.products.CATALOG;

--========Data lake in Snow flake ==========
/*
When we talk about Data Lakes at Snowflake, 
we tend to mean data that has not been loaded into traditional Snowflake tables.
We might also call these traditional tables "native" Snowflake tables, or "regular" tables

When some data is loaded and some is left in a non-loaded state.
the two types can be joined and queried together, this is sometimes referred to as a Data Lakehouse.
*/


--========Creat upsell tabkle======

-- Add a table to map the sweat suits to the sweat band sets
create table ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE varchar(25)
,UPSELL_PRODUCT_CODE varchar(10)
);

--populate the upsell table
insert into ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE
,UPSELL_PRODUCT_CODE 
)
VALUES
('Charcoal Grey','SWT_GRY')
,('Forest Green','SWT_FGN')
,('Orange','SWT_ORG')
,('Pink', 'SWT_PNK')
,('Red','SWT_RED')
,('Yellow', 'SWT_YLW');


--===Single view to web catalog =======

-- Zena needs a single view she can query for her website prototype
create view catalog_for_website as 
select color_or_style
,price
,direct_url
,size_list
,coalesce('BONUS: ' ||  headband_description || ' & ' || wristband_description, 'Consider White, Black or Grey Sweat Accessories')  as upsell_product_desc
from
(   select color_or_style, price, direct_url, image_last_modified,image_size
    ,listagg(sizes_available, ' | ') within group (order by sizes_available) as size_list
    from catalog
    group by color_or_style, price, direct_url, image_last_modified, image_size
) c
left join upsell_mapping u
on u.sweatsuit_color_or_style = c.color_or_style
left join sweatband_coordination sc
on sc.product_code = u.upsell_product_code
left join sweatband_product_line spl
on spl.product_code = sc.product_code
where price < 200 -- high priced items like vintage sweatsuits aren't a good fit for this website
and image_size < 1000000 -- large images need to be processed to a smaller size
;

SELECT * FROM catalog_for_website;
