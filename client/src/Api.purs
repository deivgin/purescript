module Api where

import Prelude
import Request (request)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson, printJsonDecodeError)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Model (Todo)


getTodos :: Aff (Either String (Array Todo))
getTodos =
  request GET "/todos" Nothing decodeTodos
  where
    decodeTodos :: Json -> Either String (Array Todo)
    decodeTodos json = case decodeJson json of
      Left err -> Left (printJsonDecodeError err)
      Right result -> Right result

createTodo :: String -> Aff (Either String Todo)
createTodo text =
  request POST "/todos" (Just $ encodeJson { text, completed: false }) decodeTodo
  where
    decodeTodo :: Json -> Either String Todo
    decodeTodo json = case decodeJson json of
      Left err -> Left (printJsonDecodeError err)
      Right result -> Right result

updateTodo :: Todo -> Aff (Either String Todo)
updateTodo todo =
  request GET ("/todos/" <> show todo.id) (Just $ encodeJson todo) decodeTodo
  where
    decodeTodo :: Json -> Either String Todo
    decodeTodo json = case decodeJson json of
      Left err -> Left (printJsonDecodeError err)
      Right result -> Right result

deleteTodo :: Int -> Aff (Either String Unit)
deleteTodo id =
  request GET ("/todos/" <> show id) Nothing (\_ -> Right unit)
