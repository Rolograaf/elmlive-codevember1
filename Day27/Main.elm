module Main exposing (..)

import Html exposing (Html)
import Mouse
import Svg exposing (Svg)
import Svg.Attributes
import Math.Vector2 exposing (..)


type alias Point =
    Vec2


type alias FlatCoin =
    { center : Point, radius : Float }


type alias FlippingCoin =
    { anchor : Point
    , flipAngle : Float
    , centerDirection : Vec2
    , radius : Float
    }


startFlip : Point -> FlatCoin -> FlippingCoin
startFlip mousePosition coin =
    { anchor =
        (direction mousePosition coin.center)
            |> Math.Vector2.negate
            |> scale coin.radius
            |> add coin.center
    , flipAngle = degrees 45
    , centerDirection = direction mousePosition coin.center
    , radius = coin.radius
    }


type alias Model =
    { flatCoins : List FlatCoin
    , flippingCoins : List FlippingCoin
    }


initialModel : Model
initialModel =
    { flatCoins = [ { center = vec2 375 250, radius = 40 } ]
    , flippingCoins = []
    }


type Msg
    = MouseMove Mouse.Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseMove { x, y } ->
            let
                mousePosition =
                    (vec2 (toFloat x) (toFloat y))

                containsMouse coin =
                    (distance mousePosition coin.center)
                        <= coin.radius

                ( coinsToFlip, coinsToKeep ) =
                    List.partition containsMouse model.flatCoins
            in
                ( { model
                    | flatCoins = coinsToKeep
                    , flippingCoins =
                        coinsToFlip
                            |> List.map (startFlip mousePosition)
                            |> List.append model.flippingCoins
                  }
                , Cmd.none
                )


translateString : Point -> String
translateString p =
    "translate("
        ++ (p |> getX |> toString)
        ++ ","
        ++ (p |> getY |> toString)
        ++ ")"


rotateString : Float -> String
rotateString angle =
    "rotate(" ++ (toString <| 180 / pi * angle) ++ ")"


renderFlatCoin : FlatCoin -> Svg msg
renderFlatCoin coin =
    Svg.circle
        [ Svg.Attributes.r (toString coin.radius)
        , Svg.Attributes.transform
            (translateString coin.center)
        , Svg.Attributes.fill "#ec3"
        ]
        []


renderFlippingCoin : FlippingCoin -> Svg msg
renderFlippingCoin coin =
    let
        orientation =
            atan2 (getY coin.centerDirection) (getX coin.centerDirection)
    in
        Svg.circle
            [ Svg.Attributes.r (toString coin.radius)
            , Svg.Attributes.transform <|
                String.join " "
                    [ translateString coin.anchor
                    , rotateString orientation
                    , "scale(" ++ (toString <| cos coin.flipAngle) ++ ",1)"
                    , rotateString -orientation
                    , translateString
                        (coin.centerDirection
                            |> scale coin.radius
                        )
                    ]
            , Svg.Attributes.fill "#f73"
            ]
            []


view : Model -> Html Msg
view model =
    Svg.svg
        [ Svg.Attributes.width "750"
        , Svg.Attributes.height "500"
        , Svg.Attributes.viewBox "0 0 750 500"
        ]
        [ model.flatCoins
            |> List.map renderFlatCoin
            |> Svg.g []
        , model.flippingCoins
            |> List.map renderFlippingCoin
            |> Svg.g []
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , subscriptions = \_ -> Mouse.moves MouseMove
        , update = update
        , view = view
        }
