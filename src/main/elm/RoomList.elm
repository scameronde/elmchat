module RoomList exposing (Msg(Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes
import RestClient
import ChatWindow
import Utils
import Tuple exposing (..)
import Time


type Msg
    = Open BusinessTypes.Participant
    | Clicked Int
    | ChatWindowMsg ChatWindow.Msg
    | ChangeTitle String
    | PostChatRoom Model
    | PostChatRoomResult (Result Http.Error Int)
    | GetChatRooms (Result Http.Error (List BusinessTypes.ChatRoom))
    | TickTock Time.Time


type alias Model =
    { participant : BusinessTypes.Participant
    , chatRooms : List BusinessTypes.ChatRoom
    , chatWindow : ChatWindow.Model
    , clicked : Int
    , newChatRoomTitle : String
    }


setChatWindow : Model -> ChatWindow.Model -> Model
setChatWindow model =
    (\chatWindow -> { model | chatWindow = chatWindow })


getChatRoom : Model -> Int -> Maybe BusinessTypes.ChatRoom
getChatRoom model id =
    List.head <| List.filter (\chatRoom -> chatRoom.id == id) model.chatRooms


init : ( Model, Cmd Msg )
init =
    let
        chatWindow =
            ChatWindow.init |> mapSecond (Cmd.map ChatWindowMsg)
    in
        ( { participant = { id = 0, name = "" }
          , chatRooms = []
          , chatWindow = first chatWindow
          , clicked = 0
          , newChatRoomTitle = ""
          }
        , Cmd.batch [ second chatWindow ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Open participant ->
            ( { model | participant = participant }, RestClient.getChatRooms GetChatRooms )

        Clicked id ->
            let
                newModel =
                    { model | clicked = id }
            in
                ( newModel, Utils.toCmd <| ChatWindowMsg <| ChatWindow.Open (getChatRoom newModel id) (Just newModel.participant) )

        ChangeTitle title ->
            ( { model | newChatRoomTitle = title }, Cmd.none )

        PostChatRoom model ->
            ( { model | newChatRoomTitle = "" }, RestClient.postChatRoom { id = 0, title = model.newChatRoomTitle } PostChatRoomResult )

        PostChatRoomResult (Ok id) ->
            ( model, RestClient.getChatRooms ChatRooms )

        PostChatRoomResult (Err error) ->
            ( model, Cmd.none )

        GetChatRooms (Ok chatRooms) ->
            ( { model | chatRooms = chatRooms }, Cmd.none )

        GetChatRooms (Err e) ->
            ( model, Cmd.none )

        TickTock time ->
            ( model, RestClient.getChatRooms ChatRooms )

        ChatWindowMsg subMsg ->
            (ChatWindow.update subMsg model.chatWindow) |> mapFirst (setChatWindow model) |> mapSecond (Cmd.map ChatWindowMsg)


viewChatRooms : Model -> Html Msg
viewChatRooms model =
    table [ class "table table-striped table-hover" ]
        [ thead []
            [ tr []
                [ th [] [ text "Chat Room" ] ]
            ]
        , tbody [] (List.map (\chatRoom -> tr [] [ td [ onClick (Clicked chatRoom.id) ] [ text chatRoom.title ] ]) model.chatRooms)
        ]


viewNewChatRoom : Model -> Html Msg
viewNewChatRoom model =
    Html.form [ onSubmit (PostChatRoom model) ]
        [ div [ class "form-group" ]
            [ label [ for "titleInput" ] [ text "New Chat Room" ]
            , input [ id "titleInput", type_ "text", value model.newChatRoomTitle, class "form-control", onInput ChangeTitle ] []
            ]
        , button [ class "btn btn-primary" ] [ text "Create" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col-md-6" ]
            [ viewChatRooms model
            , viewNewChatRoom model
            ]
        , div [ class "col-md-6" ]
            [ Html.map ChatWindowMsg (ChatWindow.view model.chatWindow)
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map ChatWindowMsg (ChatWindow.subscriptions model.chatWindow)
        , Time.every Time.second TickTock
        ]
