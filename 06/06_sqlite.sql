DROP TABLE IF EXISTS customs_declarations;

CREATE TABLE customs_declarations(
  answer TEXT
);

.mode csv
.import 06_input.txt customs_declarations

-- Generate a table of passenger groups and split each
-- passengers questions into a separate row so that we
-- notionally have a table of (group, passenger, answer)

create temporary table answers(answer, low, high, row);

with passenger_groups(high, low) AS (
    select
	    rowid, lag(rowid,1,0) over (order by rowid asc) as next
    from
        customs_declarations where answer = ""
),
string_to_characters(row, label, str) AS (
    select
        rowid, '', answer
    from
        customs_declarations where answer != ""

    union all

    select
        row, substr(str, 0, 2), substr(str, 2)
    from
        string_to_characters where str != ""
)

insert into answers
    select
        label, low, high, row
    from
        passenger_groups, string_to_characters
    where
        label != "" and row between low+1 and high-1
    order by
        low, row;

-- Part 1

select sum(total) from
    (select count(distinct answer) total from answers group by low, high);

-- Part 2

select count(*) from
    (select count(distinct row) from answers
        group by low, answer having count(answer) = high - (low+1));

