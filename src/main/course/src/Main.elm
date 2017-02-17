module Main exposing (main, Ampel(Rot))

import Html exposing (..)


main : Html msg
main =
    text "Hello World!!"



-- Simple Types


a : Bool
a =
    True


b : Int
b =
    5


c : Float
c =
    6.6


d : Char
d =
    'a'


e : String
e =
    "Ein String"


f : String
f =
    """
Noch ein String
"""


u : ()
u =
    ()



-- Aggregated Types


g : List number
g =
    [ 5, 4, 3 ]


h : ( Int, Bool, String )
h =
    ( 5, True, "Hi" )


i : Moderator
i =
    { id = Id 5, name = "Peter" }



-- Function Type


j : String -> Html msg
j =
    text


j1 : String -> Int
j1 =
    String.length



-- Sum Type


type Ampel
    = Gruen
    | Gelb
    | Rot


type Ergebnis
    = Fehler String
    | OK Int


e1 : Ergebnis
e1 =
    OK 5


e2 : Ergebnis
e2 =
    Fehler "So was auch"


type Ergebnis_ a
    = Fehler_ String
    | OK_ a


e3 : Ergebnis_ String
e3 =
    OK_ "Hallo"



-- Type Alias


type Id
    = Id Int


type alias Punkt =
    ( Int, Int )


fu : Id -> String
fu pups =
    toString pups



-- RECORDS


type alias Moderator =
    { id : Id, name : String }

type alias Participant =
  {id : Id, participantNumber : Int}

type Person =  Moderator2 { id : Id, name : String } | Participant2 {id : Id, participantNumber : Int}

p = Moderator2 {id=Id 5, name="Bert"}

-- Create


mod1 =
    { id = Id 5, name = "Bert" }


mod2 =
    Moderator (Id 5) "Ernie"


partialMod2 : String -> Moderator
partialMod2 =
    Moderator (Id 5)



-- Read
mod2Name = mod2.name
mod2Name_ = .name mod2
{id, name} = mod2

-- Modify
mod3 = {mod2 | name="Bibo"}

-- Function Application and Composition

add2 : Int -> Int
add2 value =
    value + 2

mult2 : Int -> Int
mult2 value =
    value * 2

addmult = add2 >> mult2
multadd = add2 << mult2

am1 = mult2 (add2 (mult2 5))
am2 = (mult2 << add2 << mult2)  5
am3 = 5 |> mult2 |> add2 |> mult2

lofs = "Text" |> String.trim |> String.length

