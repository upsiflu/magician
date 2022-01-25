module Seriousness exposing (Seriousness, create, read)
{-|
@docs Seriousness, create, read
-}


{-| Opaque type: must be constructed 1 and 10 -}
type Seriousness
    = Seriousness Int

{-|-}
create : Int -> Maybe Seriousness
create value =
    if value < 11 && value > 0 then
        Just (Seriousness value)
    else
        Nothing

{-|-}
read : Seriousness -> Int
read (Seriousness value) =
    value