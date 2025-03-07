module Main where

import Prelude

import AppState (initialState)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Ref as Ref
import HTTPurple (ServerM, serve)
import Route (route, router)

main :: ServerM
main = do
  stateRef <- liftEffect $ Ref.new initialState

  serve { hostname: "localhost" , port: 8080, onStarted } { route, router: router stateRef }
  where
  onStarted = do
    log " ┌─────────────────────────────────────────┐"
    log " │                                         │"
    log " │   Todo App Server                       │"
    log " │   Running on port 8080                  │"
    log " │                                         │"
    log " │   Ready to manage your tasks!           │"
    log " │                                         │"
    log " └─────────────────────────────────────────┘"
