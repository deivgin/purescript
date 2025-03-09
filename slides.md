---
marp: true
theme: dark
---

# Functional programming in web with PureScript

by Deividas Gineitis

---

## Table of contents

1. Introductions

---

## Structure of the presentation

- This presentation will try to provide a quick overview of utilizing PureScript as a functional programming language for creating Web applications.
- The presentation will go through the project solutions and along the way try to explain interesting concepts and ways that PureScript can be used for web development.
- Disclaimer: This code is by far not the best or the only way to use this technology, but we can learn some interesting things from it. Also this is a high level overview, just skimming the surface of PureScript and functional programming.

---

## Introduction

---

## Project overview

- Example web application is a simple Todo application with CRUD (Create, Read, Update, Delete) functionality.

- It is separated into two PureScript projects:

  1. Server (Backend)
  2. Client (Frontend)

---

### Server

- The Server is a simple api server that helps us create and manipulate Todo items. For this demo project persistence was not used, as app state is managed in an interesting way in PureScript.

- Let us start our DEMO from the `AppState.purs` file

---

### AppState.purs and PureScript typing system

- PureScript is a typed language, thus it allows us to type our code. By default we have access to three core JavaScript types: `String`, `Number`, `Boolean`, but we also have access to other common types, such as `Int`, `Char`, `Record`, `Array` and others.
- We can also define our own custom types with the help of _synonym_, such as `Todo`.
- We can also define and use _type constructors_, such as `Array`. These constructors require another type, as an `Array` is not just an array, it is an _Array of something_. In our case `Array Todo` - array of todo items.

```purescript
type Todo = { id :: String, text :: String, completed :: Boolean }

type AppState = { todos :: Array Todo }
```

---

- We can also define variables and functions ny providing a type declaration.
- PureScript is indentation-sensitive
- All functions in PureScript are _curried_

```purescript
initialState :: AppState
initialState = { todos: [
  { id: "1", text: "Learn PureScript", completed: false },
  { id: "2", text: "Try PureScript", completed: false },
  { id: "3", text: "Use PureScript", completed: false }
] }

isTodoWithId :: String -> Todo -> Boolean
isTodoWithId todoId todo = todo.id == todoId
```

---

## Main.purs and the Effect monad

- PureScript projects start from the Main.purs file, in our server it is where we define and run our http server with the help of the `httpurple` library.
- In this file there are a few interesting concepts:
  - The Do notation
  - The Effect monad
  - Ref mutable reference
  - The `$` symbol and the `infix operator alias`
  - The where keyword

---

### Where keyword

- Where keyword creates local binding scope that helps us define helper functions or values that are only accessible in that scope.
- It gives us several benefits, such as readability, scope control, reuse and organization.

```purescript
main :: ServerM
main = do
  serve { hostname, port, onStarted } { route, router }
  where
  hostname = "localhost"
  port = 8081
  onStarted = do
    log "Server started..."
```

---

### infix operator alias

- PureScript allows us a few interesting things, one of which is we can call functions as `infix` instead of a `prefix`
- We can also give an alias to our infix functions and define new operators, such as instead of calling `add` we can define it as `+`. (This is _similar_ to how the + operator is defined in PureScript itself)
- In our `Main.purs` file we see the `$` operator, which is an infix operator for `apply`, a function that helps us better structure our function execution.

```purescript
add :: Int -> Int -> Int
add a b = a + b

add 1 2

1 `add` 2

infix 4 add as +

1 + 2
```

---

### Monad

- A monad is quite a complex concept in mathematics and programming. Here are some simple definitions:
  - Monad - is a way to structure computations as a sequence of steps, where each step not only produces a value but also some extra information about the computation, such as a potential failure, non-determinism, or side effect.
  - Monad - design pattern in which pipeline implementation are abstracted by wrapping a value in a type.
  - Monad - allow us to chain operations under the restriction that all effects must be represented by the types.

---

### Effect monad

- In PureScript a very important monad is the `Effect` monad, which allows us to work native effects, such as console, random number generation, exceptions and reading/writing mutable state.
- The `Effect` provides us a mutable reference `Ref` that allows us to create, read and modify our application state.

---

## Route.purs

- The file `Route.purs` defines our application api endpoints. We use a routing library to make our route definitions simpler.
- Here we can see a new concepts:
  1. Pattern matching
  2. Algebraic types
  3. Type classes

