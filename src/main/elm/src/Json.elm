module Json exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline
import Json.Encode as Encode
import BusinessTypes exposing (..)


-- Id


encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string id


decoderForId : Decode.Decoder Id
decoderForId =
    Decode.map Id Decode.string



-- Participant


encodeParticipant : Participant -> Encode.Value
encodeParticipant record =
    Encode.object
        [ ( "id", encodeId record.id )
        , ( "name", Encode.string record.name )
        ]


decoderForParticipant : Decode.Decoder Participant
decoderForParticipant =
    DecodePipeline.decode Participant
        |> DecodePipeline.required "id" (decoderForId)
        |> DecodePipeline.required "name" (Decode.string)



-- ChatRoom


encodeChatRoom : ChatRoom -> Encode.Value
encodeChatRoom record =
    Encode.object
        [ ( "id", encodeId record.id )
        , ( "title", Encode.string record.title )
        ]


encodeChatRooms : List ChatRoom -> Encode.Value
encodeChatRooms list =
    Encode.list <| List.map encodeChatRoom list


decoderForChatRooms : Decode.Decoder (List ChatRoom)
decoderForChatRooms =
    Decode.list decoderForChatRoom


decoderForChatRoom : Decode.Decoder ChatRoom
decoderForChatRoom =
    DecodePipeline.decode ChatRoom
        |> DecodePipeline.required "id" (decoderForId)
        |> DecodePipeline.required "title" (Decode.string)



-- ChatRegistration


encodeChatRegistration : ChatRegistration -> Encode.Value
encodeChatRegistration record =
    Encode.object
        [ ( "participant", encodeParticipant record.participant )
        , ( "chatRoom", encodeChatRoom record.chatRoom )
        ]


decoderForChatRegistration : Decode.Decoder ChatRegistration
decoderForChatRegistration =
    DecodePipeline.decode ChatRegistration
        |> DecodePipeline.required "participant" decoderForParticipant
        |> DecodePipeline.required "chatRoom" decoderForChatRoom



-- Message


encodeMessage : Message -> Encode.Value
encodeMessage record =
    Encode.object
        [ ( "message", Encode.string record.message )
        ]


decoderForMessage : Decode.Decoder Message
decoderForMessage =
    DecodePipeline.decode Message
        |> DecodePipeline.required "message" (Decode.string)



-- MessageLog


encodeMessageLog : MessageLog -> Encode.Value
encodeMessageLog record =
    Encode.object
        [ ( "messageLog", Encode.string record.messageLog )
        ]


decoderForMessageLog : Decode.Decoder MessageLog
decoderForMessageLog =
    DecodePipeline.decode MessageLog
        |> DecodePipeline.required "messageLog" (Decode.string)



-- ChatCommand


encodeChatCommand : ChatCommand -> Encode.Value
encodeChatCommand record =
    case record of
        Register data ->
            Encode.object
                [ ( "command", Encode.string "register" )
                , ( "registration", encodeChatRegistration data )
                ]

        NewMessage data ->
            Encode.object
                [ ( "command", Encode.string "message" )
                , ( "message", encodeMessage data )
                ]
