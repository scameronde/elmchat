module Toolbox.Model exposing (init, apply, get, map, andThenDo, insteadDo, modify)

{-| Helper functions for mapping and manipulating Tupels of (Model, Cmd).

# Initializing composed models
@docs init, apply, get, andThenDo, insteadDo

# Updating composed models
@docs map, modify, andThenDo, insteadDo

-}

import Tuple exposing (..)


type Creator a
    = Creator a


{-| Prepare a new tuple (Model, Cmd) for initialization.

    init (Model firstField secondField)

    where type Model gets partially initialized and the next fields will be initilized
    with the use of @apply
-}
init : a -> ( Creator a, Cmd msg )
init a =
    ( Creator a, Cmd.none )


{-| Apply a tuple (Model, Cmd) to the initialized tuple

    init (Model firstField secondField)
      |> apply Module1.init Module1Msg

    where the model part of Module1.init will be part of the resulting model and Module1Msg wraps
    the msg type for the resulting Cmd
-}
apply : ( a, Cmd msg ) -> (msg -> msgN) -> ( Creator (a -> b), Cmd msgN ) -> ( Creator b, Cmd msgN )
apply ( modelI, cmdI ) msgMapper ( Creator f, cmd ) =
    Creator (f modelI) ! [ cmd, Cmd.map msgMapper cmdI ]


{-| Get the (model, Cmd) tuple
-}
get : ( Creator a, Cmd msg ) -> ( a, Cmd msg )
get ( Creator a, cmd ) =
    ( a, cmd )


{-| Modify an existing (model, Cmd) tuple with the result of another (model, Cmd) tuple
-}
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
