module Test.Route exposing (suite)

import Expect
import Html.Attributes as Attr
import Route as Actual
import Test exposing (..)
import Url


suite : Test
suite =
    describe "Route"
        [ describe "fromUrl"
            [ test "Home" <|
                \_ ->
                    let
                        homeUrl =
                            Url.fromString "http://example.com/"
                    in
                    homeUrl
                        |> Maybe.andThen Actual.fromUrl
                        |> Expect.equal (Just Actual.Home)
            , test "Nothing" <|
                \_ ->
                    let
                        nothingUrl =
                            Url.fromString "http://example.com/foo"
                    in
                    nothingUrl
                        |> Maybe.andThen Actual.fromUrl
                        |> Expect.equal Nothing
            ]
        , describe "href"
            [ test "Home" <|
                \_ ->
                    Actual.href Actual.Home
                        |> Expect.equal (Attr.href "/")
            ]
        ]
