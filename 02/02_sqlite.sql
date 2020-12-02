CREATE TABLE aoc_2(lower INT, upper INT, letter CHAR, password STRING);

.mode csv
.import 02_input.txt aoc_2

-- Part 1
SELECT "AOC-2020-2.1 = " || count(*)
	FROM aoc_2
	WHERE length(password) - length(replace(password, letter, '')) BETWEEN lower AND upper;

-- Part 2
SELECT "AOC-2020-2.2 = " || count(*)
	FROM aoc_2
	WHERE (substr(password, lower, 1) = letter) + (substr(password, upper,1) = letter) = 1;
