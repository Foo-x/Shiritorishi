module Page.Home exposing (..)

import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Ports.Websocket as Websocket
import Reply exposing (Reply, replyDecoder, replyEncoder)
import Store.Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , publicReplies : List Reply
    , user : String
    , word : String
    , height : Float
    , userValidity : Validity
    , wordValidity : Validity
    }


type Validity
    = Valid
    | Invalid


init : Session -> (Model, Cmd Msg)
init session =
    ( { session = session
      , publicReplies = []
      , user = ""
      , word = ""
      , height = 0
      , userValidity = Valid
      , wordValidity = Valid
      }
    , Cmd.batch
        [ Websocket.websocketListen ("room:lobby", "new_msg")
        , Websocket.websocketListen ("room:lobby", "public_replies")
        , Websocket.websocketListen ("room:lobby", "invalid_word")
        , updateHeight
        ]
    )


brandLogo : List (Attribute msg)
brandLogo =
    [ src "/images/brand-logo.png"
    , width 125
    , height 32
    ]


footerHeight : Float
footerHeight = 147


createHeightStr : Model -> String
createHeightStr model =
    String.fromFloat model.height ++ "px"


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
                    [ class "is-size-2 has-text-centered has-text-weight-bold" ]
                    [ p
                        [ class "break-word" ]
                        [ latestWord model ]
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
                                [ id "shi-replies"
                                , class "column is-11"
                                , style "max-height" (createHeightStr model)
                                ]
                                [ table
                                    [ class "table is-fullwidth" ]
                                    [ tbody
                                        []
                                        (allReplies model)
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
                                        [ classFromValidity model.userValidity "input is-small"
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
                                        [ classFromValidity model.wordValidity "input"
                                        , type_ "text"
                                        , nextHintPlaceholder model
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


latestWord : Model -> Html msg
latestWord model =
    let
        head =
            List.head model.publicReplies
    in
    case head of
        Just reply ->
            text reply.word

        Nothing ->
            text ""


allReplies : Model -> List (Html msg)
allReplies model =
    List.map toReplyLine model.publicReplies


toReplyLine : Reply -> Html msg
toReplyLine reply =
    tr
        []
        [ th
            [ class "shi-primary-dark-text" ]
            [ text reply.user ]
        , td
            []
            [ span
                []
                [ text <| String.dropRight 1 reply.word ]
            , span
                [ class "has-text-weight-bold" ]
                [ text <| String.right 1 reply.word ]
            ]
        ]


nextHintPlaceholder : Model -> Attribute msg
nextHintPlaceholder model =
    let
        head =
            List.head model.publicReplies
    in
    case head of
        Just reply ->
            placeholder <| (String.right 1 reply.word) ++ " ..."

        Nothing ->
            placeholder "..."


classFromValidity : Validity -> String -> Attribute msg
classFromValidity validity base =
    case validity of
        Valid ->
            class base
        
        Invalid ->
            class <| base ++ " " ++ "is-danger"


-- UPDATE


type Msg
    = WebsocketReceive (String, String, D.Value)
    | UpdateUser String
    | UpdateWord String
    | UpdateHeight (Result Dom.Error Dom.Element)
    | ClearWordValidity
    | SendReply String String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        WebsocketReceive ("room:lobby", "new_msg", payload) ->
            case D.decodeValue replyDecoder payload of
                Ok reply ->
                    ( { model | publicReplies = reply :: model.publicReplies }, updateHeight )

                Err _ ->
                    ( model, Cmd.none )

        WebsocketReceive ("room:lobby", "public_replies", payload) ->
            case D.decodeValue repliesDecoder payload of
                Ok publicReplies ->
                    ( { model | publicReplies = publicReplies }, updateHeight )

                Err _ ->
                    ( model, Cmd.none )

        WebsocketReceive ("room:lobby", "invalid_word", payload) ->
            ( { model | wordValidity = Invalid }, Cmd.none )

        WebsocketReceive (_, _, _) ->
            ( model, Cmd.none )

        UpdateUser user ->
            ( { model | user = user }, Cmd.none )

        UpdateWord word ->
            ( { model | word = word }, Task.perform (\_ -> ClearWordValidity) (Task.succeed ()) )

        UpdateHeight result ->
            case result of
                Ok element ->
                    ( { model | height = calcHeight element }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ClearWordValidity ->
            ( { model | wordValidity = Valid }, Cmd.none )

        SendReply user word ->
            ( model, Websocket.websocketSend ( "room:lobby", "new_msg", replyEncoder user word ) )


updateHeight : Cmd Msg
updateHeight =
    Task.attempt UpdateHeight (Dom.getElement "shi-replies")


calcHeight : Dom.Element -> Float
calcHeight element =
    element.viewport.height - element.element.y - footerHeight


repliesDecoder : D.Decoder (List Reply)
repliesDecoder =
    D.at ["data"] <| D.list replyDecoder


messageDecoder : D.Decoder String
messageDecoder =
    D.at ["data"] <| D.string


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Websocket.websocketReceive WebsocketReceive
