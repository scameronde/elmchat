module Lens exposing (..)

type alias Lens rec elem =
    { get : rec -> elem
    , set : elem -> rec -> rec
    }


(.) : Lens a b -> Lens b c -> Lens a c
(.) lensAB lensBC =
    let
        set c a =
            lensAB.get a |> lensBC.set c |> (\b -> lensAB.set b a)

        get =
            lensAB.get >> lensBC.get
    in
        Lens get set
