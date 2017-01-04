module BusinessTypes exposing (..)

import Lens exposing (..)


type alias Id =
    String


type alias Participant =
    { id : Id
    , name : String
    }


type alias ChatRoom =
    { id : Id
    , title : String
    }


type alias ChatRegistration =
    { participant : Participant
    , chatRoom : ChatRoom
    }


type alias Message =
    { message : String
    }


type alias MessageLog =
    { messageLog : String
    }


type ChatCommand
    = Register ChatRegistration
    | NewMessage Message



-- Utilities to make the handling of the busioness types easier


type alias Identifyable a =
    { a | id : Id }


setId : Id -> Identifyable a -> Identifyable a
setId id record =
    { record | id = id }


setName : b -> { a | name : b } -> { a | name : b }
setName name record =
    { record | name = name }


setTitle : b -> { a | title : b } -> { a | title : b }
setTitle title record =
    { record | title = title }


setParticipant : b -> { a | participant : b } -> { a | participant : b }
setParticipant participant record =
    { record | participant = participant }


setChatRoom : b -> { a | chatRoom : b } -> { a | chatRoom : b }
setChatRoom chatRoom record =
    { record | chatRoom = chatRoom }


setMessage : b -> { a | message : b } -> { a | message : b }
setMessage message record =
    { record | message = message }


setMessageLog : b -> { a | messageLog : b } -> { a | messageLog : b }
setMessageLog messageLog record =
    { record | messageLog = messageLog }


setError : b -> { a | error : b } -> { a | error : b }
setError error record =
    { record | error = error }


idLens : Lens { b | id : a } a
idLens =
    Lens .id (\a b -> { b | id = a })


nameLens : Lens { b | name : a } a
nameLens =
    Lens .name (\a b -> { b | name = a })


titleLens : Lens { b | title : a } a
titleLens =
    Lens .title (\a b -> { b | title = a })


participantLens : Lens { a | participant : b } b
participantLens =
    Lens .participant (\a b -> { b | participant = a })


chatRoomLens : Lens { b | chatRoom : a } a
chatRoomLens =
    Lens .chatRoom (\a b -> { b | chatRoom = a })


messageLens : Lens { b | message : a } a
messageLens =
    Lens .message (\a b -> { b | message = a })


messageLogLens : Lens { b | messageLog : a } a
messageLogLens =
    Lens .messageLog (\a b -> { b | messageLog = a })


errorLens : Lens { b | error : a } a
errorLens =
    Lens .error (\a b -> { b | error = a })
