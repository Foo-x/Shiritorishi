module Maybe.Ext exposing (flatten)


flatten : Maybe (Maybe a) -> Maybe a
flatten mx =
    case mx of
        Just x ->
            x

        Nothing ->
            Nothing
