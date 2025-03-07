module AppState where

import Data.Map (Map, fromFoldable)
import Data.Tuple (Tuple(..))

type Todo = { id :: String, text :: String, completed :: Boolean }
type AppState = { todos :: Map String Todo }

initialState :: AppState
initialState = { todos: defaultTodos }

defaultTodos :: Map String Todo
defaultTodos = fromFoldable
  [ Tuple "todo-1" { id: "todo-1", text: "Learn PureScript", completed: true }
  , Tuple "todo-2" { id: "todo-2", text: "Build a web app", completed: false }
  , Tuple "todo-3" { id: "todo-3", text: "Write documentation", completed: false }
  , Tuple "todo-4" { id: "todo-4", text: "Add routing to application", completed: false }
  , Tuple "todo-5" { id: "todo-5", text: "Implement state management", completed: false }
  ]
