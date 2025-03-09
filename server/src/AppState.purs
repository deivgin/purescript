module AppState where

import Prelude

import Data.DateTime.Instant (unInstant)
import Data.Int as Int
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Now (now)

type Todo = { id :: String, text :: String, completed :: Boolean }
type AppState = { todos :: Array Todo }

initialState :: AppState
initialState = { todos: [
  { id: "1", text: "Learn PureScript", completed: false },
  { id: "2", text: "Try PureScript", completed: false },
  { id: "3", text: "Use PureScript", completed: false }
] }

isTodoWithId :: String -> Todo -> Boolean
isTodoWithId todoId todo = todo.id == todoId

generateUniqueId :: Effect String
generateUniqueId = do
  currentTime <- now
  let Milliseconds ms = unInstant currentTime
      timestamp = show (Int.floor ms)
  pure $ "todoId-" <> timestamp
