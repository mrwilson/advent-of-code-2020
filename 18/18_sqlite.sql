create table data(line TEXT);

.mode csv
.import 18_test.txt data

create temporary table inputs(
    _line TEXT,
    line TEXT GENERATED ALWAYS AS (replace(_line," ",""))
);

insert into inputs select * from data;

create temporary table parsed as

with shunting_yard(round, input_line, operators, out, last_open_bracket) as (
    select 1, line, json_array(), json_array(), json_array() from inputs

    union all

    select
        round+1,
        input_line,
        CASE
            WHEN
                substr(input_line, round, 1) glob '[0-9]*'
                and
                json_array_length(operators) > 0
                and
                json_extract(operators, "$[#-1]") != "("
            THEN
                -- pop
                json_remove(operators,'$[#-1]')


            WHEN
                substr(input_line, round, 1) in ("+","*","(")
            THEN
                -- push the operator onto operator stack
                json_insert(operators,'$[#]',substr(input_line, round, 1))

            WHEN
                substr(input_line, round, 1) in (")")
            THEN
                -- push the operator onto operator stack
                (select json_group_array(a) from (
                    select
                        json_each.value a
                    from
                        json_each(operators)
                    where
                        json_each.id < json_extract(last_open_bracket,"$[#-1]")
                    )
                 )
            ELSE
                operators
        END,
        CASE
            WHEN
                substr(input_line, round, 1) glob '[0-9]*'
            THEN
                -- push the number onto the output stack
                (select json_group_array(a) from (
                    select json_each.value a from json_each(out)
                    union all
                    select substr(input_line, round, 1)
                    union all
                    select json_extract(operators, "$[#-1]")
                ) where a is not null and a != "(")

            WHEN
                substr(input_line, round, 1) = ')'
            THEN
                -- pop the operator stack until you meet first bracket

                (select
                    json_group_array(a)
                from (
                    select
                        json_each.id id,
                        json_each.value a
                    from
                        json_each(out)

                    union all

                    select
                        json_each.id id,
                        json_each.value a
                    from
                        json_each(operators)
                    where
                        json_each.id >= json_extract(last_open_bracket,"$[#-1]")
                        and
                        json_each.value not in ("(",")")

                    )
                )
            ELSE
                out
        END,
        CASE
            WHEN substr(input_line, round, 1) = "(" THEN json_insert(last_open_bracket, "$[#]", json_array_length(last_open_bracket)+1)
            WHEN substr(input_line, round, 1) = ")" THEN json_remove(last_open_bracket, "$[#-1]")
            ELSE last_open_bracket
        END
    from
        shunting_yard
    where
        round <= length(trim(input_line,")"))

),
rpn(input_line, out, operators) as (
    select
        input_line, out, operators
    from
        shunting_yard
    group by
        1
    having
        round = max(round)
),
pop_final_stack(line, id, symbol) as (
  select
    input_line,
    json_each.id id,
    json_each.value a
  from
    rpn, json_each(rpn.out)

  union all

  select
      input_line,
      length(rpn.out) + length(rpn.operators) - json_each.id id,
      json_each.value a
  from
      rpn,
      json_each(rpn.operators)

  order by
    1, 2

)
--select * from shunting_yard;
--.mode table
--select * from parsed;


select line, json_group_array(symbol) reverse_polish_notation from pop_final_stack group by line;

.mode table

with calculate(equation, numbers, notation) as (
    select
        line,
        json_array(),
        reverse_polish_notation
    from
        parsed

    union all

    select
        equation,
        CASE
            WHEN json_extract(notation, "$[0]") glob '[0-9]*'
            THEN
                json_insert(numbers, "$[#]", cast(json_extract(notation, "$[0]") as bigint))

            WHEN json_extract(notation, "$[0]") = "+"
            THEN
                json_insert(
                    json_remove(numbers, "$[#-1]", "$[#-1]"),
                    "$[#]",
                    json_extract(numbers, "$[#-1]") + json_extract(numbers, "$[#-2]")
                )

            WHEN json_extract(notation, "$[0]") = "*"
            THEN
                json_insert(
                    json_remove(numbers, "$[#-1]", "$[#-1]"),
                    "$[#]",
                    json_extract(numbers, "$[#-1]") * json_extract(numbers, "$[#-2]")
                )

            ELSE
                numbers
            END,

            json_remove(notation, "$[0]")

        from
            calculate
        where
            json_array_length(notation) > 0
)
select
    sum(json_extract(numbers,"$[0]"))
from
    calculate
where
    json_array_length(notation) = 0;