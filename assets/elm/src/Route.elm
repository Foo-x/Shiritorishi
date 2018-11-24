module Route exposing (Route(..), fromUrl, href, matchers)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser exposing (Parser, map, oneOf, top, parse)



-- ROUTING


type Route
    = Home


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top ]


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
