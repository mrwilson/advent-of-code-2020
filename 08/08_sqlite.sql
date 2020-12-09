DROP TABLE IF EXISTS opcodes;
CREATE TABLE opcodes(instruction TEXT, value INT);

.mode csv
.separator ' '
.import 08_input.txt opcodes

-- Part 1

WITH running_program(idx, line, instruction, value, total) AS (
	select 0, rowid, instruction, value, 0 from opcodes where rowid = 1

	UNION ALL

	select running_program.idx + 1,
		opcodes.rowid,
		opcodes.instruction,
		opcodes.value,
		CASE
		    WHEN running_program.instruction = "acc" THEN total+running_program.value
		    ELSE total
        END
		from opcodes, running_program
		where opcodes.rowid = CASE
		    WHEN running_program.instruction = "jmp" THEN line+running_program.value
		    ELSE line+1
        END
		limit 1000000

) select "Part 1 = " || total from (
	select
	    idx,
	    total,
	    row_number() over(
	        partition by line order by line asc
        ) as occurrences
    from running_program
) where occurrences > 1 order by idx asc limit 1;

-- Part 2

DROP TABLE IF EXISTS expanded_codes;
CREATE TABLE expanded_codes(flip_line int, line int, instruction TEXT, value INT);

WITH flippable(line, instruction, value) AS (
    select rowid, * from opcodes where instruction != "acc" and value != 0
) insert into expanded_codes select flippable.line as flip_line,
     opcodes.rowid as line,
      CASE
          WHEN opcodes.instruction = "nop" AND flippable.line = opcodes.rowid THEN "jmp"
          WHEN opcodes.instruction = "jmp" AND flippable.line = opcodes.rowid THEN "nop"
          ELSE opcodes.instruction
      END as instruction,
      opcodes.value as value
  from opcodes, flippable;

-- This gives you the flipped line that caused termination
with running_program(idx, flip, line, instruction, value, total) AS (
	select 0, *, 0 from expanded_codes where line = 1

	UNION ALL

	select running_program.idx + 1,
	    opcodes.flip_line,
		opcodes.line,
		opcodes.instruction,
		opcodes.value,
		CASE
		    WHEN running_program.instruction = "acc" THEN total+running_program.value
		    ELSE total
        END
		from running_program, expanded_codes opcodes
		where opcodes.line = CASE
		    WHEN running_program.instruction = "jmp" THEN running_program.line+running_program.value
		    ELSE running_program.line+1
        END
        and
        running_program.flip = opcodes.flip_line
		limit 100000
) select
	"Flipped Instruction = #" || flip,
	"Operations = " || count(*) operations
  from running_program
  group by 1
  order by 2 asc
  limit 1;
