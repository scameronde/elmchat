module ChatClient exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tuple exposing (..)
import NavBar exposing (..)
import Login
import Chat

{-| This is an example for a "sum type" module. A "sum type" module has no UI or logic by itself,
but has children. It has only one child active at most at a time. It can switch between its children,
depending on messages send by the active child.

There is another type of aggregator module, the "product type" module. See Chat.elm for an example.
-}

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
            Chat.init participant
                |> mapFirst ChatModel
                |> mapSecond (Cmd.map ChatMsg)

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
        , viewMain [ div [ class "view-area" ] [ viewMainArea model ] ]
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
