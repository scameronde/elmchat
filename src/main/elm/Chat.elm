module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils
import NavBar exposing (..)
import Login
import ChatRooms
import Tuple exposing (..)


type alias Flags =
    { debug : Bool }


type Msg
    = LoginMsg Login.Msg
    | ChatRoomsMsg ChatRooms.Msg


type ProgramState
    = LoginState
    | ChatRoomsState


type alias Model =
    { programState : ProgramState
    , loginModel : Login.Model
    , chatRoomsModel : ChatRooms.Model
    , debug : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        loginInit =
            Login.init

        chatRoomsInit =
            ChatRooms.init
    in
        ( { programState = LoginState
          , loginModel = first loginInit
          , chatRoomsModel = first chatRoomsInit
          , debug = flags.debug
          }
        , Cmd.batch
            [ Cmd.map LoginMsg (second loginInit)
            , Cmd.map ChatRoomsMsg (second chatRoomsInit)
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginMsg (Login.Exit participant) ->
            ( { model | programState = ChatRoomsState }
            , Utils.toCmd <| ChatRoomsMsg <| ChatRooms.Open participant
            )

        LoginMsg subMsg ->
            (Login.update subMsg model.loginModel)
                |> mapFirst (\a -> { model | loginModel = a })
                |> mapSecond (Cmd.map LoginMsg)

        ChatRoomsMsg subMsg ->
            (ChatRooms.update subMsg model.chatRoomsModel)
                |> mapFirst (\a -> { model | chatRoomsModel = a })
                |> mapSecond (Cmd.map ChatRoomsMsg)


viewMainArea : Model -> Html Msg
viewMainArea model =
    case model.programState of
        LoginState ->
            Html.map LoginMsg (Login.view model.loginModel)

        ChatRoomsState ->
            Html.map ChatRoomsMsg (ChatRooms.view model.chatRoomsModel)


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
    if (model.programState == ChatRoomsState) then
        Sub.map ChatRoomsMsg (ChatRooms.subscriptions model.chatRoomsModel)
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
