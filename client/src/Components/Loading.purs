module Components.Loading where

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Store (Action)

render :: forall m. Boolean -> H.ComponentHTML Action () m
render isLoading =
  if isLoading
    then HH.div [ HP.class_ (H.ClassName "loading") ] [ HH.text "Loading..." ]
    else HH.text ""
