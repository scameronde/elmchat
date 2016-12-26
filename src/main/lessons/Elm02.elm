module Elm02 exposing (..)

import Html exposing (..)


type alias Model =
    {}


type Msg
    = None


model : Model
model =
    {}


update : Model -> Model
update model =
    model


view : Model -> Html Msg
view model =
    div [] []


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }
