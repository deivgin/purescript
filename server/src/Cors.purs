module Cors where

import Prelude

import Data.Tuple (Tuple(..))
import HTTPurple (ResponseM)
import HTTPurple.Headers (mkRequestHeaders, toResponseHeaders)


addCorsHeaders :: ResponseM -> ResponseM
addCorsHeaders response = do
  let corsHeaders = mkRequestHeaders
        [ Tuple "Access-Control-Allow-Origin" "*"
        , Tuple "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
        , Tuple "Access-Control-Allow-Headers" "Content-Type, Authorization"
        , Tuple "Access-Control-Max-Age" "86400"
        ]
  res <- response
  pure res { headers = res.headers <> toResponseHeaders corsHeaders }
