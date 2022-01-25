module Patient exposing (Patient, decoder, encode, serialize, scaleAbout, translateBy, getPoint, getSeriousness, ViewMode(..), view)

{-|
@docs Patient, decoder, encode, serialize, scaleAbout, translateBy, getPoint, getSeriousness, ViewMode, view-}

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
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

{-|-}
scaleAbout : Point -> Float -> Patient -> Patient
scaleAbout origin factor ( point, seriousness ) =
    let
        newPoint =
            point
                |> Point2d.scaleAbout origin factor
    in
    ( newPoint, seriousness )

{-|-}
translateBy : Vector -> Patient -> Patient
translateBy vector ( point, seriousness ) =
    ( Point2d.translateBy vector point, seriousness )


{-|-}
getPoint : Patient -> Point
getPoint = Tuple.first

{-|-}
getSeriousness : Patient -> Seriousness
getSeriousness = Tuple.second


{-|-}
type ViewMode msg
    = Interactive {onClick : msg}
    | Highlighted {onClick : msg}
    | Passive


{-| will draw a button for the patient on absolute coordinates:
    
`n%` of the parent height resp. width.
-}
view : ViewMode msg -> Patient -> Html msg
view mode ( point, seriousness ) = 
    let 
        {x, y} = 
            Point2d.toMeters point
        
        representation =
            case mode of
                Interactive config ->
                    [ button 
                        [ Events.onClick config.onClick 
                        , css
                            [ transform (translate2 (px -22) (px -22))
                            , height (px 40)
                            , width (px 40)
                            , borderRadius (px 20)
                            , borderWidth (px 2)
                            , padding zero
                            , opacity (num 0.9)
                            ] 
                        ]
                        [text (String.fromInt (Seriousness.encode seriousness))]
                    ]
                Highlighted config ->
                    [ button 
                        [ Events.onClick config.onClick 
                        , css
                            [ transform (translate2 (px -22) (px -22))
                            , height (px 40)
                            , width (px 40)
                            , borderRadius (px 20)
                            , borderWidth (px 2)
                            , padding zero
                            , opacity (num 0.9)
                            , backgroundColor (rgb 250 230 33)
                            , borderColor (rgb 260 250 43)
                            ] 
                        ]
                        [text (String.fromInt (Seriousness.encode seriousness))]
                    ]
                Passive ->
                    [ button 
                        [ css
                            [ transform (translate2 (px -20) (px -20))
                            , height (px 40)
                            , width (px 40)
                            , borderRadius (px 20)
                            , borderWidth (px 0)
                            , padding zero
                            , opacity (num 0.8)
                            , backgroundColor (rgb 20 20 20)
                            , color (rgb 255 255 255)
                            ] 
                        , Attributes.disabled True
                        ]
                        [text (String.fromInt (Seriousness.encode seriousness))]
                    ]



    in
    div [ css
            [ position absolute
            , left ( pct x )
            , top ( pct y )
            ] 
        ]
        representation