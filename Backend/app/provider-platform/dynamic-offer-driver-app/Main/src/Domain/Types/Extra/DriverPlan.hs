{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Domain.Types.Extra.DriverPlan where

import Data.Aeson
import qualified Data.Aeson as A
import Kernel.Prelude
import Kernel.Types.Common
import Kernel.Types.Id

-- Extra code goes here --

newtype CommodityData = CommodityData
  { rentedVehicleNumber :: Maybe Text
  }
  deriving (Generic, Show, Ord, Eq)

instance ToJSON CommodityData where
  toJSON = A.genericToJSON A.defaultOptions

instance FromJSON CommodityData where
  parseJSON = A.genericParseJSON A.defaultOptions

data SubscriptionServiceRelatedData = RentedVehicleNumber Text | NoData
  deriving (Generic, Show, Ord, Eq)

instance ToJSON SubscriptionServiceRelatedData where
  toJSON (RentedVehicleNumber vehicleNumber) = A.object ["rentedVehicleNumber" A..= vehicleNumber]
  toJSON NoData = A.object []

instance FromJSON SubscriptionServiceRelatedData where
  parseJSON = A.withObject "SubscriptionServiceRelatedData" $ \o -> do
    rentedVehicleNumber <- o A..:? "rentedVehicleNumber"
    case rentedVehicleNumber of
      Just vehicleNumber -> return (RentedVehicleNumber vehicleNumber)
      Nothing -> return NoData
