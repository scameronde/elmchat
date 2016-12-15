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


postChatRoom : BusinessTypes.ChatRoom -> (Result Http.Error Int -> msg) -> Cmd msg
postChatRoom chatRoom msg =
    let
        postChatRoomRequest =
            Http.post "http://localhost:4567/chatRoom" (Http.jsonBody (BusinessTypes.encodeChatRoom chatRoom)) BusinessTypes.decodeId
    in
        Http.send msg postChatRoomRequest


getChatRooms : (Result Http.Error (List BusinessTypes.ChatRoom) -> msg) -> Cmd msg
getChatRooms msg =
    let
        getChatRoomsRequest =
            Http.get "http://localhost:4567/chatRoom" BusinessTypes.decodeChatRooms
    in
        Http.send msg getChatRoomsRequest


getChatRoom : Int -> (Result Http.Error BusinessTypes.MessageLog -> msg) -> Cmd msg
getChatRoom id msg =
    let
        getChatRoomRequest =
            Http.get ("http://localhost:4567/chatRoom/" ++ toString id) BusinessTypes.decodeMessageLog
    in
        Http.send msg getChatRoomRequest
