module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Browser
import Browser.Dom as Dom
import Component.HelpModal as HelpModal
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onClick, onInput, stopPropagationOn)
import Html.Lazy as Lazy
import Json.Decode as D
import Json.Encode as E
import Maybe.Ext as MaybeExt
import Ports.LocalStorage as LocalStorage
import Ports.Websocket as Websocket
import Process
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
    , searchDropdownActiveIndex : Maybe Index
    }


type Validity
    = Valid
    | Invalid


type alias Index =
    Int


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session

      -- 各項目がガクガクしないようにする
      , publicReplies = [ Reply "\u{3000}" "\u{3000}" "\u{3000}" "\u{3000}" ]
      , user = "\u{3000}"
      , word = ""
      , height = 0
      , userCount = 1
      , userValidity = Valid
      , wordValidity = Valid
      , invalidMessage = ""
      , helpModalModel = HelpModal.Inactive
      , searchDropdownActiveIndex = Nothing
      }
    , Cmd.batch
        [ Websocket.websocketListen ( "room:lobby", "public_replies" )
        , Websocket.websocketListen ( "room:lobby", "presence_diff" )
        , Task.perform identity (Task.succeed FetchPublicReplies)
        , Task.perform identity (Task.succeed <| SetStorageGetItem "user")
        , Websocket.websocketListen ( "room:lobby", "new_msg" )
        , Websocket.websocketListen ( "room:lobby", "invalid_user" )
        , Websocket.websocketListen ( "room:lobby", "invalid_word" )
        , Websocket.websocketListen ( "room:lobby", "valid_word" )
        ]
    )


footerHeight : Float
footerHeight =
    181


publicRepliesMaxLength : Int
publicRepliesMaxLength =
    50


defaultUser : String
defaultUser =
    "名無しりとり"


