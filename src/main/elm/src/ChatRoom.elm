module ChatRoom exposing (Msg, Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import RestClient
import WebSocket
import WebSocketClient
import BusinessTypes exposing (..)


type Msg
    = SetChatHistory (Result Http.Error MessageLog)
    | SetMessage String
    | SendMessage String
    | ReceivedMessage String


type alias Model =
    { participant : Participant
    , chatRoom : ChatRoom
    , message : String
    , messageLog : String
    , error : String
    }


init : Participant -> ChatRoom -> ( Model, Cmd Msg )
init participant chatRoom =
    { participant = participant
    , chatRoom = chatRoom
    , message = ""
    , messageLog = ""
    , error = ""
    }
        ! [ WebSocketClient.sendRegistration (ChatRegistration participant chatRoom)
          , RestClient.getChatRoom chatRoom.id SetChatHistory
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetMessage message ->
            ( model |> messageLens.set message, Cmd.none )

        SendMessage message ->
            ( model |> messageLens.set "", WebSocketClient.sendMessage (Message message) )

        ReceivedMessage message ->
            ( model |> messageLogLens.set (model.messageLog ++ message), Cmd.none )

        SetChatHistory (Ok messageLog) ->
            ( model |> messageLogLens.set messageLog.messageLog, Cmd.none )

        SetChatHistory (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ h2 [] [ text model.chatRoom.title ]
        , textarea [ class "col-md-12", rows 20, style [ ( "width", "100%" ) ], value model.messageLog ] []
        , Html.form [ class "form-inline", onSubmit (SendMessage model.message) ]
            [ input
                [ type_ "text"
                , class "form-control"
                , size 30
                , placeholder <| model.participant.name ++ ": Enter message"
                , value model.message
                , onInput SetMessage
                ]
                []
            , button [ class "btn btn-primary" ] [ text "Send" ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:4567/chat" ReceivedMessage
