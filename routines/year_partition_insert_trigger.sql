create or replace function public.year_partition_insert_trigger()
returns trigger as $$
declare
    ins_tbl varchar;
begin
    ins_tbl     :=  TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || '_' || to_char(NEW.created_at,'IYYYIW');
    execute 'insert into '|| ins_tbl ||' select ($1).*' using NEW;
    return null;
end;
$$ language plpgsql;
