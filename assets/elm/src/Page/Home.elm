module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Array
import Basics.Ext exposing (flip)
import Browser
import Browser.Dom as Dom
import Browser.Events as BEvents
import Component.Header as Header
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
import Reply exposing (Reply, replyDecoder, replyEncoder)
import Store.Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , publicReplies : List ReplyWithMaxHeight
    , user : String
    , word : String
    , height : Maybe Float
    , userCount : Int
    , userValidity : Validity
    , wordValidity : Validity
    , invalidMessage : String
    , headerModel : Header.Model
    , helpModalModel : HelpModal.Model
    , searchDropdownActiveIndex : Maybe Index
    , isSidebarOpen : Bool
    }


type alias MaxHeightWith a =
    { a | maxHeight : Maybe Float }


type alias ReplyWithMaxHeight =
    MaxHeightWith Reply


replyWithMaxHeightConstructor : Reply -> Maybe Float -> ReplyWithMaxHeight
replyWithMaxHeightConstructor { user, word, actualLastChar, upperLastChar } maxHeight =
    { user = user
    , word = word
    , actualLastChar = actualLastChar
    , upperLastChar = upperLastChar
    , maxHeight = maxHeight
    }


type Validity
    = Valid
    | Invalid


type alias Index =
    Int


init : Session -> ( Model, Cmd Msg )
init session =
    let
        ( headerModel, headerCmd ) =
            Header.init

        ( helpModalModel, helpModalCmd ) =
            HelpModal.init
    in
    ( { session = session

      -- 各項目がガクガクしないようにする
      , publicReplies = [ replyWithMaxHeightConstructor (Reply "\u{3000}" "\u{3000}" "\u{3000}" "\u{3000}") Nothing ]
      , user = "\u{3000}"
      , word = ""
      , height = Nothing
      , userCount = 1
      , userValidity = Valid
      , wordValidity = Valid
      , invalidMessage = ""
      , headerModel = headerModel
      , helpModalModel = helpModalModel
      , searchDropdownActiveIndex = Nothing
      , isSidebarOpen = False
      }
    , Cmd.batch
        [ Cmd.map HeaderMsg headerCmd
        , Cmd.map HelpModalMsg helpModalCmd
        , Websocket.websocketListen ( "room:lobby", "public_replies" )
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
    165


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
            [ class "home-container" ]
            [ Lazy.lazy headerView model.headerModel
            , div
                [ class "columns home-body" ]
                [ div
                    [ id "shi-sidebar"
                    , sidebarClass model.isSidebarOpen
                    ]
                    [ ul
                        [ class "menu-list" ]
                        [ li
                            -- TODO: URLに応じたis-active-pageをつける
                            [ class "is-active-page" ]
                            [ a
                                [ href "/" ]
                                [ span
                                    [ class "icon has-text-grey-light" ]
                                    [ i
                                        [ class "fas fa-home" ]
                                        []
                                    ]
                                , span
                                    [ class "sidebar-item-name has-text-grey-light" ]
                                    [ text "ノーマル" ]
                                ]
                            ]
                        , li
                            []
                            [ a
                                []
                                [ span
                                    [ class "icon has-text-grey-light" ]
                                    [ i
                                        [ class "fas fa-paint-brush" ]
                                        []
                                    ]
                                , span
                                    [ class "sidebar-item-name has-text-grey-light" ]
                                    [ text "お絵描き" ]
                                ]
                            ]
                        , div
                            [ class "is-divider" ]
                            []
                        , li
                            []
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
                                , span
                                    [ class "sidebar-item-name has-text-grey-light" ]
                                    [ text "ルール" ]
                                ]
                            ]
                        ]
                    , Lazy.lazy toggleSidebarButtonView model.isSidebarOpen
                    , Html.map HelpModalMsg <| HelpModal.view model.helpModalModel
                    ]
                , div
                    [ class "column content"
                    , onClick CloseSidebar
                    ]
                    [ section
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
                    ]
                ]
            ]
        ]
    }


headerView : Header.Model -> Html Msg
headerView headerModel =
    Html.map HeaderMsg <| Header.view headerModel


sidebarClass : Bool -> Attribute msg
sidebarClass isSidebarOpen =
    let
        defaultClass =
            "column menu"
    in
    if isSidebarOpen then
        class <| defaultClass ++ " is-open"

    else
        class <| defaultClass


