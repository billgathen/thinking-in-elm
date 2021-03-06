module Main where

import Html exposing (..)
import Html.Events exposing (onClick)
import Task exposing (Task)
import Effects exposing (Never)
import StartApp


-- MODEL


initialLikes = 0


initialModel =
  ( initialLikes
  , Effects.none
  )


type Action = Like | Reset | NoOp


-- UPDATE


update log action model =
  let
    liked = model + 1
    reset = initialLikes
  in
    case action of
      Like ->
        ( liked, log liked )
      Reset ->
        ( reset, log reset )
      NoOp ->
        ( model, Effects.none )


log outbox message =
  Signal.send outbox.address (toString message)
  |> Task.map (\t -> NoOp)
  |> Effects.task
    

-- VIEW


view address model =
  div [ ]
  [ text "Likes: "
  , text (toString model)
  , button [ (onClick address Like)  ] [ text "Like" ]
  , button [ (onClick address Reset) ] [ text "Reset" ]
  ]


-- MAIN


-- partially-apply update with partially-applied log function!
updateWithLogging =
    update (log outbox)


app =
  StartApp.start
    { init = initialModel
    , update = updateWithLogging
    , view = view
    , inputs = [ jsLikesActions ]
    }

  
main =
  app.html


-- SIGNALS


outbox : Signal.Mailbox String
outbox =
  Signal.mailbox ""


port logger : Signal String
port logger =
  outbox.signal

  
port tasks : Signal (Task Never ())
port tasks =
  app.tasks


port jsLikes : Signal String


jsLikesActions : Signal Action
jsLikesActions =
  Signal.map (\str -> Like) jsLikes
