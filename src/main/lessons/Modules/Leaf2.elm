module Modules.Leaf2 exposing (Msg(Send, Receive), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = Send String
    | Receive String
    | ChangeField String


type alias Model =
    { messageForTitle : String
    , messageToSend : String
    , messageReceived : String
    }


init : String -> ( Model, Cmd Msg )
init aMessage =
    ( { messageForTitle = aMessage
      , messageToSend = ""
      , messageReceived = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeField newValue ->
            ( { model | messageToSend = newValue }, Cmd.none )

        Receive aMessage ->
            ( { model | messageReceived = aMessage }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text ("Leaf 2: " ++ model.messageForTitle) ]
        , div []
            [ label [] [ text "Received: " ]
            , input [ type_ "text", disabled True, value model.messageReceived ] []
            ]
        , div []
            [ label [] [ text "Input: " ]
            , input [ type_ "text", onInput ChangeField ] []
            ]
        , div [] [ button [ onClick (Send model.messageToSend) ] [ text "Send" ] ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
