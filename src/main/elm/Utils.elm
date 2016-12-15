module Utils exposing (update, toCmd)

import Task


update :
    (msg -> model -> ( model, Cmd msg ))
    -> msg
    -> model
    -> (model -> parentModel)
    -> (msg -> parentMsg)
    -> ( parentModel, Cmd parentMsg )
update updateFunction msg model setFunction liftFunction =
    let
        ( subModel, subCmd ) =
            updateFunction msg model
    in
        ( setFunction subModel, Cmd.map liftFunction subCmd )


toCmd : msg -> Cmd msg
toCmd message =
    Task.perform identity (Task.succeed message)
