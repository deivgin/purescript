module Todo where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Store (Action(..), handleAction, State)

import Components.ErrorMessage as ErrorMessage
import Components.Loading as Loading
import Components.NewTodoInput as NewTodoInput
import Components.TodoItemList as TodoItemList

initialState :: State
initialState =
  { todos: []
  , newTodoText: ""
  , errorMessage: Nothing
  , isLoading: false
  }

component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState: \_ -> initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        }
    }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ (H.ClassName "todo-app") ]
    [ HH.h1 [] [ HH.text "Todo App" ]
    , NewTodoInput.render state
    , ErrorMessage.render state.errorMessage
    , Loading.render state.isLoading
    , TodoItemList.render state.todos
    ]
