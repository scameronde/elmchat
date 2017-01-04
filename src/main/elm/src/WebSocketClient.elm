module WebSocketClient exposing (sendRegistration, sendMessage)

import Json.Encode
import WebSocket
import BusinessTypes
import Json


sendRegistration : BusinessTypes.ChatRegistration -> Cmd a
sendRegistration registration =
    WebSocket.send "ws://localhost:4567/chat" (jsonAsString <| Json.encodeChatCommand <| BusinessTypes.Register registration)


sendMessage : BusinessTypes.Message -> Cmd a
sendMessage message =
    WebSocket.send "ws://localhost:4567/chat" (jsonAsString <| Json.encodeChatCommand <| BusinessTypes.NewMessage message)


jsonAsString : Json.Encode.Value -> String
jsonAsString =
    Json.Encode.encode 0
