.load ../utils/split.dylib
.load ../utils/product.dylib

create temporary table input(line TXT);

.mode csv
.separator \t
.import 13_input.txt input

-- Setup

create temporary table earliest_departure
    as select cast(line as int) time from input where rowid = 1;

create temporary table bus_intervals as
    select
        CASE
            WHEN value = "x" THEN 0
            ELSE cast(value as int)
        END minutes
    from
        input, split(input.line, ",")
    where
        input.rowid = 2;

-- Part 1

with range(i) as (
    select time from earliest_departure

    union all

    select i+1 from range limit
        (select product(minutes) from bus_intervals)
)
select
    (min(range.i) - earliest_departure.time) * bus_intervals.minutes
    from
        bus_intervals,
        earliest_departure,
        range
    where
        range.i % bus_intervals.minutes = 0
        and
        bus_intervals.minutes != 0;

-- Part 2

-- In which we implement the Chinese Remainder Theorem in SQL

with

pairs(x, mod) as (
    select rowid-1, minutes from bus_intervals where minutes != 0
),

product(value) as (
    select product(minutes) from bus_intervals where minutes != 0
),

multiplicative_inverse(key, a, b, x, y) as (
    select
        pairs.mod,
        product.value / pairs.mod, pairs.mod,
        0, 1
    from
        pairs, product

    union all

    select
        key,
        b, a%b,
        y - (a/b)*x, x
    from
        multiplicative_inverse
    where
        a>0
) select

    product.value - sum(
        (pairs.mod+y % pairs.mod) * pairs.x * (product.value / pairs.mod)
    ) % product.value
  from
    multiplicative_inverse, product, pairs
  where
    a=1 and multiplicative_inverse.key = pairs.mod;
