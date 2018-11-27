module Page.Home exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Ports.Websocket as Websocket
import Reply exposing (Reply, replyDecoder, replyEncoder)
import Store.Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , user : String
    , word : String
    }


init : Session -> (Model, Cmd Msg)
init session =
    ( { session = session
      , user = ""
      , word = ""
      }
    , Websocket.websocketListen ("room:lobby", "new_msg")
    )


toSession : Model -> Session
toSession model =
    model.session



-- VIEW


view : Model -> Browser.Document Msg
view model =
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
            [ id "shi-main"
            , class "section" ]
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
                    [ class "is-divider" ]
                    []
                , div
                    [ class "columns is-mobile" ]
                    [ div
                        [ class "column is-offset-1" ]
                        [ div
                            [ class "columns is-mobile" ]
                            [ div
                                [ class "column is-11" ]
                                [ table
                                    [ class "table is-fullwidth" ]
                                    [ tbody
                                        []
                                        -- TODO: 動的にする
                                        [ tr
                                            []
                                            [ th
                                                -- TODO: widthを動的にする
                                                [ class "shi-primary-dark-text" ]
                                                [ text "名無し" ]
                                            , td
                                                []
                                                [ span
                                                    []
                                                    [ text "すい" ]
                                                , span
                                                    [ class "has-text-weight-bold" ]
                                                    [ text "か" ]
                                                ]
                                            ]
                                        , tr
                                            []
                                            [ th
                                                [ class "shi-primary-dark-text" ]
                                                [ text "名無し" ]
                                            , td
                                                []
                                                [ span
                                                    []
                                                    [ text "から" ]
                                                , span
                                                    [ class "has-text-weight-bold" ]
                                                    [ text "す" ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , footer
            [ id "shi-footer"
            , class "footer" ]
            [ div
                [ class "columns is-mobile" ]
                [ div
                    [ class "column is-offset-1" ]
                    [ div
                        [ class "content" ]
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
                                        , onInput UpdateUser
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
                                        , onInput UpdateWord
                                        ]
                                        []
                                    ]
                                , div
                                    [ class "control" ]
                                    [ button
                                        [ class "button shi-primary has-text-white has-text-weight-semibold"
                                        , onClick (SendReply model.user model.word)
                                        ]
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



-- UPDATE


type Msg
    = WebsocketReceive (String, String, D.Value)
    | UpdateUser String
    | UpdateWord String
    | SendReply String String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        WebsocketReceive ("room:lobby", "new_msg", payload) ->
            case D.decodeValue replyDecoder payload of
                Ok reply ->
                    Debug.log "ok receive" ( model, Cmd.none )
                Err _ ->
                    Debug.log "error receive" ( model, Cmd.none )

        WebsocketReceive (_, _, _) ->
            Debug.log "other msg" ( model, Cmd.none )

        UpdateUser user ->
            ( { model | user = user }, Cmd.none )

        UpdateWord word ->
            ( { model | word = word }, Cmd.none )

        SendReply user word ->
            Debug.log "send reply" ( model, Websocket.websocketSend ( "room:lobby", "new_msg", replyEncoder user word ) )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Websocket.websocketReceive WebsocketReceive
