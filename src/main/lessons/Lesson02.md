# Beginners Program

Eine einfache Seite mit einem Label, einem Feld und einem Button,
all das in einer Form.

## Einen View bauen

1. Einfaches HTML Template für das was wir vorhaben
    ```
        Html.form []
            [ div []
                [ label [] []
                , input [] []
                ]
            , button [] []
            ]
    ```

1. Label, Input und Button füllen 
    ```
        Html.form []
            [ div []
                [ label [] [ text "Eingabe: " ]
                , input [] []
                ]
            , button [] [ text "OK" ]
            ]
    ```

1. Beziehung zwischen Label und Input herstellen
    ```
        Html.form []
            [ div []
                [ label [ for "myInput" ] [ text "Eingabe: " ]
                , input [ id "myInput" ] []
                ]
            , button [] [ text "OK" ]
            ]
    ```
  
1. Ein wenig Bootstrap Styling
    ```
        div [ class "container" ]
            [ Html.form []
                [ div [ class "form-group" ]
                    [ label [ for "myInput" ] [ text "Eingabe: " ]
                    , input [ id "myInput", class "form-control" ] []
                    ]
                , button [ class "btn btn-primary" ] [ text "OK" ]
                ]
            ]
    ```
  
1. Und eine Debug-Ausgabe hinzufügen
    ```
            , div [ class "debug" ] [ text <| toString model ]
    ```
  
## Ein Model bauen und mit dem View verbinden

1. Modelldefinition
    ```
    type alias Model =
        { name : String }
    ```
    
1. Modellinitialisierung
    ```
    model : Model
    model =
        { name = "" }
    ```

1. Modell mit View verbinden
    ```
    , input [ id "myInput", class "form-control", value model.name] []
    ```
    
    TESTEN!
    
1. View mit Modell verbinden
    ```
    , input [ id "myInput", class "form-control", value model.name, onInput ChangeName] []
    ```
    
    ```
    type Msg
        = ChangeName String
    ```
    
    UNBEDINGT TESTEN!!! (lustiger Effekt)
    
1. Modell aktualisieren
    ```
    update : Msg -> Model -> Model
    update msg model =
        case msg of
            ChangeName newName ->
                { model | name = newName }
    ```
    
    TESTEN!