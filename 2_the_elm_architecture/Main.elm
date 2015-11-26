module Main where


import Html exposing (..)
import Html.Events exposing (onClick)
import StartApp.Simple as StartApp


-- MODEL


-- No likes at the beginning
initialModel = 0


-- Our complete set of valid actions: separate different options with a pipe |
type Action = Like | Reset


-- UPDATE


-- Whatever this function returns becomes the new model
update action model =
  case action of
    Like ->
      model + 1
    Reset ->
      initialModel


-- VIEW


-- `address` is a StartApp-supplied target for actions the page fires.
-- `onClick` is a helper which sends the supplied action to the address
-- where it triggers the update function and re-runs the flow.
view address model =
  div [ ]
  [ text "Likes: "
  , text (toString model)
  , button [ onClick address Like  ] [ text "Like" ]
  , button [ onClick address Reset ] [ text "Reset" ]
  ]


-- MAIN


-- StartApp accepts the 3 elements of our model-update-view flow and
-- wires them together automatically, saving you the trouble of writing
-- that repetitive code yourself.
main =
  StartApp.start
    { model  = initialModel
    , update = update
    , view   = view
    }
