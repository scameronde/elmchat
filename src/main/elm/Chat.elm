module Chat exposing (Msg(Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tuple exposing (..)
import Utils
import BusinessTypes exposing (..)
import ChatRooms
import ChatRoom


type Msg
    = Open Participant
    | ChatRoomsMsg ChatRooms.Msg
    | ChatRoomMsg ChatRoom.Msg


type alias Model =
    { chatRoomsModel : ChatRooms.Model
    , chatRoomModel : ChatRoom.Model
    , participant : Maybe Participant
    }


init : ( Model, Cmd Msg )
init =
    let
        chatRoomsInit =
            ChatRooms.init

        chatRoomInit =
            ChatRoom.init
    in
        ( { chatRoomsModel = first chatRoomsInit
          , chatRoomModel = first chatRoomInit
          , participant = Nothing
          }
        , Cmd.batch
            [ Cmd.map ChatRoomsMsg (second chatRoomsInit)
            , Cmd.map ChatRoomMsg (second chatRoomInit)
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Open participant ->
            ( model |> setParticipant (Just participant), Cmd.none )

        ChatRoomsMsg (ChatRooms.Selected chatRoom) ->
            case model.participant of
                Just participant ->
                    ( model, Utils.toCmd (ChatRoomMsg (ChatRoom.Open chatRoom participant)) )

                _ ->
                    ( model, Utils.toCmd (ChatRoomMsg ChatRoom.Close) )

        ChatRoomsMsg (ChatRooms.Deselected) ->
            ( model, Utils.toCmd (ChatRoomMsg ChatRoom.Close) )

        ChatRoomsMsg subMsg ->
            ChatRooms.update subMsg model.chatRoomsModel
                |> mapFirst (\a -> { model | chatRoomsModel = a })
                |> mapSecond (Cmd.map ChatRoomsMsg)

        ChatRoomMsg subMsg ->
            ChatRoom.update subMsg model.chatRoomModel
                |> mapFirst (\a -> { model | chatRoomModel = a })
                |> mapSecond (Cmd.map ChatRoomMsg)



{-
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


-}


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
