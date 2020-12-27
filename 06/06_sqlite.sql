.load ../utils/split.dylib

create table customs_declarations(answer TEXT);

.mode csv
.import 06_input.txt customs_declarations

-- Generate a table of passenger groups and split each
-- passengers questions into a separate row so that we
-- notionally have a table of (group, passenger, answer)

create table answers as with passenger_groups(high, low) as (
    select
	    rowid, lag(rowid,1,0) over (order by rowid asc) as next
    from
        customs_declarations where answer = ""
)
select
    split.value answer,
    low,
    high,
    customs_declarations.rowid row
from
    passenger_groups,
    customs_declarations,
    split(customs_declarations.answer,"")
where
    customs_declarations.rowid between low+1 and high-1
order by
    2, 4;

-- Part 1

select sum(total) from
    (select count(distinct answer) total from answers group by low, high);

-- Part 2

select count(*) from
    (select count(distinct row) from answers
        group by low, answer having count(answer) = high - (low+1));

