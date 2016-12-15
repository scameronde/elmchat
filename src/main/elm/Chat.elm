module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils
import NavBar exposing (..)
import EnterParticipantName
import RoomList


type Msg
    = EnterParticipantNameMsg EnterParticipantName.Msg
    | RoomListMsg RoomList.Msg


type ProgramState
    = EnterParticipantName
    | RoomList


type alias Model =
    { programState : ProgramState
    , enterParticipantName : EnterParticipantName.Model
    , roomList : RoomList.Model
    }


getProgramState : Model -> ProgramState
getProgramState =
    .programState


setProgramState : Model -> ProgramState -> Model
setProgramState model =
    (\value -> { model | programState = value })


getRoomList : Model -> RoomList.Model
getRoomList =
    .roomList


setRoomList : Model -> RoomList.Model -> Model
setRoomList model =
    (\value -> { model | roomList = value })


getEnterParticipantName : Model -> EnterParticipantName.Model
getEnterParticipantName =
    .enterParticipantName


setEnterParticipantName : Model -> EnterParticipantName.Model -> Model
setEnterParticipantName model =
    (\value -> { model | enterParticipantName = value })


init : ( Model, Cmd Msg )
init =
    let
        ( enterParticipantNameModel, enterParticipantNameCmd ) =
            EnterParticipantName.init

        ( roomListModel, roomListCmd ) =
            RoomList.init
    in
        ( { programState = EnterParticipantName
          , enterParticipantName = enterParticipantNameModel
          , roomList = roomListModel
          }
        , Cmd.batch
            [ Cmd.map EnterParticipantNameMsg enterParticipantNameCmd
            , Cmd.map RoomListMsg roomListCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterParticipantNameMsg (EnterParticipantName.Exit participant) ->
            ( setProgramState model RoomList, Utils.toCmd <| RoomListMsg <| RoomList.Open participant )

        EnterParticipantNameMsg subMsg ->
            Utils.update EnterParticipantName.update subMsg (getEnterParticipantName model) (setEnterParticipantName model) EnterParticipantNameMsg

        RoomListMsg subMsg ->
            Utils.update RoomList.update subMsg (getRoomList model) (setRoomList model) RoomListMsg


viewMainArea : Model -> Html Msg
viewMainArea model =
    case model.programState of
        EnterParticipantName ->
            Html.map EnterParticipantNameMsg (EnterParticipantName.view model.enterParticipantName)

        RoomList ->
            Html.map RoomListMsg (RoomList.view model.roomList)


view : Model -> Html Msg
view model =
    div []
        [ viewNavBar model
        , div [ class "container" ]
            [ div [ class "view-area" ] [ viewMainArea model ]
            , div [ class "debug" ] [ text <| toString model ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map RoomListMsg (RoomList.subscriptions model.roomList)



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
