module Route.AddTodo where

import Prelude

import AppState (AppState, generateUniqueId)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode ((.:), decodeJson)
import Data.Argonaut.Decode.Class (class DecodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Array (snoc)
import Data.Either (Either(..))
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
          todoId <- liftEffect generateUniqueId
          let newTodo = { id: todoId, text: request.text, completed: false }
          _ <- liftEffect $ modify (\s -> s { todos = snoc s.todos newTodo }) stateRef
          ok $ stringify $ encodeJson newTodo
