CREATE TEMPORARY TABLE input(code TEXT);

.mode csv
.import 12_input.txt input

-- Pre process

CREATE TEMPORARY TABLE instructions as
    select
        substr(code, 1, 1) as operation,
        cast(substr(code, 2) as int) as amount
    from
        input
;

create temporary table range(i int);

with loop(i) as (
    select 1

    union all

    select i+1 from loop

    limit (select count(*) from instructions)
) insert into range select * from loop;

-- Part 1

with iteration(i, x, y, direction) as (
    select 1, 0, 0, 90

    union all

    select
        iteration.i+1,
        CASE
            WHEN
                ins.operation = "E" or (iteration.direction = 90 and ins.operation = "F")
            THEN
                iteration.x + ins.amount

            WHEN
                ins.operation = "W" or (iteration.direction = 270 and ins.operation = "F")
            THEN
                iteration.x - ins.amount

            ELSE
                iteration.x
        END,
        CASE
            WHEN
                ins.operation = "N" or (iteration.direction = 0 and ins.operation = "F")
            THEN
                iteration.y + ins.amount

            WHEN ins.operation = "S" or (iteration.direction = 180 and ins.operation = "F")
            THEN iteration.y - ins.amount
            ELSE
                iteration.y
        END,
        CASE
            WHEN ins.operation = "R" THEN (iteration.direction + ins.amount + 360) % 360
            WHEN ins.operation = "L" THEN (iteration.direction - ins.amount + 360) % 360
            ELSE iteration.direction
        END
    from
        instructions ins,
        range,
        iteration
    where
        ins.rowid = range.i
        and
        iteration.i = range.i

    limit
        (select count(*) from instructions) + 1
)

select abs(x) + abs(y) from iteration order by i desc limit 1;

-- Part 2

with iteration(i, x, y, wx, wy) as (
    select 1, 0, 0, 10, 1

    union all

    select
        iteration.i+1,
        CASE
            WHEN ins.operation = "F" THEN iteration.x + (ins.amount * iteration.wx)
            ELSE iteration.x
        END,
        CASE
            WHEN ins.operation = "F" THEN iteration.y + (ins.amount * iteration.wy)
            ELSE iteration.y
        END,
        CASE
            WHEN ins.operation = "E" THEN iteration.wx + ins.amount
            WHEN ins.operation = "W" THEN iteration.wx - ins.amount
            WHEN (ins.operation = "L" and ins.amount = 90) THEN -iteration.wy
            WHEN (ins.operation = "L" and ins.amount = 180) THEN -iteration.wx
            WHEN (ins.operation = "L" and ins.amount = 270) THEN iteration.wy
            WHEN (ins.operation = "R" and ins.amount = 90) THEN iteration.wy
            WHEN (ins.operation = "R" and ins.amount = 180) THEN -iteration.wx
            WHEN (ins.operation = "R" and ins.amount = 270) THEN -iteration.wy
        ELSE
            iteration.wx
        END,
        CASE
            WHEN ins.operation = "N" THEN iteration.wy + ins.amount
            WHEN ins.operation = "S" THEN iteration.wy - ins.amount
            WHEN (ins.operation = "L" and ins.amount = 90) THEN iteration.wx
            WHEN (ins.operation = "L" and ins.amount = 180) THEN -iteration.wy
            WHEN (ins.operation = "L" and ins.amount = 270) THEN -iteration.wx
            WHEN (ins.operation = "R" and ins.amount = 90) THEN -iteration.wx
            WHEN (ins.operation = "R" and ins.amount = 180) THEN -iteration.wy
            WHEN (ins.operation = "R" and ins.amount = 270) THEN iteration.wx
        ELSE
            iteration.wy
        END
    from
        instructions ins,
        range,
        iteration
    where
        ins.rowid = range.i
        and
        iteration.i = range.i

    limit
        (select count(*) from instructions) + 1
)

select abs(x) + abs(y) from iteration order by i desc limit 1;