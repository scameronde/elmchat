# Elm Programme modularisieren

Die Grundregel beim Erstellen von Komponenten für Elemente einer Applikation ist:
"Tue es nicht!". Meistens lässt sich das gleiche Ergebnis besser durch eine
einfache Funktion erzielen. Für komplexe Teile einer Applikation - mit eigenem
Modell und Zustandshandling - reicht einfache funktionale Zerlegung aber nicht
mehr aus.

## Aufbau einer Komponente

Teile die als Komponente extrahiert werden sollen, werden in einem
eigenen Elm Modul untergebracht. Jede Komponente muss, damit sie in den
Elm Lifecycle eingebunden werden kann folgende Elemente bereit stellen:

- Typen für Model und Message
- die Funktionen `init`, `update`, `view` und `subscriptions`
- Konstruktoren für Messages, die zur Kommunikation zwischen der Komponente und
  ihrem Nutzer (ab jetzt Parent genannt) verwendet werden.

Eine Komponente kann also wie folgt aussehen:

```elm
module ModuleVorlage exposing (Msg(Exit, Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = Exit String
    | Open String


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

## Einbinden einer Komponente

Eine Komponente muss aktiv von ihrem Parent in den Elm Lifecycle eingebunden werden.
Elm kenn nur die Funktionen `init`, `update`, `view` und `subscriptions` des Hauptprogramms.
Das Hauptprogramm ist dafür verantwortlich alle direkten Kind-Komponenten aktiv einzubinden.
Jede Komponente muss wiederum alle ihre Kind-Komponenten aktiv einbinden. Dies
erfordert auf der einen Seite zwar einigen Boiler-Plate Code, gibt einem auf
der anderen Seite aber volle Kontrolle.

Folgende Patterns haben sich bei meinen Versuchen herausgebildet:

### Einbindung der Models

Ein einem Elm Programm gibt es nur ein einziges Modell. Dieses Modell wird
von der Elm Runtime immer wieder an die `update` Funktion übergeben und von
dieser mutiert. Die Modelle von Komponenten müssen deswegen im Modell des Parents
eingebunden werden.

```elm
type alias Model =
  { komponente1Model : Komponente1.Model
  , komponente2Model : Komponente2.Model
  }
```

### Einbindung der Messages

Ein Elm Programm kennt nur einen Typ von Messages. Diese Messages werden von der
Elm Runtime verwendet, um Nachrichten an die `update` Funktion zu übergeben.
Die Messages von Komponenten müssen deswegen vom Parent in Messages des Parent
verpackt werden.

```elm
type Msg
  = Komponente1Msg Komponente1.Msg
  | Komponente2Msg Komponente2.Msg
```

### Einbindung von `init`

Ein Elm Programm kennt nur eine `init` Funktion. Die `init` Funktion des Parent
muss deswegen die `init` Funktionen aller Komponenten aufrufen und die so erhaltenen
Modelle und Commands einbinden.

Die Modelle der Komponenten müssen im Modell des Parents vermerkt, und die
Commands müssen in Commands des Parents verpackt werden.

```elm
init : Flags -> (Model, Cmd Msg)
init flags =
  let
    initKomponente1 = Komponente1.init |> mapSecond (Cmd.map Komponente1Msg)
    initKomponente2 = Komponente2.init |> mapSecond (Cmd.map Komponente2Msg)
  in
    ( { komponente1Model = first initKomponente1
      , komponente2Model = first initKomponente2
      }
    , Cmd.batch [second initKomponente1, second initKomponente2]
    )
```

### Einbindung von `update`

Ein Elm Programm kennt nur eine `update` Funktion. Die `update` Funktion des
Parent muss deswegen die Messages der Komponenten entpacken und an die `update`
Funktion der Komponenten, gemeinsam mit deren Model, weiter geben. Der Rückgabewert
der `update` Funktion der Komponenten muss wieder in das Modell des Parents
eingebunden und die Commands der Komponenten auf Commands des Parents gemappt
werden.

Manche Messages der Komponenten darf der Parent auch für sich verwerten. Auf
diese Art und Weise kann eine Komponente Werte an den Parent liefern.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Komponente1Msg (Komponente1.Exit value) ->
      (model, Cmd.none) -- hier den value direkt verwerten

    Komponente1Msg subMsg ->
      (Komponente1.update subMsg model.komponente1Model) |> mapFirst (\a -> {model | komponente1Model = a}) |> mapSecond (Cmd.map Komponente1Msg)

    Komponente2Msg subMsg ->
      (Komponente2.update subMsg model.komponente2Model) |> mapFirst (\a -> {model | komponente2Model = a}) |> mapSecond (Cmd.map Komponente2Msg)
```

### Einbindung von `view`

Ein Elm Programm kennt nur eine `view` Funktion. Die `view` Funktion des Parents
muss deswegen die `view` Funktionen der Komponenten einbinden und dabei die
Messages der Komponenten auf eigenen Messages mappen.

```elm
view : Model -> (Html Msg)
view model =
  div []
    [ Html.map Komponente1Msg (Komponente1.view model.komponente1Model)
    , Html.map Komponente2Msg (Komponente2.view model.komponente2Model)
    ]
```

### Einbindung von `subscriptions`

Ein Elm Programm kennt nur eine `subscriptions` Funktion. Die `subscriptions`
Funktion des Parents muss deswegen die `subscriptions` Funktion der Komponenten
einbinden und dabei die Messages der Komponenten auf eigene Messages mappen.

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ Sub.map Komponente1Msg (Komponente1.subscriptions model.komponente1Model)
            , Sub.map Komponente2Msg (Komponente2.subscriptions model.komponente2Model)
            ]
```
