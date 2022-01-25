module Patient.Seriousness exposing (Seriousness, create, encode)
{-|
@docs Seriousness, create, read
-}


{-| Opaque type: must be constructed out of an integer from 1 to 10 -}
type Seriousness
    = Seriousness Int

{-|-}
create : Int -> Maybe Seriousness
create value =
    if value <= 10 && value >= 1 then
        Just (Seriousness value)
    else
        Nothing

{-|-}
encode : Seriousness -> Int
encode (Seriousness value) =
    value