module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils
import NavBar exposing (..)
import EnterParticipantName
import RoomList
import Tuple exposing (mapFirst, mapSecond, first, second)


type alias Flags =
    { debug : Bool }


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
    , debug : Bool
    }


setRoomList : Model -> RoomList.Model -> Model
setRoomList model =
    (\value -> { model | roomList = value })


setEnterParticipantName : Model -> EnterParticipantName.Model -> Model
setEnterParticipantName model =
    (\value -> { model | enterParticipantName = value })


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        enterParticipantName =
            EnterParticipantName.init

        roomList =
            RoomList.init
    in
        ( { programState = EnterParticipantName
          , enterParticipantName = first enterParticipantName
          , roomList = first roomList
          , debug = flags.debug
          }
        , Cmd.batch
            [ Cmd.map EnterParticipantNameMsg (second enterParticipantName)
            , Cmd.map RoomListMsg (second roomList)
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
        , viewMain
            [ div [ class "view-area" ] [ viewMainArea model ]
            , if model.debug then
                div [ class "debug" ] [ text <| toString model ]
              else
                div [] []
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    if (model.programState == RoomList) then
        Sub.map RoomListMsg (RoomList.subscriptions model.roomList)
    else
        Sub.none



-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
