module Main where

import Prelude

import Effect.Console (log)
import HTTPurple (ServerM, serve)
import Route (route, router)


main :: ServerM
main = do
  serve { hostname: "localhost" , port: 8080, onStarted } { route, router }
  where
  onStarted = do
    log " ┌────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                 │"
    log " │                                            │"
    log " │ To test, run:                              │"
    log " │  > curl localhost:8080   # => hello world! │"
    log " │  > curl localhost:8080/todos              │"
    log " └────────────────────────────────────────────┘"
