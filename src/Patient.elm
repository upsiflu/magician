module Patient exposing (Patient, decoder, encode, serialize, scaleAbout, translateBy, view)

{-|
@docs Patient, decoder, encode, serialize, scaleAbout, translateBy, view-}

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events as Events
import Css exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field
import Json.Encode as Encode

import Country exposing (Point, Vector)
import Point2d 

import Patient.Seriousness as Seriousness exposing (Seriousness)

{-|-}  
type alias Patient = ( Point, Seriousness )


{-|-}
decoder : Decoder Patient
decoder =
    Field.require "x" Decode.string <|\x ->
    Field.require "y" Decode.string <|\y ->
    Field.require "seriousness" Decode.string <|\seriousness ->
    case ( String.toInt seriousness, String.toFloat x, String.toFloat y) of
        ( Nothing, _, _ ) ->
            Decode.fail ("Hint: Seriousness is an Integer from 1 to 10.")
        
        ( Just integer, Just fx, Just fy ) ->
            case Seriousness.create integer of
                Just inBounds ->
                    Decode.succeed 
                        ( Country.point { x = fx , y = fy }, inBounds )
                Nothing ->
                    Decode.fail ("Seriousness is out of bounds: "++seriousness++".")
        _ ->
            Decode.fail ("Enter kilometers in the format XX.XXX")

{-|-}
encode : Patient -> Encode.Value
encode (point, seriousness) =
    let {x, y} = Point2d.toMeters point
    in
    Encode.object 
        [ ("x", Encode.float x)
        , ("y", Encode.float y)
        , ("seriousness", Encode.int (Seriousness.encode seriousness))
        ]

{-|-}
serialize : Patient -> String
serialize (point, seriousness) =
    let {x, y} = Point2d.toMeters point
    in
    String.join " "
        [ String.fromFloat x
        , String.fromFloat y
        , String.fromInt (Seriousness.encode seriousness)
        ]

scaleAbout : Point -> Float -> Patient -> Patient
scaleAbout origin factor ( point, seriousness ) =
    let
        newPoint =
            point
                |> Point2d.scaleAbout origin factor
    in
    ( newPoint, seriousness )

translateBy : Vector -> Patient -> Patient
translateBy vector ( point, seriousness ) =
    ( Point2d.translateBy vector point, seriousness )


{-| will draw a button for the patient on absolute coordinates:
    
`n%` of the parent height resp. width.
-}
view : {onClick : msg} -> Patient -> Html msg
view config ( point, seriousness ) = 
    let 
        {x, y} = 
            Point2d.toMeters point
    in
    div [ css
            [ position absolute
            , left ( pct x )
            , top ( pct y )
            ] 
        ]
        [ button 
            [ Events.onClick config.onClick 
            , css
                [ margin2 (px -20) (px -20)
                , height (px 40)
                , width (px 40)
                , borderRadius (px 20)
                , borderWidth (px 0)
                , padding zero
                ] 
            ]
            [text (String.fromInt (Seriousness.encode seriousness))]
        ]