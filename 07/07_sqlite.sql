DROP TABLE IF EXISTS bag_rules;

CREATE TABLE bag_rules (
  colour TEXT,
  amount INT,
  other_colour TEXT
);

-- Magic happens here to turn the input format (bad)
-- into colour, amount, other_colour tuples (good)

.mode csv
.import 07_input.csv bag_rules

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