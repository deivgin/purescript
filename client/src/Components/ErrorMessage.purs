module Components.ErrorMessage where

import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Store (Action)

render :: forall m. Maybe String -> H.ComponentHTML Action () m
render = case _ of
  Nothing -> HH.text ""
  Just msg -> HH.div [ HP.class_ (H.ClassName "error") ] [ HH.text msg ]
