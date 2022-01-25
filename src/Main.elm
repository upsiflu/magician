module Main exposing (..)

import Browser
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Vector2d exposing (Vector2d)
import Point2d exposing (Point2d)
import Length exposing (Meters)
import Seriousness exposing (Seriousness, create, read)
import Css exposing (..)

{-|
@docs Model, init
-}

main =
  Browser.sandbox { init = init, update = update, view = view >> toUnstyled }

type Model
    = Scry (List String) Shared
    | Map Shared
    | Print Shared

init : Model
init = Scry [] initShared


{-| A coordinate system where `(0, 0)` is the tower position, and positive `y` values go North, and positive `x` values go East, and distances can be calculated as if all patients were living on a plane (Euclidean distance). -}
type Country =
    Country

{-| Position relative to the tower (in Meters, because that's the package's internal representation)-}
type alias Point =
    Point2d Meters Country

{-| Lengths **in m** -}
point : { x : Float, y : Float } -> Point
point = Point2d.fromMeters

{-|-}
tower : Point
tower = Point2d.origin

{-| Position relative to the previous point, i.e. Path Segment -}
type alias Vector =
    Vector2d Meters Country

{-|The Zoom center is the last path node, the zoom magnification depends on the patient pair that is closest adjacent. -}
type alias Shared =
    { patients : Patients
    , path : Path
    , showHints : Bool
    , zoomIn : Bool 
    }

initShared : Shared
initShared = 
    { patients = []
    , path = []
    , showHints = True
    , zoomIn = False
    }

type alias Patient = ( Point, Seriousness )
type alias Patients = List Patient
patientsToList p = [] 

{-| In a path, the **implied** initial and terminal "patient" is the tower. This makes it a Polygon2D. -}
type alias Path = List (Vector, Patient)

type Msg
    = GoToScry
    | GoToMap
    | GoToPrint

update msg model =
    let
        shared =
            case model of
                Scry _ s -> s
                Map s -> s
                Print s -> s
    in shared
        |> (case msg of
                GoToScry ->
                    Scry (patientsToList shared.patients)
                GoToMap ->
                    Map
                GoToPrint ->
                    Print
            )

theme = { accent = rgb 150 163 250, dark = rgb 12 66 120 }

view model =
    let
        header = h1 [ css [margin (px 0), backgroundColor theme.accent, fontSize (rem 1), textAlign center]] [text "SkryScanner!"]
        scene =
            case model of
                Scry inputLines shared ->
                    text "Input Scry Data Here"
                Map shared ->
                    text "(WIP Map view with Path creation tools)"
                Print shared ->
                    text "(WIP Path view with export options)"
        navigation =
            nav [css [displayFlex, justifyContent center, backgroundColor theme.accent]]
            [ button [ onClick GoToScry ] [ text "Go to Scry" ]
            , button [ onClick GoToMap ] [ text "Go to Map" ]
            , button [ onClick GoToPrint ] [ text "Print Path" ]
            ]
    in div [ css [displayFlex, flexDirection column, height (vh 100)]]
        [ header
        , main_ 
            [ css
                [ flexGrow (num 2)
                , padding (px 20)
                , border3 (rem 0.5) solid theme.dark
                , displayFlex
                ]
            ] 
            [scene]
        , navigation
        ]