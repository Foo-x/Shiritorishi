module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Page.Home as Home
import Page.NotFound as NotFound
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)
import Store.Session exposing (Session, fromNavKey)
import Url



-- MODEL


type Model
    = NotFound Session
    | Home Session


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    changeRouteTo (Route.fromUrl url) (Home key)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        NotFound session ->
            NotFound.view

        Home session ->
            Home.view



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (toSession model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            changeRouteTo (Route.fromUrl url) model


toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session

        Home session ->
            session


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            ( Home session, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
