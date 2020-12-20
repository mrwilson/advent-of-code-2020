.load ../utils/split.dylib
.mode csv

create temporary table rules(field TEXT, lower int, upper int);
.import 16_real_bounds.txt rules

create temporary table input (line TEXT);
.separator \t
.import 16_real_tickets.txt input

create temporary table tickets as
     select
        input.rowid ticket_id,
        cast(value as int) value
    from
        input,
        split(input.line,",");

create temporary table invalid_fields as with validation(ticket_id, value, valid) as (
    select
        ticket_id,
        value,
        CASE
            WHEN tickets.value between rules.lower and rules.upper THEN 1
            ELSE 0
        END
    from
        tickets,
        rules
)
    select ticket_id, value from validation group by 1,2 having sum(valid) = 0;

-- Part 1

select sum(value) from invalid_fields;

-- Part 2

-- We only care about valid tickets
create temporary table valid_tickets as
    select
        ticket_id,
        ((tickets.rowid-1) % (select count(*)/2 from rules))+1 as column,
        tickets.value as value
    from
        tickets
    where
        ticket_id not in
            (select distinct ticket_id from invalid_fields);

create temporary table final_result(column TEXT, name TEXT PRIMARY KEY);

-- Winnow out field names that have only one possible column
with candidates(col, name) as (
    select
        column col,
        rules.field name
    from
        valid_tickets,
        rules
    where
        valid_tickets.value between rules.lower and rules.upper
    group by 1, 2
    having
        count(*) = (select count(distinct ticket_id) from valid_tickets)
)
insert into final_result
      select
          candidates.col,
          candidates.name
      from
          (select col, count(*) total from candidates group by 1) a,
          candidates
      where
          candidates.col = a.col
      order by
        total
      on
        conflict(name) do nothing;

-- Print out columns that need to be multiplied
select column from final_result where name like '%departure%';