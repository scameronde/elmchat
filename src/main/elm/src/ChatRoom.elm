module ChatRoom exposing (Msg(Open, Close), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import RestClient
import WebSocket
import WebSocketClient
import BusinessTypes exposing (..)


type Msg
    = Open ChatRoom Participant
    | Close
    | SetChatHistory (Result Http.Error MessageLog)
    | SetMessage String
    | SendMessage String
    | ReceivedMessage String


type alias Model =
    { participant : Maybe Participant
    , chatRoom : Maybe ChatRoom
    , message : String
    , messageLog : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( { participant = Nothing
      , chatRoom = Nothing
      , message = ""
      , messageLog = ""
      , error = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Open chatRoom participant ->
            let
                newModel =
                    model
                        |> participantLens.set (Just participant)
                        |> chatRoomLens.set (Just chatRoom)
                        |> messageLens.set ""
                        |> messageLogLens.set ""

                commands =
                    Cmd.batch
                        [ WebSocketClient.sendRegistration <| ChatRegistration participant chatRoom
                        , RestClient.getChatRoom chatRoom.id SetChatHistory
                        ]
            in
                ( newModel, commands )

        Close ->
            ( model |> participantLens.set Nothing |> chatRoomLens.set Nothing, Cmd.none )

        SetMessage message ->
            ( model |> messageLens.set message, Cmd.none )

        SendMessage message ->
            ( model |> messageLens.set "", WebSocketClient.sendMessage <| BusinessTypes.Message message )

        ReceivedMessage message ->
            ( model |> messageLogLens.set (model.messageLog ++ message), Cmd.none )

        SetChatHistory (Ok messageLog) ->
            ( model |> messageLogLens.set messageLog.messageLog, Cmd.none )

        SetChatHistory (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )


view : Model -> Html Msg
view model =
    case ( model.participant, model.chatRoom ) of
        ( Just participant, Just chatRoom ) ->
            div [ class "row" ]
                [ h2 [] [ text chatRoom.title ]
                , textarea [ class "col-md-12", rows 20, style [ ( "width", "100%" ) ], value model.messageLog ] []
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
