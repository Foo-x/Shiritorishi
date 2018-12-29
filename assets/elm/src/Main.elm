module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Drawing as Drawing
import Page.Home as Home
import Page.NotFound as NotFound
import Route exposing (Route)
import Store.Session exposing (Session, fromNavKey)
import Url



-- MODEL


type Model
    = NotFound Session
    | Home Home.Model
    | Drawing Session


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    changeRouteTo (Route.fromUrl url) (NotFound key)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        NotFound session ->
            NotFound.view

        Home home ->
            let
                { title, body } =
                    Home.view home
            in
            { title = title
            , body = List.map (Html.map HomeMsg) body
            }

        Drawing session ->
            Drawing.view



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (toSession model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( HomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home HomeMsg

        ( _, _ ) ->
            ( model, Cmd.none )


toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Drawing session ->
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
            Home.init session
                |> updateWith Home HomeMsg

        Just Route.Drawing ->
            ( Drawing session, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Home _ ->
            Sub.map HomeMsg Home.subscriptions

        _ ->
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
