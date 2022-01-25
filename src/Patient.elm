module Patient exposing (Patient, view)

{-|
@docs Patient, view-}

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)

import Country exposing (Point)

import Seriousness exposing (Seriousness, create, read)

{-|-}
type alias Patient = ( Point, Seriousness )

{-|-}
view : Patient -> Html msg
view patient = text "(Patient view)"