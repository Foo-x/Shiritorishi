module Test.Maybe.Ext exposing (suite)

import Expect
import Maybe.Ext as Actual
import Test exposing (..)


suite : Test
suite =
    describe "Maybe.Ext"
        [ describe "flatten"
            [ test "Just in Just" <|
                \_ ->
                    Just (Just 1)
                        |> Actual.flatten
                        |> Expect.equal (Just 1)
            , test "Nothing in Just" <|
                \_ ->
                    Just Nothing
                        |> Actual.flatten
                        |> Expect.equal Nothing
            , test "Nothing" <|
                \_ ->
                    Nothing
                        |> Actual.flatten
                        |> Expect.equal Nothing
            ]
        ]
