module Test.Basics.Ext exposing (suite)

import Basics.Ext as Actual
import Expect
import Fuzz exposing (int, string, tuple)
import Test exposing (..)


suite : Test
suite =
    describe "Basics.Ext"
        [ describe "flip"
            [ fuzz (tuple ( string, int )) "flips arguments" <|
                \( first, second ) ->
                    let
                        f a b =
                            ( a, b )
                    in
                    f
                        |> Actual.flip
                        |> (\f_ -> f_ first second)
                        |> Expect.equal ( second, first )
            , fuzz (tuple ( string, int )) "restores original if run twice" <|
                \( first, second ) ->
                    let
                        f a b =
                            ( a, b )
                    in
                    f
                        |> Actual.flip
                        |> Actual.flip
                        |> (\f_ -> f_ first second)
                        |> Expect.equal ( first, second )
            ]
        ]
