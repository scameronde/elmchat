module ChatClient exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tuple exposing (..)
import Toolbox.Cmd exposing (..)
import NavBar exposing (..)
import Login
import Chat


type Msg
    = LoginMsg Login.Msg
    | ChatMsg Chat.Msg


type Model
    = LoginModel Login.Model
    | ChatModel Chat.Model


init : ( Model, Cmd Msg )
init =
    Login.init
        |> mapFirst LoginModel
        |> mapSecond (Cmd.map LoginMsg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg (Login.Login participant), LoginModel model_ ) ->
            Chat.init
                |> mapFirst ChatModel
                |> mapSecond (Cmd.map ChatMsg)
                |> mapSecond (\cmd -> Cmd.batch [ cmd, toCmd (ChatMsg (Chat.Open participant)) ])

        ( LoginMsg msg_, LoginModel model_ ) ->
            Login.update msg_ model_
                |> mapFirst LoginModel
                |> mapSecond (Cmd.map LoginMsg)

        ( ChatMsg msg_, ChatModel model_ ) ->
            Chat.update msg_ model_
                |> mapFirst ChatModel
                |> mapSecond (Cmd.map ChatMsg)

        _ ->
            Debug.crash "Stray combiniation of Model and Message found"


viewMainArea : Model -> Html Msg
viewMainArea model =
    case model of
        LoginModel model_ ->
            Html.map LoginMsg (Login.view model_)

        ChatModel model_ ->
            Html.map ChatMsg (Chat.view model_)


view : Model -> Html Msg
view model =
    div []
        [ viewNavBar model
        , viewMain
            [ div [ class "view-area" ] [ viewMainArea model ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        LoginModel model ->
            Sub.map LoginMsg (Login.subscriptions model)

        ChatModel model ->
            Sub.map ChatMsg (Chat.subscriptions model)



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
