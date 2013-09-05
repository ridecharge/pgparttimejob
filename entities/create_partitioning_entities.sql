drop schema if exists pgparttimejob cascade;
create schema pgparttimejob;

create table pgparttimejob.partition_ranges
(
    parition_range_id       serial,
    day                     date        NOT NULL,
    day_partition_suffix    varchar(8)  NOT NULL,
    day_partition_start     date        NOT NULL,
    day_partition_end       date        NOT NULL,
    week_partition_suffix   varchar(6)  NOT NULL,
    week_partition_start    date        NOT NULL,
    week_partition_end      date        NOT NULL,
    month_partition_suffix  varchar(6)  NOT NULL,
    month_partition_start   date        NOT NULL,
    month_partition_end     date        NOT NULL,
    year_partition_suffix   varchar(4)  NOT NULL,
    year_partition_start    date        NOT NULL,
    year_partition_end      date        NOT NULL
)
;

insert into pgparttimejob.partition_ranges
    (
    day,
    day_partition_suffix,
    day_partition_start,
    day_partition_end,
    week_partition_suffix,
    week_partition_start,
    week_partition_end,
    month_partition_suffix,
    month_partition_start,
    month_partition_end,
    year_partition_suffix,
    year_partition_start,
    year_partition_end
    )
(
select
    start_date,
    to_char(daterange.start_date,'YYYYMMDD') as day_partition_suffix,
    daterange.start_date as day_partition_start,
    daterange.end_date as day_partition_end,
    to_char(daterange.start_date,'IYYYIW') as week_partition_suffix,
    cast(date_trunc('week',daterange.start_date) as date) week_partition_start,
    cast(date_trunc('week',daterange.start_date + interval '1 week') as date) week_partition_end,
    to_char(daterange.start_date,'YYYYMM') as month_partition_suffix,
    cast(date_trunc('month',daterange.start_date) as date) month_partition_start,
    cast(date_trunc('month',daterange.start_date + interval '1 month') as date) month_partition_end,
    to_char(daterange.start_date,'YYYY') as year_partition_suffix,
    cast(date_trunc('year',daterange.start_date) as date) year_partition_start,
    cast(date_trunc('year',daterange.start_date + interval '1 year') as date) year_partition_end
from
    (
    select
        to_date('2013-01-01','YYYY-MM-DD') + x.interval as start_date,
        to_date('2013-01-02','YYYY-MM-DD') + x.interval as end_date
    from
        generate_series(0,1500,1) as x(interval)
    ) daterange
)
;

create type pgparttimejob.frequency as enum ('day','week','month','year');

create table pgparttimejob.partition_tables
(
    partition_table_id      serial,
    table_schema            varchar(64) NOT NULL,
    table_name              varchar(64) NOT NULL,
    partition_frequency     pgparttimejob.frequency NOT NULL,
    look_ahead              integer     NOT NULL
)
;

