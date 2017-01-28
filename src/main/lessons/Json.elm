module Json exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline
import Types exposing (..)


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
