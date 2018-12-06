module Component.HelpModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- MODEL


type Model
    = Active
    | Inactive



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ modalClass model ]
        [ div
            [ class "modal-background"
            , onClick Inactivate
            ]
            []
        , div
            [ class "modal-content" ]
            [ div
                [ class "card" ]
                [ div
                    [ class "card-content" ]
                    [ text "hello" ]
                ]
            ]
        , button
            [ class "modal-close is-large"
            , attribute "aria-label" "close"
            , onClick Inactivate
            ]
            []
        ]


modalClass : Model -> Html.Attribute msg
modalClass model =
    case model of
        Active ->
            class "modal is-active"

        Inactive ->
            class "modal"



-- UPDATE


type Msg
    = Activate
    | Inactivate


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Activate ->
            ( Active, Cmd.none )

        Inactivate ->
            ( Inactive, Cmd.none )
