module BusinessTypes exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


-- Participant


type alias Participant =
    { id : Int
    , name : String
    }


decodeParticipant : Json.Decode.Decoder Participant
decodeParticipant =
    Json.Decode.Pipeline.decode Participant
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)


encodeParticipant : Participant -> Json.Encode.Value
encodeParticipant record =
    Json.Encode.object
        [ ( "id", Json.Encode.int <| record.id )
        , ( "name", Json.Encode.string <| record.name )
        ]



-- ChatRoom


type alias ChatRoom =
    { id : Int
    , title : String
    }


decodeChatRooms : Json.Decode.Decoder (List ChatRoom)
decodeChatRooms =
    Json.Decode.list decodeChatRoom


encodeChatRooms : List ChatRoom -> Json.Encode.Value
encodeChatRooms list =
    Json.Encode.list <| List.map encodeChatRoom list


decodeChatRoom : Json.Decode.Decoder ChatRoom
decodeChatRoom =
    Json.Decode.Pipeline.decode ChatRoom
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "title" (Json.Decode.string)


encodeChatRoom : ChatRoom -> Json.Encode.Value
encodeChatRoom record =
    Json.Encode.object
        [ ( "id", Json.Encode.int <| record.id )
        , ( "title", Json.Encode.string <| record.title )
        ]



-- ChatRegistration


type alias ChatRegistration =
    { participant : Participant
    , chatRoom : ChatRoom
    }


decodeChatRegistration : Json.Decode.Decoder ChatRegistration
decodeChatRegistration =
    Json.Decode.Pipeline.decode ChatRegistration
        |> Json.Decode.Pipeline.required "participant" decodeParticipant
        |> Json.Decode.Pipeline.required "chatRoom" decodeChatRoom


encodeChatRegistration : ChatRegistration -> Json.Encode.Value
encodeChatRegistration record =
    Json.Encode.object
        [ ( "participant", encodeParticipant record.participant )
        , ( "chatRoom", encodeChatRoom record.chatRoom )
        ]



-- Message


type alias Message =
    { message : String
    }


decodeMessage : Json.Decode.Decoder Message
decodeMessage =
    Json.Decode.Pipeline.decode Message
        |> Json.Decode.Pipeline.required "message" (Json.Decode.string)


encodeMessage : Message -> Json.Encode.Value
encodeMessage record =
    Json.Encode.object
        [ ( "message", Json.Encode.string <| record.message )
        ]



-- MessageLog


type alias MessageLog =
    { messageLog : String
    }


decodeMessageLog : Json.Decode.Decoder MessageLog
decodeMessageLog =
    Json.Decode.Pipeline.decode MessageLog
        |> Json.Decode.Pipeline.required "messageLog" (Json.Decode.string)


encodeMessageLog : MessageLog -> Json.Encode.Value
encodeMessageLog record =
    Json.Encode.object
        [ ( "messageLog", Json.Encode.string <| record.messageLog )
        ]



-- Id


type alias Id =
    Int


decodeId : Json.Decode.Decoder Int
decodeId =
    Json.Decode.int
