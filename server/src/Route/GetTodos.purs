module Route.GetTodos where

import Prelude

import AppState (AppState)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Encode (encodeJson)
import Effect.Ref (Ref, read)
import Effect.Class (liftEffect)
import HTTPurple (ResponseM, ok)

handler :: Ref AppState -> ResponseM
handler stateRef = do
  state <- liftEffect $ read stateRef
  ok (stringify $ encodeJson state.todos)
