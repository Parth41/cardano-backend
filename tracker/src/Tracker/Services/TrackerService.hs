module Tracker.Services.TrackerService 
  ( TrackerService(..)
  , mkTrackerService
  ) where 

import Tracker.Models.AppConfig
import Tracker.Repository.ExplorerRepo
import Tracker.Services.Logger as Log

import Explorer.Models
import Explorer.Service
import Explorer.Types

import Prelude
import GHC.Natural as Natural ( naturalToInt )
import RIO

data TrackerService f = TrackerService
 { getOutputs :: f [FullTxOut] 
 }

mkTrackerService 
  :: (Monad f, MonadIO f)
  => TrackerServiceConfig 
  -> ExplorerRepo f 
  -> Explorer f 
  -> TrackerService f
mkTrackerService settings repo client = TrackerService $ getOutputs' settings repo client

getOutputs'
  :: (Monad f, MonadIO f)
  => TrackerServiceConfig
  -> ExplorerRepo f 
  -> Explorer f 
  -> f [FullTxOut]
getOutputs' TrackerServiceConfig{..} ExplorerRepo{..} Explorer{..} = do
  _ <- Log.log "Going to fetch min index"
  minIndex <- getMinIndex
  _ <- Log.log $ "Min index is " ++ show minIndex
  outputs  <- getUspentOutputs minIndex (Limit $ toInteger $ Natural.naturalToInt limitOffset)
  _ <- Log.log $ "Min index is " ++ show minIndex
  _        <- putMinIndex $ Gix $ unGix minIndex + toInteger (length $ items outputs)
  pure $ items outputs
