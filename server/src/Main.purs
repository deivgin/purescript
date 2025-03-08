module Main where

import Prelude

import AppState (initialState)
import Cors (addCorsHeaders)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Ref as Ref
import HTTPurple (ServerM, serve, ok)
import HTTPurple.Method (Method(..))
import Route (route, router)


main :: ServerM
main = do
  stateRef <- liftEffect $ Ref.new initialState

  serve
    { hostname: "localhost" , port: 8081, onStarted }
    { route
    , router: \req -> do
        if req.method == Options
          then do
            addCorsHeaders (ok "")
          else do
            response <- router stateRef req
            addCorsHeaders (pure response)
    }
  where
  onStarted = do
    log " ┌─────────────────────────────────────────┐"
    log " │                                         │"
    log " │   Todo App Server                       │"
    log " │   Running on port 8081                  │"
    log " │                                         │"
    log " │   Ready to manage your tasks!           │"
    log " │                                         │"
    log " └─────────────────────────────────────────┘"
