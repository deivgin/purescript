module Todo where

import Prelude

import Api as Api
import Data.Array (filter, find)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.Event.Event (Event)
import Web.Event.Event as Event
import Data.Either (Either(..))
import Model (Todo, State)

data Action
  = Initialize
  | LoadTodos
  | UpdateNewTodoText String
  | AddTodo Event
  | ToggleTodo String
  | DeleteTodo String

initialState :: State
initialState =
  { todos: []
  , newTodoText: ""
  , errorMessage: Nothing
  , isLoading: false
  }

component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState: \_ -> initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        }
    }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ (H.ClassName "todo-app") ]
    [ HH.h1 [] [ HH.text "Todo App" ]
    , renderNewTodoInput state
    , renderErrorMessage state.errorMessage
    , renderLoadingIndicator state.isLoading
    , renderTodos state.todos
    ]

renderNewTodoInput :: forall m. State -> H.ComponentHTML Action () m
renderNewTodoInput state =
  HH.form
    [ HE.onSubmit AddTodo ]
    [ HH.input
        [ HP.type_ HP.InputText
        , HP.value state.newTodoText
        , HP.placeholder "What needs to be done?"
        , HE.onValueInput UpdateNewTodoText
        ]
    , HH.button
        [ HP.type_ HP.ButtonSubmit
        , HP.disabled (state.newTodoText == "")
        ]
        [ HH.text "Add" ]
    ]

renderErrorMessage :: forall m. Maybe String -> H.ComponentHTML Action () m
renderErrorMessage = case _ of
  Nothing -> HH.text ""
  Just msg -> HH.div [ HP.class_ (H.ClassName "error") ] [ HH.text msg ]

renderLoadingIndicator :: forall m. Boolean -> H.ComponentHTML Action () m
renderLoadingIndicator isLoading =
  if isLoading
    then HH.div [ HP.class_ (H.ClassName "loading") ] [ HH.text "Loading..." ]
    else HH.text ""

renderTodos :: forall m. Array Todo -> H.ComponentHTML Action () m
renderTodos todos =
  HH.ul
    [ HP.class_ (H.ClassName "todo-list") ]
    (map renderTodoItem todos)

renderTodoItem :: forall m. Todo -> H.ComponentHTML Action () m
renderTodoItem todo =
  HH.li
    [ HP.class_ (H.ClassName if todo.completed then "completed" else "") ]
    [ HH.input
        [ HP.type_ HP.InputCheckbox
        , HP.checked todo.completed
        , HE.onClick \_ -> ToggleTodo todo.id
        ]
    , HH.span [] [ HH.text todo.text ]
    , HH.button
        [ HE.onClick \_ -> DeleteTodo todo.id ]
        [ HH.text "Delete" ]
    ]

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
        -- Delete was successful, update local state
        H.modify_ \state -> state { todos = filter (\todo -> todo.id /= id) state.todos }
      Left error -> do
        -- Handle error case
        H.modify_ \state -> state { errorMessage = Just error }
