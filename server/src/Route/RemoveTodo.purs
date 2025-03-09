module Route.RemoveTodo where

import Prelude

import AppState (AppState, isTodoWithId)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Array (filter, find)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Ref (Ref, modify, read)
import HTTPurple (ResponseM, ok, notFound)

handler :: Ref AppState -> String -> ResponseM
handler stateRef todoId = do
  state <- liftEffect $ read stateRef

  case find (isTodoWithId todoId) state.todos of
    Nothing -> notFound
    Just todo -> do
      _ <- liftEffect $ modify removeTodo stateRef
      ok $ stringify $ encodeJson { success: true, id: todoId, todo }
      where
      removeTodo s = s { todos = filter (not isTodoWithId todoId) s.todos }
