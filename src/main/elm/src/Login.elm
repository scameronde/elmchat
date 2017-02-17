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
                |> errorLens.set (updatedErrorMessage name model.error)
            , Cmd.none
            )

        GetParticipant ->
            if (model.name |> String.isEmpty) then
                ( model, Cmd.none )
            else
                ( model, RestClient.getParticipant model.name GetParticipantResult )

        GetParticipantResult (Ok participant) ->
            ( model, toCmd (Login participant) )

        GetParticipantResult (Err error) ->
            ( model |> errorLens.set (toString error), Cmd.none )

        -- for external communication
        Login participant ->
            ( model, Cmd.none )


updatedErrorMessage : String -> String -> String
updatedErrorMessage name error =
    (if String.isEmpty name then
        ""
     else
        error
    )


view : Model -> Html Msg
view model =
    div []
        [ viewErrorMsg model "Wrong Credentials!"
        , Html.form [ onSubmit GetParticipant ]
            [ div [ class "form-group" ]
                [ label [ for "nameInput" ] [ text "Your name" ]
                , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
                ]
            , button [ class "btn btn-primary", disabled (noName model) ] [ text "OK" ]
            ]
        ]


viewErrorMsg : Model -> String -> Html Msg
viewErrorMsg model msg =
    if (String.isEmpty model.error) then
        div [] []
    else
        div [ class "alert alert-danger" ] [ text msg ]


noError : Model -> Bool
noError model =
    String.isEmpty model.error


noName : Model -> Bool
noName model =
    String.isEmpty model.name


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
