DROP TABLE IF EXISTS preamble;
CREATE TABLE preamble(value INT);

.mode csv
.import 09_input.txt preamble

DROP TABLE IF EXISTS missing_values;
CREATE TABLE missing_values(value INT);

-- Magic number is 5 for example, 25 for real input

INSERT INTO missing_values select * from preamble where value not in (
    select a.value from preamble a, preamble b, preamble c
        where a.value = (b.value + c.value)
            and b.rowid BETWEEN a.rowid - 5 and a.rowid - 1
            and c.rowid BETWEEN a.rowid - 5 and a.rowid - 1
    )
    and rowid > 5;

-- Part 1

select * from missing_values limit 1;

-- Part 2

WITH

bounded_pairs(lower, upper) AS (
    select
        a.rowid, b.rowid
    from
        preamble a, preamble b
    where
        b.rowid > a.rowid
)
    select
        min(value) + max(value)
    from
        preamble a, bounded_pairs b
    where
        a.rowid between b.lower AND b.upper
    group by
        lower, upper
    having
        sum(value) = (select * from missing_values limit 1);