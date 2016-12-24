module WSClient exposing (..)

import WebSocket
import BusinessTypes
import Json
import Utils


sendRegistration : BusinessTypes.ChatRegistration -> Cmd a
sendRegistration registration =
    WebSocket.send "ws://localhost:4567/chat" (Utils.jsonAsString <| Json.encodeChatCommand <| BusinessTypes.Register registration)


sendMessage : BusinessTypes.Message -> Cmd a
sendMessage message =
    WebSocket.send "ws://localhost:4567/chat" (Utils.jsonAsString <| Json.encodeChatCommand <| BusinessTypes.NewMessage message)
