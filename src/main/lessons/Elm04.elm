module Elm04 exposing (..)

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


setParticipant : a -> { c | participant : a } -> { c | participant : a }
setParticipant participant model =
    { model | participant = participant }


setError : a -> { c | error : a } -> { c | error : a }
setError error model =
    { model | error = error }


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
                newModel =
                    setParticipant (setName newName model.participant) model
            in
                ( newModel, Cmd.none )

        PostParticipant participant ->
            ( model, postParticipant participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                newModel =
                    setParticipant (setId id model.participant) model
            in
                ( newModel, Cmd.none )

        PostParticipantResult (Err error) ->
            let
                newModel =
                    setError (toString error) model
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
