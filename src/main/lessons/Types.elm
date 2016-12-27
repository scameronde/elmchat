module Types exposing (..)


type alias Id =
    String


type alias Participant =
    { id : Id, name : String }


setId : a -> { c | id : a } -> { c | id : a }
setId id model =
    { model | id = id }


setName : a -> { c | name : a } -> { c | name : a }
setName name model =
    { model | name = name }
