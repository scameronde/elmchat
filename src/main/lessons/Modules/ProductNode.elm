module Modules.ProductNode exposing (..)

import Modules.Leaf2 as Leaf2
import Modules.Leaf3 as Leaf3
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
    let
        ( leaf2Model, leaf2Cmd ) =
            Leaf2.init aMessage

        ( leaf3Model, leaf3Cmd ) =
            Leaf3.init aMessage
    in
        ( { leaf2Model = leaf2Model, leaf3Model = leaf3Model }
        , Cmd.batch [ Cmd.map Leaf2Msg leaf2Cmd, Cmd.map Leaf3Msg leaf3Cmd ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Leaf2Msg (Leaf2.Send aMessage) ->
            let
                ( rmodel, rcmd ) =
                    Leaf3.update (Leaf3.Receive aMessage) model.leaf3Model
            in
                ( { model | leaf3Model = rmodel }, Cmd.map Leaf3Msg rcmd )

        Leaf3Msg (Leaf3.Send aMessage) ->
            let
                ( rmodel, rcmd ) =
                    Leaf2.update (Leaf2.Receive aMessage) model.leaf2Model
            in
                ( { model | leaf2Model = rmodel }, Cmd.map Leaf2Msg rcmd )

        Leaf2Msg imsg ->
            let
                ( rmodel, rcmd ) =
                    Leaf2.update imsg model.leaf2Model
            in
                ( { model | leaf2Model = rmodel }, Cmd.map Leaf2Msg rcmd )

        Leaf3Msg imsg ->
            let
                ( rmodel, rcmd ) =
                    Leaf3.update imsg model.leaf3Model
            in
                ( { model | leaf3Model = rmodel }, Cmd.map Leaf3Msg rcmd )


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
