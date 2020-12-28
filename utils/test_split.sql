.load split.dylib

select
    group_concat(value,"|")
from
    split("abc",""); -- a,b,c
