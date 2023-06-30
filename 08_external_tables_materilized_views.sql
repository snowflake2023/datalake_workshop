/**
Materialized views
External Tables
Iceberg Tables
**/

/*
External Tables
An External Table is a table put over the top of non-loaded data 

An External Table points at a stage folder and includes a reference to a file format 
External can be directly created over a stage

*/


select * FROM  MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL;

ALTER VIEW  MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL rename to V_CHERRY_CREEK_TRAIL ;


select * FROM  MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.V_CHERRY_CREEK_TRAIL;

create or replace external table T_CHERRY_CREEK_TRAIL(
	my_filename varchar(50) as (metadata$filename::varchar(50))
) 
location= @trails_parquet -- Name of the stage
auto_refresh = true
file_format = (type = parquet);

select get_ddl('view','mels_smoothie_challenge_db.trails.v_cherry_creek_trail');

--view def

create or replace view V_CHERRY_CREEK_TRAIL( POINT_ID, TRAIL_NAME, LNG, LAT, COORD_PAIR ) as select   $1:sequence_1 as point_id,  $1:trail_name::varchar as trail_name,  $1:latitude::number(11,8) as lng,  $1:longitude::number(11,8) as lat,  lng||' '||lat as coord_pair from @trails_parquet (file_format => ff_parquet) order by point_id;

/** create external table using view definition
Notice that the use of the stage and file format are very similar to the view definition
The column definitions require a bit of transposition on column name, 
and the table definition is a little more strict in requiring you to define the data types with CAST syntax (:: is CASTING). 
*/

CREATE OR REPLACE EXTERNAL TABLE T_CHERRY_CREEK_TRAIL(
point_id number as ($1:sequence_1::number) ,
trail_name varchar(50) as ($1:trail_name::varchar), 
lng number(11,8) as ($1:latitude::number(11,8)) ,
lat number(11,8) as ($1:longitude::number(11,8)) ,
coord_pair varchar(50) as (lng:varchar||' '||lat:varchar) 
)
location= @trails_parquet -- Name of the stage
auto_refresh = true
file_format = (type = parquet);

SELECT * FROM T_CHERRY_CREEK_TRAIL;

create or replace external table mels_smoothie_challenge_db.trails.T_CHERRY_CREEK_TRAIL(
	POINT_ID number as ($1:sequence_1::number),
	TRAIL_NAME varchar(50) as  ($1:trail_name::varchar),
	LNG number(11,8) as ($1:latitude::number(11,8)),
	LAT number(11,8) as ($1:longitude::number(11,8)),
	COORD_PAIR varchar(50) as (lng::varchar||' '||lat::varchar)
) 
location= @mels_smoothie_challenge_db.trails.trails_parquet
auto_refresh = true
file_format = mels_smoothie_challenge_db.trails.ff_parquet;



/**
A Materialized View is like a view that is frozen in place (more or less looks and acts like a table).

The big difference is that if some part of the underlying data changes,  
Snowflake recognizes the need to refresh it, automatically.

People often choose to create a materialized view if they have a view with intensive logic that they query often but that does NOT change often. 
you can't put a materialized view directly on top of staged data. 
"regular" view can be directly created over a stage

 You CAN put a Materialized View over an External Table, even if that External Table is based on a Stage!!
*/
create or REPLACE secure materialized view SMV_CHERRY_CREEK_TRAIL
    -- comment = '<comment>'
    as SELECT * FROM mels_smoothie_challenge_db.trails.T_CHERRY_CREEK_TRAIL;


SELECT * FROM SMV_CHERRY_CREEK_TRAIL;
