module Components.TodoItem where

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Store (Action(..))
import Model (Todo)


render :: forall m. Todo -> H.ComponentHTML Action () m
render todo =
  HH.li
    [ HP.class_ (H.ClassName if todo.completed then "completed" else "") ]
    [ HH.input
        [ HP.type_ HP.InputCheckbox
        , HP.checked todo.completed
        , HE.onClick \_ -> ToggleTodo todo.id
        ]
    , HH.span [] [ HH.text todo.text ]
    , HH.button
        [ HE.onClick \_ -> DeleteTodo todo.id ]
        [ HH.text "Delete" ]
    ]
