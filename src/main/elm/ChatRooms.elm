module ChatRooms exposing (Msg(Selected, Deselected), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import Utils
import Time


type Msg
    = Selected ChatRoom
    | Deselected
    | SelectChatRoom Id
    | ChangeTitle String
    | PostChatRoom Model
    | PostChatRoomResult (Result Http.Error String)
    | GetChatRoomsResult (Result Http.Error (List ChatRoom))
    | Refresh Time.Time


type alias Model =
    { chatRooms : List ChatRoom
    , selectedChatRoom : Maybe Id
    , newChatRoomTitle : String
    }


getChatRoom : List ChatRoom -> Id -> Maybe ChatRoom
getChatRoom chatRooms id =
    List.head <| List.filter (\chatRoom -> chatRoom.id == id) chatRooms


init : ( Model, Cmd Msg )
init =
    ( { chatRooms = []
      , selectedChatRoom = Nothing
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
                    { model | selectedChatRoom = Just id }

                selectedChatRoom =
                    getChatRoom model.chatRooms id

                newCmd =
                    case selectedChatRoom of
                        Just chatRoom ->
                            Utils.toCmd <| Selected chatRoom

                        _ ->
                            Utils.toCmd <| Deselected
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

        Refresh time ->
            ( model, RestClient.getChatRooms GetChatRoomsResult )

        Selected chatRoom ->
            ( model, Cmd.none )

        Deselected ->
            ( model, Cmd.none )


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
    div []
        [ h2 [] [ text "Chat Room Selection" ]
        , viewChatRooms model
        , viewNewChatRoom model
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second Refresh
