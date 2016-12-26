module RestClient exposing (..)

import Http
import BusinessTypes
import Json


postParticipant : BusinessTypes.Participant -> (Result Http.Error BusinessTypes.Id -> msg) -> Cmd msg
postParticipant participant msg =
    let
        postParticipantRequest =
            Http.post "http://localhost:4567/participant" (participant |> Json.encodeParticipant |> Http.jsonBody) Json.decodeId
    in
        Http.send msg postParticipantRequest


postChatRoom : BusinessTypes.ChatRoom -> (Result Http.Error BusinessTypes.Id -> msg) -> Cmd msg
postChatRoom chatRoom msg =
    let
        postChatRoomRequest =
            Http.post "http://localhost:4567/chatRoom" (chatRoom |> Json.encodeChatRoom |> Http.jsonBody) Json.decodeId
    in
        Http.send msg postChatRoomRequest


getChatRooms : (Result Http.Error (List BusinessTypes.ChatRoom) -> msg) -> Cmd msg
getChatRooms msg =
    let
        getChatRoomsRequest =
            Http.get "http://localhost:4567/chatRoom" Json.decodeChatRooms
    in
        Http.send msg getChatRoomsRequest


getChatRoom : String -> (Result Http.Error BusinessTypes.MessageLog -> msg) -> Cmd msg
getChatRoom id msg =
    let
        getChatRoomRequest =
            Http.get ("http://localhost:4567/chatRoom/" ++ id) Json.decodeMessageLog
    in
        Http.send msg getChatRoomRequest
