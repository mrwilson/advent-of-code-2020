.load ../utils/binary_to_int.dylib

create table input(memory_location int, value text);

.mode csv
.import 14_input.txt input

-- Part 1
with processing(round, memory_location, value, current_mask) as (
    select 1, -1, 0, value from input where input.rowid = 1

    union all

    select
        round+1,
        input.memory_location,
        case
            when input.memory_location = -1 then -1
            else
                (cast(input.value as int) | binary_to_int(replace(current_mask, "X", 0)))
                    & binary_to_int(replace(current_mask, "X", 1))
        end,
        case
            when input.memory_location = -1 then input.value
            else current_mask
        end
    from
        processing,
        input
    where
        input.rowid = processing.round+1
),

last_entries(round) as (
    select
        max(round)
    from
        processing
    where
        memory_location != -1
    group by
        memory_location
)

select
    sum(value)
from
    processing
join
    last_entries on (last_entries.round = processing.round);