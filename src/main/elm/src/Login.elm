module Login exposing (Msg(..), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import Toolbox.Cmd exposing (..)
import Toolbox.Lens exposing (..)


type Msg
    = Login Participant
    | PostParticipant Participant
    | PostParticipantResult (Result Http.Error Id)
    | ChangeName String


type alias Model =
    { error : String
    , participant : Participant
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
        ChangeName name ->
            ( (participantLens . nameLens).set name model, Cmd.none )

        PostParticipant participant ->
            ( model, RestClient.postParticipant model.participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            ( (participantLens . idLens).set id model, toCmd (Login (idLens.set id model.participant)) )

        PostParticipantResult (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )

        -- for external communication
        Login participant ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (PostParticipant model.participant) ]
        [ div [ class "form-group" ]
            [ label [ for "nameInput" ] [ text "Your name" ]
            , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
            ]
        , button [ class "btn btn-primary" ] [ text "OK" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
