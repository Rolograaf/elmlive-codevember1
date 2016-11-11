module Main exposing (..)

import Graphics.Render exposing (..)
import Color exposing (Color)
import Html exposing (Html)
import Html.App
import Random
import Random.Extra
import Http
import Task
import Json.Decode
import Color.Convert


triangle : Float -> Color -> Form msg
triangle size color =
    polygon
        [ ( 0, 0 )
        , ( abs size, 0 )
        , ( abs size / 2, size * sqrt 3 / 2 )
        ]
        |> solidFill color


triangleRow : List Color -> List Triangle -> Form msg
triangleRow palette triangles =
    let
        chooseColor i =
            if List.length palette == 0 then
                Color.black
            else
                palette
                    |> List.drop (i % List.length palette)
                    |> List.head
                    |> Maybe.withDefault Color.black

        step i { size, color } =
            triangle (toFloat size * 50) (chooseColor color)
                |> move (50 * toFloat i) 0
    in
        triangles
            |> List.indexedMap step
            |> group


type alias Model =
    { palette : List Color
    , triangleData : List (List Triangle)
    }


view : Model -> Html msg
view model =
    group
        [ rectangle 750 500
            |> solidFill (Color.rgb 255 255 240)
        , model.triangleData
            |> List.indexedMap (\i sizes -> triangleRow model.palette sizes |> move 0 (toFloat i * 60))
            |> group
            |> move -170 -120
        ]
        |> svg 750 500


modelGenerator : Random.Generator (List (List Triangle))
modelGenerator =
    let
        randomSize =
            Random.int -2 2

        randomRow =
            Random.list 6 (Random.map2 Triangle randomSize (Random.int 0 50))
    in
        Random.list 4 randomRow


type alias Triangle =
    { size : Int, color : Int }


type Msg
    = NewTriangleData (List (List Triangle))
    | NewPalette (List Color)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" msg of
        NewPalette colors ->
            ( { model | palette = colors }, Cmd.none )

        NewTriangleData newData ->
            ( { model | triangleData = newData }, Cmd.none )


paletteDecoder : Json.Decode.Decoder (List Color)
paletteDecoder =
    Json.Decode.tuple1 identity
        (Json.Decode.at [ "colors" ]
            (Json.Decode.map (List.filterMap identity) <|
                (Json.Decode.list (Json.Decode.map Color.Convert.hexToColor Json.Decode.string))
            )
        )


main : Program Never
main =
    Html.App.program
        { init =
            ( { palette = []
              , triangleData = []
              }
            , Cmd.batch
                [ Random.generate NewTriangleData modelGenerator
                , Http.get paletteDecoder
                    "http://localhost:8001/color.json"
                    --"http://www.colourlovers.com/api/palettes/random?format=json"
                    |>
                        Task.perform (always <| NewPalette []) NewPalette
                ]
            )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
