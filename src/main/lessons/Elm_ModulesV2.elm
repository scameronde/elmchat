module Elm_Modules exposing (..)

import Modules.SumNodeV2 as SumNode
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = SumNode.Model

type alias Msg = SumNode.Msg


init : (Model, Cmd Msg)
init = SumNode.init

update : Msg -> Model -> (Model, Cmd Msg)
update = SumNode.update

view : Model -> Html Msg
view = SumNode.view

subscriptions : Model -> Sub Msg
subscriptions = SumNode.subscriptions

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
