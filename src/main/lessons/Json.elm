module Json exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Types exposing (..)


encodeParticipant : Participant -> Encode.Value
encodeParticipant record =
    Encode.object
        [ ( "id", Encode.string record.id )
        , ( "name", Encode.string record.name )
        ]


decodeId : Decode.Decoder String
decodeId =
    Decode.string
