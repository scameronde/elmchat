module RestClient exposing (getParticipant, postChatRoom, getChatRoom, getChatRooms, deleteChatRoom)

import Http
import BusinessTypes exposing (..)
import Json


getParticipant : String -> (Result Http.Error Participant -> msg) -> Cmd msg
getParticipant participantName msg =
    let
        getParticipantRequest =
            Http.get ("http://localhost:4567/participant/" ++ participantName) Json.decodeParticipant
    in
        Http.send msg getParticipantRequest


postParticipant : Participant -> (Result Http.Error Id -> msg) -> Cmd msg
postParticipant participant msg =
    let
        postParticipantRequest =
            Http.post "http://localhost:4567/participant" (participant |> Json.encodeParticipant |> Http.jsonBody) Json.decodeId
    in
        Http.send msg postParticipantRequest


postChatRoom : ChatRoom -> (Result Http.Error Id -> msg) -> Cmd msg
postChatRoom chatRoom msg =
    let
        postChatRoomRequest =
            Http.post "http://localhost:4567/chatRoom" (chatRoom |> Json.encodeChatRoom |> Http.jsonBody) Json.decodeId
    in
        Http.send msg postChatRoomRequest


getChatRooms : (Result Http.Error (List ChatRoom) -> msg) -> Cmd msg
getChatRooms msg =
    let
        getChatRoomsRequest =
            Http.get "http://localhost:4567/chatRoom" Json.decodeChatRooms
    in
        Http.send msg getChatRoomsRequest


getChatRoom : Id -> (Result Http.Error MessageLog -> msg) -> Cmd msg
getChatRoom (Id id) msg =
    let
        getChatRoomRequest =
            Http.get ("http://localhost:4567/chatRoom/" ++ id) Json.decodeMessageLog
    in
        Http.send msg getChatRoomRequest


deleteChatRoom : Id -> (Result Http.Error () -> msg) -> Cmd msg
deleteChatRoom (Id id) msg =
    let
        deleteChatRoomRequest =
            delete ("http://localhost:4567/chatRoom/" ++ id)
    in
        Http.send msg deleteChatRoomRequest


delete : String -> Http.Request ()
delete url =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
