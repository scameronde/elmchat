module Toolbox.Update exposing (..)

import Tuple exposing (..)


map : (modelA -> modelB) -> (msgA -> msgB) -> ( modelA, Cmd msgA ) -> ( modelB, Cmd msgB )
map f g r =
    ( first r |> f, second r |> Cmd.map g )


andThenDo : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThenDo cmd r =
    first r ! [ second r, cmd ]


insteadDo : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
insteadDo cmd r =
    ( first r, cmd )


modify : (model -> model) -> ( model, Cmd msg ) -> ( model, Cmd msg )
modify =
    mapFirst
