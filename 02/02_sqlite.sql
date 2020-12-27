create table passwords(lower int, upper int, letter char, password text);

.mode csv
.import 02_input.txt passwords

-- Part 1
select
    count(*)
from
    passwords
where
    length(password) - length(replace(password, letter, '')) between lower and upper;;

-- Part 2
select
    count(*)
from
    passwords
where
    (substr(password, lower, 1) = letter) +
    (substr(password, upper, 1) = letter) = 1;
