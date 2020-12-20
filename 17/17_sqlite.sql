.load ../utils/split.dylib
.mode csv

-- Data loading
create temporary table input(line TEXT);
.import 17_chonky.txt input

create table all_cubes as
    select value from input, split(input.line, "");

-- Pre-processing

create table cubes as with dimensions(d) as (
    select max(length(line)) from input
)
    select
        (all_cubes.rowid-1) / dimensions.d x,
        (all_cubes.rowid-1) % dimensions.d y,
        0 z
    from
        all_cubes,
        dimensions
    where
        value != "."
    order by 1, 2;

-- Iterate x 6

create temporary table next_layout(x int, y int, z int, state int);

with

one_away(i) as (
    select 1 union select 0 union select -1
),

transforms(x, y, z) as (
    select
        a.i, b.i, c.i
    from
        one_away a,
        one_away b,
        one_away c
    where
        -- ignore the identity transform
        abs(a.i) + abs(b.i) + abs(c.i) != 0
),

neighbours(x, y, z) as (
    select
        cubes.x + transforms.x,
        cubes.y + transforms.y,
        cubes.z + transforms.z
    from
        cubes,
        transforms
),

counts(x, y, z, total) as (
    select
        x, y, z, count(*) n
    from
        neighbours
    group by
        x, y, z
)

insert into next_layout
    select
        b.x, b.y, b.z,
    CASE
        -- Inactive cubes with 3 active neighbours become active
        WHEN a.x IS NULL AND b.total = 3 THEN 1

        -- Active cubes with 2 or 3 active neighbours remain active
        WHEN a.x IS NOT NULL AND b.total BETWEEN 2 AND 3 THEN 1

        -- All other cubes become inactive
        ELSE 0
    END
    from
        counts b
    left join
        cubes a
    on
        (a.x = b.x and a.y = b.y and a.z = b.z);

delete from cubes;

insert into cubes
    select x,y,z from next_layout where state = 1;
select count(*) from cubes;

