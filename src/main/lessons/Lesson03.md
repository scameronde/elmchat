# JSON, REST und richtige Programme

## Elm <-> JSON

1. Modell erweitern
    1. Datei `Types.elm` anlegen
    1. Typen da rein
        ```
        type alias Id =
            String
        
        
        type alias Participant =
            { id : Id, name : String }
        ```

1. JSON Mapping von Participant erstellen (in eigenem Modul)
    1. Datei ```Json.elm``` anlegen
    1. Elm -> JSON -> Elm
        ```
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
        ```

## REST

1. Rest POST erstellen
    1. Datei `Rest.elm` anlegen
    1. POST Request
        ```
        import Http
        import Types exposing (..)
        import Json
        
        
        postParticipant : Participant -> (Result Http.Error Id -> msg) -> Cmd msg
        postParticipant participant msg =
            let
                postParticipantRequest =
                    Http.post "http://localhost:4567/participant" (participant |> Json.encodeParticipant |> Http.jsonBody) Json.decodeId
            in
                Http.send msg postParticipantRequest
        ```

## Ein richtiges Programm

1. Funktion `main` anpassen
    ```
    main : Program Flags Model Msg
    main =
        Html.programWithFlags
            { init = init
            , view = view
            , update = update
            , subscriptions = subscriptions
            }
    ```
    
1. Funktion `update` anpassen
    ```
    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
        case msg of
            ChangeName newName ->
                ({ model | name = newName }, Cmd.none)
    ```

1. Funktion `model` zu `init` umbauen
    ```
    init : Flags -> (Model, Cmd Msg)
    init flags =
        ({ name = "" }, Cmd.none)
    ```

1. `Subscriptions` einführen
    ```
    subscriptions : Model -> Sub Msg
    subscriptions model = Sub.none
    ```
     
1. Type `Flags` einführen und übergeben
    ```
    type alias Flags =
        { debug : Bool }
    ```
    
    ```
        <script>
          Elm.Elm03.fullscreen({debug : true});
        </script>
    ```

## Auf ```Participant``` umstellen

1. Modell in Participant und Error aufteilen
   ```
   type alias Model =
       { participant : Participant
       , error : String
       }
   ```
     
1. ```init``` anpassen
    ```
    init : Flags -> ( Model, Cmd Msg )
    init flags =
        ( { participant = { id = "", name = "" }, error = "" }, Cmd.none )
    ```
    
1. ```view``` anpassen
    ```
    , input [ id "myInput", class "form-control", value model.participant.name, onInput ChangeName ] []
    ```

1. ```update``` anpassen
    ```
            ChangeName newName ->
                let
                    participant =
                        model.participant
    
                    newParticipant =
                        { participant | name = newName }
    
                    newModel =
                        { model | participant = newParticipant }
                in
                    ( newModel, Cmd.none )
    ```

1. REST Commandos und Messages verbauen
    1. `Msg` um Message für Form-Submit erweitern
        ```
        type Msg
            = ChangeName String
            | PostParticipant Participant
        ```
    1. `view` um Form-Submit erweitern
        ```
        [ Html.form [onSubmit (PostParticipant model.participant)]
        ```
    1. `update` das Form-Submit behandeln lassen
        ```
        PostParticipant participant ->
            ( model, postParticipant participant PostParticipantResult )
        ```
    1. `Msg` um Message für das Ergebnis des POST Requests erweitern
        ```
            | PostParticipantResult (Result Http.Error Id)
        ```
    1. `update` das Ergebnis behandeln lassen
        ```
        PostParticipantResult (Ok id) ->
            let
                participant =
                    model.participant

                newParticipant =
                    { participant | id = id }

                newModel =
                    { model | participant = newParticipant }
            in
                ( newModel, Cmd.none )

        PostParticipantResult (Err error) ->
            let
                newModel =
                    { model | error = toString error }
            in
                ( newModel, Cmd.none )
        ```


