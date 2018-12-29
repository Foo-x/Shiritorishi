module Test.Reply exposing (suite)

import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as D
import Json.Encode as E
import Reply as Actual
import Test exposing (..)


type alias ExtraWith reply =
    { reply | extra : String }


type alias ReplyWithExtra =
    ExtraWith Actual.Reply


createReplyTestObj : String -> String -> String -> String -> String -> ReplyWithExtra
createReplyTestObj user word actualLastChar upperLastChar extra =
    { user = user
    , word = word
    , actualLastChar = actualLastChar
    , upperLastChar = upperLastChar
    , extra = extra
    }


replyWithExtraFuzzer : Fuzzer ReplyWithExtra
replyWithExtraFuzzer =
    Fuzz.map createReplyTestObj Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.string


suite : Test
suite =
    describe "Reply"
        [ describe "replyDecoder"
            [ fuzz replyWithExtraFuzzer "valid object" <|
                \replyWithExtra ->
                    E.object
                        [ ( "user", E.string replyWithExtra.user )
                        , ( "word", E.string replyWithExtra.word )
                        , ( "actual_last_char", E.string replyWithExtra.actualLastChar )
                        , ( "upper_last_char", E.string replyWithExtra.upperLastChar )
                        , ( "extra", E.string replyWithExtra.extra )
                        ]
                        |> D.decodeValue Actual.replyDecoder
                        |> Expect.ok
            , fuzz replyWithExtraFuzzer "invalid: no user" <|
                \replyWithExtra ->
                    E.object
                        [ ( "word", E.string replyWithExtra.word )
                        , ( "actual_last_char", E.string replyWithExtra.actualLastChar )
                        , ( "upper_last_char", E.string replyWithExtra.upperLastChar )
                        ]
                        |> D.decodeValue Actual.replyDecoder
                        |> Expect.err
            , fuzz replyWithExtraFuzzer "invalid: no word" <|
                \replyWithExtra ->
                    E.object
                        [ ( "user", E.string replyWithExtra.user )
                        , ( "actual_last_char", E.string replyWithExtra.actualLastChar )
                        , ( "upper_last_char", E.string replyWithExtra.upperLastChar )
                        , ( "extra", E.string replyWithExtra.extra )
                        ]
                        |> D.decodeValue Actual.replyDecoder
                        |> Expect.err
            , fuzz replyWithExtraFuzzer "invalid: no actual_last_char" <|
                \replyWithExtra ->
                    E.object
                        [ ( "user", E.string replyWithExtra.user )
                        , ( "word", E.string replyWithExtra.word )
                        , ( "upper_last_char", E.string replyWithExtra.upperLastChar )
                        ]
                        |> D.decodeValue Actual.replyDecoder
                        |> Expect.err
            , fuzz replyWithExtraFuzzer "invalid: no upper_last_char" <|
                \replyWithExtra ->
                    E.object
                        [ ( "user", E.string replyWithExtra.user )
                        , ( "word", E.string replyWithExtra.word )
                        , ( "actual_last_char", E.string replyWithExtra.actualLastChar )
                        ]
                        |> D.decodeValue Actual.replyDecoder
                        |> Expect.err
            ]
        , describe "replyEncoder"
            [ fuzz replyWithExtraFuzzer "has user" <|
                \replyWithExtra ->
                    let
                        userDecoder =
                            D.field "user" D.string
                    in
                    Actual.replyEncoder replyWithExtra.user replyWithExtra.word
                        |> D.decodeValue userDecoder
                        |> (\result ->
                                case result of
                                    Ok ok ->
                                        if ok == replyWithExtra.user then
                                            Expect.pass

                                        else
                                            Expect.fail ok

                                    Err err ->
                                        Expect.fail <| D.errorToString err
                           )
            , fuzz replyWithExtraFuzzer "has word" <|
                \replyWithExtra ->
                    let
                        wordDecoder =
                            D.field "word" D.string
                    in
                    Actual.replyEncoder replyWithExtra.user replyWithExtra.word
                        |> D.decodeValue wordDecoder
                        |> (\result ->
                                case result of
                                    Ok ok ->
                                        if ok == replyWithExtra.word then
                                            Expect.pass

                                        else
                                            Expect.fail ok

                                    Err err ->
                                        Expect.fail <| D.errorToString err
                           )
            ]
        ]
