module Model where

import Prelude

import Data.Maybe (Maybe)

type Todo =
  { id :: Int
  , text :: String
  , completed :: Boolean
  }

type State =
  { todos :: Array Todo
  , newTodoText :: String
  , errorMessage :: Maybe String
  , isLoading :: Boolean
  }
