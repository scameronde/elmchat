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
            selectChatRoom model (Just id)

        -- enter the title for a new chat room
        ChangeTitle title ->
            ( model |> newChatRoomTitleLens.set title, Cmd.none )

        -- add a new chat room
        PostChatRoom model ->
            ( model |> newChatRoomTitleLens.set ""
            , RestClient.postChatRoom { id = "", title = model.newChatRoomTitle } PostChatRoomResult
            )

        PostChatRoomResult (Ok id) ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        PostChatRoomResult (Err error) ->
            ( model, Cmd.none )

        -- get available chat rooms
        GetChatRooms time ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        GetChatRoomsResult (Ok chatRooms) ->
            if (getChatRoom chatRooms model.selectedChatRoomId == Nothing) then
                ( model |> chatRoomsLens.set (List.sortBy .title chatRooms) |> selectedChatRoomIdLens.set Nothing, toCmd Deselected )
            else
                ( model |> chatRoomsLens.set (List.sortBy .title chatRooms), Cmd.none )

        GetChatRoomsResult (Err e) ->
            ( model, Cmd.none )

        -- delete chat room
        DeleteChatRoom id ->
            ( model |> chatRoomIdToDeleteLens.set (Just id), Cmd.none )

        DeleteChatRoomAcknowledge ->
            model.chatRoomIdToDelete |> Maybe.map (deleteChatRoom model) |> Maybe.withDefault ( model, Cmd.none )

        DeleteChatRoomCancel ->
            ( model |> chatRoomIdToDeleteLens.set Nothing, Cmd.none )

        DeleteChatRoomResult _ ->
            ( model, Cmd.none )

        -- for external communication
        Selected chatRoom ->
            ( model, Cmd.none )

        Deselected ->
            ( model, Cmd.none )


getChatRoom : List ChatRoom -> Maybe Id -> Maybe ChatRoom
getChatRoom chatRooms id =
    case id of
        Just id ->
            List.head <| List.filter (\chatRoom -> chatRoom.id == id) chatRooms

        Nothing ->
            Nothing


selectChatRoom : Model -> Maybe Id -> ( Model, Cmd Msg )
selectChatRoom model id =
    if (model.selectedChatRoomId == id) then
        ( model |> selectedChatRoomIdLens.set Nothing, toCmd Deselected )
    else
        let
            newModel =
                model |> selectedChatRoomIdLens.set id

            newCmd =
                getChatRoom model.chatRooms id |> Maybe.map (\x -> toCmd (Selected x)) |> Maybe.withDefault (toCmd Deselected)
        in
            ( newModel, newCmd )


deleteChatRoom : Model -> Id -> ( Model, Cmd Msg )
deleteChatRoom model id =
    if (Just id == model.selectedChatRoomId) then
        ( model |> chatRoomIdToDeleteLens.set Nothing
        , Cmd.batch
            [ toCmd Deselected
            , RestClient.deleteChatRoom id DeleteChatRoomResult
            ]
        )
    else
        ( model |> chatRoomIdToDeleteLens.set Nothing
        , RestClient.deleteChatRoom id DeleteChatRoomResult
        )


rowClass : BusinessTypes.ChatRoom -> Model -> String
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
