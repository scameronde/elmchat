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
    Login.init |> mapFirst LoginModel |> mapSecond (Cmd.map LoginMsg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg (Login.Login participant), LoginModel loginModel ) ->
            Chat.init |> mapFirst ChatModel |> mapSecond (Cmd.map ChatMsg) |> mapSecond (\cmd -> Cmd.batch [ cmd, toCmd (ChatMsg (Chat.Open participant)) ])

        ( LoginMsg subMsg, LoginModel model ) ->
            Login.update subMsg model |> mapFirst LoginModel |> mapSecond (Cmd.map LoginMsg)

        ( ChatMsg subMsg, ChatModel model ) ->
            Chat.update subMsg model |> mapFirst ChatModel |> mapSecond (Cmd.map ChatMsg)

        ( x, y ) ->
            let
                _ =
                    Debug.log "Stray found" x
            in
                ( model, Cmd.none )


viewMainArea : Model -> Html Msg
viewMainArea model =
    case model of
        LoginModel model ->
            Html.map LoginMsg (Login.view model)

        ChatModel model ->
            Html.map ChatMsg (Chat.view model)


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
