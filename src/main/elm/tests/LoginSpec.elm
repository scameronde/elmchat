module LoginSpec exposing (..)

import Tuple exposing (..)
import Test exposing (..)
import Expect exposing (..)
import Fuzz exposing (..)
import ElmTestBDDStyle exposing (..)
import Dict
import Login
import Http
import BusinessTypes
import Utils


all : Test
all =
    describe "Login test suite"
        [ it "initializes an empty model" <|
            expect Login.init
                to
                equal
                ( { error = ""
                  , participant =
                        { id = ""
                        , name = ""
                        }
                  }
                , Cmd.none
                )
        , fuzz (string) "Change name results in new participant name" <|
            \newName ->
                let
                    initialModel =
                        Login.init |> first

                    updatedModel =
                        Login.update (Login.ChangeField Login.Name newName) initialModel |> first
                in
                    expect updatedModel.participant.name to equal newName
        , fuzz (string) "On successful REST Post it deliveres new model with new id" <|
            \newId ->
                let
                    initialModel =
                        Login.Model "" (BusinessTypes.Participant "" "")

                    updatedModel =
                        Login.update (Login.GetParticipantResult (Ok newId)) initialModel |> first
                in
                    expect updatedModel.participant.id to equal newId
        , fuzz2 string string "On successful REST Post the model name is unchanged" <|
            \newId initialName ->
                let
                    initialModel =
                        Login.Model "" (BusinessTypes.Participant "" initialName)

                    updatedModel =
                        Login.update (Login.GetParticipantResult (Ok newId)) initialModel |> first
                in
                    expect updatedModel.participant.name to equal initialName
        , fuzz2 httpError string "On unsuccessful REST Post the model name is unchanced" <|
            \error initialName ->
                let
                    initialModel =
                        Login.Model "" (BusinessTypes.Participant "" initialName)

                    updatedModel =
                        Login.update (Login.GetParticipantResult (Err error)) initialModel |> first
                in
                    expect updatedModel.participant.name to equal initialName
        ]


httpError : Fuzzer Http.Error
httpError =
    frequencyOrCrash
        [ ( 1, map (Http.BadUrl) string )
        , ( 1, constant Http.Timeout )
        , ( 1, constant Http.NetworkError )
        , ( 1
          , map2
                (\x y ->
                    Http.BadStatus
                        { url = ""
                        , status = { code = x, message = y }
                        , headers = Dict.empty
                        , body = ""
                        }
                )
                int
                string
          )
        , ( 1
          , map3
                (\x y z ->
                    Http.BadPayload x
                        { url = ""
                        , status = { code = y, message = z }
                        , headers = Dict.empty
                        , body = ""
                        }
                )
                string
                int
                string
          )
        ]
