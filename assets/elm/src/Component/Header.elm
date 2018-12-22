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
        ( helpModalModel, helpModalCmd) =
            HelpModal.init
    in
    ( helpModalModel, Cmd.map HelpModalMsg helpModalCmd )



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
            , class "navbar-menu is-active"
            ]
            [ div
                [ class "navbar-end" ]
                [ div
                    [ class "navbar-item" ]
                    [ button
                        [ class "button transparent"
                        , onClick (HelpModalMsg HelpModal.Activate)
                        ]
                        [ span
                            [ class "icon has-text-grey-light" ]
                            [ i
                                [ class "fas fa-info-circle" ]
                                []
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
