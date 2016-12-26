module Rest exposing (..)

import Http
import Types exposing (..)
import Json


postParticipant : Participant -> (Result Http.Error Id -> msg) -> Cmd msg
postParticipant participant msg =
    let
        postParticipantRequest =
            Http.post "http://localhost:4567/participant" (participant |> Json.encodeParticipant |> Http.jsonBody) Json.decodeId
    in
        Http.send msg postParticipantRequest
