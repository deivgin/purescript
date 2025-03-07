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
    log " ┌────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                 │"
    log " │                                            │"
    log " │ To test, run:                              │"
    log " │  > curl localhost:8080   # => hello world! │"
    log " │  > curl localhost:8080/todos              │"
    log " └────────────────────────────────────────────┘"
