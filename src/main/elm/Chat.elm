module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils
import NavBar exposing (..)
import EnterParticipantName
import RoomList
import Tuple exposing (mapFirst, mapSecond)


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


setRoomList : Model -> RoomList.Model -> Model
setRoomList model =
    (\value -> { model | roomList = value })


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
            ( { model | programState = RoomList }, Utils.toCmd <| RoomListMsg <| RoomList.Open participant )

        EnterParticipantNameMsg subMsg ->
            (EnterParticipantName.update subMsg model.enterParticipantName) |> mapFirst (setEnterParticipantName model) |> mapSecond (Cmd.map EnterParticipantNameMsg)

        RoomListMsg subMsg ->
            (RoomList.update subMsg model.roomList) |> mapFirst (setRoomList model) |> mapSecond (Cmd.map RoomListMsg)


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
