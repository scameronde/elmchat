module Chat exposing (Msg(Exit, Open), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import BusinessTypes exposing (..)
import ChatRooms
import ChatRoom


type Msg
    = Exit
    | Open Participant


type alias Model =
    { chatRoomsModel : ChatRooms.Model
    , chatRoomModel : ChatRoom.Model
    }


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
