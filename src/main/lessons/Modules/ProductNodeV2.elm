module Modules.ProductNodeV2 exposing (..)

import Modules.Leaf2 as Leaf2
import Modules.Leaf3 as Leaf3
import Toolbox.Model as Model
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { leaf2Model : Leaf2.Model
    , leaf3Model : Leaf3.Model
    }


type Msg
    = Leaf2Msg Leaf2.Msg
    | Leaf3Msg Leaf3.Msg


init : String -> ( Model, Cmd Msg )
init aMessage =
    Model.create Model
        |> Model.combine Leaf2Msg (Leaf2.init aMessage)
        |> Model.combine Leaf3Msg (Leaf3.init aMessage)
        |> Model.run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Leaf2Msg (Leaf2.Send aMessage) ->
            Leaf3.update (Leaf3.Receive aMessage) model.leaf3Model
                |> Model.map (\a -> { model | leaf3Model = a }) Leaf3Msg

        Leaf2Msg imsg ->
            Leaf2.update imsg model.leaf2Model
                |> Model.map (\a -> { model | leaf2Model = a }) Leaf2Msg

        Leaf3Msg (Leaf3.Send aMessage) ->
            Leaf2.update (Leaf2.Receive aMessage) model.leaf2Model
                |> Model.map (\a -> { model | leaf2Model = a }) Leaf2Msg

        Leaf3Msg imsg ->
            Leaf3.update imsg model.leaf3Model
                |> Model.map (\a -> { model | leaf3Model = a }) Leaf3Msg


view : Model -> Html Msg
view model =
    div []
        [ Html.map Leaf2Msg (Leaf2.view model.leaf2Model)
        , Html.map Leaf3Msg (Leaf3.view model.leaf3Model)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Leaf2Msg (Leaf2.subscriptions model.leaf2Model)
        , Sub.map Leaf3Msg (Leaf3.subscriptions model.leaf3Model)
        ]
