module Route.AddTodo where

import Prelude

import AppState (AppState)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode ((.:), decodeJson)
import Data.Argonaut.Decode.Class (class DecodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..))
import Data.Map (insert)
import Effect.Class (liftEffect)
import Effect.Ref (Ref, modify)
import HTTPurple (ResponseM, ok, badRequest)

newtype AddTodoRequest = AddTodoRequest { text :: String }

instance DecodeJson AddTodoRequest where
  decodeJson json = do
    obj <- decodeJson json
    text <- obj .: "text"
    pure $ AddTodoRequest { text }

handler :: Ref AppState -> String -> ResponseM
handler stateRef body = do
  case jsonParser body of
    Left err -> badRequest $ "Invalid JSON: " <> show err
    Right json ->
      case decodeJson json of
        Left err -> badRequest $ "Invalid request format: " <> show err
        Right (AddTodoRequest request) -> do
          let todoId = "todo-" <> request.text

          let newTodo = { id: todoId, text: request.text, completed: false }

          _ <- liftEffect $ modify (\state ->
            { todos: insert todoId newTodo state.todos }
          ) stateRef

          ok $ stringify $ encodeJson newTodo
