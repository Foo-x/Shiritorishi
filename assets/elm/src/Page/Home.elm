module Page.Home exposing (..)

import Browser
import Html exposing (Html, a, div, i, img, nav, section, span, text)
import Html.Attributes exposing (attribute, class, height, href, id, src, width)



-- VIEW


view : Browser.Document msg
view =
    { title = "しりとりし"
    , body =
        [ nav
            [ class "navbar shi-navbar"
            , attribute "role" "navigation"
            , attribute "aria-label" "main navigation"
            ]
            [ div 
                [ class "navbar-brand" ]
                [ a
                    [ class "navbar-item"
                    , href "/"
                    ]
                    [ img
                        [ src "/images/brand-logo.svg"
                        , width 32
                        , height 32
                        ]
                        []
                    ]
                ]
            , div
                [ id "shi-navbar-menu"
                , class "navbar-menu is-active"
                ]
                [ div
                    [ class "navbar-end" ]
                    [ div
                        [ class "navbar-item" ]
                        -- TODO: ヘルプ画面実装
                        [ a
                            [ class "button transparent" ]
                            [ span
                                [ class "icon has-text-grey-light" ]
                                [ i
                                    [ class "fas fa-question-circle" ]
                                    []
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , section
            [ class "section" ]
            [ div
                [ class "container" ]
                [ text "Hello World!" ]
            ]
        ]
    }
