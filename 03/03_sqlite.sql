-- Preprocess input into CSV of coordinates
CREATE TABLE trees(x int, y int);

-- 31 is the width of the repeating biome

-- Part 1
select count(*) from trees where y = (3 * x) % 31;


-- Part 2

select
  (select count(*) from trees where y = x % 31) *
  (select count(*) from trees where y = (3 * x) % 31) *
  (select count(*) from trees where y = (5 * x) % 31) *
  (select count(*) from trees where y = (7 * x) % 31) *
  (select count(*) from trees where x % 2 = 0 and y = (x/2) % 31);
