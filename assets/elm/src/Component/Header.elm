module Component.Header exposing (Model, Msg, init, update, view)

import Component.HelpModal as HelpModal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    HelpModal.Model


init : ( Model, Cmd Msg )
init =
    let
        ( helpModalModel, helpModalCmd ) =
            HelpModal.init
    in
    ( helpModalModel, Cmd.map HelpModalMsg helpModalCmd )


type alias IconName =
    String


type alias IconText =
    String



-- VIEW


view : Model -> Html Msg
view model =
    nav
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
                    brandLogo
                    []
                ]
            ]
        , div
            [ id "shi-navbar-menu"
            , class "navbar-menu"
            ]
            [ div
                [ class "navbar-start" ]
                [ div
                    [ class "navbar-item is-tab is-active is-active-page" ]
                    [ a
                        [ href "/"
                        , class "button transparent"
                        ]
                        [ iconWithText "fa-home" "ノーマル" ]
                    ]
                , div
                    [ class "navbar-item is-tab" ]
                    [ a
                        [ href "/"
                        , class "button transparent"
                        ]
                        [ iconWithText "fa-paint-brush" "お絵描き" ]
                    ]
                ]
            , div
                [ class "navbar-end" ]
                [ div
                    [ class "navbar-item has-dropdown is-hoverable" ]
                    [ button
                        [ class "navbar-link button transparent is-arrowless"
                        ]
                        [ iconWithText "fa-ellipsis-v" "その他" ]
                    , div
                        [ class "navbar-dropdown is-right" ]
                        [ a
                            [ class "navbar-item" ]
                            [ span
                                [ class "icon has-text-navbar navbar-dropdown-icon" ]
                                [ i
                                    [ class "fas fa-question" ]
                                    []
                                , span
                                    [ class "navbar-dropdown-itemname" ]
                                    [ text "クイズ" ]
                                ]
                            ]
                        , hr
                            [ class "navbar-divider" ]
                            []
                        , button
                            [ class "button transparent navbar-item"
                            , onClick <| HelpModalMsg HelpModal.Activate
                            ]
                            [ span
                                [ class "icon has-text-navbar navbar-dropdown-icon" ]
                                [ i
                                    [ class "fas fa-info-circle" ]
                                    []
                                , span
                                    [ class "navbar-dropdown-itemname" ]
                                    [ text "ルール" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , Html.map HelpModalMsg <| HelpModal.view model
        ]


brandLogo : List (Attribute msg)
brandLogo =
    [ src "/images/brand-logo.png"
    , width 125
    , height 32
    ]


iconWithText : IconName -> IconText -> Html Msg
iconWithText name iconText =
    span
        [ class "icon has-text-navbar" ]
        [ span
            [ class "fa-layers fa-fw" ]
            [ i
                [ class <| "fas " ++ name
                , attribute "data-fa-transform" "up-7"
                ]
                []
            , span
                [ class "fa-layers-text navbar-icon-text"
                , attribute "data-fa-transform" "down-17"
                ]
                [ text iconText ]
            ]
        ]



-- UPDATE


type Msg
    = HelpModalMsg HelpModal.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HelpModalMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    HelpModal.update subMsg model
            in
            ( subModel, Cmd.map HelpModalMsg subCmd )
