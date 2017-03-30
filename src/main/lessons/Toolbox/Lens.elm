module Toolbox.Lens exposing (..)


type alias Lens rec elem =
    { get : rec -> elem
    , set : elem -> rec -> rec
    , fset : rec -> elem -> rec
    }


lens : (rec -> elem) -> (elem -> rec -> rec) -> Lens rec elem
lens get set =
    Lens get set (flip set)


(.) : Lens a b -> Lens b c -> Lens a c
(.) lensAB lensBC =
    let
        set c a =
            lensAB.get a |> lensBC.set c |> (\b -> lensAB.set b a)

        get =
            lensAB.get >> lensBC.get
    in
        lens get set


compose : Lens a b -> Lens b c -> Lens a c
compose =
    (.)
