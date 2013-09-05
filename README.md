pgparttimejob
==============

PostgreSQL Partition Manager for Date/Timestamp ranges. A set of entities and routines for managing date or timestamp partitions in PostgreSQL. Tables can be partitioned by day, week, month, or year.

Installation
------------
Clone the repo and then execute the install.sql script as a user with suitable permissions to create databases and execute routines. 
- git clone https://github.com/ridecharge/pgparttimejob
- cd pgparttimejob
- psql database_name < install.sql

Verify your Install
-------------------
The install script creates a set of test tables created in the pgparttimejob schema which allow you to verify the functionality before implementing your own tables. You can log into your database and check for exsting partitions to validate things are working correctly.

```
psql> select parent.relname as table_name, child.relname as partition_name from pg_inherits join pg_class parent on pg_inherits.inhparent = parent.oid join pg_class child on pginherits.inhrelid = child.oid order by parent.relname, child.relname;
 table_name  |   partition_name   
-------------+--------------------
testdaily   | testdaily_20130905
 testdaily   | testdaily_20130906
 testdaily   | testdaily_20130907
 testdaily   | testdaily_20130908
 testdaily   | testdaily_20130909
 testdaily   | testdaily_20130910
 testdaily   | testdaily_20130911
 testmonthly | testmonthly_201309
 testmonthly | testmonthly_201310
 testmonthly | testmonthly_201311
 testmonthly | testmonthly_201312
 testweekly  | testweekly_201336
 testweekly  | testweekly_201337
 testweekly  | testweekly_201338
 testweekly  | testweekly_201339
 testweekly  | testweekly_201340
 testweekly  | testweekly_201341
 testyearly  | testyearly_2013
 testyearly  | testyearly_2014
 testyearly  | testyearly_2015
(20 rows)


```

Use It
------
Due to the nature of PostgreSQL partitioning through table inheritence, all you really need to start is a table with a created_at column.

In order for the system to know that your table needs partition management, you need to insert a row into the partition_tables table. Partition Frequency can be daily, weekly, monthly, or yearly. Look Ahead refers to the number of future partitions you want to create.

```
insert into pgparttimejob.partition_tables
    (
    table_schema,
    table_name,
    partition_frequency,
    look_ahead
    )
values
    (
    'my_schema',
    'partition_me_dates',
    'daily',
    7
    )
;
```

Next apply the appropriate trigger to the table. It is very important that your trigger procedure matches the frequency you inserted into pgparttimejob.partition_tables. Options are [day|week|month|year]_partition_insert_trigger.

```
create trigger 
    insert_daily_on_mytable 
before insert on 
    myschema.mytable 
for each row 
execute procedure 
    day_partition_insert_trigger;
```

Once you have created the table and inserted the record into the partition_tables table, you can manage your partitions simply by calling the routine:

```
select pgparttimejob.manage_partitions();
```

We suggest putting that call in a daily crontab.
