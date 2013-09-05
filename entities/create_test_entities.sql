create table pgparttimejob.testdaily
(
    test_daily_id           serial,
    created_at              timestamp without time zone default now()
)
;

create table pgparttimejob.testweekly
(
    test_weekly_id          serial,
    created_at              timestamp without time zone default now()
)
;

create table pgparttimejob.testmonthly
(
    test_montly_id          serial,
    created_at              timestamp without time zone default now()
)
;

create table pgparttimejob.testyearly
(
    test_yearly_id          serial,
    created_at              timestamp without time zone default now()
)
;

insert into pgparttimejob.partition_tables
    (
    table_schema,
    table_name,
    partition_frequency,
    look_ahead
    )
values
    (
    'pgparttimejob',
    'testdaily',
    'day',
    7
    ),
    (
    'pgparttimejob',
    'testweekly',
    'week',
    5
    ),
    (
    'pgparttimejob',
    'testmonthly',
    'month',
    3
    ),
    (
    'pgparttimejob',
    'testyearly',
    'year',
    2
    )
;

select pgparttimejob.manage_partitions();

create trigger insert_testdaily_trigger 
before insert on pgparttimejob.testdaily 
for each row 
execute procedure day_partition_insert_trigger();

create trigger insert_testweekly_trigger 
before insert on pgparttimejob.testweekly 
for each row 
execute procedure week_partition_insert_trigger();

create trigger insert_testmonthly_trigger 
before insert on pgparttimejob.testmonthly 
for each row 
execute procedure month_partition_insert_trigger();

create trigger insert_testyearly_trigger 
before insert on pgparttimejob.testyearly 
for each row 
execute procedure year_partition_insert_trigger();


