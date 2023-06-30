## Iceberg in Snowflake

+ Iceberg is an open-source table type, which means a private company does not own the technology. Iceberg Table technology is not proprietary. 

+ Iceberg Tables are a layer of functionality you can lay on top of parquet file that will make files behave more like loaded data. In this way, it's like a file format, but also MUCH more.

+ Iceberg Table data will be editable via Snowflake.
+ Not just the tables are editable (like the table name), but the data they make available (like the data values in columns and rows).
+ So, you will be able to create an Iceberg Table in Snowflake, on top of a set of parquet files that have NOT BEEN LOADED into Snowflake, 
and then run INSERT and UPDATE statements on the data using SQL 
