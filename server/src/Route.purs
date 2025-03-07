module Route where

import Prelude (($))
import Data.Generic.Rep (class Generic)
import HTTPurple (Request, ResponseM, ok)
import Routing.Duplex as RD
import Routing.Duplex.Generic as RG
import Routing.Duplex.Generic.Syntax ((/))

data Route = Hello | GoodBye
derive instance Generic Route _

route :: RD.RouteDuplex' Route
route = RD.root $ RG.sum
  { "Hello": "hello" / RG.noArgs
  , "GoodBye": "goodbye" / RG.noArgs
  }

router :: Request Route -> ResponseM
router { route: Hello } = ok "hello"
router { route: GoodBye } = ok "goodbye"
