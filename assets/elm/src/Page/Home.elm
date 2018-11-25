module Page.Home exposing (..)

import Browser
import Html exposing (Html, a, div, i, img, input, label, nav, p, section, span, text)
import Html.Attributes exposing (attribute, class, height, href, id, placeholder, src, type_, width)



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
                        [ src "/images/brand-logo.png"
                        , width 125
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
                [ div
                    [ class "is-size-1 has-text-centered has-text-weight-bold" ]
                    [ p
                        [ class "break-word" ]
                        -- TODO: 動的にする
                        [ text "かちょうふうげつ" ]
                    ]
                , div
                    [ class "columns is-mobile" ]
                    [ div
                        [ class "column is-offset-1" ]
                        [ div
                            [ id "shi-name"
                            , class "columns is-mobile"
                            ]
                            [ div
                                [ id "shi-name-field"
                                , class "column is-5 field"
                                ]
                                [ label
                                    [ class "label is-small" ]
                                    [ text "名前" ]
                                , div
                                    [ class "control" ]
                                    [ input
                                        [ class "input is-small"
                                        , type_ "text"
                                        , placeholder "名無し"
                                        ]
                                        []
                                    ]
                                ]
                            , div
                                [ class "column is-2 is-offset-4 relative" ]
                                [ div
                                    [ id "shi-user-counts"
                                    , class "is-size-7 has-text-grey"
                                    ]
                                    [ span
                                        [ class "icon is-small" ]
                                        [ i
                                            [ class "fas fa-user" ]
                                            []
                                        ]
                                    -- TODO: 動的にする
                                    , text "12"
                                    ]
                                ]
                            ]
                        , div
                            [ class "columns is-mobile" ]
                            [ div
                                [ class "column is-11 field has-addons" ]
                                [ div
                                    [ class "control is-expanded" ]
                                    [ input
                                        [ class "input"
                                        , type_ "text"
                                        -- TODO: 動的にする
                                        , placeholder "つ ..."
                                        ]
                                        []
                                    ]
                                , div
                                    [ class "control" ]
                                    [ a
                                        [ class "button shi-primary has-text-white has-text-weight-semibold" ]
                                        [ text "送信" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