toSession : Model -> Session
toSession =
    .session



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "しりとりし"
    , body =
        [ div
            (homeOutsideAttr model.searchDropdownActiveIndex)
            [ div
                [ class "home-inside-container" ]
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
                    , class "section"
                    ]
                    [ div
                        [ class "container" ]
                        [ div
                            [ class "is-size-2 has-text-centered has-text-weight-bold" ]
                            [ p
                                [ class "break-word" ]
                                [ Lazy.lazy latestWord model.publicReplies ]
                            ]
                        , div
                            [ class "is-divider" ]
                            []
                        , div
                            [ id "shi-replies-box"
                            , class "columns is-mobile"
                            ]
                            [ div
                                [ class "column is-offset-1" ]
                                [ div
                                    [ class "columns is-mobile" ]
                                    [ div
                                        [ id "shi-replies"
                                        , class "column is-11"
                                        , style "max-height" (createHeightStr model.height)
                                        ]
                                        [ table
                                            [ class "table is-fullwidth" ]
                                            [ Lazy.lazy2 allReplies model.publicReplies model.searchDropdownActiveIndex ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                , footer
                    [ id "shi-footer"
                    , class "footer"
                    ]
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
                                    , class "columns is-mobile"
                                    ]
                                    [ div
                                        [ class "column is-11 field has-addons" ]
                                        [ div
                                            [ class "control is-expanded" ]
                                            [ input
                                                [ classFromValidity model.wordValidity "input"
                                                , type_ "text"
                                                , nextHintPlaceholder model.publicReplies
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
                                    , class "columns is-mobile"
                                    ]
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
            ]
        ]
    }


brandLogo : List (Attribute msg)
brandLogo =
    [ src "/images/brand-logo.png"
    , width 125
    , height 32
    ]


homeOutsideAttr : Maybe Index -> List (Attribute Msg)
homeOutsideAttr searchDropdownActiveIndex =
    searchDropdownActiveIndex
        |> Maybe.map (always [ on "click" <| D.succeed InactivateDropdown ])
        |> Maybe.withDefault []
        |> (::) (class "home-outside-container")


createHeightStr : Float -> String
createHeightStr height =
    String.fromFloat height ++ "px"


latestWord : List Reply -> Html msg
latestWord publicReplies =
    let
        head =
            List.head publicReplies
    in
    case head of
        Just reply ->
            text reply.word

        Nothing ->
            -- 区切り線がガクガクしないようにする
            text "\u{3000}"


allReplies : List Reply -> Maybe Index -> Html Msg
allReplies publicReplies activeIndex =
    let
        indexedReplies =
            List.indexedMap Tuple.pair publicReplies

        dropdownClassList =
            createDropdownClassList (List.length publicReplies) activeIndex
    in
    tbody [] (List.map2 toReplyLine indexedReplies dropdownClassList)


createDropdownClassList : Int -> Maybe Index -> List (Attribute Msg)
createDropdownClassList length activeIndex =
    case activeIndex of
        Just index ->
            List.range 0 length
                |> List.map3 createDropdownClass (List.repeat length length) (List.repeat length index)

        Nothing ->
            List.repeat length (class searchDropdownClass)


createDropdownClass : Int -> Index -> Index -> Attribute Msg
createDropdownClass length activeIndex thisIndex =
    searchDropdownClass
        |> (\classStr ->
                if thisIndex == length - 1 then
                    classStr ++ " is-up"

                else
                    classStr
           )
        |> (\classStr ->
                if thisIndex == activeIndex then
                    classStr ++ " is-active"

                else
                    classStr
           )
        |> class


searchDropdownClass : String
searchDropdownClass =
    "dropdown is-right"


toReplyLine : ( Index, Reply ) -> Attribute Msg -> Html Msg
toReplyLine ( index, reply ) dropdownClass =
    tr
        []
        [ th
            [ class "shi-primary-dark-text" ]
            [ text reply.user ]
        , td
            []
            (toReplyWord reply.word reply.actualLastChar)
        , td
            [ id "shi-word-search" ]
            [ div
                [ dropdownClass ]
                (Dict.get index wordSearchDict |> Maybe.withDefault [])
            ]
        ]


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


wordSearchDict : Dict Int (List (Html Msg))
wordSearchDict =
    List.range 0 publicRepliesMaxLength
        |> List.map
            (\index ->
                ( index
                , [ div
                        [ class "dropdown-trigger" ]
                        [ button
                            [ class "button transparent"
                            , attribute "aria-haspopup" "true"
                            , attribute "aria-controls" "dropdown-menu"
                            , stopPropagationOn "click" <| D.succeed ( ToggleDropdown index, True )
                            ]
                            [ span
                                [ class "icon" ]
                                [ i
                                    [ class "fas fa-search"
                                    , attribute "aria-hidden" "true"
                                    ]
                                    []
                                ]
                            ]
                        ]
                  , div
                        [ class "dropdown-menu"
                        , attribute "role" "menu"
                        ]
                        [ div
                            [ class "dropdown-content" ]
                            [ a
                                [ class "dropdown-item" ]
                                -- TODO
                                [ text "todo" ]
                            ]
                        ]
                  ]
                )
            )
        |> Dict.fromList


splitForLastChar : String -> String -> ( String, String, Maybe String )
splitForLastChar word actualLastChar =
    if String.endsWith actualLastChar word then
        ( String.left (String.length word - 1) word, actualLastChar, Nothing )

    else
        let
            lastCharIndex =
                String.indices actualLastChar word
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault 0
        in
        ( String.left lastCharIndex word, actualLastChar, Just <| String.dropLeft (lastCharIndex + 1) word )


untilLastChar : String -> String -> List (Html msg)
untilLastChar initStr lastStr =
    [ span
        []
        [ text initStr ]
    , span
        [ class "has-text-weight-bold" ]
        [ text lastStr ]
    ]


nextHintPlaceholder : List Reply -> Attribute msg
nextHintPlaceholder publicReplies =
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
            class <| base ++ " is-danger"


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (D.map tagger keyCode)



-- UPDATE


type Msg
    = NoOp
      -- About Model
    | ClearUserValidity
    | ClearWordValidity
    | UpdateHeight (Result Dom.Error Dom.Element)
    | UpdateUser String
    | UpdateWord String
      -- About event
    | InactivateDropdown
    | KeyDown Int
    | ToggleDropdown Index
      -- About LocalStorage
    | ReceiveFromLocalStorage ( String, D.Value )
    | SaveUser String
    | SetStorageGetItem String
      -- About Websocket
    | FetchPublicReplies
    | SendReply String String
    | WebsocketReceive ( String, String, D.Value )
      -- About imported msg
    | HelpModalMsg HelpModal.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ClearUserValidity ->
            ( { model | userValidity = Valid }, Cmd.none )

        ClearWordValidity ->
            ( { model | wordValidity = Valid }, Cmd.none )

        UpdateHeight result ->
            result
                |> Result.map (\element -> { model | height = calcHeight element })
                |> Result.withDefault model
                |> (\newModel -> ( newModel, Cmd.none ))

        UpdateUser user ->
            ( { model | user = user }, Cmd.none )
                |> andThen ClearUserValidity

        UpdateWord word ->
            ( { model | word = word }, Cmd.none )
                |> andThen ClearWordValidity

        InactivateDropdown ->
            ( { model | searchDropdownActiveIndex = Nothing }, Cmd.none )

        KeyDown key ->
            case key of
                13 ->
                    ( model, Cmd.none )
                        |> andThen (SendReply model.user model.word)

                _ ->
                    ( model, Cmd.none )

        ToggleDropdown index ->
            case model.searchDropdownActiveIndex of
                Just currentIndex ->
                    if currentIndex == index then
                        ( { model | searchDropdownActiveIndex = Nothing }, Cmd.none )

                    else
                        ( { model | searchDropdownActiveIndex = Just index }, Cmd.none )

                Nothing ->
                    ( { model | searchDropdownActiveIndex = Just index }, Cmd.none )

        ReceiveFromLocalStorage ( "user", value ) ->
            D.decodeValue (D.nullable D.string) value
                |> Result.toMaybe
                |> MaybeExt.flatten
                -- placeholderを表示させる
                |> Maybe.withDefault ""
                |> (\user -> ( { model | user = user }, Cmd.none ))

        ReceiveFromLocalStorage ( _, _ ) ->
            ( model, Cmd.none )

        SaveUser user ->
            ( model, LocalStorage.storageSetItem ( "user", E.string user ) )

        SetStorageGetItem key ->
            ( model, LocalStorage.storageGetItem key )

        FetchPublicReplies ->
            ( model, Websocket.websocketSend ( "room:lobby", "fetch_public_replies", E.null ) )

        SendReply user word ->
            let
                actualUser =
                    if String.isEmpty user then
                        defaultUser

                    else
                        user
            in
            ( model, Websocket.websocketSend ( "room:lobby", "new_msg", replyEncoder actualUser word ) )

        WebsocketReceive ( "room:lobby", "invalid_user", payload ) ->
            D.decodeValue messageDecoder payload
                |> Result.map (\message -> { model | invalidMessage = message, userValidity = Invalid })
                |> Result.withDefault model
                |> (\newModel -> ( newModel, Cmd.none ))

        WebsocketReceive ( "room:lobby", "invalid_word", payload ) ->
            D.decodeValue messageDecoder payload
                |> Result.map
                    (\message ->
                        if model.userValidity == Invalid then
                            { model | wordValidity = Invalid }

                        else
                            { model | invalidMessage = message, wordValidity = Invalid }
                    )
                |> Result.withDefault model
                |> (\newModel -> ( newModel, Cmd.none ))

        WebsocketReceive ( "room:lobby", "new_msg", payload ) ->
            D.decodeValue replyDecoder payload
                |> Result.map (\reply -> reply :: model.publicReplies)
                |> Result.map (List.take publicRepliesMaxLength)
                |> Result.map
                    (\publicReplies ->
                        { model
                            | publicReplies = publicReplies
                            , searchDropdownActiveIndex = Nothing
                        }
                    )
                |> Result.map (\newModel -> ( newModel, updateHeight ))
                |> Result.withDefault ( model, Cmd.none )

        WebsocketReceive ( "room:lobby", "presence_diff", payload ) ->
            D.decodeValue userCountDecoder payload
                |> Result.map (\userCount -> { model | userCount = userCount })
                |> Result.withDefault model
                |> (\newModel -> ( newModel, Cmd.none ))

        WebsocketReceive ( "room:lobby", "public_replies", payload ) ->
            D.decodeValue repliesDecoder payload
                |> Result.map (List.take publicRepliesMaxLength)
                |> Result.map
                    (\publicReplies ->
                        { model
                            | publicReplies = publicReplies
                            , searchDropdownActiveIndex = Nothing
                        }
                    )
                |> Result.map (\newModel -> ( newModel, updateHeight ))
                |> Result.withDefault ( model, Cmd.none )

        WebsocketReceive ( "room:lobby", "valid_word", payload ) ->
            ( { model
                | word = ""
                , invalidMessage = ""
              }
            , Cmd.none
            )
                |> andThen (SaveUser model.user)

        WebsocketReceive ( _, _, _ ) ->
            ( model, Cmd.none )

        HelpModalMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    HelpModal.update subMsg model.helpModalModel
            in
            ( { model | helpModalModel = subModel }, Cmd.map HelpModalMsg subCmd )


updateHeight : Cmd Msg
updateHeight =
    Task.attempt UpdateHeight (Dom.getElement "shi-replies")


calcHeight : Dom.Element -> Float
calcHeight element =
    element.viewport.height - element.element.y - footerHeight


repliesDecoder : D.Decoder (List Reply)
repliesDecoder =
    D.at [ "data" ] <| D.list replyDecoder


messageDecoder : D.Decoder String
messageDecoder =
    D.at [ "data" ] D.string


userCountDecoder : D.Decoder Int
userCountDecoder =
    D.at [ "user_count" ] D.int


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
