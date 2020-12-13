create temporary table next_layout(x int, y int, status int);

with neighbours(x,y) as (
    select x+1, y from seats where status = 1
    union all

    select x, y+1 from seats where status = 1
    union all

    select x-1, y from seats where status = 1
    union all

    select x, y-1 from seats where status = 1
    union all

    select x+1, y+1 from seats where status = 1
    union all

    select x-1, y+1 from seats where status = 1
    union all

    select x-1, y-1 from seats where status = 1
    union all

    select x+1, y-1 from seats where status = 1

), counts(x,y,total) as (
    SELECT
        x,
        y,
        COUNT(*) n
    FROM neighbours
    GROUP BY x,y
) insert into next_layout select
    a.x,
    a.y,
    CASE
        WHEN a.status = 0 AND coalesce(b.total, 0) = 0 THEN 1
        WHEN a.status = 1 AND coalesce(b.total, 0) >= 4 THEN 0
        ELSE a.status
    END
    from
        seats a
    left join
        counts b
    on
        (a.x = b.x and a.y = b.y);
--

delete from seats;
insert into seats select * from next_layout;

select sum(status) from seats;