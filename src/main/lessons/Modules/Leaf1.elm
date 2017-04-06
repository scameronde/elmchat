module Modules.Leaf1 exposing (Msg(Exit), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = Exit String
    | ChangeField String


type alias Model =
    { message : String
    }


init : ( Model, Cmd Msg )
init =
    ( { message = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeField newValue ->
            ( { model | message = newValue }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Leaf 1" ]
        , Html.form [ onSubmit (Exit model.message) ]
            [ div []
                [ label [] [ text "Input: " ]
                , input [ type_ "text", onInput ChangeField ] []
                ]
            , button [] [ text "Leave" ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
