# ElmLive - Codevember Day 1 (2016)

## Following along @avh4 at [youtube](https://www.youtube.com/watch?v=Z0yKvWqkqyE)

thanks Aaron!

- [#Codevember on twitter](https://twitter.com/codevember_)
- [Codevember website day 1](http://codevember.xyz/day/1)

![animated on browser refresh](day1/animated.gif)

making use of [Kwarrtz/render](http://package.elm-lang.org/packages/Kwarrtz/render/latest) SVG render package making use of Random and the Random-extra package

## commands

- `elm-package install Kwarrtz/render`
- `elm-package install elm-community/random-extra`
- `npm install --save-dev elm elm-live` for the watch/make functionality
- `npm run elm-live` to start the server ( or `./node_modules/.bin/elm-live ./day1/Main.elm --open )

# continued day 2

## same repository but now in subfolders

- [elmlive Codevember day 2](https://www.youtube.com/watch?v=OBYVWaAIosM)

  ### result

  ![animated](day2/animated.gif)

  ## commands

- `npm run live2` to start the server ( or `./node_modules/.bin/elm-live ./day2/Main.elm --open )

# continued day 3

making a Japanese Wave inspired graphic

- [elmlive Codevember day 2](https://www.youtube.com/watch?v=KcXfvS-sl8A)
- ![animated](day3/animated.gif)

## commands

- `npm run live3` to start the server ( or `./node_modules/.bin/elm-live ./day3/Main.elm --open )

# continued day 4

Day 4 of Codevember 2016\. We color triangles using the ColourLovers API, and have problems with CORS.

- [elmlive Codevember day 4](https://youtu.be/rE7ozNZkuO0?list=PLDA4wlOlLJvXAEsJDje4hdLazsihZiQNf)
- using this [hsl color picker](http://hslpicker.com/#faffdb)
- NOT using this [ColourLovers API](http://www.colourlovers.com/api) ALAS...
- in particular [pallet, random, json](http://www.colourlovers.com/api/palettes/random?format=json) is copied as local file
- using [color-extra package](http://package.elm-lang.org/packages/eskimoblood/elm-color-extra/latest)
- using [http-server](https://www.npmjs.com/package/http-server) to serve the local colors file (since CORS will not let us use ColourLovers)
- ![animated as refreshing the browser would](day4/animated.gif)

## commands

- `elm-package install evancz/elm-http` we will be using Http for first time in Elmlive-Codevember
- `elm-package install eskimoblood/elm-color-extra` for hex helper function
- `npm install http-server -g` for local server
- `npm run color-server` or `http-server -p 8001 --cors` to start the server since CORS does not let us use ColourLovers API!
- `npm run live4` to start the server ( or `./node_modules/.bin/elm-live ./day4/Main.elm --open )
