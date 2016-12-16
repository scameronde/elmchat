# Elm und WebSockets

Die WebSocket Unterstützung in Elm ist ein zweischneidiges Schwert. Auf der
einen Seite wird einem das ganze Handling der WebSocket Verbindung abgenommen,
auf der anderen Seite wird nur `String` als Payload unterstützt. D.h. man ist
selber für einen vernünftigen Inhalt verantwortlich.

## Aufbau einer WebSocket Verbindung

Lustigerweise ist der dauerhafte Aufbau einer WebSocket Verbindung nicht mit dem
Senden von Messages, sondern mit dem Empfangen von Messages verknüpft. Man muss
quasi den Rücksendekanal deklarieren, um eine dauerhafte Verbindung aufzubauen.
Wenn man nur Senden - also den Hinkanal verwendet - wird die Verbindung wie
bei REST jedesmal neu aufgebaut.

Der Rückkanal wird über eine `Subscription` aufgebaut. Der Subscription muss
der Messagetyp (eigentlich der Messagekonstruktor) mitgegeben werden, der
zum eigentlichen Empfangen der Daten genutzt wird.

Es ist guter Stil, den WebSocket nur so lange offen zu halten, wie er auch
benötigt wird.

Solange der WebSocket offen gehalten wird, sorgt Elm dafür, dass dem auch so ist.
Sollte die Verbindung irgendwie abreißen, baut Elm sie neu auf. Notfalls nutzt
Elm dafür eine mehrstufige Backup Strategie für die Verbindungsart. Sollten
Nachrichten verschickt werden während die Verbindung gerade unten ist, queued
Elm die Nachrichten und verschickt diese nach dem Wiederaufbau.

```elm
type Message
  = ReceiveWebSocketMessage String


subscriptions : Model -> Sub Msg
subscriptions model =
  if (model.isActive == True) then
    WebSocket.listen "ws:/localhost:4567/chat" ReceiveWebSocketMessage
  else
    Sub.none
```

## Empfang von Daten über den WebSocket

Die Daten werden als Message an die `update` Funktion übergeben. Für das Parsing
der Message ist man komplett selbst verantwortlich.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    ReceiveWebSocketMessage message ->
      (model, Cmd.none)

```

## Senden von Daten über den WebSocket

Wie REST Calls kann man nicht direkt Nachrichten an einen WebSocket senden,
da dies ein Seiteneffekt wäre. Stattdessen muss man ein Command absenden.

```elm
sendWSMessage : String -> Cmd Msg
sendWSMessage message =
  WebSocket.send "ws://localhost:4567/chat" message

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    SendWSMessage message ->
      (model, sendWSMessage message)

```
