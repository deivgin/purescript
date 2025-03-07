module Request where

import Prelude

import Affjax.RequestBody as AXRB
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as AXRF
import Affjax.Web as AX
import Data.Argonaut.Core (Json)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.MediaType (MediaType(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)

baseUrl :: String
baseUrl = "http://localhost:8081"

request ::
  forall a.
  Method ->
  String ->
  Maybe Json ->
  (Json -> Either String a) ->
  Aff (Either String a)
request method path body decoder = do
  let url = baseUrl <> path
      headers = [ ContentType (MediaType "application/json") ]

  response <- case method, body of
    GET, _ -> AX.request $ AX.defaultRequest
      { url = url
      , method = Left GET
      , responseFormat = AXRF.json
      }
    DELETE, _ -> AX.request $ AX.defaultRequest
      { url = url
      , method = Left DELETE
      , responseFormat = AXRF.json
      }
    _, Just b -> AX.request $ AX.defaultRequest
      { url = url
      , method = Left method
      , headers = headers
      , content = Just (AXRB.json b)
      , responseFormat = AXRF.json
      }
    _, Nothing -> AX.request $ AX.defaultRequest
      { url = url
      , method = Left method
      , headers = headers
      , responseFormat = AXRF.json
      }

  case response of
    Left err -> do
      let errorMsg = "Request failed: " <> AX.printError err
      log errorMsg
      pure $ Left errorMsg
    Right res -> case decoder res.body of
      Left err -> do
        let errorMsg = "Decode failed: " <> err
        log errorMsg
        pure $ Left errorMsg
      Right a -> pure $ Right a
