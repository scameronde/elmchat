module Elm03 exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Types exposing (..)
import Rest exposing (..)


type alias Flags =
    { debug : Bool }


type alias Model =
    { name : String
    , participant : Participant
    , error : String
    }


type Msg
    = GetParticipant
    | GetParticipantResult (Result Http.Error Participant)
    | ChangeName String


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { name = ""
      , participant = { id = Id "", name = "" }
      , error = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName newName ->
            ( { model | name = newName }, Cmd.none )

        GetParticipant ->
            ( model, Rest.getParticipant model.name GetParticipantResult )

        GetParticipantResult (Ok participant) ->
            ( { model | participant = participant }, Cmd.none )

        GetParticipantResult (Err error) ->
            ( { model | error = (toString error) }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit GetParticipant ]
            [ div [ class "form-group" ]
                [ label [ for "myInput" ] [ text "Eingabe: " ]
                , input [ id "myInput", class "form-control", value model.name, onInput ChangeName ] []
                ]
            , button [ class "btn btn-primary" ] [ text "OK" ]
            ]
        , div [ class "debug" ] [ text <| toString model ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
