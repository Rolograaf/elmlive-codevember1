module Main exposing (..)

import Html exposing (..)
import Html.Attributes
import Random


boardWidth : Int
boardWidth =
    10


boardHeight : Int
boardHeight =
    10


tileWidth : Int
tileWidth =
    100


tileDepth : Int
tileDepth =
    83


tileHeight : Int
tileHeight =
    41


type alias Character =
    { location : ( Int, Int )
    , image : String
    }


characterImages : List String
characterImages =
    [ "PlanetCute PNG/Character Horn Girl.png"
    , "PlanetCute PNG/Character Cat Girl.png"
    , "PlanetCute PNG/Character Pink Girl.png"
    , "PlanetCute PNG/Character Princess Girl.png"
    , "PlanetCute PNG/Character Boy.png"
    ]


type alias Model =
    { characters :
        List Character
        --, resources : Dict
    }


initialModel : Model
initialModel =
    { characters = [ Character ( 3, 3 ) "PlanetCute PNG/Character Horn Girl.png" ]
    }


type Msg
    = Start (List ( Int, Int ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start characterLocations ->
            ( { characters = List.map2 Character characterLocations characterImages }, Cmd.none )


renderTile : Int -> ( Int, Int ) -> String -> Html msg
renderTile z ( x, y ) imageSrc =
    Html.img
        [ Html.Attributes.src imageSrc
        , Html.Attributes.width tileWidth
        , Html.Attributes.style
            [ ( "position", "absolute" )
            , ( "left", (toString <| x * tileWidth) ++ "px" )
            , ( "top", (toString <| y * tileDepth - z * tileHeight) ++ "px" )
            ]
        ]
        []


renderRow : Int -> Html msg
renderRow y =
    List.range 0 boardWidth
        |> List.map
            (\x -> renderTile 0 ( x, y ) "PlanetCute PNG/Grass Block.png")
        |> Html.div
            []


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.style
            [ ( "position", "relative" )
            , ( "width", "100vw" )
            , ( "height", "100vh" )
            ]
        ]
        [ List.range 0 boardHeight
            |> List.map
                (\y -> renderRow y)
            |> Html.div []
        , model.characters
            |> List.map (\c -> renderTile 1 c.location c.image)
            |> Html.div []
        ]


randomLocation : Random.Generator ( Int, Int )
randomLocation =
    Random.map2 (,)
        (Random.int 0 boardWidth)
        (Random.int 0 boardHeight)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Random.generate Start (Random.list 5 randomLocation) )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
