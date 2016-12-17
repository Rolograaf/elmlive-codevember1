module Main exposing (..)

import Color
import Collage
import Html exposing (Html)
import Element
import Color.Mixing
import Time exposing (Time)
import AnimationFrame
import Shapes


sunset : Float -> Float -> Float -> Collage.Form
sunset width height percent =
    let
        blue =
            Color.hsl (degrees 191) 1.0 0.33

        orange =
            Color.hsl (degrees 29) 0.92 0.49

        red =
            Color.red

        black =
            Color.black
    in
        Collage.rect width height
            |> Collage.gradient
                (Color.linear
                    ( 0, 250 )
                    ( 0, -250 )
                    [ ( 0, blue |> Color.Mixing.mix percent black )
                    , ( 1, orange |> Color.Mixing.mix percent red )
                    ]
                )


beach : Collage.Form
beach =
    Collage.group
        [ Collage.polygon
            (Shapes.curve ( -375, -150 ) ( -200, -100 ) ( 375, -150 ) 20
                ++ [ ( 375, -250 )
                   , ( -375, -250 )
                   ]
            )
            |> Collage.filled Color.black
        , Collage.polygon
            (Shapes.curve ( 200, -170 ) ( 230, -100 ) ( 230, 190 ) 10
                ++ Shapes.curve ( 250, 200 ) ( 240, 0 ) ( 250, -170 ) 10
            )
            |> Collage.filled Color.black
        , Collage.polygon
            (Shapes.curve ( 220, 190 ) ( 55, 180 ) ( 30, 50 ) 10
                ++ Shapes.curve ( 30, 50 ) ( 95, 160 ) ( 220, 190 ) 10
            )
            |> Collage.filled Color.black
        , Collage.polygon
            (Shapes.curve ( 225, 180 ) ( 75, 160 ) ( 110, 10 ) 10
                ++ Shapes.curve ( 110, 10 ) ( 115, 140 ) ( 225, 180 ) 10
            )
            |> Collage.filled Color.black
        , Collage.polygon
            (Shapes.curve ( 227, 202 ) ( 95, 233 ) ( 53, 157 ) 10
                ++ Shapes.curve ( 53, 157 ) ( 130, 213 ) ( 227, 202 ) 10
            )
            |> Collage.filled Color.black
        ]


type alias Model =
    { time : Float }


initialModel : Model
initialModel =
    { time = 0 }


type Msg
    = Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( { model | time = model.time + dt }, Cmd.none )


view : Model -> Html msg
view model =
    [ sunset 750 500 (model.time / 3000)
    , beach
    ]
        |> Collage.collage 750 500
        |> Element.toHtml


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions =
            \model ->
                if model.time < 3000 then
                    AnimationFrame.diffs Tick
                else
                    Sub.none
        , update = update
        , view = view
        }
