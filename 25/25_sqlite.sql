with handshake(round, public_key) as (
    select 0, 1

    union all

    select
        round+1,
        (public_key * 7) % 20201227
    from
        handshake
    where
        round <= 20201228
)
select
    public_key
from
    (select round from handshake where public_key=8421034 limit 1) as card_loop,
    (select round from handshake where public_key=15993936 limit 1) as door_loop,
    handshake
where
    handshake.round = (card_loop.round * door_loop.round) % 20201226;