module Sideeffect exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Random


type alias Model =
    Int


type Msg
    = NewRandomValue Int
    | RequestNewRandomValue


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestNewRandomValue ->
            ( model, Random.generate NewRandomValue (Random.int 1 100) )

        NewRandomValue value ->
            ( value, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ span [] [ text (toString model) ]
        , button [ onClick RequestNewRandomValue ] [ text "New random value" ]
        ]


subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }