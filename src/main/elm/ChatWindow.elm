module ChatWindow exposing (Msg(Exit, Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import BusinessTypes


type Msg
    = Exit
    | Open (Maybe BusinessTypes.ChatRoom) (Maybe BusinessTypes.Participant)
    | SetMessage String
    | SendMessage String
    | ReceivedMessage String


type alias Model =
    { participant : Maybe BusinessTypes.Participant
    , chatRoom : Maybe BusinessTypes.ChatRoom
    , message : String
    , chatHistory : String
    }


init : ( Model, Cmd Msg )
init =
    ( { participant = Nothing
      , chatRoom = Nothing
      , message = ""
      , chatHistory = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Exit ->
            ( model, Cmd.none )

        Open (Just chatRoom) (Just participant) ->
            let
                newModel =
                    { model
                        | participant = Just participant
                        , chatRoom = Just chatRoom
                        , message = ""
                        , chatHistory = ""
                    }

                commands =
                    Cmd.batch
                        [ WebSocket.send "ws://localhost:4567/chat" ("participant:" ++ toString participant.id ++ "," ++ participant.name)
                        , WebSocket.send "ws://localhost:4567/chat" ("chatRoom:" ++ toString chatRoom.id)
                        ]
            in
                ( newModel, commands )

        Open chatRoom participant ->
            ( { model | participant = participant, chatRoom = chatRoom }, Cmd.none )

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        SendMessage message ->
            ( { model | message = "" }, WebSocket.send "ws://localhost:4567/chat" ("message:" ++ message) )

        ReceivedMessage message ->
            ( { model | chatHistory = model.chatHistory ++ "\n" ++ message }, Cmd.none )


view : Model -> Html Msg
view model =
    case ( model.participant, model.chatRoom ) of
        ( Just participant, Just chatRoom ) ->
            div [ class "row" ]
                [ h2 [] [ text chatRoom.title ]
                , textarea [ class "col-md-12", rows 20, value model.chatHistory ] []
                , Html.form [ class "form-inline", onSubmit (SendMessage model.message) ]
                    [ input [ type_ "text", class "form-control", size 30, placeholder <| participant.name ++ ": Enter message", value model.message, onInput SetMessage ] []
                    , button [ class "btn btn-primary" ] [ text "Send" ]
                    ]
                , span [] [ text <| toString model ]
                ]

        _ ->
            div [] []


subscriptions : Model -> Sub Msg
subscriptions model =
    case ( model.participant, model.chatRoom ) of
        ( Just participant, Just chatRoom ) ->
            WebSocket.listen "ws://localhost:4567/chat" ReceivedMessage

        _ ->
            Sub.none
