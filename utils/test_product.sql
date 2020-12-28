.load product.dylib

with range(i) as (
    select 1 union select i+1 from range limit 5
)
select
    product(i),
    product(cast(i as float))
from
    range; -- 120,120.0