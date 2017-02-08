module BusinessTypes exposing (..)

import Toolbox.Lens exposing (..)


type Id
    = Id String


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


idLens : Lens { b | id : a } a
idLens =
    lens .id (\a b -> { b | id = a })


nameLens : Lens { b | name : a } a
nameLens =
    lens .name (\a b -> { b | name = a })


titleLens : Lens { b | title : a } a
titleLens =
    lens .title (\a b -> { b | title = a })


participantLens : Lens { a | participant : b } b
participantLens =
    lens .participant (\a b -> { b | participant = a })


chatRoomLens : Lens { b | chatRoom : a } a
chatRoomLens =
    lens .chatRoom (\a b -> { b | chatRoom = a })


messageLens : Lens { b | message : a } a
messageLens =
    lens .message (\a b -> { b | message = a })


messageLogLens : Lens { b | messageLog : a } a
messageLogLens =
    lens .messageLog (\a b -> { b | messageLog = a })


errorLens : Lens { b | error : a } a
errorLens =
    lens .error (\a b -> { b | error = a })
