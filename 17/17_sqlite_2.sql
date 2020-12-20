.load ../utils/split.dylib

create temporary table input(line TEXT);

.mode csv
.import 17_chonky.txt input

create table all_cubes as
    select value from input, split(input.line, "");

create table cubes as with dimensions(d) as (
    select max(length(line)) from input
)
    select
        (all_cubes.rowid-1) / dimensions.d x,
        (all_cubes.rowid-1) % dimensions.d y,
        0 z,
        0 w
    from
        all_cubes,
        dimensions
    where
        value != "."
    order by 1, 2;

-- Iterate x 6

create temporary table next_layout(x int, y int, z int, w int, state int);

with

one_away(i) as (
    select 1 union select 0 union select -1
),
transforms(x, y, z, w) as (
    select
        a.i, b.i, c.i, d.i
    from
        one_away a,
        one_away b,
        one_away c,
        one_away d
    where
        -- ignore the identity transform
        abs(a.i) + abs(b.i) + abs(c.i) + abs(d.i) != 0
),
neighbours(x, y, z, w) as (
    select
        cubes.x + transforms.x,
        cubes.y + transforms.y,
        cubes.z + transforms.z,
        cubes.w + transforms.w
    from
        cubes,
        transforms
),

counts(x, y, z, w, total) as (
    select
        x, y, z, w, count(*) n
    from
        neighbours
    group by
        x, y, z, w

)

insert into next_layout
    select
        b.x, b.y, b.z, b.w,
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
        (a.x = b.x and a.y = b.y and a.z = b.z and a.w = b.w);

delete from cubes;

insert into cubes
    select x, y, z, w from next_layout where state = 1;

select count(*) from cubes;