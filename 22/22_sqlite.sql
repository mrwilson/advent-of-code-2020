create table player1(card int);
create table player2(card int);

.mode csv
.import 22_player_1.txt player1
.import 22_player_2.txt player2

with
deck1(deck) as ( select json_group_array(card) from player1 ),
deck2(deck) as ( select json_group_array(card) from player2 ),
game(p1, p2) as (
    select deck1.deck, deck2.deck from deck1, deck2

    union all

    select
        case
            when json_extract(p1, "$[0]") > json_extract(p2, "$[0]")
            then json_remove(
                    json_insert(p1,
                        "$[#]", json_extract(p1, "$[0]"),
                        "$[#]", json_extract(p2, "$[0]")
                    )
                ,"$[0]")
            else json_remove(p1, "$[0]")
        end,
        case
            when json_extract(p1, "$[0]") > json_extract(p2, "$[0]")
            then json_remove(p2, "$[0]")
            else json_remove(
                     json_insert(p2,
                         "$[#]", json_extract(p2, "$[0]"),
                         "$[#]", json_extract(p1, "$[0]")
                     )
                 ,"$[0]")
        end
    from
        game
    where
        json_array_length(p1) > 0 and json_array_length(p2) > 0
),

winning_deck(deck) as (
    select
        case when json_array_length(p1) > 0 then p1 else p2 end
    from
        game
    where
        json_array_length(p1) * json_array_length(p2) = 0
)
select
    sum(
        ((json_array_length(winning_deck.deck)+1) -json_each.id) * json_each.value
    )
from
    winning_deck,
    json_each(winning_deck.deck);

