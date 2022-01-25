module Main exposing (main, Model(..), Shared, Msg(..))

{-| The SkryScanner App for the beloved Magician!

@docs main, Model, Shared, Msg
-}

import Browser
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Css exposing (..)
import Country
import Patient.Path as Path exposing (Path)
import Patient.Cloud as Cloud exposing (Cloud)
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
    { patients : Cloud
    , path : Path
    , showHints : Bool
    , zoomIn : Bool
    , info : String
    }

initShared : Shared
initShared = 
    { patients = []
    , path = []
    , showHints = True
    , zoomIn = False
    , info = ""
    }


{-|-}
type Msg
    = GoToScry
    | GoToMap
    | GoToPrint
    | GotRawInput (List String)
    | GotSanitizedCloud Cloud
    | SelectedPatient Int

update msg model =
    case ( model, msg ) of
            -- Scry screen

                ( Scry _ shared, GoToMap ) ->
                    Map shared
                
                ( Scry _ shared, GotRawInput lines) ->
                    Scry lines shared

                ( Scry _ shared, GotSanitizedCloud cloud) ->
                    Scry 
                        ( Cloud.serialize cloud )
                        { shared | patients = cloud }

            -- Map screen
                
                ( Map shared, GoToScry ) ->
                    Scry (Cloud.serialize shared.patients) shared
                
                ( Map shared, GoToPrint ) ->
                    Print shared

                ( Map shared, SelectedPatient i ) ->
                    Map shared -- Todo!
                

            -- Print screen

                ( Print shared, GoToScry ) ->
                    Scry (Cloud.serialize shared.patients) shared
                
                ( Print shared, GoToMap ) ->
                    Map shared

            -- Impossible cases
                _ -> model
            

theme = { accent = rgb 150 163 250, dark = rgb 12 66 120, bright = rgb 200 220 255 }

view model =
    let
        header = h1 [ css [margin (px 0), backgroundColor theme.accent, fontSize (rem 1), textAlign center]] [text "ScryScanner!"]
        scene =
            case model of
                Scry inputLines shared ->
                    Cloud.view 
                        ( Cloud.Input 
                            { onInput = String.split "\n" >> GotRawInput
                            , onSanitize = GotSanitizedCloud 
                            } 
                            inputLines 
                        ) 
                        shared.patients
                Map shared ->
                    Cloud.view 
                        ( Cloud.Map { onClick = SelectedPatient } ) 
                        shared.patients
                Print shared ->
                    text "(WIP Path view with export options)"

        navigation =
            let
                makeNavButton message labeling = 
                    button [ css [ width (rem 12) ], onClick message ] [ text labeling ]
                disabledButton labeling = 
                    button [ Attributes.disabled True, css [ width (rem 12) ] ] [ text labeling ]
                activeButton labeling = 
                    button [ Attributes.disabled True, css [ width (rem 12), borderColor theme.dark, backgroundColor theme.dark, color theme.bright ] ] [ text labeling ]
            in
            nav [css [displayFlex, justifyContent center, backgroundColor theme.accent]]
                <| ( case model of
                        Scry _ _ -> [ activeButton "Scry Input"
                                , makeNavButton GoToMap "Find your Path!" 
                                , disabledButton "Print out current Path"
                                ]
                        Map _ -> [ makeNavButton GoToScry "Review Scry Input" 
                                , activeButton "Find your Path"
                                , makeNavButton GoToPrint "Print out current Path"]
                        Print _ -> [ makeNavButton GoToScry "Review Scry Input" 
                                , makeNavButton GoToMap "Go back to the Path editor" 
                                ,activeButton "Print out current Path" ]
                )
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