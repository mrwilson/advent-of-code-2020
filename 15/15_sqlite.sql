-- Part 1
with game(round, last_number, entries) as (
    select 7, 18, json_object(
        "2",  1,
        "0",  2,
        "1",  3,
        "7",  4,
        "4",  5,
        "14", 6
    )

    union all

    select
        round+1,
        CASE
            WHEN json_extract(entries, "$."|| last_number) IS NULL THEN 0
            ELSE round - json_extract(entries, "$."||last_number)
        END,
        json_set(entries, "$."||last_number, round)
    from
        game
    limit
        2020

) select last_number from game where round=2020;