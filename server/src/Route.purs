module Route where

import AppState (AppState)
import Data.Generic.Rep (class Generic)
import Effect.Ref (Ref)
import HTTPurple (Request, ResponseM)
import Prelude (($))
import Route.GetTodos as GetTodosRoute
import Routing.Duplex as RD
import Routing.Duplex.Generic as RG
import Routing.Duplex.Generic.Syntax ((/))


data Route =  GetTodos
derive instance Generic Route _

route :: RD.RouteDuplex' Route
route = RD.root $ RG.sum
  { "Home": "home" / RG.noArgs
  , "GetTodos": "todos" / RG.noArgs
  }

router :: Ref AppState -> Request Route -> ResponseM
router state { route: GetTodos } = GetTodosRoute.handler state
