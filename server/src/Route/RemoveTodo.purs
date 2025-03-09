module Route.RemoveTodo where

import Prelude

import AppState (AppState, isTodoWithId)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Array (filter, find)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Ref (Ref, modify, read)
import HTTPurple (ResponseM, ok)
import HTTPurple.Response (response)
import HTTPurple.Status (notFound)

handler :: Ref AppState -> String -> ResponseM
handler stateRef todoId = do
  state <- liftEffect $ read stateRef

  case find (isTodoWithId todoId) state.todos of
    Nothing -> do
      let errorMsg = stringify $ encodeJson { error: "Todo not found", id: todoId }
      response notFound errorMsg

    Just todo -> do
      _ <- liftEffect $ modify removeTodo stateRef
      ok $ stringify $ encodeJson { success: true, id: todoId, todo }
      where
      removeTodo s = s { todos = filter (not isTodoWithId todoId) s.todos }
