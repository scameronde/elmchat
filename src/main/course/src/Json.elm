module Json exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline as DecodePipeline
import BusinessTypes exposing (..)


-- Id


{-| example:  encodeId (Id "4711")  ->  " '4711' "
-}
encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string id


{-| example:  decodeString decoderForId " '4711' "  ->  Ok (Id '4711') : Result String id
-}
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
