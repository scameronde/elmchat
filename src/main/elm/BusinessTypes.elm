module BusinessTypes exposing (..)


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
