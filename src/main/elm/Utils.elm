module Utils exposing (toCmd, jsonAsString)

import Task
import Json.Encode


toCmd : msg -> Cmd msg
toCmd message =
    Task.perform identity (Task.succeed message)


jsonAsString : Json.Encode.Value -> String
jsonAsString json =
    Json.Encode.encode 0 json
