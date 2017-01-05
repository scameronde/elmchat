module ChatRooms exposing (Msg(Selected, Deselected), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dialog
import Http
import BusinessTypes exposing (..)
import RestClient
import Toolbox.Cmd exposing (..)
import Toolbox.Lens exposing (..)
import Time


type Msg
    = Selected ChatRoom
    | Deselected
    | SelectChatRoom Id
    | DeleteChatRoom Id
    | DeleteChatRoomAcknowledge
    | DeleteChatRoomCancel
    | DeleteChatRoomResult (Result Http.Error ())
    | ChangeTitle String
    | PostChatRoom Model
    | PostChatRoomResult (Result Http.Error String)
    | GetChatRooms Time.Time
    | GetChatRoomsResult (Result Http.Error (List ChatRoom))


type alias Model =
    { chatRooms : List ChatRoom
    , selectedChatRoomId : Maybe Id
    , chatRoomIdToDelete : Maybe Id
    , newChatRoomTitle : String
    }


init : ( Model, Cmd Msg )
init =
    ( { chatRooms = []
      , selectedChatRoomId = Nothing
      , chatRoomIdToDelete = Nothing
      , newChatRoomTitle = ""
      }
    , RestClient.getChatRooms GetChatRoomsResult
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- select or deselect a chat room
        SelectChatRoom id ->
            selectChatRoom id model

        -- enter the title for a new chat room
        ChangeTitle title ->
            ( model |> newChatRoomTitleLens.set title, Cmd.none )

        -- add a new chat room
        PostChatRoom model ->
            ( model |> newChatRoomTitleLens.set ""
            , RestClient.postChatRoom (ChatRoom "" model.newChatRoomTitle) PostChatRoomResult
            )

        PostChatRoomResult (Ok id) ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        PostChatRoomResult (Err error) ->
            ( model, Cmd.none )

        -- get available chat rooms
        GetChatRooms time ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        GetChatRoomsResult (Ok chatRooms) ->
            updateChatRoomList chatRooms model

        GetChatRoomsResult (Err e) ->
            ( model, Cmd.none )

        -- delete chat room
        DeleteChatRoom id ->
            ( model |> chatRoomIdToDeleteLens.set (Just id), Cmd.none )

        DeleteChatRoomAcknowledge ->
            deleteChatRoom model

        DeleteChatRoomCancel ->
            ( model |> chatRoomIdToDeleteLens.set Nothing, Cmd.none )

        DeleteChatRoomResult _ ->
            ( model, Cmd.none )

        -- for external communication
        Selected chatRoom ->
            ( model, Cmd.none )

        Deselected ->
            ( model, Cmd.none )


findChatRoom : Id -> List ChatRoom -> Maybe ChatRoom
findChatRoom id chatRooms =
    List.filter (\chatRoom -> chatRoom.id == id) chatRooms |> List.head


selectChatRoom : Id -> Model -> ( Model, Cmd Msg )
selectChatRoom id model =
    if (model.selectedChatRoomId == Just id) then
        ( model |> selectedChatRoomIdLens.set Nothing, toCmd Deselected )
    else
        case findChatRoom id model.chatRooms of
            Nothing ->
                ( model |> selectedChatRoomIdLens.set Nothing, toCmd Deselected )

            Just chatRoom ->
                ( model |> selectedChatRoomIdLens.set (Just id), toCmd (Selected chatRoom) )


updateChatRoomList : List ChatRoom -> Model -> ( Model, Cmd Msg )
updateChatRoomList chatRooms model =
    let
        newModel =
            model |> chatRoomsLens.set (List.sortBy .title chatRooms)
    in
        case model.selectedChatRoomId of
            Nothing ->
                ( newModel, Cmd.none )

            Just id ->
                case findChatRoom id chatRooms of
                    Nothing ->
                        ( newModel |> selectedChatRoomIdLens.set Nothing, toCmd Deselected )

                    Just chatRoom ->
                        ( newModel, Cmd.none )


deleteChatRoom : Model -> ( Model, Cmd Msg )
deleteChatRoom model =
    let
        newModel =
            model |> chatRoomIdToDeleteLens.set Nothing
    in
        case ( model.chatRoomIdToDelete, model.selectedChatRoomId ) of
            ( Just idToDelete, Just selectedId ) ->
                if idToDelete == selectedId then
                    ( newModel |> selectedChatRoomIdLens.set Nothing
                    , Cmd.batch
                        [ toCmd Deselected
                        , RestClient.deleteChatRoom idToDelete DeleteChatRoomResult
                        ]
                    )
                else
                    ( newModel, RestClient.deleteChatRoom idToDelete DeleteChatRoomResult )

            ( Just idToDelete, Nothing ) ->
                ( newModel, RestClient.deleteChatRoom idToDelete DeleteChatRoomResult )

            ( Nothing, _ ) ->
                ( newModel, Cmd.none )


rowClass : ChatRoom -> Model -> String
rowClass chatRoom model =
    if (model.selectedChatRoomId == Just chatRoom.id) then
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


viewDialog : Model -> Html Msg
viewDialog model =
    Dialog.view
        (if model.chatRoomIdToDelete /= Nothing then
            Just (dialogConfig model)
         else
            Nothing
        )


dialogConfig : Model -> Dialog.Config Msg
dialogConfig model =
    { closeMessage = Just DeleteChatRoomAcknowledge
    , containerClass = Nothing
    , header = Just (h3 [] [ text "Delete chat room" ])
    , body = Just (text ("Really delete chat room?"))
    , footer =
        Just
            (div []
                [ button
                    [ class "btn btn-danger"
                    , onClick DeleteChatRoomAcknowledge
                    ]
                    [ text "OK" ]
                , button [ class "btn", onClick DeleteChatRoomCancel ] [ text "Cancel" ]
                ]
            )
    }


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Chat Room Selection" ]
        , viewChatRooms model
        , viewNewChatRoom model
        , viewDialog model
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second GetChatRooms



-- Lenses


chatRoomsLens : Lens { b | chatRooms : a } a
chatRoomsLens =
    Lens .chatRooms (\a b -> { b | chatRooms = a })


selectedChatRoomIdLens : Lens { b | selectedChatRoomId : a } a
selectedChatRoomIdLens =
    Lens .selectedChatRoomId (\a b -> { b | selectedChatRoomId = a })


chatRoomIdToDeleteLens : Lens { b | chatRoomIdToDelete : a } a
chatRoomIdToDeleteLens =
    Lens .chatRoomIdToDelete (\a b -> { b | chatRoomIdToDelete = a })


newChatRoomTitleLens : Lens { b | newChatRoomTitle : a } a
newChatRoomTitleLens =
    Lens .newChatRoomTitle (\a b -> { b | newChatRoomTitle = a })
