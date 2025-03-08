module Main where

import Prelude

import AppState (initialState)
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Ref as Ref
import HTTPurple (ServerM, serve, ok)
import HTTPurple.Headers (mkRequestHeaders, toResponseHeaders)
import Route (route, router)
import HTTPurple.Method (read, Method(..))


main :: ServerM
main = do
  stateRef <- liftEffect $ Ref.new initialState

  serve
    { hostname: "localhost" , port: 8081, onStarted }
    { route
    , router: \req -> do
        -- Add CORS headers to all responses
        let withCorsHeaders response = do
              let corsHeaders = mkRequestHeaders
                    [ Tuple "Access-Control-Allow-Origin" "*"
                    , Tuple "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
                    , Tuple "Access-Control-Allow-Headers" "Content-Type, Authorization"
                    , Tuple "Access-Control-Max-Age" "86400"
                    ]
              pure $ response { headers = toResponseHeaders corsHeaders }

        if req.method == Options
          then do
            liftEffect $ log $ "OPTION"
            ok "" >>= withCorsHeaders
          else do
            liftEffect $ log $ "Request received: " <> show req.method
            -- For regular requests, use the router and then add CORS headers
            response <- router stateRef req
            withCorsHeaders response
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
