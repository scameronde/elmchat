module Utils exposing (toCmd)

import Task


toCmd : msg -> Cmd msg
toCmd message =
    Task.perform identity (Task.succeed message)
