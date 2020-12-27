create table boarding_passes (
	code text,
	row int,
	seat int,
	seat_id int generated always as (row * 8 + seat) stored
);


-- HERE WE GO
-- Generate all pairs (0..127,0..8) and derive their boarding pass number
-- This is our precompute table so the problem-solving becomes "just" a lookup

insert into boarding_passes with
row_number(row) as ( select 0 union all select row+1 from row_number limit 128 ),
seat_number(seat) as ( select 0 union all select seat+1 from seat_number LIMIT 8 )

select
    -- Row number
    case when row & 64 then "B" else "F" end
    || case when row & 32 then "B" else "F" end
    || case when row & 16 then "B" else "F" end
    || case when row & 8 then "B" else "F" end
    || case when row & 4 then "B" else "F" end
    || case when row & 2 then "B" else "F" end
    || case when row % 2 then "B" else "F" end
    -- Seat number
    || case when seat & 4 then "R" else "L" end
    || case when seat & 2 then "R" else "L" end
    || case when seat % 2 then "R" else "L" end,
    row,
    seat
    from
        row_number,
        seat_number;

-- Load data

create table test_passes(code TEXT);

.mode csv
.import 05_input.txt test_passes

-- Part 1

select max(seat_id)
    from boarding_passes bp
    join test_passes tp on (bp.code = tp.code);

-- Part 2

create temporary table test_seat_ids as
    select
        bp.seat_id
    from
        boarding_passes bp,
        test_passes tp
    where
        tp.code = bp.code;

select
    seat_id
from
    boarding_passes
where
    row not in (0, 127)
    and
    seat_id not in (select * from test_seat_ids)
    and
    seat_id - 1 in (select * from test_seat_ids)
    and
    seat_id + 1 in (select * from test_seat_ids);




