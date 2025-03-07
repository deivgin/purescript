module Todo where

import Data.Maybe (Maybe(..))
import Prelude

import Data.Array (filter)
import Data.Foldable (foldl)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.Event.Event (Event, preventDefault)

type Todo =
  { id :: Int
  , text :: String
  , completed :: Boolean
  }

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
  | ToggleTodo Int
  | DeleteTodo Int

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
    H.modify_ \state -> state { todos = sampleTodos, isLoading = false }

  UpdateNewTodoText text -> do
    H.modify_ \state -> state { newTodoText = text }

  AddTodo event -> do
    H.liftEffect $ preventDefault event
    state <- H.get
    if state.newTodoText == "" then
      pure unit
    else do
      let newId = case state.todos of
                    [] -> 1
                    todos -> 1 + (maximum $ map _.id todos)
      let newTodo = { id: newId, text: state.newTodoText, completed: false }
      H.modify_ \s -> s { todos = s.todos <> [newTodo], newTodoText = "" }

  ToggleTodo id -> do
    H.modify_ \state -> state { todos = map (\todo -> if todo.id == id then todo { completed = not todo.completed } else todo) state.todos }

  DeleteTodo id -> do
    H.modify_ \state -> state { todos = filter (\todo -> todo.id /= id) state.todos }

maximum :: Array Int -> Int
maximum [] = 0
maximum xs = foldl max 0 xs

-- Sample data for testing
sampleTodos :: Array Todo
sampleTodos =
  [ { id: 1, text: "Learn PureScript", completed: true }
  , { id: 2, text: "Build Halogen app", completed: false }
  , { id: 3, text: "Connect to backend API", completed: false }
  ]
