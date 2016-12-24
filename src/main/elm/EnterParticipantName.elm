module EnterParticipantName exposing (Msg(Exit), Model, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes
import RestClient
import Utils exposing (..)


type Msg
    = Exit BusinessTypes.Participant
    | PostParticipant BusinessTypes.Participant
    | PostParticipantResult (Result Http.Error BusinessTypes.Id)
    | ChangeName String


type alias Model =
    { participant : BusinessTypes.Participant
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( { participant =
            { id = ""
            , name = ""
            }
      , error = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Exit participant ->
            ( model, Cmd.none )

        ChangeName name ->
            let
                oldParticipant =
                    model.participant

                newParticipant =
                    { oldParticipant | name = name }
            in
                ( { model | participant = newParticipant }, Cmd.none )

        PostParticipant participant ->
            ( model, RestClient.postParticipant model.participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                oldParticipant =
                    model.participant

                newParticipant =
                    { oldParticipant | id = id }

                newModel =
                    { model | participant = newParticipant }
            in
                ( newModel, toCmd (Exit newParticipant) )

        PostParticipantResult (Err error) ->
            ( { model | error = toString error }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (PostParticipant model.participant) ]
        [ div [ class "form-group" ]
            [ label [ for "nameInput" ] [ text "Dein Name" ]
            , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
            ]
        , button [ class "btn btn-primary" ] [ text "OK" ]
        ]
