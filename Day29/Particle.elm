module Particle exposing (Particle, update, random, inBounds)

import Math.Vector2 exposing (..)
import Random


type alias Particle =
    { pos : Vec2
    , kind : Bool
    }


inBounds : ( Float, Float ) -> ( Float, Float ) -> Particle -> Bool
inBounds ( minx, miny ) ( maxx, maxy ) particle =
    let
        x =
            getX particle.pos

        y =
            getY particle.pos
    in
        x >= minx && x <= maxx && y >= miny && y <= maxy


update : List Particle -> Particle -> Particle
update neighbours particle =
    let
        ( sameNeighbours, oppositeNeighbours ) =
            List.partition (\n -> n.kind == particle.kind) neighbours

        oppositeCenter =
            List.foldl (\n sum -> add n.pos sum) (vec2 0 0) oppositeNeighbours
                |> scale (toFloat <| List.length oppositeNeighbours)

        sameCenter =
            List.foldl (\n sum -> add n.pos sum) (vec2 0 0) sameNeighbours
                |> scale (toFloat <| List.length sameNeighbours)

        targetPos =
            oppositeCenter
                |> add (Math.Vector2.negate sameCenter)
    in
        if targetPos == particle.pos then
            particle
        else
            { particle
                | pos =
                    particle.pos
                        |> add (direction targetPos particle.pos)
            }



-- let
--     ( x, y ) =
--         toTuple particle.pos
--
--     dvel =
--         vec2
--             (sin (x / 100 + t))
--             (cos (x / 100 + t))
--             |> scale (5 + sin (t / 2000))
-- in
--     { particle
--         | pos =
--             particle.pos
--                 |> add (scale dt particle.vel)
--         , vel =
--             particle.vel
--                 |> add dvel
--     }


randomVec2 : ( Float, Float ) -> ( Float, Float ) -> Random.Generator Vec2
randomVec2 ( minx, miny ) ( maxx, maxy ) =
    Random.map2 vec2
        (Random.float minx maxx)
        (Random.float miny maxy)


random : Random.Generator Particle
random =
    Random.map2 Particle
        (randomVec2 ( -375, -250 ) ( 375, 250 ))
        (Random.bool)
