module Route where

import Prelude

import AppState (AppState)
import Data.Generic.Rep (class Generic)
import Effect.Ref (Ref)
import HTTPurple (Request, ResponseM)
import HTTPurple.Body (toString)
import Route.AddTodo as AddTodoRoute
import Route.GetTodos as GetTodosRoute
import Route.RemoveTodo as RemoveTodoRoute
import Routing.Duplex as RD
import Routing.Duplex.Generic as RG
import Routing.Duplex.Generic.Syntax ((/))

data Route =  GetTodos | AddTodo | RemoveTodo String
derive instance Generic Route _

route :: RD.RouteDuplex' Route
route = RD.root $ RG.sum
  { "GetTodos": "todos" / RG.noArgs
  , "AddTodo": "todos" / "add" / RG.noArgs
  , "RemoveTodo": "todos" / "remove" / RD.segment
  }

router :: Ref AppState -> Request Route -> ResponseM
router state { route: GetTodos } = GetTodosRoute.handler state
router state { route: AddTodo, body } = do
  bodyString <- toString body
  AddTodoRoute.handler state bodyString
router state { route: RemoveTodo todoId } = RemoveTodoRoute.handler state todoId
