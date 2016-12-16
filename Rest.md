# Elm und REST

REST Calls können in Elm nicht direkt gemacht werden, da dies Seiteneffekte
wären. Deswegen müssen REST Calls als Commands (`Cmd msg`) ausgedrückt und
per `init` oder `update` an die Elm Runtime übergeben werden.

Die Antwort eines REST Calls kommt dann als Message zurück. Die Message muss, um
Fehler als Ergebnis des REST Calls verarbeiten zu können, eine Payload
vom Typ `Result Http.Error a` haben.


## Definition Message

```elm
type Msg
  = GetAdresseResult (Result Http.Error Adresse)
  | PostAdresseResult (Result Http.Error Id)
```

## Absetzen eines REST Calls

Die REST API vom Elm unterstützt momentan auf komfortable Art und Weise nur
`GET` und `POST` Requests. Alle anderen müssen recht rudimentär zusammengebastelt
werden.

### GET

```elm
getAdresse : Int -> Cmd GetAdresseResult
getAdresse id =
    let
        getAdresseRequest =
            Http.get ("http://localhost:4567/adresse/" ++ toString id) Json.decodeAdresse
    in
        Http.send GetAdresseResult getAdresseRequest
```

### POST

```elm
postAdresse : Adresse -> Cmd PostAdresseResult
postAdresse adresse =
  let
    postAdresseRequest =
        Http.post "http://localhost:4567/adresse" (Http.jsonBody (Json.encodeAdresse adresse)) Json.decodeId
in
    Http.send PostAdresseResult postAdresseRequest

```

## Das Ergebnis eines REST Calls empfangen

Die Ergebnisse von REST Calls werden als Messages an die `update` Funktion
übergeben. Da ein REST Call sowohl in einem Fehler als auch in einem Erfolg
resultieren kann, müssen beide Fälle abgehandelt werden.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    GetAdresseResult (Ok adresse) ->
      ( model, Cmd.none )

    GetAdresseResult (Err error) ->
      ( model, Cmd.none )

    PostAdresseResult (Ok id) ->
      ( model, Cmd.none )

    PostAdresseResult (Err error) ->
      ( model, Cmd.none )

```
