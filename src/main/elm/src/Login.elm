module Login exposing (Msg(..), Model, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes exposing (..)
import RestClient
import Toolbox.Cmd exposing (..)


type Msg
    = Login Participant
    | GetParticipant
    | GetParticipantResult (Result Http.Error Participant)
    | ChangeName String


type alias Model =
    { name : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( { name = "", error = "" }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName name ->
            ( model
                |> nameLens.set name
                |> errorLens.set
                    (if String.isEmpty name then
                        ""
                     else
                        model.error
                    )
            , Cmd.none
            )

        GetParticipant ->
            ( model, RestClient.getParticipant model.name GetParticipantResult )

        GetParticipantResult (Ok participant) ->
            ( model, toCmd (Login participant) )

        GetParticipantResult (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )

        -- for external communication
        Login participant ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div [ class "alert alert-danger", hidden (noError model) ] [ text "Wrong Credentials!" ]
        , Html.form [ onSubmit GetParticipant ]
            [ div [ class "form-group" ]
                [ label [ for "nameInput" ] [ text "Your name" ]
                , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
                ]
            , button [ class "btn btn-primary", disabled (noName model) ] [ text "OK" ]
            ]
        ]


noError : Model -> Bool
noError model =
    String.isEmpty model.error


noName : Model -> Bool
noName model =
    String.isEmpty model.name


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
