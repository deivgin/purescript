module Components.TodoItemList where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Store (Action)
import Model (Todo)

import Components.TodoItem as TodoItem

render :: forall m. Array Todo -> H.ComponentHTML Action () m
render todos =
  HH.ul
    [ HP.class_ (H.ClassName "todo-list") ]
    (map TodoItem.render todos)
