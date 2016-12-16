# Elm und Polling

Sollte das Server Backend keine WebSockets unterstützen, dann bleibt einem
für regelmäßige Statusaktualisierungen nur Polling. Polling wird über einen
Timer umgesetzt, der - wie WebSockets - über Subscriptions funktioniert.


## Aufsetzten eines regelmäßigen Pollings

Wie bei WebSockets gilt, dass der Timer nur dann aktiv sein sollte, wenn er
auch benötigt wird.

```elm

subscriptions : Model -> Sub Msg
subscriptions model =
  if (model.isActive == True) then
    Time.every Time.second TickTock
  else
    Sub.none


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of ->
    TickTock time ->
      (model, makeARestCall)    
```
