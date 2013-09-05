create or replace function pgparttimejob.manage_partitions() returns void as $$
declare
    tab_cur cursor for
        select
            table_name,
            table_schema,
            partition_frequency,
            look_ahead
        from
            pgparttimejob.partition_tables
    ;
    part_cur    varchar;
    part_rec    record;

    part_sql    varchar; 
    
begin

    for tab_rec in tab_cur loop

    part_cur    :=  'select '
                ||  ''''||tab_rec.table_name||'_''||pr.'||tab_rec.partition_frequency||'_partition_suffix as partition_name, '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_start as partition_filter_start, '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_end as partition_filter_end '
                ||  'from pgparttimejob.partition_ranges pr '
                ||  'where pr.day >= current_date and pr.day < current_date + interval '''|| tab_rec.look_ahead  || ' ' || tab_rec.partition_frequency ||''' and '
                ||  'not exists (select 1 from pg_inherits inh, pg_class cl where '
                ||  'inh.inhrelid = cl.oid and '
                ||  'inh.inhparent = '''||tab_rec.table_schema||'.'||tab_rec.table_name||'''::regclass and '
                ||  'cl.relname = '''||tab_rec.table_name||'_''||pr.'||tab_rec.partition_frequency||'_partition_suffix ) '
                ||  'group by '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_suffix, '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_start, '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_end '
                ||  'order by '
                ||  'pr.'||tab_rec.partition_frequency||'_partition_suffix '
                ||  'limit '||tab_rec.look_ahead
                ||  ';';

        -- Raise notice 'query was : %', part_cur;
        for part_rec in execute part_cur loop

            part_sql    :=  'create table '||tab_rec.table_schema||'.'||part_rec.partition_name||' ('
                        ||  'check ( '
                        ||  'created_at >= '''||part_rec.partition_filter_start||''' and '
                        ||  'created_at < '''||part_rec.partition_filter_end||''') '
                        ||  ') inherits ('||tab_rec.table_schema||'.'||tab_rec.table_name||' )'
                        ||  ';';
    
            -- Raise notice 'create table was : %', part_sql;

            execute part_sql;

        end loop;

    end loop;

end;
$$ language plpgsql;
