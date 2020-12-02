CREATE TABLE aoc_1(value INT);

.mode csv
.import 01_input.txt aoc_1

-- Part 1
SELECT DISTINCT "AOC-2020-1.1 = " || (a.value * b.value)
	FROM aoc_1 a, aoc_1 b WHERE a.value + b.value = 2020;

-- Part 2
SELECT DISTINCT "AOC-2020-1.2 = " || (a.value * b.value * c.value)
	FROM aoc_1 a, aoc_1 b, aoc_1 c WHERE a.value + b.value + c.value = 2020;
