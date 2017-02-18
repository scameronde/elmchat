module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { name : String, error : String }


type Msg
    = NewValue Field String
    | Login


type Field
    = Name


init : ( Model, Cmd Msg )
init =
    ( { name = "", error = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewValue Name value ->
            ( { model | name = value }, Cmd.none )

        Login ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ class "view-area" ]
        [ Html.form [ onSubmit Login ]
            [ div [ class "form-group" ]
                [ label [ for "nameInput" ] [ text "Your name" ]
                , input [ id "nameInput", class "form-control", value model.name, onInput (NewValue Name) ] []
                ]
            , button [ class "btn btn-primary" ] [ text "Login" ]
            ]
        , div [ class "debug" ] [ text <| toString model ]
        ]


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