---

### Pattern matching

- Pattern matching is a common technique in functional programming that allow us to write compact functions with different cases.
- In our routing implementation, we define a router function that has a case for each of our routes.
- PureScript is able to identify what router function case to run based on what instance of route is being used.
- This allows us to handle each route and call its corresponding handler.

```purescript
router :: Ref AppState -> Request Route -> ResponseM
router state { route: GetTodos } = GetTodosRoute.handler state
router state { route: RemoveTodo todoId } = RemoveTodoRoute.handler state todoId
router state { route: AddTodo, body } = do
  bodyString <- toString body
  AddTodoRoute.handler state bodyString
router state { route: UpdateTodo todoId, body } = do
   bodyString <- toString body
   UpdateTodoRoute.handler state todoId bodyString
```

---

### Algebraic types

- Algebraic data types in PureScript is closely related to pattern matching, allowing us to do the same thing but with data types.
- So here we create a new data type `Route` which is a collection of type constructors for our routes. Some have no additional types, others, such as the `RemoveTodo` route, requires a string.

```purescript
data Route =  GetTodos | AddTodo | RemoveTodo String | UpdateTodo String
```

---

### Type classes

- classes here are not the same as in OOP, so they should not be confused with classes from other languages.
- Type classes allow functions to behave differently depending on the types they operate on. They can be taught of as interfaces or contracts.
- In our code, we `derive instance` of `Generic` type class for our Route data type, meaning we allow the compiler to automatically generate a type class instance.
- The `_` lets the compiler to infer the representation type of this instance by itself.

```purescript
derive instance Generic Route _
```

---

## GetTodosRoute.purs

- This is the simplest route handler in our solution and all it does is reads our state object, binds it to `state`, encodes it into json, stringifies it and sends it to the client.
- an interesting part here is the `liftEffect` function.
- the `read` function reads our state reference and produces a `Effect AppState` monad.
- In this handler we work with a Response Monad `ResponseM`, thus we need to "lift" our state into the response context.

```purescript
handler :: Ref AppState -> ResponseM
handler stateRef = do
  state <- liftEffect $ read stateRef
  ok $ stringify $ encodeJson state.todos
```

---

## RemoveTodo.purs

- This route is responsible for removing a todo item from our state.
- Here we see a new `case` expression and usage of the `Maybe` monad

---

### Maybe monad

- The `Maybe` monad abstracts the null value check
- It provides us with two cases:
  1. `Nothing` when there is no value
  2. `Just` when we do have a value.

---

### Case expression

- The `case` expression provides a utility for pattern matching on values.
- It is a way to examine values and execute different code based on its structure.
- In our handler we define a case, where we search for a specific todo item in our state. The `find` returns a `Maybe Todo` monad, that then we match what we do when we do not find (`Nothing`) and when we find (`Just`) the todo item.

```purescript
case find (isTodoWithId todoId) state.todos of
  Nothing -> ...
  Just todo -> ...
```

---

## AddTodo.purs

- This handler is responsible for adding a new todo item into our apps state.
- Here we can see the usage of `Either` monad.
- Also we see _string interpolation_, which in PureScript is defined with `<>`

---

### Either monad

- Either is an elegant solution to computation that might fail.
- It defines two cases for `Left` and `Right`. In our solution, when we tru to parse or decode json we can either fail (`Left`) or succeed (`Right`). So once again by using the case expression we are able to handle both cases.

```purescript
case decodeJson json of
  Left err -> badRequest $ "Invalid request format: " <> show err
  Right (AddTodoRequest request) -> do
    let todoId = "todo-" <> request.text
        newTodo = { id: todoId, text: request.text, completed: false }

    _ <- liftEffect $ modify (\s -> s { todos = snoc s.todos newTodo }) stateRef
    ok $ stringify $ encodeJson newTodo
```

---

## UpdateTodo.purs

- Our last route handles updating the todo state. For this solution we only update the checked property, to keep the solution simple.
- Here we also see the combined usage of `Either` and `Maybe` monads to decode json, find the required item and update it.

---

## Resources

1. https://book.purescript.org/index.html
2. https://en.wikipedia.org/wiki/Currying
3. https://www.youtube.com/watch?v=HIBTu-y-Jwk
4. https://www.youtube.com/watch?v=VgA4wCaxp-Q
