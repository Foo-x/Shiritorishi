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
            [ article
                [ class "message" ]
                [ div
                    [ id "help-header"
                    , class "message-header has-text-grey-dark" ]
                    [ p
                        []
                        [ text "ルール" ]
                    , button
                        [ class "delete"
                        , attribute "aria-label" "close"
                        , onClick Inactivate
                        ]
                        []
                    ]
                , div
                    [ id "help-content"
                    , class "message-body content" ]
                    [ ul
                        []
                        [ li
                            []
                            [ text "直前の最後の文字で始める必要があります。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        []
                                        [ text "しりと" ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "り" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "り" ]
                                    , span
                                        []
                                        [ text "んご" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "最後の文字に「ん」や「ン」を使用することはできません。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        [ class "icon is-small has-text-danger" ]
                                        [ i
                                            [ class "fas fa-times" ]
                                            []
                                        ]
                                    , span
                                        []
                                        [ text "ライオ" ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "ン" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "使用できる文字はひらがなとカタカナのみです。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        []
                                        [ text "しりとり" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "icon is-small has-text-danger" ]
                                        [ i
                                            [ class "fas fa-times" ]
                                            []
                                        ]
                                    , span
                                        []
                                        [ text "林檎" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "1文字の単語は使用できません。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        []
                                        [ text "りす" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "icon is-small has-text-danger" ]
                                        [ i
                                            [ class "fas fa-times" ]
                                            []
                                        ]
                                    , span
                                        []
                                        [ text "す" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "直前の50個中に使用されている単語は使用できません。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        [ class "has-text-weight-bold" ]
                                        [ text "りす" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        []
                                        [ text "すきま" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        []
                                        [ text "まり" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "icon is-small has-text-danger" ]
                                        [ i
                                            [ class "fas fa-times" ]
                                            []
                                        ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "りす" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "直前の最後の文字が長音(ー)の場合、その直前の文字で始める必要があります。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        []
                                        [ text "コー" ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "ヒ" ]
                                    , span
                                        []
                                        [ text "ー" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "ひ" ]
                                    , span
                                        []
                                        [ text "まわり" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "直前の最後の文字が小文字の場合、大文字に直した文字で始める必要があります。"
                            , ul
                                []
                                [ li
                                    []
                                    [ span
                                        []
                                        [ text "きし" ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "ゃ" ]
                                    , span
                                        []
                                        [ text " → " ]
                                    , span
                                        [ class "has-text-weight-bold" ]
                                        [ text "や" ]
                                    , span
                                        []
                                        [ text "さい" ]
                                    ]
                                ]
                            ]
                        , li
                            []
                            [ text "名前や単語は20文字以下にする必要があります。" ]
                        ]
                    ]
                ]
            ]
        ]


modalClass : Model -> Html.Attribute msg
modalClass model =
    case model of
        Active ->
            class "modal modal-fx-slideBottom is-active"

        Inactive ->
            class "modal modal-fx-slideBottom"



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
