.load ../utils/split.dylib

create table inputs(line text);

.mode csv
.separator \t
.import 07_input.txt inputs

create table bag_rules as with cleanup(rule) as (
    select
        replace(
            replace(
                replace(
                    replace(line, ".", ""),
                    " bags contain ",
                    ":"
                ),
                " bags",
                ""
            ),
            " bag",
            ""
        )
    from
        inputs
),
outer_inner(outside, inside) as (
    select
        substr(rule, 0, instr(rule, ":")),
        substr(rule, instr(rule, ":")+1)
    from
        cleanup
),
rules(colour, amount, other_colour) as (
    select
        outside colour,
        cast(
            substr(
                trim(split.value," "),
                0,
                instr(trim(split.value), " ")
        ) as int) amount,
        substr(
            trim(split.value," "),
            instr(trim(split.value), " ")+1
        ) other_colour
    from
        outer_inner,
        split(outer_inner.inside, ",")
) select * from rules;

-- Part 1

WITH results(current_colour) as (
  select "shiny gold"

  UNION ALL

  select colour from bag_rules, results where other_colour = current_colour
)

-- Knock off 1 for "shiny gold" being in the result set
select count(distinct current_colour) - 1 from results;

-- Part 2

WITH results(current_colour, running_total) as (
  select "shiny gold", 1

  UNION ALL

  select other_colour, running_total * amount from bag_rules, results where colour = current_colour
)

-- Knock off 1 for "shiny gold" being in the result set
select sum(running_total) - 1 from results;