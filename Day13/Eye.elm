module Day13.Eye exposing (eye)

import Collage
import Element
import Color
import Day13.Shapes as Shapes


eye : Float -> Float -> Collage.Form
eye opened rotationT =
    Collage.group
        [ iris 50
            120
            (sin rotationT)
            (sin (rotationT * 3))
            (sin (rotationT * 1.7))
        , pupil 50
        , eyelids 120 200 opened
        ]


iris : Float -> Float -> Float -> Float -> Float -> Collage.Form
iris pupilRadius size outerOffset midOffset pupilOffset =
    let
        pointsInCircle =
            40

        midRadius =
            (size + pupilRadius) / 2

        circlePoint r i =
            ( r * cos (degrees <| i * 360 / pointsInCircle)
            , r * sin (degrees <| i * 360 / pointsInCircle)
            )

        makeLine size midRadius outerOffset outerIndex innerOffset innerIndex =
            Collage.segment
                (circlePoint size (outerIndex + outerOffset))
                (circlePoint midRadius (innerIndex + innerOffset))
                |> Collage.traced (Collage.solid Color.darkGreen)

        makeLines size midRadius outerOffset innerOffset outerIndex =
            [(outerIndex)..(outerIndex + 5)]
                |> List.map (makeLine size midRadius outerOffset outerIndex innerOffset)
                |> Collage.group

        makeRing size midRadius outerOffset innerOffset =
            [0..pointsInCircle]
                |> List.map (makeLines size midRadius outerOffset innerOffset)
                |> Collage.group
    in
        Collage.group
            [ Collage.circle size
                |> Collage.filled Color.yellow
            , makeRing size midRadius outerOffset midOffset
            , makeRing midRadius pupilRadius midOffset pupilOffset
            ]


pupil : Float -> Collage.Form
pupil size =
    Collage.circle size
        |> Collage.filled Color.black


eyelids : Float -> Float -> Float -> Collage.Form
eyelids height width opened =
    Collage.group
        [ Collage.polygon
            (Shapes.curve ( -width, 0 ) ( 0, (height * 1.5 * opened) ) ( width, 0 ) 20
                ++ Shapes.curve ( width, 0 ) ( 0, (height * 2) ) ( -width, 0 ) 20
            )
            |> Collage.filled Color.brown
        , Collage.polygon
            (Shapes.curve ( -width, 0 ) ( 0, -(height * 1.5 * opened) ) ( width, 0 ) 20
                ++ Shapes.curve ( width, 0 ) ( 0, -(height * 2) ) ( -width, 0 ) 20
            )
            |> Collage.filled Color.brown
        ]
