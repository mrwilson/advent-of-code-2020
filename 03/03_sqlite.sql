.load ../utils/split.dylib

create table inputs(line text);

.mode csv
.import 03_input.txt inputs

-- Preprocess input into table of tree coordinates
create temporary table coordinates as
    select
        inputs.rowid - 1 x, split.value square
    from
        inputs, split(inputs.line,"");

create temporary table trees as
    select
        x, (rowid-1) % 31 y
    from
        coordinates
    where
        square = "#";

-- Part 1

select count(*) from trees where y = (3 * x) % 31;

-- Part 2
select
    count(*) filter (where y = x % 31) *
    count(*) filter (where y = (3 * x) % 31) *
    count(*) filter (where y = (5 * x) % 31) *
    count(*) filter (where y = (7 * x) % 31) *
    count(*) filter (where x % 2 = 0 and y = (x/2) % 31)
from
    trees;
