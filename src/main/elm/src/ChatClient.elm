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


type ProgramState
    = LoginState
    | ChatState


type alias Model =
    { programState : ProgramState
    , loginModel : Login.Model
    , chatModel : Chat.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        loginInit =
            Login.init

        chatInit =
            Chat.init
    in
        ( { programState = LoginState
          , loginModel = first loginInit
          , chatModel = first chatInit
          }
        , Cmd.batch
            [ Cmd.map LoginMsg (second loginInit)
            , Cmd.map ChatMsg (second chatInit)
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginMsg (Login.Login participant) ->
            ( { model | programState = ChatState }
            , toCmd (ChatMsg (Chat.Open participant))
            )

        LoginMsg subMsg ->
            (Login.update subMsg model.loginModel)
                |> mapFirst (\a -> { model | loginModel = a })
                |> mapSecond (Cmd.map LoginMsg)

        ChatMsg subMsg ->
            (Chat.update subMsg model.chatModel)
                |> mapFirst (\a -> { model | chatModel = a })
                |> mapSecond (Cmd.map ChatMsg)


viewMainArea : Model -> Html Msg
viewMainArea model =
    case model.programState of
        LoginState ->
            Html.map LoginMsg (Login.view model.loginModel)

        ChatState ->
            Html.map ChatMsg (Chat.view model.chatModel)


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
    case model.programState of
        ChatState ->
            Sub.map ChatMsg (Chat.subscriptions model.chatModel)

        LoginState ->
            Sub.map LoginMsg (Login.subscriptions model.loginModel)



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
