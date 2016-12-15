module RoomList exposing (Msg(Exit, Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes
import RestClient
import ChatWindow
import Utils


type Msg
    = Exit
    | Open BusinessTypes.Participant
    | ChatRooms (Result Http.Error (List BusinessTypes.ChatRoom))
    | Clicked Int
    | ChatWindowMsg ChatWindow.Msg


type alias Model =
    { participant : BusinessTypes.Participant
    , chatRooms : List BusinessTypes.ChatRoom
    , chatWindow : ChatWindow.Model
    , clicked : Int
    }


getChatWindow : Model -> ChatWindow.Model
getChatWindow model =
    model.chatWindow


setChatWindow : Model -> ChatWindow.Model -> Model
setChatWindow model =
    (\chatWindow -> { model | chatWindow = chatWindow })


getParticipant : Model -> BusinessTypes.Participant
getParticipant model =
    model.participant


getChatRoom : Model -> Int -> Maybe BusinessTypes.ChatRoom
getChatRoom model id =
    List.head <| List.filter (\chatRoom -> chatRoom.id == id) model.chatRooms


init : ( Model, Cmd Msg )
init =
    let
        ( chatWindowModel, chatWindowCmd ) =
            ChatWindow.init
    in
        ( { participant = { id = 0, name = "" }
          , chatRooms = []
          , chatWindow = chatWindowModel
          , clicked = 0
          }
        , Cmd.batch [ Cmd.map ChatWindowMsg chatWindowCmd, Cmd.none ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Exit ->
            ( model, Cmd.none )

        Open participant ->
            ( { model | participant = participant }, RestClient.getChatRooms ChatRooms )

        ChatRooms (Ok chatRooms) ->
            ( { model | chatRooms = chatRooms }, Cmd.none )

        ChatRooms (Err e) ->
            ( model, Cmd.none )

        Clicked id ->
            let
                newModel =
                    { model | clicked = id }
            in
                ( newModel, Utils.toCmd <| ChatWindowMsg <| ChatWindow.Open (getChatRoom newModel id) (Just (getParticipant newModel)) )

        ChatWindowMsg subMsg ->
            Utils.update ChatWindow.update subMsg (getChatWindow model) (setChatWindow model) ChatWindowMsg


viewChatRooms : Model -> Html Msg
viewChatRooms model =
    table [ class "table table-striped table-hover" ]
        [ thead []
            [ tr []
                [ th [] [ text "Chat Room" ] ]
            ]
        , tbody [] (List.map (\chatRoom -> tr [] [ td [ onClick (Clicked chatRoom.id) ] [ text chatRoom.title ] ]) model.chatRooms)
        ]


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col-md-6" ]
            [ viewChatRooms model
            , div [] [ text <| "Clicked Id: " ++ toString model.clicked ]
            ]
        , div [ class "col-md-6" ]
            [ Html.map ChatWindowMsg (ChatWindow.view model.chatWindow)
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ChatWindowMsg (ChatWindow.subscriptions model.chatWindow)
