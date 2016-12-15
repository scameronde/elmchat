module RestClient exposing (..)

import Http
import BusinessTypes


postParticipant : BusinessTypes.Participant -> (Result Http.Error Int -> msg) -> Cmd msg
postParticipant participant msg =
    let
        postParticipantRequest =
            Http.post "http://localhost:4567/participant" (Http.jsonBody (BusinessTypes.encodeParticipant participant)) BusinessTypes.decodeId
    in
        Http.send msg postParticipantRequest


getChatRooms : (Result Http.Error (List BusinessTypes.ChatRoom) -> msg) -> Cmd msg
getChatRooms msg =
    let
        getChatRoomsRequest =
            Http.get "http://localhost:4567/chatRoom" BusinessTypes.decodeChatRooms
    in
        Http.send msg getChatRoomsRequest
