module PathTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Patient.Path as Path


suite : Test
suite =
    describe "Paths"
        [ describe "Path.toggle"
            [ fuzz (list int) "Toggle twice equals identity" <|
                \path ->
                    let
                        index = 10
                    in
                    path
                        |> Path.toggle index
                        |> Path.toggle index
                        |> Expect.equal path
            ]
        ]