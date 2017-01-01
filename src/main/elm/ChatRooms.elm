module ChatRooms exposing (Msg(Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import ChatRoom
import Utils
import Tuple exposing (..)
import Time


type Msg
    = Open Participant
    | SelectChatRoom Id
    | ChatRoomMsg ChatRoom.Msg
    | ChangeTitle String
    | PostChatRoom Model
    | PostChatRoomResult (Result Http.Error String)
    | GetChatRoomsResult (Result Http.Error (List ChatRoom))
    | TickTock Time.Time


type alias Model =
    { participant : Maybe Participant
    , chatRooms : List ChatRoom
    , chatRoom : ChatRoom.Model
    , selectedChatRoom : Maybe Id
    , newChatRoomTitle : String
    }


getChatRoom : List ChatRoom -> Id -> Maybe ChatRoom
getChatRoom chatRooms id =
    List.head <| List.filter (\chatRoom -> chatRoom.id == id) chatRooms


init : ( Model, Cmd Msg )
init =
    let
        chatRoom =
            ChatRoom.init
    in
        ( { participant = Nothing
          , chatRooms = []
          , chatRoom = first chatRoom
          , selectedChatRoom = Nothing
          , newChatRoomTitle = ""
          }
        , Cmd.map ChatRoomMsg (second chatRoom)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Open participant ->
            ( { model | participant = Just participant }, RestClient.getChatRooms GetChatRoomsResult )

        SelectChatRoom id ->
            let
                newModel =
                    { model | selectedChatRoom = Just id }

                selectedChatRoom =
                    getChatRoom model.chatRooms id

                newCmd =
                    case ( selectedChatRoom, model.participant ) of
                        ( Just chatRoom, Just participant ) ->
                            Utils.toCmd <| ChatRoomMsg <| ChatRoom.Open chatRoom participant

                        _ ->
                            Utils.toCmd <| ChatRoomMsg <| ChatRoom.Close
            in
                ( newModel, newCmd )

        ChangeTitle title ->
            ( { model | newChatRoomTitle = title }, Cmd.none )

        PostChatRoom model ->
            ( { model | newChatRoomTitle = "" }, RestClient.postChatRoom { id = "", title = model.newChatRoomTitle } PostChatRoomResult )

        PostChatRoomResult (Ok id) ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        PostChatRoomResult (Err error) ->
            ( model, Cmd.none )

        GetChatRoomsResult (Ok chatRooms) ->
            ( { model | chatRooms = chatRooms }, Cmd.none )

        GetChatRoomsResult (Err e) ->
            ( model, Cmd.none )

        TickTock time ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        ChatRoomMsg subMsg ->
            (ChatRoom.update subMsg model.chatRoom) |> mapFirst (\a -> { model | chatRoom = a }) |> mapSecond (Cmd.map ChatRoomMsg)


rowClass : BusinessTypes.ChatRoom -> Model -> String
rowClass chatRoom model =
    if (model.selectedChatRoom == Just (chatRoom.id)) then
        "info"
    else
        ""


viewChatRooms : Model -> Html Msg
viewChatRooms model =
    table [ class "table table-striped table-hover" ]
        [ thead []
            [ tr []
                [ th [] [ text "Available Chat Rooms" ] ]
            ]
        , tbody []
            (List.map
                (\chatRoom ->
                    tr [ class (rowClass chatRoom model) ]
                        [ td [ onClick (SelectChatRoom chatRoom.id) ] [ text chatRoom.title ] ]
                )
                model.chatRooms
            )
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
            [ h2 [] [ text "Chat Room Selection" ]
            , viewChatRooms model
            , viewNewChatRoom model
            ]
        , div [ class "col-md-6" ]
            [ Html.map ChatRoomMsg (ChatRoom.view model.chatRoom)
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map ChatRoomMsg (ChatRoom.subscriptions model.chatRoom)
        , Time.every Time.second TickTock
        ]