toggleSidebarButtonView : Bool -> Html Msg
toggleSidebarButtonView isSidebarOpen =
    button
        [ id "shi-toggle-sidebar-button"
        , class "button"
        , onClick ToggleSidebar
        ]
        -- 動的にiconを作るとランタイムエラーが発生するので、両方用意してdisplayをtoggleする
        [ span
            [ toggleSidebarButtonIconClass <| not isSidebarOpen ]
            [ i
                [ class "fas fa-lg fa-angle-double-right" ]
                []
            ]
        , span
            [ toggleSidebarButtonIconClass <| isSidebarOpen ]
            [ i
                [ class "fas fa-lg fa-angle-double-left" ]
                []
            ]
        ]


toggleSidebarButtonIconClass : Bool -> Attribute Msg
toggleSidebarButtonIconClass visible =
    let
        defaultClass =
            "icon is-medium has-text-grey-light"
    in
    if visible then
        class <| defaultClass

    else
        class <| defaultClass ++ " display-none"


createHeightStr : Maybe Float -> String
createHeightStr height =
    height
        |> Maybe.map String.fromFloat
        |> Maybe.map (flip (++) "px")
        |> Maybe.withDefault "0px"


latestWord : List ReplyWithMaxHeight -> Html msg
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


allReplies : List ReplyWithMaxHeight -> Maybe Index -> Html Msg
allReplies publicReplies activeIndex =
    let
        indexedReplies =
            List.indexedMap Tuple.pair publicReplies

        dropdownClassList =
            createDropdownClassList (List.length publicReplies) activeIndex
    in
    tbody [] (List.map2 toReplyLine indexedReplies dropdownClassList |> List.concat)


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
                if thisIndex >= length - 10 then
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


toReplyLine : ( Index, ReplyWithMaxHeight ) -> Attribute Msg -> List (Html Msg)
toReplyLine ( index, reply ) dropdownClass =
    let
        dropdown =
            Dict.get index dropdownTriggerDict
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
                |> List.append [ createDropdownMenu reply.word ]
    in
    [ tr
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
                dropdown
            ]
        ]
    , toSearchWordLine reply.word reply.maxHeight index
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


