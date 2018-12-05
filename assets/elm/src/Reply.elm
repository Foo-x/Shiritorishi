module Reply exposing (Reply, replyDecoder, replyEncoder)

import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E



-- MODEL


type alias Reply =
    { user : String
    , word : String
    , actualLastChar : String
    , upperLastChar : String
    }


replyDecoder : Decoder Reply
replyDecoder =
    D.succeed Reply
        |> required "user" string
        |> required "word" string
        |> required "actual_last_char" string
        |> required "upper_last_char" string


replyEncoder : String -> String -> E.Value
replyEncoder user word =
    E.object
        [ ( "user", E.string user )
        , ( "word", E.string word )
        ]
