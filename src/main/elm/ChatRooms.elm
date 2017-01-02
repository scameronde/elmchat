module ChatRooms exposing (Msg(Selected, Deselected), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import Utils exposing (..)
import Time


type Msg
    = Selected ChatRoom
    | Deselected
    | SelectChatRoom Id
    | DeleteChatRoom Id
    | DeleteChatRoomResult (Result Http.Error ())
    | ChangeTitle String
    | PostChatRoom Model
    | PostChatRoomResult (Result Http.Error String)
    | GetChatRoomsResult (Result Http.Error (List ChatRoom))
    | GetChatRooms Time.Time


type alias Model =
    { chatRooms : List ChatRoom
    , selectedChatRoomId : Maybe Id
    , newChatRoomTitle : String
    }


getChatRoom : List ChatRoom -> Id -> Maybe ChatRoom
getChatRoom chatRooms id =
    List.head <| List.filter (\chatRoom -> chatRoom.id == id) chatRooms


init : ( Model, Cmd Msg )
init =
    ( { chatRooms = []
      , selectedChatRoomId = Nothing
      , newChatRoomTitle = ""
      }
    , RestClient.getChatRooms GetChatRoomsResult
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectChatRoom id ->
            let
                newModel =
                    if (model.selectedChatRoomId == Just id) then
                        model |> setSelectedChatRoomId Nothing
                    else
                        model |> setSelectedChatRoomId (Just id)

                newCmd =
                    if (model.selectedChatRoomId == Just id) then
                        toCmd Deselected
                    else
                        case getChatRoom model.chatRooms id of
                            Just chatRoom ->
                                Utils.toCmd <| Selected chatRoom

                            _ ->
                                Utils.toCmd <| Deselected
            in
                ( newModel, newCmd )

        ChangeTitle title ->
            ( model |> setNewChatRoomTitle title, Cmd.none )

        PostChatRoom model ->
            ( model |> setNewChatRoomTitle ""
            , RestClient.postChatRoom { id = "", title = model.newChatRoomTitle } PostChatRoomResult
            )

        PostChatRoomResult (Ok id) ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        PostChatRoomResult (Err error) ->
            ( model, Cmd.none )

        GetChatRooms time ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        GetChatRoomsResult (Ok chatRooms) ->
            ( model |> setChatRooms (List.sortBy .title chatRooms), Cmd.none )

        GetChatRoomsResult (Err e) ->
            ( model, Cmd.none )

        DeleteChatRoom id ->
            if (Just id == model.selectedChatRoomId) then
                ( model
                , Cmd.batch
                    [ toCmd (Deselected)
                    , RestClient.deleteChatRoom id DeleteChatRoomResult
                    ]
                )
            else
                ( model, RestClient.deleteChatRoom id DeleteChatRoomResult )

        DeleteChatRoomResult _ ->
            ( model, Cmd.none )

        Selected chatRoom ->
            ( model, Cmd.none )

        Deselected ->
            ( model, Cmd.none )


rowClass : BusinessTypes.ChatRoom -> Model -> String
rowClass chatRoom model =
    if (model.selectedChatRoomId == Just (chatRoom.id)) then
        "info"
    else
        ""


viewChatRooms : Model -> Html Msg
viewChatRooms model =
    table [ class "table table-striped table-hover" ]
        [ thead []
            [ tr []
                [ th [] [ text "Available Chat Rooms" ]
                , th [] [ text "Actions" ]
                ]
            ]
        , tbody []
            (List.map
                (\chatRoom ->
                    tr [ class (rowClass chatRoom model) ]
                        [ td [ onClick (SelectChatRoom chatRoom.id) ] [ text chatRoom.title ]
                        , td []
                            [ button
                                [ class "btn btn-danger btn-xs"
                                , onClick (DeleteChatRoom chatRoom.id)
                                ]
                                [ text "X" ]
                            ]
                        ]
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
        , button
            [ class "btn btn-primary"
            , disabled ((model.newChatRoomTitle |> String.trim |> String.length) == 0)
            ]
            [ text "Create" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Chat Room Selection" ]
        , viewChatRooms model
        , viewNewChatRoom model
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second GetChatRooms



-- Setter


setChatRooms : b -> { a | chatRooms : b } -> { a | chatRooms : b }
setChatRooms chatRooms record =
    { record | chatRooms = chatRooms }


setSelectedChatRoomId : b -> { a | selectedChatRoomId : b } -> { a | selectedChatRoomId : b }
setSelectedChatRoomId selectedChatRoomId record =
    { record | selectedChatRoomId = selectedChatRoomId }


setNewChatRoomTitle : b -> { a | newChatRoomTitle : b } -> { a | newChatRoomTitle : b }
setNewChatRoomTitle newChatRoomTitle record =
    { record | newChatRoomTitle = newChatRoomTitle }
