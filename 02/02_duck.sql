create table passwords(lower int, upper int, letter char, password text);

copy passwords from './02_input.txt';

-- Part 1

select
    count(*)
from
    passwords
where
    length(password) - length(replace(password, letter, '')) between lower and upper;

-- Part 2

select
    count(*)
from
    passwords
where
    case when substring(password, lower, 1) = letter then 1 else 0 end
    + case when substring(password, upper, 1) = letter then 1 else 0 end = 1;
