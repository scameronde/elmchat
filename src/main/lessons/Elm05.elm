module Elm05 exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import EnterParticipant
import Tuple exposing (..)


type alias Flags =
    { debug : Bool }


type Msg
    = EnterParticipantMsg EnterParticipant.Msg


type alias Model =
    { enterParticipantModel : EnterParticipant.Model }


setEnterParticipantModel : a -> { c | enterParticipantModel : a } -> { c | enterParticipantModel : a }
setEnterParticipantModel enterParticipantModel model =
    { model | enterParticipantModel = enterParticipantModel }


init : Flags -> ( Model, Cmd Msg )
init flags =
    EnterParticipant.init
        |> mapFirst (\a -> { enterParticipantModel = a })
        |> mapSecond (Cmd.map EnterParticipantMsg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterParticipantMsg subMsg ->
            (EnterParticipant.update subMsg model.enterParticipantModel)
                |> mapFirst ((flip setEnterParticipantModel) model)
                |> mapSecond (Cmd.map EnterParticipantMsg)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "debug" ] [ text <| toString model ]
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
