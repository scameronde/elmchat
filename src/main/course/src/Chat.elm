module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    String


type Msg
    = NewName Fields String
    | Login

type Fields = Name


init : ( Model, Cmd Msg )
init =
    ( "", Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ Html.form [ onSubmit Login ]
            [ div [ class "form-group" ]
                [ label [ for "nameInput" ] [ text "Your name" ]
                , input [ id "nameInput", class "form-control", value model, onInput (NewName Name) ] []
                ]
            , button [ class "btn btn-primary" ] [ text "Login" ]
            ]
        , div [ class "debug" ] [ text model ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewName Name value ->
            ( value, Cmd.none )

        Login ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
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
