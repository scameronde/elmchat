module RestClient exposing (getParticipant, postChatRoom, getChatRoom, getChatRooms, deleteChatRoom)

import Http
import BusinessTypes
import Json


getParticipant : String -> (Result Http.Error BusinessTypes.Participant -> msg) -> Cmd msg
getParticipant participantName msg =
    let
        getParticipantRequest =
            Http.get ("http://localhost:4567/participant/" ++ participantName) Json.decodeParticipant
    in
        Http.send msg getParticipantRequest


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


deleteChatRoom : String -> (Result Http.Error () -> msg) -> Cmd msg
deleteChatRoom id msg =
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
