module Main exposing (main, Model(..), Shared, Msg(..))

{-| The SkryScanner App for the beloved Magician!

@docs main, Model, Shared, Msg
-}

import Browser
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Css exposing (..)
import Country
import Patient.Path as Path exposing (Path)
import Patient exposing (Patient)

{-|-}
main:Program () Model Msg
main =
  Browser.sandbox { init = init, update = update, view = view >> toUnstyled }

{-|-}
type Model
    = Scry (List String) Shared
    | Map Shared
    | Print Shared

init : Model
init = Scry [] initShared




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

type alias Patients = List Patient
patientsToList p = [] 


{-|-}
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