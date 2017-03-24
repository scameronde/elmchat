module DebugChatClient exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Toolbox.Model as Model
import ChatClient


type alias Flags =
    { debug : Bool }


type alias Msg =
    ChatClient.Msg


type alias Model =
    { debug : Bool
    , model : ChatClient.Model
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    Model.create (Model flags.debug)
    |> Model.combine identity ChatClient.init
    |> Model.run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ChatClient.update msg model.model
        |> Model.map (\ccm -> { model | model = ccm }) identity


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
