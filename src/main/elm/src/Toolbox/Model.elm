module Toolbox.Model exposing (create, set, combine, run, map, andThenDo, insteadDo, modify )

{-| Helper functions for mapping and manipulating Tupels of (Model, Cmd).

# Initializing composed models
@docs create, combine, run, andThenDo, insteadDo

# Updating composed models
@docs map, modify, andThenDo, insteadDo

-}

import Tuple exposing (..)


type Creator a m
    = Creator (a, Cmd m)

pure : (a, Cmd m) -> Creator a m
pure = Creator

hoist : (msgI -> msgO) -> Creator a msgI -> Creator a msgO
hoist f (Creator (a, cmdI)) = Creator (a, Cmd.map f cmdI)

apply : Creator (a -> b) m -> Creator a m -> Creator b m
apply (Creator (f, m1)) (Creator (a, m2)) = Creator (f a ! [m1, m2])

{-| Extract the (model, Cmd msg) tuple
-}
run : Creator a m -> (a, Cmd m)
run (Creator tupple) = tupple

{-| Prepare a new tuple (Model, Cmd) for initialization.

    create (Model firstField secondField)

    where type Model gets partially initialized and the next fields will be initialized
    with the use of @combine
-}
create : (a -> b) -> Creator (a -> b) m
create f = pure (f, Cmd.none)

{-| Combine a tuple (Model, Cmd) with the created tuple

    create (Model firstField secondField)
      |> combine Module1Msg Module1.init

    where the model part of Module1.init will be part of the resulting model and Module1Msg wraps
    the msg type for the resulting Cmd
-}
combine : (msgI -> msgO) -> (a, Cmd msgI) -> Creator (a -> b) msgO -> Creator b msgO
combine msgMapper innerInit creator =
  pure innerInit |> hoist msgMapper |> apply creator

{-| Combine a simple value with the created tuple

  create (Model firstField)
    |> set secondField
    |> combine Module1Msg Module1.init
    |> set fourthField
-}
set : a -> Creator (a -> b) m -> Creator b m
set value creator =
  combine identity (value, Cmd.none) creator

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
