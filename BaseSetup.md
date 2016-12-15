# Basic Setup

Für ein neues Projekt benötigen wir drei Dateien:

- `elm-package.json`
- `index.html`
- und irgend eine Elm-Datei

Als Elm-Datei nehmen wir mal Main.elm. Außerdem nutzen wir Bootstrap und jQuery. Beides muss erreichbar sein. Ich kopiere beides gerne direkt in das Projektverzeichnis.

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

Das sollte für eine erste HTML Datei reichen.

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

