# Elm und JSON

Für die Umwandlung von Elm Datentypen von und nach JSON gibt es Bibliotheken
im Core. Allerdings gibt es eine Zusatzbibliothek (Pipeline), die die Umwandlung
von JSON nach Elm etwas einfacher gestaltet. Deswegen nehme ich diese mit hinzu.

Den Code für die Konvertierung Elm von/nach JSON muss man übrigens nicht per Hand
schreiben. Es gibt einen wunderschönen Codegenerator, der aus JSON Beispieldaten
den notwendigen Elm Code generiert. Der Konverter kann Code sowohl untern
Nutzung der Core Bibliotheken, als auch für die Pipeline Erweiterung generieren.

Der Konverter kann unter http://noredink.github.io/json-to-elm/ genutzt und
herunter geladen werden.

Was Nutzer von dynamischen Sprachen oder Sprachen mit Reflection wundert, ist
die Tatsache dass man in Elm tatsächlich Code für die Konvertierung schreiben
muss. Das ist der Tatsache geschuldet, dass Elm stark typisiert ist und der
Compiler alle Informationen zur Laufzeit benötigt.

## Beispieldaten

```elm
type alias Adresse =
  { strasse : String
  , ort : String
  }

type alias Person =
  { name : String
  , alter : Int
  , adresse : adresse
  }

type alias Personen =
  List Person

```

## Elm nach JSON

Das Muster ist immer das gleiche. Wie gesagt, der Codegenerator macht gute Arbeit,
man kann aber nach dem Muster das ganze auch per Hand coden.

```elm
encodeAdresse : Adresse -> Json.Encode.Value
encodeAdresse record =
    Json.Encode.object
        [ ("strasse",  Json.Encode.string <| record.strasse)
        , ("ort",  Json.Encode.string <| record.ort)
        ]


encodePerson : Person -> Json.Encode.Value
encodePerson record =
    Json.Encode.object
        [ ("name",  Json.Encode.string <| record.name)
        , ("alter",  Json.Encode.int <| record.alter)
        , ("adresse",  encodeAdresse <| record.adresse)
        ]


encodePersonen : (List Person) -> Json.Encode.Value
encodePersonen list =
    Json.Encode.list <| List.map encodePerson list
```
## JSON nach Elm

Das Muster ist immer das gleiche. Wie gesagt, der Codegenerator macht gute Arbeit,
man kann aber nach dem Muster das ganze auch per Hand coden.

```elm
decodeAdresse : Json.Decode.Decoder Adresse
decodeAdresse =
    Json.Decode.Pipeline.decode Adresse
        |> Json.Decode.Pipeline.required "strasse" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "ort" (Json.Decode.string)


decodePerson : Json.Decode.Decoder Person
decodePerson =
    Json.Decode.Pipeline.decode Person
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "alter" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "adresse" (decodePersonAdresse)


decodePersonen : Json.Decode.Decoder (List Person)
decodePersonen =
    Json.Decode.list decodePerson
```
