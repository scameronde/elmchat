module Subscribe exposing (..)

import Html exposing (..)
import Time exposing (..)

type alias Model = Time


type Msg
    = Tick Time


init : (Model, Cmd Msg)
init =
    (0, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Tick time ->
            (time, Cmd.none)


view : Model -> Html Msg
view model =
    div []
        [ span [] [text (toString model)]
        ]

subscriptions model = Time.every second Tick

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
