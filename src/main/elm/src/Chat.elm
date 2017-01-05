module Chat exposing (Msg, Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tuple exposing (..)
import Toolbox.Cmd exposing (..)
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
    { chatRoomsModel : ChatRooms.Model
    , chatRoomModel : ChatRoom.Model
    , participant : Participant
    }


init : Participant -> ( Model, Cmd Msg )
init participant =
    let
        chatRoomsInit =
            ChatRooms.init

        chatRoomInit =
            ChatRoom.init
    in
        ( { chatRoomsModel = first chatRoomsInit
          , chatRoomModel = first chatRoomInit
          , participant = participant
          }
        , Cmd.batch
            [ Cmd.map ChatRoomsMsg (second chatRoomsInit)
            , Cmd.map ChatRoomMsg (second chatRoomInit)
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChatRoomsMsg (ChatRooms.Selected chatRoom) ->
            ( model, toCmd (ChatRoomMsg (ChatRoom.Open chatRoom model.participant)) )

        ChatRoomsMsg (ChatRooms.Deselected) ->
            ( model, toCmd (ChatRoomMsg ChatRoom.Close) )

        ChatRoomsMsg msg_ ->
            ChatRooms.update msg_ model.chatRoomsModel
                |> mapFirst (\a -> { model | chatRoomsModel = a })
                |> mapSecond (Cmd.map ChatRoomsMsg)

        ChatRoomMsg msg_ ->
            ChatRoom.update msg_ model.chatRoomModel
                |> mapFirst (\a -> { model | chatRoomModel = a })
                |> mapSecond (Cmd.map ChatRoomMsg)


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col-md-6" ]
            [ Html.map ChatRoomsMsg (ChatRooms.view model.chatRoomsModel)
            ]
        , div [ class "col-md-6" ]
            [ Html.map ChatRoomMsg (ChatRoom.view model.chatRoomModel)
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map ChatRoomsMsg (ChatRooms.subscriptions model.chatRoomsModel)
        , Sub.map ChatRoomMsg (ChatRoom.subscriptions model.chatRoomModel)
        ]
