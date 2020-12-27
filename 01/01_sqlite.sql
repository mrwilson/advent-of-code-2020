create table expense_report(entry int);

.mode csv
.import 01_input.txt expense_report

-- Part 1
select
    distinct (a.entry * b.entry)
from
    expense_report a,
    expense_report b
where
    a.entry + b.entry = 2020;

-- Part 2

select
    distinct (a.entry * b.entry * c.entry)
from
    expense_report a,
    expense_report b,
    expense_report c
where
    a.entry + b.entry + c.entry = 2020;