dropdownTriggerDict : Dict Int (Html Msg)
dropdownTriggerDict =
    List.range 0 publicRepliesMaxLength
        |> List.map
            (\index ->
                ( index
                , div
                    [ class "dropdown-trigger" ]
                    [ button
                        [ class "button transparent"
                        , attribute "aria-haspopup" "true"
                        , attribute "aria-controls" "dropdown-menu"
                        , onClick <| FindSearchWordLineAndToggle index
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
                )
            )
        |> Dict.fromList


toSearchWordLine : String -> Maybe Float -> Index -> Html Msg
toSearchWordLine word maxHeight index =
    tr
        []
        [ td
            [ id <| "shi-search-word-line-parent" ++ String.fromInt index
            , colspan 3
            , attribute "aria-hidden" <|
                case maxHeight of
                    Just _ ->
                        "false"

                    Nothing ->
                        "true"
            ]
            [ div
                [ id <| "shi-search-word-line-child" ++ String.fromInt index
                , class "columns is-multiline is-mobile shi-search-word-line"
                , style "max-height" <|
                    case maxHeight of
                        Just n ->
                            String.fromFloat n ++ "px"

                        Nothing ->
                            ""
                ]
                [ div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/google.png"
                        ("https://www.google.com/search?source=hp&q=" ++ word)
                        "Google"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/google.png"
                        ("https://www.google.com/search?source=hp&tbm=isch&q=" ++ word)
                        "Google 画像"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/google-news.png"
                        ("https://news.google.com/search?q=" ++ word)
                        "Google ニュース"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/wikipedia.png"
                        ("https://ja.wikipedia.org/wiki/" ++ word)
                        "Wikipedia"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/uncyclopedia.ico"
                        ("http://ja.uncyclopedia.info/wiki/" ++ word)
                        "アンサイクロペディア"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/youtube.png"
                        ("https://www.youtube.com/results?search_query=" ++ word)
                        "YouTube"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/twitter.ico"
                        ("https://twitter.com/search?q=" ++ word)
                        "Twitter"
                    ]
                , div
                    [ class "column is-half-mobile is-one-quarter-tablet" ]
                    [ wordSearchItem
                        "/images/brands/instagram.ico"
                        ("https://www.instagram.com/explore/tags/" ++ word)
                        "Instagram"
                    ]
                ]
            ]
        ]


createDropdownMenu : String -> Html Msg
createDropdownMenu word =
    div
        [ class "dropdown-menu"
        , attribute "role" "menu"
        ]
        [ div
            [ class "dropdown-content" ]
            [ wordSearchItem
                "/images/brands/google.png"
                ("https://www.google.com/search?source=hp&q=" ++ word)
                "Google"
            , wordSearchItem
                "/images/brands/google.png"
                ("https://www.google.com/search?source=hp&tbm=isch&q=" ++ word)
                "Google 画像"
            , wordSearchItem
                "/images/brands/google-news.png"
                ("https://news.google.com/search?q=" ++ word)
                "Google ニュース"
            , wordSearchItem
                "/images/brands/wikipedia.png"
                ("https://ja.wikipedia.org/wiki/" ++ word)
                "Wikipedia"
            , wordSearchItem
                "/images/brands/uncyclopedia.ico"
                ("http://ja.uncyclopedia.info/wiki/" ++ word)
                "アンサイクロペディア"
            , wordSearchItem
                "/images/brands/youtube.png"
                ("https://www.youtube.com/results?search_query=" ++ word)
                "YouTube"
            , wordSearchItem
                "/images/brands/twitter.ico"
                ("https://twitter.com/search?q=" ++ word)
                "Twitter"
            , wordSearchItem
                "/images/brands/instagram.ico"
                ("https://www.instagram.com/explore/tags/" ++ word)
                "Instagram"
            ]
        ]


wordSearchItem : String -> String -> String -> Html Msg
wordSearchItem srcStr hrefStr textStr =
    a
        [ class "dropdown-item"
        , href hrefStr
        , target "_blank"
        ]
        -- TODO
        [ img
            [ src srcStr
            , class "is-vmiddle"
            , width 16
            , height 16
            ]
            []
        , p
            [ class "is-size-7" ]
            [ text textStr ]
        ]


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


nextHintPlaceholder : List ReplyWithMaxHeight -> Attribute msg
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
    | GetElementAndUpdateHeight
    | UpdateHeight (Result Dom.Error Dom.Element)
    | UpdateUser String
    | UpdateWord String
      -- About event
    | InactivateDropdown
    | KeyDown Int
    | FindSearchWordLineAndToggle Index
    | ToggleSearchWordLine Index (Result Dom.Error Dom.Viewport)
    | ToggleSidebar
    | CloseSidebar
      -- About LocalStorage
    | ReceiveFromLocalStorage ( String, D.Value )
    | SaveUser String
    | SetStorageGetItem String
      -- About Websocket
    | FetchPublicReplies
    | SendReply String String
    | WebsocketReceive ( String, String, D.Value )
      -- About imported msg
    | HeaderMsg Header.Msg
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

        GetElementAndUpdateHeight ->
            ( model, updateHeight )

        UpdateHeight result ->
            result
                |> Result.map (\element -> { model | height = Just <| calcHeight element })
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

        FindSearchWordLineAndToggle index ->
            let
                toggleSearchWordLine =
                    Task.attempt
                        (ToggleSearchWordLine index)
                        (Dom.getViewportOf <| "shi-search-word-line-child" ++ String.fromInt index)
            in
            ( model, toggleSearchWordLine )

        ToggleSearchWordLine index viewportResult ->
            let
                updatePublicReplies maxHeight =
                    model.publicReplies
                        |> updateListOnly
                            (\reply ->
                                case reply.maxHeight of
                                    Just _ ->
                                        { reply | maxHeight = Nothing }

                                    Nothing ->
                                        { reply | maxHeight = Just maxHeight }
                            )
                            index
                        |> updateListExcept
                            (\reply -> { reply | maxHeight = Nothing })
                            index
            in
            viewportResult
                |> Result.map (.scene >> .height)
                |> Result.map (\maxHeight -> ( { model | publicReplies = updatePublicReplies maxHeight }, Cmd.none ))
                |> Result.withDefault ( model, Cmd.none )

        ToggleSidebar ->
            ( { model | isSidebarOpen = not model.isSidebarOpen }, Cmd.none )

        CloseSidebar ->
            ( { model | isSidebarOpen = False }, Cmd.none )

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
                |> Result.map (\reply -> replyWithMaxHeightConstructor reply Nothing)
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
                |> Result.map (List.map (\reply -> replyWithMaxHeightConstructor reply Nothing))
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

        HeaderMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Header.update subMsg model.headerModel
            in
            ( { model | headerModel = subModel }, Cmd.map HeaderMsg subCmd )

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


updateListOnly : (a -> a) -> Index -> List a -> List a
updateListOnly f index list =
    let
        updateOnly i el =
            if i == index then
                f el

            else
                el
    in
    List.indexedMap updateOnly list


updateListExcept : (a -> a) -> Index -> List a -> List a
updateListExcept f index list =
    let
        updateExcept i el =
            if i /= index then
                f el

            else
                el
    in
    List.indexedMap updateExcept list


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
        , BEvents.onResize (\_ _ -> GetElementAndUpdateHeight)
        ]
