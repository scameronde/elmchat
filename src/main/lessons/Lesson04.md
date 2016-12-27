# Update Code kürzen

## Functional setters
1. In `Types.elm`
    ```
    setId id model = { model | id = id }
    
    setName name model = { model | name = name }
    ```
   Und danach die vorgeschlagene Typsignatur besprechen.
   
1. Im Hauptprogramm
    ```
    setParticipant participant model = { model | participant = participant }
    
    setError error model = { model | error = error }
    ```
    
    
## `update` vereinfachen
```
ChangeName newName ->
    let
        newModel =
            setParticipant (setName newName model.participant) model
    in
        ( newModel, Cmd.none )
```
```
PostParticipantResult (Ok id) ->
    let
        newModel =
            setParticipant (setId id model.participant) model
    in
        ( newModel, Cmd.none )
```
```
PostParticipantResult (Err error) ->
    let
        newModel =
            setError (toString error) model
    in
        ( newModel, Cmd.none )
```
