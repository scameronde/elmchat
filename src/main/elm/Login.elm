module Login exposing (Msg(Exit), Model, init, update, view)

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
    { error : String
    , participant : BusinessTypes.Participant
    }


init : ( Model, Cmd Msg )
init =
    ( { error = ""
      , participant =
            { id = ""
            , name = ""
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Exit participant ->
            ( model, Cmd.none )

        ChangeName name ->
            ( { model | participant = BusinessTypes.setName name model.participant }, Cmd.none )

        PostParticipant participant ->
            ( model, RestClient.postParticipant model.participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                newParticipant =
                    BusinessTypes.setId id model.participant
            in
                ( { model | participant = newParticipant }, toCmd (Exit newParticipant) )

        PostParticipantResult (Err error) ->
            ( { model | error = (toString error) }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (PostParticipant model.participant) ]
        [ div [ class "form-group" ]
            [ label [ for "nameInput" ] [ text "Your name" ]
            , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
            ]
        , button [ class "btn btn-primary" ] [ text "OK" ]
        ]
