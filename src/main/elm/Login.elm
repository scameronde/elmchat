module Login exposing (Msg(Login), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import Utils exposing (..)


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
        Login participant ->
            ( model, Cmd.none )

        ChangeName name ->
            let
                newParticipant =
                    model.participant |> setName name

                newModel =
                    model |> setParticipant newParticipant
            in
                ( newModel, Cmd.none )

        PostParticipant participant ->
            ( model, RestClient.postParticipant model.participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                newParticipant =
                    model.participant |> setId id

                newModel =
                    model |> setParticipant newParticipant
            in
                ( newModel, toCmd (Login newParticipant) )

        PostParticipantResult (Err error) ->
            ( model |> setError (toString error), Cmd.none )


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
