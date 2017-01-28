module Json exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline
import Json.Encode as Encode
import BusinessTypes exposing (..)


-- Id


decodeId : Decode.Decoder Id
decodeId =
    Decode.map Id Decode.string


encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string <| id



-- Participant


decodeParticipant : Decode.Decoder Participant
decodeParticipant =
    DecodePipeline.decode Participant
        |> DecodePipeline.required "id" (decodeId)
        |> DecodePipeline.required "name" (Decode.string)


encodeParticipant : Participant -> Encode.Value
encodeParticipant record =
    Encode.object
        [ ( "id", encodeId <| record.id )
        , ( "name", Encode.string <| record.name )
        ]



-- ChatRoom


decodeChatRooms : Decode.Decoder (List ChatRoom)
decodeChatRooms =
    Decode.list decodeChatRoom


decodeChatRoom : Decode.Decoder ChatRoom
decodeChatRoom =
    DecodePipeline.decode ChatRoom
        |> DecodePipeline.required "id" (decodeId)
        |> DecodePipeline.required "title" (Decode.string)


encodeChatRoom : ChatRoom -> Encode.Value
encodeChatRoom record =
    Encode.object
        [ ( "id", encodeId <| record.id )
        , ( "title", Encode.string <| record.title )
        ]


encodeChatRooms : List ChatRoom -> Encode.Value
encodeChatRooms list =
    Encode.list <| List.map encodeChatRoom list



-- ChatRegistration


decodeChatRegistration : Decode.Decoder ChatRegistration
decodeChatRegistration =
    DecodePipeline.decode ChatRegistration
        |> DecodePipeline.required "participant" decodeParticipant
        |> DecodePipeline.required "chatRoom" decodeChatRoom


encodeChatRegistration : ChatRegistration -> Encode.Value
encodeChatRegistration record =
    Encode.object
        [ ( "participant", encodeParticipant record.participant )
        , ( "chatRoom", encodeChatRoom record.chatRoom )
        ]



-- Message


decodeMessage : Decode.Decoder Message
decodeMessage =
    DecodePipeline.decode Message
        |> DecodePipeline.required "message" (Decode.string)


encodeMessage : Message -> Encode.Value
encodeMessage record =
    Encode.object
        [ ( "message", Encode.string <| record.message )
        ]



-- MessageLog


decodeMessageLog : Decode.Decoder MessageLog
decodeMessageLog =
    DecodePipeline.decode MessageLog
        |> DecodePipeline.required "messageLog" (Decode.string)


encodeMessageLog : MessageLog -> Encode.Value
encodeMessageLog record =
    Encode.object
        [ ( "messageLog", Encode.string <| record.messageLog )
        ]



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
