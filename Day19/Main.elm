module Main exposing (..)

import Html exposing (Html)
import Html.Attributes
import Time exposing (Time)


type alias Model =
    { current : String
    , nextLines : List String
    }


initialModel : Model
initialModel =
    { current = ""
    , nextLines =
        [ "Soul, wilt thou toss again?"
        , "By just such a hazard"
        , "Hundreds have lost, indeed,"
        , "But tens have won an all."
        , "Angels' breathless ballot"
        , "Lingers to record thee;"
        , "Imps in eager caucus"
        , "Raffle for my soul."
        ]
    }


type Msg
    = Tick Time


nextStep : String -> String -> String
nextStep current target =
    if current == "" then
        String.left 1 target
    else if String.left 1 current /= String.left 1 target then
        String.dropRight 1 current
    else
        (String.left 1 current
            ++ nextStep
                (String.dropLeft 1 current)
                (String.dropLeft 1 target)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick now ->
            case model.nextLines of
                [] ->
                    ( model, Cmd.none )

                next :: rest ->
                    ( { model
                        | current = nextStep model.current next
                        , nextLines =
                            if model.current == next then
                                rest
                            else
                                model.nextLines
                      }
                    , Cmd.none
                    )


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.style
            [ ( "background-color", "black" )
            , ( "color", "#ddc" )
            , ( "width", "100%" )
            , ( "height", "100%" )
            , ( "font-size", "64px" )
            ]
        ]
        [ Html.div
            [ Html.Attributes.style
                [ ( "position", "relative" )
                , ( "top", "50%" )
                , ( "transform", "translateY(-50%)" )
                , ( "text-align", "center" )
                ]
            ]
            [ Html.text model.current ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions =
            \model ->
                if model.nextLines == [] then
                    Sub.none
                else
                    Time.every 100 Tick
        , update = update
        , view = view
        }
