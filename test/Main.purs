module Test.Main where

import Prelude

import Cache (db, host, newConn, port, socketKeepAlive) as C
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Data.Either (Either(..))
import Data.Options ((:=))
import Test.Basic (basicTest)
import Test.Hash (hashTest)
import Test.List (listTest)
import Test.Multi (multiTest)
import Test.PubSub (pubsubTest)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (run)
import Test.Stream (streamTest)

startTest :: Aff _ Unit
startTest = do
    let cacheOpts = C.host := "127.0.0.1" <> C.port := 6379 <> C.db := 0 <> C.socketKeepAlive := true
    eCacheConn <- C.newConn cacheOpts
    liftEff $ run [consoleReporter] do
       case eCacheConn of
         Right cacheConn -> do
            basicTest cacheConn
            pubsubTest cacheConn
            listTest cacheConn
            hashTest cacheConn
            multiTest cacheConn
            streamTest cacheConn
         Left err        -> do
            describe "Connection" do
               it "fails" do
                  fail $ show err

main :: Eff _ Unit
main = launchAff startTest *> pure unit
