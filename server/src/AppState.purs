module AppState where

import Data.Map (Map, empty)

type Todo = { id :: String, text :: String, completed :: Boolean }
type AppState = { todos :: Map String Todo }

initialState :: AppState
initialState = { todos: empty }
