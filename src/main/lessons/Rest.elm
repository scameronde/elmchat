module Rest exposing (..)

import Http
import Types exposing (..)
import Json


getParticipant : String -> (Result Http.Error Participant -> msg) -> Cmd msg
getParticipant participantName msg =
    let
        getParticipantRequest =
            Http.get ("http://localhost:4567/participant/" ++ participantName) Json.decodeParticipant
    in
        Http.send msg getParticipantRequest
