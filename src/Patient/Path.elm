module Patient.Path exposing (Path, toggle, ViewMode(..), visited, isRecent, view)

{-|

@docs Path, ViewMode, toggle, visited, isRecent, view

-}

import Maybe.Extra as Maybe
import List.Extra as List

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events exposing (onClick)

import Svg.Styled as Svg
import Svg.Styled.Attributes exposing (..)

import Css exposing (flexGrow)

import Vector2d exposing (Vector2d)
import Point2d exposing (Point2d)
import Polyline2d exposing (Polyline2d)
import Length exposing (Meters)

import Patient exposing (Patient)
import Patient.Cloud as Cloud exposing (Cloud)

import Country exposing (Point, Vector)



{-| In a path, the **implied** initial and terminal "patient" is the tower. This makes it a Polygon2D. 
The second property is the position of the patient in the patients `Cloud`.-}
type alias Path = List Int


{-|-}
toggle : Int -> Path -> Path
toggle i path =
    case path of
        [] -> [i]
        p::pp -> if p == i then pp else i::path

{-|-}
visited : Int -> Path -> Bool
visited = List.member

{-|-}
isRecent : Int -> Path -> Bool
isRecent index = 
    List.head
        >> Maybe.map ( (==) index )
        >> Maybe.withDefault False

toPolygon : Cloud -> Path -> List Point
toPolygon cloud = 
    List.map (\i -> Cloud.at i cloud |> Maybe.map Patient.getPoint )
        >> Maybe.values


{-|-}
type ViewMode
    = OverlaidOver Cloud
    | List

{-|-}
view : ViewMode -> Path -> Html msg
view mode path = 
    case mode of
        OverlaidOver cloud ->
            let
                vertices =
                    toPolygon cloud path
                        |> List.map 
                            ( Point2d.toMeters
                                >> ( \{x, y} -> String.fromFloat x ++ "," ++ String.fromFloat y )
                            )
                        |> String.join " "
                        |> (\str -> str++" 50,50")
            in
            Svg.svg 
                [ width "100%"
                , viewBox "0 0 100 100"
                ] 
                [ Svg.polyline [ fill "none", stroke "black", points vertices ] [] ]
        List ->
            div [Attributes.css [ flexGrow (Css.num 1), Css.displayFlex, Css.flexDirection Css.column]]
                [ h2 [] [text "Your Path"]
                , div []
                    [ label [] [ text "calculating total Length, total Payment, etc (TODO)"] ]
                , path
                    |> List.reverse
                    |> List.map String.fromInt
                    |> String.join "\n" 
                    |> text
                    |> List.singleton
                    |> textarea [Attributes.readonly True, Attributes.css [ flexGrow (Css.num 1)]]
                ]