module ChatWindow exposing (Msg(Exit, Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import RestClient
import WebSocket
import BusinessTypes


type Msg
    = Exit
    | Open (Maybe BusinessTypes.ChatRoom) (Maybe BusinessTypes.Participant)
    | SetChatHistory (Result Http.Error BusinessTypes.MessageLog)
    | SetMessage String
    | SendMessage String
    | ReceivedMessage String


type alias Model =
    { participant : Maybe BusinessTypes.Participant
    , chatRoom : Maybe BusinessTypes.ChatRoom
    , message : String
    , chatHistory : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( { participant = Nothing
      , chatRoom = Nothing
      , message = ""
      , chatHistory = ""
      , error = ""
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
                        [ WebSocket.send "ws://localhost:4567/chat" ("registration:" ++ (BusinessTypes.jsonAsString <| BusinessTypes.encodeChatRegistration { participant = participant, chatRoom = chatRoom }))
                        , RestClient.getChatRoom chatRoom.id SetChatHistory
                        ]
            in
                ( newModel, commands )

        Open chatRoom participant ->
            ( { model | participant = participant, chatRoom = chatRoom }, Cmd.none )

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        SendMessage message ->
            ( { model | message = "" }, WebSocket.send "ws://localhost:4567/chat" ("message:" ++ (BusinessTypes.jsonAsString <| BusinessTypes.encodeMessage { message = message })) )

        ReceivedMessage message ->
            ( { model | chatHistory = model.chatHistory ++ message }, Cmd.none )

        SetChatHistory (Ok messageLog) ->
            ( { model | chatHistory = messageLog.messageLog }, Cmd.none )

        SetChatHistory (Err error) ->
            ( { model | error = toString error }, Cmd.none )


view : Model -> Html Msg
view model =
    case ( model.participant, model.chatRoom ) of
        ( Just participant, Just chatRoom ) ->
            div [ class "row" ]
                [ h2 [] [ text chatRoom.title ]
                , textarea [ class "col-md-12", rows 20, style [ ( "width", "100%" ) ], value model.chatHistory ] []
                , Html.form [ class "form-inline", onSubmit (SendMessage model.message) ]
                    [ input [ type_ "text", class "form-control", size 30, placeholder <| participant.name ++ ": Enter message", value model.message, onInput SetMessage ] []
                    , button [ class "btn btn-primary" ] [ text "Send" ]
                    ]
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
