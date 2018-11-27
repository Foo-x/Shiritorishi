module Reply exposing (Reply, replyDecoder, replyEncoder)

import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E



-- MODEL


type alias Reply =
    { user : String
    , word : String
    }


replyDecoder : Decoder Reply
replyDecoder =
    D.succeed Reply
        |> required "user" string
        |> required "word" string


replyEncoder : String -> String -> E.Value
replyEncoder user word =
    E.object
        [ ( "user", E.string user )
        , ( "word", E.string word )
        ]
