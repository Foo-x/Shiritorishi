module Basics.Ext exposing (flip)


flip : (b -> a -> c) -> (a -> b -> c)
flip f b a =
    f a b
