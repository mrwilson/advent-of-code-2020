.load ../utils/split.dylib

create temporary table input(line TEXT);

.mode csv
.import 11_input.txt input

create table all_seats as
    select value from input, split(input.line, "");

create table seats(x int, y int, status int, unique(x,y));

with dimensions(d) as (
    select max(length(line)) from input
) insert into seats select
        (all_seats.rowid-1) / dimensions.d,
        (all_seats.rowid-1) % dimensions.d,
        CASE
            WHEN value = "L" THEN 0 -- empty
            ELSE 1 -- taken
        END
    from
        all_seats,
        dimensions
    where
        value != "."
    order by 1, 2;

select count(*), max(length(line)), min(length(line)) from input;