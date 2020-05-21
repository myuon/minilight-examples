{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Concurrent.MVar
import Control.Lens
import Control.Monad
import Data.Maybe
import MiniLight
import MiniLight.Lua

mainFile = "src/main.lua"

main :: IO ()
main = runLightT $ runMiniloop
  (defConfig { hotConfigReplacement = Just "src", appConfigFile = Just "" })
  initial
  (const mainloop)
 where
  initial = do
    comp <- registerComponent mainFile =<< liftIO newLuaComponent
    reload mainFile

    return ()

  mainloop :: MiniLoop ()
  mainloop = do
    ref <- view _events
    evs <- liftIO $ tryReadMVar ref

    let notifys = case evs of
          Just evs -> mapMaybe asNotifyEvent evs
          _        -> []
    unless (null notifys) $ reload mainFile
