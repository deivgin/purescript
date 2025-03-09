module Route.UpdateTodo where

import Prelude

import AppState (AppState, isTodoWithId)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode (decodeJson, (.:))
import Data.Argonaut.Decode.Class (class DecodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Array (findIndex, updateAt, (!!))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Effect.Class (liftEffect)
import Effect.Ref (Ref, modify, read)
import HTTPurple (ResponseM, ok, badRequest)
import HTTPurple.Response (response)
import HTTPurple.Status (notFound)

newtype UpdateTodoRequest = UpdateTodoRequest { completed :: Boolean }

instance DecodeJson UpdateTodoRequest where
  decodeJson json = do
    obj <- decodeJson json
    completed <- obj .: "completed"
    pure $ UpdateTodoRequest { completed }


handler :: Ref AppState -> String -> String -> ResponseM
handler stateRef todoId body = do
  case jsonParser body of
    Left err -> badRequest $ "Invalid JSON: " <> show err

    Right json ->
      case decodeJson json of
        Left err -> badRequest $ "Invalid request format: " <> show err

        Right (UpdateTodoRequest request) -> do
          state <- liftEffect $ read stateRef

          let todoIndex = findIndex (isTodoWithId todoId) state.todos

          case todoIndex of
            Nothing -> do
              let errorMsg = stringify $ encodeJson { error: "Todo not found", id: todoId }
              response notFound errorMsg

            Just index ->
              case state.todos !! index of
                Nothing -> do
                  let errorMsg = stringify $ encodeJson { error: "Todo not found at computed index", id: todoId }
                  response notFound errorMsg

                Just todo -> do
                  let updatedTodo = todo { completed = request.completed }
                      updatedTodos = fromMaybe state.todos (updateAt index updatedTodo state.todos)

                  _ <- liftEffect $ modify (\s -> s { todos = updatedTodos }) stateRef
                  ok $ stringify $ encodeJson updatedTodo
