module Chat exposing (Msg, Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Toolbox.Model as Model
import BusinessTypes exposing (..)
import ChatRooms
import ChatRoom


{-| This is an example for a "product type" module. A "product type" module has no UI or logic by itself,
but has children. The children are all active at the same time (usually displayed at the same time) and
must be coordinated by the "product type" module.

There is another type of aggregator module, the "sum type" module. See ChatClient.elm for an example.
-}
type Msg
    = ChatRoomsMsg ChatRooms.Msg
    | ChatRoomMsg ChatRoom.Msg


type alias Model =
    { participant : Participant
    , chatRoomModel : Maybe ChatRoom.Model
    , chatRoomsModel : ChatRooms.Model
    }


init : Participant -> ( Model, Cmd Msg )
init participant =
    Model.init (Model participant Nothing)
        |> Model.apply ChatRooms.init ChatRoomsMsg
        |> Model.get


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChatRoomsMsg (ChatRooms.Selected chatRoom) ->
            ChatRoom.init model.participant chatRoom
                |> Model.map (\a -> { model | chatRoomModel = Just a }) ChatRoomMsg

        ChatRoomsMsg (ChatRooms.Deselected) ->
            ( { model | chatRoomModel = Nothing }, Cmd.none )

        ChatRoomsMsg msg_ ->
            ChatRooms.update msg_ model.chatRoomsModel
                |> Model.map (\a -> { model | chatRoomsModel = a }) ChatRoomsMsg

        ChatRoomMsg msg_ ->
            case model.chatRoomModel of
                Just model_ ->
                    ChatRoom.update msg_ model_
                        |> Model.map (\a -> { model | chatRoomModel = Just a }) ChatRoomMsg

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col-md-6" ]
            [ Html.map ChatRoomsMsg (ChatRooms.view model.chatRoomsModel)
            ]
        , div [ class "col-md-6" ]
            [ case model.chatRoomModel of
                Just model_ ->
                    Html.map ChatRoomMsg (ChatRoom.view model_)

                _ ->
                    div [] []
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map ChatRoomsMsg (ChatRooms.subscriptions model.chatRoomsModel)
        , case model.chatRoomModel of
            Just model_ ->
                Sub.map ChatRoomMsg (ChatRoom.subscriptions model_)

            _ ->
                Sub.none
        ]
