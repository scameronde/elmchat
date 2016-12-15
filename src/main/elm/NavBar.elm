module NavBar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


viewNavBar : model -> Html msg
viewNavBar model =
    nav [ class "navbar navbar-inverse navbar-fixed-top" ]
        [ div [ class "container" ]
            [ div [ class "navbar-header" ]
                [ button [ attribute "aria-controls" "navbar", attribute "aria-expanded" "false", class "navbar-toggle collapsed", attribute "data-target" "#navbar", attribute "data-toggle" "collapse", type_ "button" ]
                    [ span [ class "sr-only" ]
                        [ text "Toggle navigation" ]
                    , span [ class "icon-bar" ]
                        []
                    , span [ class "icon-bar" ]
                        []
                    , span [ class "icon-bar" ]
                        []
                    ]
                , a [ class "navbar-brand", href "#" ]
                    [ text "Elm Chat" ]
                ]
            , div [ class "collapse navbar-collapse", id "navbar" ]
                [ ul [ class "nav navbar-nav" ] []
                  {-
                     [ li [ class "active" ]
                         [ a [ href "#" ]
                             [ text "Home" ]
                         ]
                     , li []
                         [ a [ href "#about" ]
                             [ text "About" ]
                         ]
                     , li []
                         [ a [ href "#contact" ]
                             [ text "Contact" ]
                         ]
                     ]
                  -}
                ]
            , text "     "
            ]
        ]


viewMain : List (Html msg) -> Html msg
viewMain elements =
    div [ class "container" ] elements
