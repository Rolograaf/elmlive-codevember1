module Day13.Eye exposing (Eye, startBlink, view)

import Collage
import Element
import Color
import Day13.Shapes as Shapes
import Time exposing (Time)
import Animation


-- MODEL


type alias Eye =
    { irisSize : Float
    , pupilSize : Float
    , eyeSize : Float
    , blinkStart : Time
    }



-- UPDATE


startBlink : Time -> Eye -> Eye
startBlink now eye =
    { eye | blinkStart = now }



-- VIEW


view : Time -> Eye -> Collage.Form
view now model =
    let
        eyelidAnimation =
            Animation.animation model.blinkStart
                |> Animation.from 0
                |> Animation.to 1.0
                |> Animation.duration 200

        rotationT =
            now / 1000

        opened =
            Animation.animate now eyelidAnimation
    in
        Collage.group
            [ whites model.irisSize model.eyeSize
            , iris model.pupilSize
                model.irisSize
                (sin rotationT)
                (sin (rotationT * 3))
                (sin (rotationT * 1.7))
            , pupil model.pupilSize
            , eyelids model.irisSize model.eyeSize opened
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


whites : Float -> Float -> Collage.Form
whites height width =
    Collage.polygon
        (Shapes.curve ( width, 0 ) ( 0, (height * 2) ) ( -width, 0 ) 20
            ++ Shapes.curve ( width, 0 ) ( 0, -(height * 2) ) ( -width, 0 ) 20
        )
        |> Collage.filled Color.white


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
