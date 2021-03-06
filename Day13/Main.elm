module Main exposing (..)

import Collage
import Element
import Day13.Eye as Eye exposing (Eye)
import Day13.TrippyBackground as TrippyBackground
import Html exposing (Html)
import Html.App
import Html.Attributes
import Time exposing (Time)
import Random
import Random.Extra
import Color exposing (Color)
import Animation
import AnimationFrame


appearTime : Float
appearTime =
    2000


type alias Model =
    { eyes : List ( ( Float, Float ), Eye )
    , disappearingEye : Maybe ( Time, ( Float, Float ), Eye )
    , appearingEye : Maybe ( Time, ( Float, Float ), Eye )
    , now : Time
    }


initialModel : Model
initialModel =
    { eyes = []
    , disappearingEye = Nothing
    , appearingEye = Nothing
    , now = 0
    }


type Msg
    = Tick Time
    | StartBlink
    | ChangeEye
    | ResetEyes (List ( ( Float, Float ), Eye ))
    | NewEye ( ( Float, Float ), Eye )


promoteAppearingEye : Model -> Model
promoteAppearingEye model =
    case model.appearingEye of
        Nothing ->
            model

        Just ( startTime, ( x, y ), eye ) ->
            if startTime + appearTime <= model.now then
                { model
                    | appearingEye = Nothing
                    , eyes = model.eyes ++ [ ( ( x, y ), eye ) ]
                }
            else
                model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick diff ->
            ( { model | now = model.now + diff }
                |> promoteAppearingEye
            , Cmd.none
            )

        StartBlink ->
            ( { model
                | eyes =
                    List.map (\( p, eye ) -> ( p, Eye.startBlink model.now eye ))
                        model.eyes
              }
            , Cmd.none
            )

        ResetEyes eyes ->
            ( { model | eyes = eyes }
            , Cmd.none
            )

        NewEye ( ( x, y ), eye ) ->
            ( { model | appearingEye = Just ( model.now, ( x, y ), eye ) }
            , Cmd.none
            )

        ChangeEye ->
            case model.eyes of
                [] ->
                    ( model, Cmd.none )

                ( point, eye ) :: rest ->
                    ( { model
                        | disappearingEye = Just ( model.now, point, eye )
                        , eyes = rest
                      }
                    , Random.generate NewEye randomEye
                    )


view : Model -> Html msg
view model =
    Html.div [ Html.Attributes.style [ ( "position", "relative" ) ] ]
        [ Html.div [ Html.Attributes.style [ ( "position", "absolute" ) ] ]
            [ TrippyBackground.view 750 500 (model.now / 1000) ]
        , Html.div [ Html.Attributes.style [ ( "position", "absolute" ) ] ]
            [ eyesView model ]
        ]


eyesView : Model -> Html msg
eyesView model =
    [ case model.disappearingEye of
        Nothing ->
            Collage.group []

        Just ( startTime, ( x, y ), eye ) ->
            let
                alphaAnimation =
                    Animation.animation startTime
                        |> Animation.from 1.0
                        |> Animation.to 0.0
                        |> Animation.duration 2000
            in
                if Animation.isDone model.now alphaAnimation then
                    Collage.group []
                else
                    Eye.view model.now eye
                        |> Collage.scale (0.7 + 0.3 * Animation.animate model.now alphaAnimation)
                        |> Collage.move ( x, y )
                        |> Collage.alpha
                            (Animation.animate model.now alphaAnimation)
    , model.eyes
        |> List.map
            (\( ( x, y ), eye ) ->
                Eye.view model.now eye
                    |> Collage.move ( x, y )
            )
        |> Collage.group
    , case model.appearingEye of
        Nothing ->
            Collage.group []

        Just ( startTime, ( x, y ), eye ) ->
            let
                alphaAnimation =
                    Animation.animation startTime
                        |> Animation.from 0.0
                        |> Animation.to 1.0
                        |> Animation.duration appearTime
            in
                if Animation.isScheduled model.now alphaAnimation then
                    Collage.group []
                else
                    Eye.view model.now eye
                        |> Collage.scale (0.7 + 0.3 * Animation.animate model.now alphaAnimation)
                        |> Collage.move ( x, y )
                        |> Collage.alpha
                            (alphaAnimation |> Animation.animate model.now)
    ]
        |> Collage.collage 750 500
        |> Element.toHtml


map7 :
    (a -> b -> c -> d -> e -> f -> g -> h)
    -> Random.Generator a
    -> Random.Generator b
    -> Random.Generator c
    -> Random.Generator d
    -> Random.Generator e
    -> Random.Generator f
    -> Random.Generator g
    -> Random.Generator h
map7 f genA genB genC genD genE genF genG =
    Random.Extra.map6 f genA genB genC genD genE genF
        |> flip Random.Extra.andMap genG


whitesColorGenerator : Random.Generator Color
whitesColorGenerator =
    Random.map3 Color.hsl
        (Random.float -(degrees 50) (degrees 60))
        (Random.float 0 1)
        (Random.float 0.9 1.0)


irisColorGenerator : Random.Generator Color
irisColorGenerator =
    Random.map3 Color.hsl
        (Random.float (degrees 120) (degrees 250))
        (Random.float 0.65 1)
        (Random.float 0.1 0.5)


skinColorGenerator : Random.Generator Color
skinColorGenerator =
    Random.map3 Color.hsl
        (Random.float (degrees 25) (degrees 45))
        (Random.Extra.constant 0.55)
        (Random.float 0.2 0.7)


randomEye : Random.Generator ( ( Float, Float ), Eye )
randomEye =
    Random.map2 (,)
        (Random.map2 (,) (Random.float -250 250) (Random.float -150 150))
        (map7 Eye
            (Random.float 50 250)
            (Random.float 0.3 0.5)
            (Random.float 0.2 0.7)
            (Random.Extra.constant 0)
            skinColorGenerator
            irisColorGenerator
            whitesColorGenerator
        )


main : Program Never
main =
    Html.App.program
        { init =
            ( initialModel
            , Random.generate ResetEyes (Random.list 5 randomEye)
            )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ AnimationFrame.diffs Tick
                    , Time.every 3000 (always StartBlink)
                    , Time.every 10000 (always ChangeEye)
                    ]
        , update = update
        , view = view
        }
