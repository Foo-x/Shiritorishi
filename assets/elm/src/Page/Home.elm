module Page.Home exposing (..)

import Browser
import Browser.Dom as Dom
import Component.HelpModal as HelpModal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, keyCode)
import Json.Decode as D
import Json.Encode as E
import Maybe.Ext as MaybeExt
import Ports.Websocket as Websocket
import Ports.LocalStorage as LocalStorage
import Regex exposing (Regex)
import Reply exposing (Reply, replyDecoder, replyEncoder)
import Set exposing (Set)
import Store.Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , publicReplies : List Reply
    , user : String
    , word : String
    , height : Float
    , userCount : Int
    , userValidity : Validity
    , wordValidity : Validity
    , invalidMessage : String
    , helpModalModel : HelpModal.Model
    }


type Validity
    = Valid
    | Invalid


init : Session -> (Model, Cmd Msg)
init session =
    ( { session = session
      -- 各項目がガクガクしないようにする
      , publicReplies = [ Reply "　" "　" "　" "　" ]
      , user = "　"
      , word = ""
      , height = 0
      , userCount = 1
      , userValidity = Valid
      , wordValidity = Valid
      , invalidMessage = ""
      , helpModalModel = HelpModal.Inactive
      }
    , Cmd.batch
        [ Websocket.websocketListen ("room:lobby", "new_msg")
        , Websocket.websocketListen ("room:lobby", "public_replies")
        , Websocket.websocketListen ("room:lobby", "invalid_user")
        , Websocket.websocketListen ("room:lobby", "invalid_word")
        , Websocket.websocketListen ("room:lobby", "valid_word")
        , Websocket.websocketListen ("room:lobby", "presence_diff")
        , LocalStorage.storageGetItem "user"
        ]
    )


footerHeight : Float
footerHeight = 181


publicRepliesMaxLength : Int
publicRepliesMaxLength = 50


defaultUser : String
defaultUser = "名無しりとり"


toSession : Model -> Session
toSession = .session



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
                        [ button
                            [ class "button transparent"
                            , onClick (HelpModalMsg HelpModal.Activate)
                            ]
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
                                        , placeholder defaultUser
                                        , onInput UpdateUser
                                        , value model.user
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
                                    , text <| String.fromInt model.userCount
                                    ]
                                ]
                            ]
                        , div
                            [ id "shi-word"
                            , class "columns is-mobile" ]
                            [ div
                                [ class "column is-11 field has-addons" ]
                                [ div
                                    [ class "control is-expanded" ]
                                    [ input
                                        [ classFromValidity model.wordValidity "input"
                                        , type_ "text"
                                        , nextHintPlaceholder model
                                        , onInput UpdateWord
                                        , onKeyDown KeyDown
                                        , value model.word
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
                        , div
                            [ id "shi-invalid-message"
                            , class "columns is-mobile" ]
                            [ p
                                [ class "column help is-danger" ]
                                [ text model.invalidMessage ]
                            ]
                        ]
                    ]
                ]
            ]
        , Html.map HelpModalMsg <| HelpModal.view model.helpModalModel
        ]
    }


brandLogo : List (Attribute msg)
brandLogo =
    [ src "/images/brand-logo.png"
    , width 125
    , height 32
    ]


createHeightStr : Model -> String
createHeightStr { height } =
    String.fromFloat height ++ "px"


latestWord : Model -> Html msg
latestWord { publicReplies } =
    let
        head =
            List.head publicReplies
    in
    case head of
        Just reply ->
            text reply.word

        Nothing ->
            -- 区切り線がガクガクしないようにする
            text "　"


allReplies : Model -> List (Html msg)
allReplies { publicReplies } =
    List.map toReplyLine publicReplies


myFind : String -> String -> List Regex.Match
myFind regexStr string =
    case Regex.fromString regexStr of
        Just regex ->
            Regex.find regex string

        Nothing ->
            []


splitForLastChar : String -> String -> (String, String, Maybe String)
splitForLastChar word actualLastChar =
    case myFind ("(.*)" ++ actualLastChar ++ "(.*)") word of
        head :: _ ->
            case head.submatches of
                maybeFirst :: maybeSecond :: _ ->
                    (Maybe.withDefault "" maybeFirst, actualLastChar, maybeSecond)

                _ ->
                    ( "", "", Nothing )

        _ ->
            ( "", "", Nothing )


toReplyWord : String -> String -> List (Html msg)
toReplyWord word actualLastChar =
    case splitForLastChar word actualLastChar of
        ( initStr, lastStr, Nothing ) ->
            untilLastChar initStr lastStr

        ( initStr, lastStr, Just ignored ) ->
            List.append (untilLastChar initStr lastStr)
                [ span
                    []
                    [ text ignored ]
                ]


untilLastChar initStr lastStr =
    [ span
        []
        [ text initStr ]
    , span
        [ class "has-text-weight-bold" ]
        [ text lastStr ]
    ]


toReplyLine : Reply -> Html msg
toReplyLine reply =
    tr
        []
        [ th
            [ class "shi-primary-dark-text" ]
            [ text reply.user ]
        , td
            []
            (toReplyWord reply.word reply.actualLastChar)
        ]


