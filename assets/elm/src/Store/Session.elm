module Store.Session exposing (Session, fromNavKey, navKey)

import Browser.Navigation as Nav



-- MODEL


type alias Session =
    Nav.Key


navKey : Session -> Nav.Key
navKey session =
    session


fromNavKey : Nav.Key -> Session
fromNavKey key =
    key
