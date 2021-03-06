module DrawTree exposing (draw)

import TreeDiagram
import TreeDiagram.Svg
import Svg exposing (..)
import Svg.Attributes exposing (..)


draw : TreeDiagram.Tree String -> Svg msg
draw =
    TreeDiagram.Svg.draw
        { orientation = TreeDiagram.topToBottom
        , levelHeight = 50
        , siblingDistance = 180
        , subtreeDistance = 170
        , padding = 100
        }
        -- TreeDiagram.defaultTreeLayout
        drawNode
        drawLine


drawLine : ( Float, Float ) -> Svg msg
drawLine ( targetX, targetY ) =
    line
        [ x1 "0"
        , y1 "0"
        , x2 (toString targetX)
        , y2 (toString targetY)
        , stroke "black"
        ]
        []


drawNode : String -> Svg msg
drawNode n =
    let
        w =
            (String.length n * 9)
                |> Basics.max 50
    in
        g
            []
            [ rect
                [ x <| toString (toFloat -w / 2)
                , y "-6"
                , width <| toString w
                , height "32"
                , stroke "black"
                , fill "white"
                ]
                []
              -- circle [ r "16", stroke "black", fill "white", cx "0", cy "0" ] []
            , text_ [ textAnchor "middle", transform "translate(0,15)" ] [ text n ]
            ]
