module Toolbox.Update exposing (..)

import Tuple exposing (..)


map : (modelA -> modelB) -> (msgA -> msgB) -> ( modelA, Cmd msgA ) -> ( modelB, Cmd msgB )
map f g r =
    ( first r |> f, Cmd.map g (second r) )


andThenDo : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThenDo cmd r =
    first r ! [ second r, cmd ]


insteadDo : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
insteadDo cmd r =
    ( first r, cmd )


modify : (model -> model) -> ( model, Cmd msg ) -> (model, Cmd msg)
modify f r =
    ( (first r) |> f, second r )
