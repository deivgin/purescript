module Store where

import Prelude

import Api as Api
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Web.Event.Event (Event)
import Web.Event.Event as Event
import Data.Array (filter, find)
import Model (Todo)

type State =
  { todos :: Array Todo
  , newTodoText :: String
  , errorMessage :: Maybe String
  , isLoading :: Boolean
  }

data Action
  = Initialize
  | LoadTodos
  | UpdateNewTodoText String
  | AddTodo Event
  | ToggleTodo String
  | DeleteTodo String

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction = case _ of
  Initialize -> handleAction LoadTodos

  LoadTodos -> do
    H.modify_ \state -> state { isLoading = true, errorMessage = Nothing }
    result <- H.liftAff Api.getTodos
    case result of
      Left err ->
        H.modify_ \state -> state { errorMessage = Just err, isLoading = false }
      Right todos ->
        H.modify_ \state -> state { todos = todos, isLoading = false }

  UpdateNewTodoText text -> do
    H.modify_ \state -> state { newTodoText = text }

  AddTodo event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    if state.newTodoText == "" then
      pure unit
    else do
      H.modify_ \s -> s { isLoading = true, errorMessage = Nothing }
      result <- H.liftAff $ Api.createTodo state.newTodoText
      case result of
        Left err ->
          H.modify_ \s -> s { errorMessage = Just err, isLoading = false }
        Right newTodo ->
          H.modify_ \s -> s { todos = s.todos <> [newTodo], newTodoText = "", isLoading = false }


  ToggleTodo id -> do
    state <- H.get
    case find (\todo -> todo.id == id) state.todos of
      Nothing -> pure unit
      Just todo -> do
        let updatedTodo = todo { completed = not todo.completed }
        H.modify_ \s -> s { isLoading = true, errorMessage = Nothing }
        result <- H.liftAff $ Api.updateTodo updatedTodo
        case result of
          Left err ->
            H.modify_ \s -> s { errorMessage = Just err, isLoading = false }
          Right _ ->
            H.modify_ \s -> s {
              todos = map (\t -> if t.id == id then updatedTodo else t) s.todos,
              isLoading = false
            }

  DeleteTodo id -> do
    response <- H.liftAff $ Api.deleteTodo id
    case response of
      Right _ -> do
        H.modify_ \state -> state { todos = filter (\todo -> todo.id /= id) state.todos }
      Left error -> do
        H.modify_ \state -> state { errorMessage = Just error }
