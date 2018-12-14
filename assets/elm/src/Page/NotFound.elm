module Page.NotFound exposing (view)

import Browser
import Html exposing (Html, a, div, h1, section, text)
import Html.Attributes exposing (attribute, class, id)
import Route



-- VIEW


view : Browser.Document msg
view =
    { title = "Page Not Found"
    , body =
        [ section
            [ class "section" ]
            [ div
                [ class "container" ]
                [ div
                    [ id "content", class "columns" ]
                    [ div
                        [ class "column has-text-centered" ]
                        [ h1
                            [ class "title is-1" ]
                            [ text "Page Not Found" ]
                        , a
                            [ class "button"
                            , Route.href Route.Home
                            , attribute "role" "button"
                            ]
                            [ text "Return to Home" ]
                        ]
                    ]
                ]
            ]
        ]
    }
