module Patient.Cloud exposing (Cloud, deserialize, Raw, serialize, ViewMode(..), view)

{-| This models a serializable ordered set of `Patient`s. 
@docs Cloud, deserialize, Raw, serialize, ViewMode, view-}

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events as Events
import Css exposing (..)

import Point2d exposing (Point2d)
import Vector2d
import Length

import Json.Encode as Encode
import Json.Decode as Decode

import Patient exposing (Patient)
import Result exposing (Result(..))
import Result.Extra as Result

import Country

{-|-}
type alias Cloud = List Patient

{-|-}
type alias Raw = List (Result String Patient)

{-| A deserialization may fail. Sanitize the deserialization `Results` to get a `Cloud`. -}
deserialize : List String -> Raw
deserialize =
    let
        deserializeLine l =
            case String.split " " l of
                [""] ->
                    Err "--"
                [x, y, s] ->
                    Decode.decodeValue Patient.decoder
                        ( Encode.object 
                            [ ("x", Encode.string x)
                            , ("y", Encode.string y)
                            , ("seriousness", Encode.string s)
                            ]
                        )
                        |> Result.mapError Decode.errorToString
                _ ->
                  Err "Enter three values separated by single spaces."
    in
    List.map deserializeLine
        

{-| Use with caution. Throws out all serialization errors. -}
sanitize : Raw -> Cloud
sanitize = 
    Result.partition >> Tuple.first

{-|-}
serialize : Cloud -> List String
serialize =
    List.map Patient.serialize

{-|-}
type ViewMode msg
    = Map {onClick : Int -> msg}
    | Input {onInput : String -> msg, onSanitize : Cloud -> msg} (List String)

{-|-}
view : ViewMode msg -> Cloud -> Html msg
view mode cloud =
    case mode of
        Map { onClick } ->
            let
                factor =
                    cloud
                        |> List.map 
                            ( Tuple.first >> Point2d.distanceFrom Country.tower >> Length.inMeters )
                        |> List.maximum
                        |> Maybe.withDefault 0.0
                        |> Debug.log "my maximum distance"
                        |> (\max -> 50/max)
                leftTopCorner =
                    Vector2d.meters 50 50
            in
            cloud
                |> List.indexedMap (\i -> 
                    Patient.scaleAbout Country.tower factor
                        >> Patient.translateBy (leftTopCorner)
                        >> Patient.view {onClick = onClick i}
                    )
                |> div 
                    [css 
                        [ width (vh 80)
                        , height (vh 80)
                        , backgroundColor (rgb 55 140 88)
                        , borderRadius (pct 50)
                        , position relative
                        ]
                    ]

        Input config lines  ->
            let 
                isSanitized =
                    deserialize lines
                        |> Result.combine
                        |> Result.isOk

                viewRawLine l =
                    case l of
                        Ok _ -> "Ok"
                        Err str -> str

                parseInput string =
                    case deserialize (String.split "\n" string) |> Result.combine of
                        Err _ -> config.onInput string
                        Ok c -> config.onSanitize c

            in
            div [ css [flexGrow (num 2), alignItems stretch, displayFlex, flexDirection column ] ]
                [ Html.Styled.small [] [text "Input one patient per line: <x in km> <y> <seriousness (1..10)>"]
                , div [ css [ displayFlex, flexGrow (num 2), alignItems stretch] ]
                    [ textarea 
                        [ css [ flexGrow (num 1), width (pct 50), minHeight (pct 95), padding zero, margin zero]
                        , Attributes.placeholder "<x in km> <y> <seriousness (1..10)>"
                        , Events.onInput parseInput
                        , Attributes.value (String.join "\n" lines)
                        ] []
                    , Html.Styled.pre 
                        [ css [ paddingLeft (rem 1), margin zero, flexGrow (num 1), width (pct 50) ]] 
                        [text (lines |> deserialize |> List.map viewRawLine |> String.join "\n")]
                    ]
                , button 
                    [ Attributes.disabled (isSanitized), Events.onClick ( lines |> deserialize |> sanitize |> config.onSanitize) ] 
                    [ text "Delete all patient lines that failed to parse" ]
                ]