.load product.dylib

-- Integer

with range(i) as (
    select 1 union select i+1 from range limit 5
)
select product(i) from range; -- 120

-- Floating point

with range(i) as (
    select 1.0 union select i+1 from range limit 5
)
select product(i) from range; -- 120.0