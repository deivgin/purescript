module AppState where

type Todo = { id :: String, text :: String, completed :: Boolean }
type AppState = { todos :: Array Todo }

initialState :: AppState
initialState = { todos: [
  { id: "1", text: "Learn PureScript", completed: false },
  { id: "2", text: "Try PureScript", completed: false },
  { id: "3", text: "Use PureScript", completed: false }
] }
