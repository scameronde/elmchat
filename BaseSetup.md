# Basic Setup

Für ein neues Projekt benötigen wir drei Dateien:

- `elm-package.json`
- `index.html`
- und irgend eine Elm-Datei

Die Datei `elm-package.json` beschreibt das Projekt und seine Abhängigkeite.
Es ist vergleichbar mit einer Maven POM Datei.

Die `index.html` ist der Einstieg in den Browser. Der Elm Compiler erzeugt selbst
keine Html Dateien, sondern eine große JavaScript Datei, die den kompletten Code
inklusive aller genutzten Bibliotheken enthält. Diese JavaScript Datei muss
geladen und das Elm Programm gestartet werden. Außerdem wird man in jedem
halbwegs ernst zu nehmenden Client Programm Bootstrap und jQuery einsetzen.
Die werden in der `index.html` ebenfalls geladen. Woher Bootstrap und jQuery
bezogen werden ist abhängig vom Projekt. Für kleinere Sachen kopiere ich beide
einfach in den Projektordner.

Unsere Elm Datei nennen wir mal `Main.elm`. Sie wird unser Hauptprogramm sein.

## `elm-package.json`

Hier eine Beispieldatei:

```json
{
    "version": "1.0.0",
    "summary": "helpful summary of your project, less than 80 characters",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "source-directories": [
        "."
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "elm-lang/html": "2.0.0 <= v < 3.0.0",
        "elm-lang/http": "1.0.0 <= v < 2.0.0",
        "elm-lang/websocket": "1.0.2 <= v < 2.0.0",
        "NoRedInk/elm-decode-pipeline": "3.0.0 <= v < 4.0.0"
    },
    "elm-version": "0.18.0 <= v < 0.19.0"
}
```

## `index.html`

Die Datei lädt Bootstrap, jQuery, eine CSS Datei für das Programm und unseren
Elm Code. Außerdem startet sie unser Elm Programm.

```HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="bootstrap/css/bootstrap.css">
    <link rel="stylesheet" href="main.css">
    <script src="Main.js"></script>
  </head>
  <body>
    <script>
      Elm.Main.fullscreen({debug : true});
    </script>
    <script src="jquery/jquery.js"></script>
    <script src="bootstrap/js/bootstrap.js"></script>
  </body>
</html>
```

## `Main.elm`

Dies ist das Grundgerüst für ein Hauptprogramm.

```elm
module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Flags =
    { debug : Bool }


type Msg
    = None


type alias Model =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text "Hello World!" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

```
