module Types exposing (..)


type Id =
    Id String


type alias Participant =
    { id : Id, name : String }
