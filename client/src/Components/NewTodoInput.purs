module Components.NewTodoInput where

import Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Store (Action(..), State)

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.form
    [ HE.onSubmit AddTodo ]
    [ HH.input
        [ HP.type_ HP.InputText
        , HP.value state.newTodoText
        , HP.placeholder "What needs to be done?"
        , HE.onValueInput UpdateNewTodoText
        ]
    , HH.button
        [ HP.type_ HP.ButtonSubmit
        , HP.disabled (state.newTodoText == "")
        ]
        [ HH.text "Add" ]
    ]