nextHintPlaceholder : Model -> Attribute msg
nextHintPlaceholder { publicReplies } =
    let
        maybeLastChar =
            publicReplies
                |> List.head
                |> Maybe.map (\reply -> reply.upperLastChar)
    in
    case maybeLastChar of
        Just lastChar ->
            placeholder <| lastChar ++ " ..."

        Nothing ->
            placeholder "..."


classFromValidity : Validity -> String -> Attribute msg
classFromValidity validity base =
    case validity of
        Valid ->
            class base

        Invalid ->
            class <| base ++ " " ++ "is-danger"


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (D.map tagger keyCode)


-- UPDATE


type Msg
    = WebsocketReceive (String, String, D.Value)
    | UpdateUser String
    | UpdateWord String
    | UpdateHeight (Result Dom.Error Dom.Element)
    | ClearUserValidity
    | ClearWordValidity
    | KeyDown Int
    | SendReply String String
    | HelpModalMsg HelpModal.Msg
    | ReceiveFromLocalStorage (String, D.Value)
    | SaveUser String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        WebsocketReceive ("room:lobby", "new_msg", payload) ->
            D.decodeValue replyDecoder payload
                |> Result.map (\reply -> reply :: model.publicReplies)
                |> Result.map (List.take publicRepliesMaxLength)
                |> Result.map (\publicReplies -> { model | publicReplies = publicReplies })
                |> Result.map (\newModel -> ( newModel, updateHeight ))
                |> Result.withDefault ( model, Cmd.none )

        WebsocketReceive ("room:lobby", "public_replies", payload) ->
            D.decodeValue repliesDecoder payload
                |> Result.map (List.take publicRepliesMaxLength)
                |> Result.map (\publicReplies -> { model | publicReplies = publicReplies })
                |> Result.map (\newModel -> ( newModel, updateHeight ))
                |> Result.withDefault ( model, Cmd.none )

        WebsocketReceive ("room:lobby", "invalid_user", payload) ->
            D.decodeValue messageDecoder payload
                |> Result.map (\message -> { model | invalidMessage = message, userValidity = Invalid })
                |> Result.withDefault model
                |> \newModel -> ( newModel, Cmd.none )

        WebsocketReceive ("room:lobby", "invalid_word", payload) ->
            D.decodeValue messageDecoder payload
                |> Result.map (\message ->
                    if model.userValidity == Invalid then
                        { model | wordValidity = Invalid}
                    else
                        { model | invalidMessage = message, wordValidity = Invalid })
                |> Result.withDefault model
                |> \newModel -> ( newModel, Cmd.none )

        WebsocketReceive ("room:lobby", "valid_word", payload) ->
            ( { model
              | word = ""
              , invalidMessage = ""
              }
            , Cmd.none
            )
                |> andThen (SaveUser model.user)

        WebsocketReceive ("room:lobby", "presence_diff", payload) ->
            D.decodeValue userCountDecoder payload
                |> Result.map (\userCount -> { model | userCount = userCount })
                |> Result.withDefault model
                |> \newModel -> ( newModel, Cmd.none )

        WebsocketReceive (_, _, _) ->
            ( model, Cmd.none )

        UpdateUser user ->
            ( { model | user = user }, Cmd.none )
                |> andThen ClearUserValidity

        UpdateWord word ->
            ( { model | word = word }, Cmd.none )
                |> andThen ClearWordValidity

        UpdateHeight result ->
            result
                |> Result.map (\element -> { model | height = calcHeight element })
                |> Result.withDefault model
                |> \newModel -> ( newModel, Cmd.none )

        ClearUserValidity ->
            ( { model | userValidity = Valid }, Cmd.none )

        ClearWordValidity ->
            ( { model | wordValidity = Valid }, Cmd.none )

        KeyDown key ->
            case key of
                13 ->
                    ( model, Cmd.none )
                        |> andThen (SendReply model.user model.word)
                _ ->
                    ( model, Cmd.none )

        SendReply user word ->
            let
                actualUser =
                    if String.isEmpty user then defaultUser else user
            in
            ( model, Websocket.websocketSend ( "room:lobby", "new_msg", replyEncoder actualUser word ) )

        HelpModalMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    HelpModal.update subMsg model.helpModalModel
            in
            ( { model | helpModalModel = subModel }, Cmd.map HelpModalMsg subCmd )

        ReceiveFromLocalStorage ("user", value) ->
            D.decodeValue (D.nullable D.string) value
                |> Result.toMaybe
                |> MaybeExt.flatten
                -- placeholderを表示させる
                |> Maybe.withDefault ""
                |> \user -> ( { model | user = user }, Cmd.none )

        ReceiveFromLocalStorage (_, _) ->
            ( model, Cmd.none )

        SaveUser user ->
            ( model, LocalStorage.storageSetItem ("user", E.string user))


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
    D.at ["data"] D.string


userCountDecoder : D.Decoder Int
userCountDecoder =
    D.at ["user_count"] D.int


andThen : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen nextMsg ( previousModel, previousCmd ) =
    let
        ( newModel, newCmd ) =
            update nextMsg previousModel
    in
    ( newModel, Cmd.batch [ previousCmd, newCmd ] )


-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Websocket.websocketReceive WebsocketReceive
        , LocalStorage.storageGetItemResponse ReceiveFromLocalStorage
        ]
