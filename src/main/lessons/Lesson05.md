# Modul extrahieren

Wir brauchen:
- Ein eigenes Modul für die Eingabe des Participant.
- Eine Möglichkeit dass das Modul den Participant an das Hauptprogramm
  zurück gibt.
- Einen Weg, das Modul in den Lebenszyklus des Hauptprogramms einzubinden.

## Modul `EnterParticipant.elm`

### Basics
Das Modul braucht die vier Lebenszyklusmethoden `init`, `update`, `view` und `subscriptions`.

Das Modul braucht eigene Messages und ein eigenes Model.

Anlegen mit IntelliJ Template `elmmodul`

```elm
module EnterParticipant exposing (Msg(Exit), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = Exit


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
```

### Übertragen der Funktionalität

1. `Msg`, `Model`, `init`, `update` und `view` vom Hauptprogramm kopieren.
1. Type `Msg` um `Exit Participant` erweitern
1. `init` den Parameter `flags` wegnehmen
1. aus `view` den umliegenden Container und die Debug-Ausgabe wegnehmen
1. ´update´ wie folgt erweitern:
    ```
    PostParticipantResult (Ok id) ->
        let
            newModel =
                setParticipant (setId id model.participant) model
        in
            ( newModel, toCmd (Exit newModel.participant) )
    ```
    ```
    Exit participant ->
        ( model, Cmd.none )
    ```
    
## Einbinden in das Hauptprogramm

Erst einmal bis auf den Rumpf alles aus dem Hauptprogramm entfernen.

Danach das Modul in den eigenen Lebenszyklus einbinden:

1. Wrapper für Messages des Moduls erstellen
1. Model des Moduls in eigenes Model einbinden
1. `init` Funktion aufrufen
1. `update` Funktion aufrufen
1. `view` Funktion aufrufen
1. `subscriptions` Funktion aufrufen

### Wrapper für Messages des Moduls erstellen
```
type Msg
    = EnterParticipantMsg EnterParticipant.Msg
```

### Model des Moduls in eigenes Model einbinden
```
type alias Model =
    { enterParticipantModel : EnterParticipant.Model }
```

### `init` Funktion aufrufen
```
init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        enterParticipantInit =
            EnterParticipant.init
    in
        ( { enterParticipantModel = first enterParticipantInit }
        , Cmd.map EnterParticipantMsg (second enterParticipantInit)
        )
```

### `update` Funktion aufrufen
```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterParticipantMsg subMsg ->
            let
                enterParticipantUpdate =
                    EnterParticipant.update subMsg model.enterParticipantModel
            in
                ( { enterParticipantModel = first enterParticipantUpdate }
                , Cmd.map EnterParticipantMsg (second enterParticipantUpdate)
                )
```

oder etwas einfacher:
```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterParticipantMsg subMsg ->
            (EnterParticipant.update subMsg model.enterParticipantModel)
                |> mapFirst (\a -> { model | enterParticipantModel = a })
                |> mapSecond (Cmd.map EnterParticipantMsg)
```

oder noch anders:
```
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterParticipantMsg subMsg ->
            (EnterParticipant.update subMsg model.enterParticipantModel)
                |> mapFirst ((flip setEnterParticipantModel) model)
                |> mapSecond (Cmd.map EnterParticipantMsg)
```

### `view` Funktion aufrufen
```
```

### `subscriptions` Funktion aufrufen
```
```
