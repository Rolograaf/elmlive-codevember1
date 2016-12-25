module Main exposing (..)

import AnimationFrame
import Collage
import Color exposing (Color)
import Element
import Html exposing (Html)
import Math.Vector2 exposing (..)
import Particle exposing (Particle)
import Random
import Time exposing (Time)


type alias Model =
    { particles : List Particle
    , t : Time
    , i : Int
    }


particleCount : Int
particleCount =
    100


initialModel : Model
initialModel =
    { particles = []
    , t = 0
    , i = 0
    }


type Msg
    = Tick Time
    | NewParticles (List Particle)
    | AddParticle Particle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick t ->
            ( { model
                | t = model.t + 0.1
                , i = model.i + 1
                , particles =
                    List.map
                        (\p ->
                            Particle.update
                                (List.filter
                                    (\n -> distance n.pos p.pos < 100)
                                    model.particles
                                )
                                p
                        )
                        model.particles
                        |> List.filter
                            (Particle.inBounds ( -375, -250 ) ( 375, 250 ))
              }
            , if List.length model.particles < particleCount then
                Random.generate AddParticle Particle.random
              else
                Cmd.none
            )

        NewParticles particles ->
            ( { model | particles = particles }
            , Cmd.none
            )

        AddParticle particle ->
            ( { model | particles = particle :: model.particles }
            , Cmd.none
            )


drawParticle : Particle -> Collage.Form
drawParticle particle =
    let
        color =
            if particle.kind then
                Color.black
            else
                Color.white

        --     a =
        --         scale 0.2 particle.vel
        --
        --     b =
        --         scale -0.2 particle.vel
    in
        Collage.circle 3
            |> Collage.filled color
            |> Collage.move (toTuple particle.pos)



-- Collage.segment (toTuple a) (toTuple b)
--     |> Collage.traced
--         { color = Color.hsl 0 0 (length particle.pos / 500)
--         , width = 3
--         , cap = Collage.Flat
--         , join = Collage.Clipped
--         , dashing = []
--         , dashOffset = 0
--         }


view : Model -> Html msg
view model =
    [ Collage.rect 750 500
        |> Collage.filled (Color.hsl (degrees 42) 0.73 0.66)
    , model.particles
        |> List.map drawParticle
        |> Collage.group
    ]
        |> Collage.collage 750 500
        |> Element.toHtml


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( initialModel
            , Random.generate NewParticles (Random.list particleCount Particle.random)
            )
        , subscriptions =
            \model ->
                if List.isEmpty model.particles then
                    Sub.none
                else
                    AnimationFrame.times Tick
        , update = update
        , view = view
        }
