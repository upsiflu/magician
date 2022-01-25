module Patient.Path exposing (Path, view)

{-|

@docs Path, view

-}


import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)

import Vector2d exposing (Vector2d)
import Point2d exposing (Point2d)
import Length exposing (Meters)

import Patient exposing (Patient)

import Country exposing (Vector)



{-| In a path, the **implied** initial and terminal "patient" is the tower. This makes it a Polygon2D. -}
type alias Path = List (Vector, Patient)

{-|-}
view : Path -> Html msg
view path = text "(Path view)"