DROP TABLE IF EXISTS boarding_passes;

CREATE TABLE boarding_passes (
	code TEXT,
	row INT,
	seat INT,
	seat_id INT GENERATED ALWAYS AS (row * 8 + seat) STORED
);


-- HERE WE GO
-- Generate all pairs (0..127,0..8) and derive their boarding pass number
-- This is our precompute table so the problem-solving becomes "just" a lookup

INSERT INTO boarding_passes WITH RECURSIVE
row_number(row) AS (
    SELECT 0 UNION ALL SELECT row+1 FROM row_number LIMIT 128
), seat_number(seat) AS (
     SELECT 0 UNION ALL SELECT seat+1 FROM seat_number LIMIT 8
 ) SELECT
    -- Row number
    CASE WHEN row & 64 THEN "B" ELSE "F" END
    || CASE WHEN row & 32 THEN "B" ELSE "F" END
    || CASE WHEN row & 16 THEN "B" ELSE "F" END
    || CASE WHEN row & 8 THEN "B" ELSE "F" END
    || CASE WHEN row & 4 THEN "B" ELSE "F" END
    || CASE WHEN row & 2 THEN "B" ELSE "F" END
    || CASE WHEN row % 2 THEN "B" ELSE "F" END
    -- Seat number
    || CASE WHEN seat & 4 THEN "R" ELSE "L" END
    || CASE WHEN seat & 2 THEN "R" ELSE "L" END
    || CASE WHEN seat % 2 THEN "R" ELSE "L" END,
    row,
    seat
    FROM row_number, seat_number;

-- Load data

DROP TABLE IF EXISTS test_passes;
CREATE TABLE test_passes(code TEXT);

.mode csv
.import 05_input.txt test_passes

-- Part 1

select max(seat_id)
    from boarding_passes bp
    join test_passes tp on (bp.code = tp.code);

-- Part 2

create temporary table test_seat_ids as select
    bp.seat_id from
        boarding_passes bp,
        test_passes tp where tp.code = bp.code;

select seat_id
    from boarding_passes
    where
        row not in (0, 127)
        and
        seat_id not in (select * from test_seat_ids)
        and
        seat_id - 1 in (select * from test_seat_ids)
        and
        seat_id + 1 in (select * from test_seat_ids)
        ;




