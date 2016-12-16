module EnterParticipantName exposing (Msg(Exit), Model, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import BusinessTypes
import RestClient
import Utils


type Msg
    = Exit BusinessTypes.Participant
    | PostParticipant BusinessTypes.Participant
    | PostParticipantResult (Result Http.Error Int)
    | ChangeName String


type alias Model =
    BusinessTypes.Participant


init : ( Model, Cmd Msg )
init =
    ( { id = 0, name = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Exit participant ->
            ( model, Cmd.none )

        ChangeName name ->
            ( { model | name = name }, Cmd.none )

        PostParticipant participant ->
            ( model, RestClient.postParticipant participant PostParticipantResult )

        PostParticipantResult (Ok id) ->
            let
                newModel =
                    { model | id = id }
            in
                ( newModel, Utils.toCmd (Exit newModel) )

        PostParticipantResult (Err error) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (PostParticipant model) ]
        [ div [ class "form-group" ]
            [ label [ for "nameInput" ] [ text "Dein Name" ]
            , input [ id "nameInput", type_ "text", class "form-control", onInput ChangeName ] []
            ]
        , button [ class "btn btn-primary" ] [ text "OK" ]
        ]
