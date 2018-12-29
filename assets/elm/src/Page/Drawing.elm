module Page.Drawing exposing (view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Route



-- VIEW


view : Browser.Document msg
view =
    { title = "お絵描き | しりとりし"
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
                            [ text "お絵描き" ]
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
