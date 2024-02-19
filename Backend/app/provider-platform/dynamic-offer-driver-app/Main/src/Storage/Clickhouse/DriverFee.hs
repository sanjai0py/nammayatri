{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Storage.Clickhouse.DriverFee where

import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Driver as Common
import qualified Data.Time.Calendar as Time
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Volunteer as DVolunteer
import Kernel.Prelude
import Kernel.Storage.ClickhouseV2 as CH
import qualified Kernel.Storage.ClickhouseV2.UtilsTH as TH
import Kernel.Types.Common (Centesimal)
import Kernel.Types.Id

-- see module Dashboard.ProviderPlatform.Revenue

data DriverFeeT f = DriverFeeT
  { merchantId :: C f (Id DM.Merchant),
    driverId :: C f (Maybe (Id DP.Driver)),
    status :: C f (Maybe Common.DriverFeeStatus),
    numRides :: C f (Maybe Int),
    platformFee :: C f (Maybe Centesimal), -- is it correct?
    cgst :: C f (Maybe Centesimal), -- is it correct?
    sgst :: C f (Maybe Centesimal), -- is it correct?
    specialZoneAmount :: C f (Maybe Centesimal),
    govtCharges :: C f (Maybe Int),
    collectedAt :: C f CH.DateTime, -- DateTime on clickhouse side
    collectedBy :: C f (Maybe (Id DVolunteer.Volunteer))
  }
  deriving (Generic)

deriving instance Show DriverFee

-- TODO move to TH (quietSnake)
driverFeeTTable :: DriverFeeT (FieldModification DriverFeeT)
driverFeeTTable =
  DriverFeeT
    { merchantId = "merchant_id",
      driverId = "driver_id",
      status = "status",
      numRides = "num_rides",
      platformFee = "platform_fee",
      cgst = "cgst",
      sgst = "sgst",
      specialZoneAmount = "special_zone_amount",
      govtCharges = "govt_charges",
      collectedAt = "collected_at",
      collectedBy = "collected_by"
    }

type DriverFee = DriverFeeT Identity

$(TH.mkClickhouseInstances ''DriverFeeT)

data DriverFeeAggregated = DriverFeeAggregated
  { statusAgg :: Maybe Common.DriverFeeStatus,
    numRidesAgg :: Maybe Int,
    numDrivers :: Int,
    totalAmount :: Maybe Centesimal,
    specialZoneAmt :: Maybe Centesimal,
    date :: Maybe Time.Day,
    hour :: Maybe Int
  }
  deriving (Show)

-- up to 5 columns supported now
findAllByStatus ::
  CH.HasClickhouseEnv CH.ATLAS_DRIVER_OFFER_BPP m =>
  Id DM.Merchant ->
  [Common.DriverFeeStatus] ->
  Maybe UTCTime ->
  Maybe UTCTime ->
  m [DriverFeeAggregated]
findAllByStatus merchantId statuses mbFrom mbTo = do
  driverFeeTuple <-
    CH.findAll $
      CH.select_
        ( \driverFee -> do
            let totalAmount =
                  CH.sum_ $
                    driverFee.platformFee
                      CH.+. driverFee.cgst
                      CH.+. driverFee.sgst
                      CH.+. CH.unsafeCoerceNum @(Maybe Int) @(Maybe Centesimal) driverFee.govtCharges
            let numRides = CH.sum_ driverFee.numRides
            let numDrivers = CH.count_ (CH.distinct driverFee.driverId)
            let specialZoneAmount = CH.sum_ driverFee.specialZoneAmount
            CH.groupBy driverFee.status $ \status -> do
              (status, numRides, numDrivers, totalAmount, specialZoneAmount)
        )
        $ CH.filter_
          ( \driverFee _ ->
              driverFee.merchantId CH.==. merchantId
                CH.&&. driverFee.status `in_` (Just <$> statuses)
                CH.&&. CH.whenJust_ mbFrom (\from -> driverFee.collectedAt >=. CH.DateTime from)
                CH.&&. CH.whenJust_ mbTo (\to -> driverFee.collectedAt <=. CH.DateTime to)
          )
          (CH.all_ @CH.ATLAS_DRIVER_OFFER_BPP driverFeeTTable)
  pure $ mkDriverFeeByStatus <$> driverFeeTuple

-- up to 5 columns supported now
-- mbCollBy = Just [] ---> condition = False
-- mbCollBy = Nothing ---> condition = True
findAllByDate ::
  CH.HasClickhouseEnv CH.ATLAS_DRIVER_OFFER_BPP m =>
  Id DM.Merchant ->
  [Common.DriverFeeStatus] ->
  Maybe UTCTime ->
  Maybe UTCTime ->
  Bool ->
  Maybe [Id DVolunteer.Volunteer] ->
  m [DriverFeeAggregated]
findAllByDate merchantId statuses mbFrom mbTo dayBasis mbCollBy = do
  driverFeeTuple <-
    CH.findAll $
      CH.select_
        ( \driverFee -> do
            let totalAmount =
                  CH.sum_ $
                    driverFee.platformFee
                      CH.+. driverFee.cgst
                      CH.+. driverFee.sgst
                      CH.+. CH.unsafeCoerceNum @(Maybe Int) @(Maybe Centesimal) driverFee.govtCharges
            let numRides = CH.sum_ driverFee.numRides
            let numDrivers = CH.count_ (CH.distinct driverFee.driverId)
            let specialZoneAmount = CH.sum_ driverFee.specialZoneAmount
            let date' = CH.toDate driverFee.collectedAt
            let hour' = if dayBasis then CH.valColumn 0 else CH.toHour driverFee.collectedAt
            CH.groupBy (date', hour') $ \(date, hour) -> do
              (totalAmount, specialZoneAmount, numRides, numDrivers, date, hour)
        )
        $ CH.orderBy_ (\_ (_, _, _, _, date, hour) -> CH.asc (date, hour)) $
          CH.filter_
            ( \driverFee _ ->
                driverFee.merchantId CH.==. merchantId
                  CH.&&. driverFee.status `in_` (Just <$> statuses)
                  CH.&&. CH.whenJust_ mbFrom (\from -> driverFee.collectedAt >=. CH.DateTime from)
                  CH.&&. CH.whenJust_ mbTo (\to -> driverFee.collectedAt <=. CH.DateTime to)
                  CH.&&. CH.whenJust_ mbCollBy (\collBy -> driverFee.collectedBy `in_` (Just <$> collBy))
            )
            $ CH.all_ @CH.ATLAS_DRIVER_OFFER_BPP driverFeeTTable
  pure $ mkDriverFeeByDate <$> driverFeeTuple

mkDriverFeeByStatus :: (Maybe Common.DriverFeeStatus, Maybe Int, Int, Maybe Centesimal, Maybe Centesimal) -> DriverFeeAggregated
mkDriverFeeByStatus (statusAgg, numRidesAgg, numDrivers, totalAmount, specialZoneAmt) = DriverFeeAggregated {date = Nothing, hour = Nothing, ..}

mkDriverFeeByDate :: (Maybe Centesimal, Maybe Centesimal, Maybe Int, Int, Time.Day, Int) -> DriverFeeAggregated
mkDriverFeeByDate (totalAmount, specialZoneAmt, numRidesAgg, numDrivers, date, hour) = DriverFeeAggregated {statusAgg = Nothing, date = Just date, hour = Just hour, ..}
