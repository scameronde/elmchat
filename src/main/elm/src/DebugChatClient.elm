module DebugChatClient exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tuple exposing (..)
import ChatClient


type alias Flags =
    { debug : Bool }


type alias Msg =
    ChatClient.Msg


type alias Model =
    { model : ChatClient.Model
    , debug : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ChatClient.init |> mapFirst (\init -> { model = init, debug = flags.debug })


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ChatClient.update msg model.model |> mapFirst (\ccm -> { model | model = ccm })


view : Model -> Html Msg
view model =
    div []
        [ ChatClient.view model.model
        , if model.debug then
            div [ class "debug" ] [ text <| toString model ]
          else
            div [] []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    ChatClient.subscriptions model.model



-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
