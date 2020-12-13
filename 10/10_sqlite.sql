.load ../utils/product.dylib

CREATE TEMPORARY TABLE adapters(voltage int);

.mode csv
.import 10_input.txt adapters

CREATE TEMPORARY TABLE connections(value int, next int);

WITH voltage_pairs(value, next, difference) as (
    -- Possible connections out from the socket
    select
        0,
        voltage
    from adapters where voltage <= 3

    union all

    -- Connecting highest voltage to the device
    select
        max(voltage),
        max(voltage) + 3
    from adapters

    union all

    -- Everything in between
    select
        a.voltage,
        b.voltage
    from
        adapters a,
        adapters b
    where
        b.voltage > a.voltage
        and
        b.voltage - a.voltage <= 3
) insert into connections select * from voltage_pairs;


-- Part 1

with smallest_jumps(difference) as (
    select
        min(next - value)
    from
        connections
    group by
        value
)

select product(c) from (
    select count(*) c from smallest_jumps group by difference
);

-- Part 2

with nearest_successor(value, next) as (
    select
        value, min(next)
    from
        connections
    group by 1

), clusters(value, next, running, total) as (

    -- Find out how often we get a run of
    -- adapters that are 1 volt apart as these
    -- are the parts which differ between possible sequences

    select *, 1, 0 from nearest_successor where value = 0

    union all

    select
        a.value,
        a.next,
        CASE
            WHEN a.next = a.value + 1 THEN running+1 ELSE 0 END,
        CASE
            WHEN running = 2 AND a.next != a.value + 1 THEN 2
            WHEN running = 3 AND a.next != a.value + 1 THEN 4
            WHEN running = 4 AND a.next != a.value + 1 THEN 7
            ELSE 0
        END
    from
        nearest_successor a,
        clusters
    where
        a.value = clusters.next
)

select product(total) from (
    select
        total,
        lead(total, 1, 0) over (order by value) as is_end_of_cluster
    from
        clusters
) where is_end_of_cluster = 0 and total != 0;
