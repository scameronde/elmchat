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
    | GetParticipant String
    | GetParticipantResult (Result Http.Error Participant)
    | ChangeName String


type alias Model =
    { name : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( {name = "", error = ""}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName name ->
            ( model |> nameLens.set name, Cmd.none )

        GetParticipant participant ->
            ( model, RestClient.getParticipant model.name GetParticipantResult )

        GetParticipantResult (Ok participant) ->
            ( model , toCmd (Login participant) )

        GetParticipantResult (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )

        -- for external communication
        Login participant ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (GetParticipant model.name) ]
        [ div [ class "form-group" ]
            [ label [ for "nameInput" ] [ text "Your name" ]
            , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
            ]
        , button [ class "btn btn-primary" ] [ text "OK" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
