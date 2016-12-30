module SideeffectWithError exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http
import Random


type alias Model =
    Int

type alias User = String

type alias UserId = String

type Msg
    = RestPost User
    | RestPostResult (Result Http.Error UserId)


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RestPost user ->
            ( model, RestClient.postUser user )

        RestPostResult (Ok userId) ->
            (model, Cmd.none)

        RestPostResult (Err error) ->
            (model, Cmd.none)


view : Model -> Html Msg
view model =
    div []
        [ span [] [ text (toString model) ]
        , button [ onClick RestPost "" ] [ text "New random value" ]
        ]


subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
