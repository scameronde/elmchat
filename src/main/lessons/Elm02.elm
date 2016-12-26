module Elm02 exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { name : String }


type Msg
    = ChangeName String


model : Model
model =
    { name = "" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeName newName ->
            { model | name = newName }


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form []
            [ div [ class "form-group" ]
                [ label [ for "myInput" ] [ text "Eingabe: " ]
                , input [ id "myInput", class "form-control", value model.name, onInput ChangeName ] []
                ]
            , button [ class "btn btn-primary" ] [ text "OK" ]
            ]
        , div [ class "debug" ] [ text <| toString model ]
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }
