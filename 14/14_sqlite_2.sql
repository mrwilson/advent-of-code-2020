.load ../utils/binary_to_int.dylib

-- preprocess into CSV to avoid unnecessary joins
create table input(mask text, memory_location int, value text);

.mode csv
.import 14_input.csv input

create table plausible_memory_locations as with

locations(round, original, mask) as (
    select distinct
        0,
        mask,
        replace(replace(mask,"0","Y"),"1","Y")
    from input

    union all

    select
        round+1,
        original,
        case
            when
                instr(mask, "X") = length(mask)
            then
                substr(mask, 1, 35) || options.replacement

            else
                substr(mask, 1, instr(mask, "X")-1)
                || options.replacement
                || substr(mask, instr(mask,"X")+1)
        end
    from
        locations,
        (select 0 replacement union select 1) options
    where
        instr(mask, "X") > 0
) select
    original,
    binary_to_int(replace(mask,"Y",1)) lower_mask,
    binary_to_int(replace(mask,"Y",0)) upper_mask
from locations where instr(mask, "X") = 0;

---- Part 2
with processing(round, memory_location, value) as (
    select
        input.rowid,
        input.memory_location
                | binary_to_int(replace(input.mask, "X", 0))
                & plausible_memory_locations.lower_mask
                | plausible_memory_locations.upper_mask,
        cast(input.value as bigint)
    from
        input,
        plausible_memory_locations
    where
        plausible_memory_locations.original = input.mask
),

last_entries(memory_location, round) as (
    select
        memory_location, max(round)
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
    (select
        distinct processing.memory_location,
        value
    from
        last_entries
    join
        processing
    on
        (processing.round = last_entries.round and processing.memory_location = last_entries.memory_location)
);