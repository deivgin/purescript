module Main where

import Prelude
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Todo as Todo

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  -- We're discarding the return value with _ since we don't need it
  _ <- runUI Todo.component unit body
  pure unit
