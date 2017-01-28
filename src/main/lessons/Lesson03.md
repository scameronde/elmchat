# JSON, REST und richtige Programme

## Elm <-> JSON

1. Modell erweitern
    1. Datei `Types.elm` anlegen
    1. Typen da rein
        ```
        type Id =
            Id String
        
        
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
        ```

## REST

1. Rest GET erstellen
    1. Datei `Rest.elm` anlegen
    1. GET Request
        ```
        import Http
        import Types exposing (..)
        import Json
        
        
        getParticipant : String -> (Result Http.Error Participant -> msg) -> Cmd msg
        getParticipant participantName msg =
            let
                getParticipantRequest =
                    Http.get ("http://localhost:4567/participant/" ++ participantName) Json.decodeParticipant
            in
                Http.send msg getParticipantRequest
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

## Modell um ```Participant``` erweitern

1. Modell in Name, Participant und Error aufteilen
    ```
    type alias Model =
        { name : String
        , participant : Participant
        , error : String
        }
    ```
     
1. ```init``` anpassen
    ```
    init : Flags -> ( Model, Cmd Msg )
    init flags =
        ( { name = ""
          , participant = { id = Id "", name = "" }
          , error = ""
          }
        , Cmd.none
        )
    ```
    
1. REST Commandos und Messages verbauen
    1. `Msg` um Message für Form-Submit erweitern
        ```
        type Msg
            = GetParticipant
            | GetParticipantResult (Result Http.Error Participant)
            | ChangeName String
        ```
    1. `view` um Form-Submit erweitern
        ```
        [ Html.form [onSubmit GetParticipant]
        ```
    1. `update` das Form-Submit behandeln lassen
        ```
        GetParticipant ->
            ( model, Rest.getParticipant model.name GetParticipantResult )
        ```
    1. `update` das Ergebnis behandeln lassen
        ```
        GetParticipantResult (Ok participant) ->
            ( { model | participant = participant }, Cmd.none )

        GetParticipantResult (Err error) ->
            ( { model | error = (toString error) }, Cmd.none )
        ```


