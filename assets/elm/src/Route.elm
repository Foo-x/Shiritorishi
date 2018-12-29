module Route exposing (Route(..), fromUrl, href)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)



-- ROUTING


type Route
    = Home
    | Drawing


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map Drawing <| s "drawing"
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    url
        |> parse matchers


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


toString : Route -> String
toString route =
    case route of
        Home ->
            "/"

        Drawing ->
            "/drawing"
