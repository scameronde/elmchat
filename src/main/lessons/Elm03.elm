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
    { participant : Participant
    , error : String
    }


type Msg
    = ChangeName String
    | PostParticipant Participant
    | PostParticipantResult (Result Http.Error Id)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { participant = { id = "", name = "" }, error = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName newName ->
            let
                participant =
                    model.participant

                newParticipant =
                    { participant | name = newName }

                newModel =
                    { model | participant = newParticipant }
            in
                ( newModel, Cmd.none )

        PostParticipant participant ->
            ( model, postParticipant participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                participant =
                    model.participant

                newParticipant =
                    { participant | id = id }

                newModel =
                    { model | participant = newParticipant }
            in
                ( newModel, Cmd.none )

        PostParticipantResult (Err error) ->
            let
                newModel =
                    { model | error = toString error }
            in
                ( newModel, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit (PostParticipant model.participant) ]
            [ div [ class "form-group" ]
                [ label [ for "myInput" ] [ text "Eingabe: " ]
                , input [ id "myInput", class "form-control", value model.participant.name, onInput ChangeName ] []
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
