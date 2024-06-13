{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.DriverStats (module Storage.Queries.DriverStats, module ReExport) where

import qualified Domain.Types.DriverStats
import qualified Domain.Types.Person
import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Common
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Sequelize as Se
import qualified Storage.Beam.DriverStats as Beam
import Storage.Queries.DriverStatsExtra as ReExport
import Storage.Queries.Transformers.DriverStats

create :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.DriverStats.DriverStats -> m ())
create = createWithKV

createMany :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => ([Domain.Types.DriverStats.DriverStats] -> m ())
createMany = traverse_ create

deleteById :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Driver -> m ())
deleteById driverId = do deleteWithKV [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]

updatePayoutEarningsByDriverId :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Common.HighPrecMoney -> Kernel.Types.Id.Id Domain.Types.Person.Driver -> m ())
updatePayoutEarningsByDriverId totalPayoutEarnings driverId = do
  _now <- getCurrentTime
  updateOneWithKV
    [ Se.Set Beam.totalPayoutEarnings (Kernel.Prelude.roundToIntegral totalPayoutEarnings),
      Se.Set Beam.totalPayoutEarningsAmount (Kernel.Prelude.Just totalPayoutEarnings),
      Se.Set Beam.updatedAt _now
    ]
    [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]

updateTotalReferralCount :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Int -> Kernel.Types.Id.Id Domain.Types.Person.Driver -> m ())
updateTotalReferralCount totalReferralCounts driverId = do
  _now <- getCurrentTime
  updateOneWithKV [Se.Set Beam.totalReferralCounts totalReferralCounts, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]

updateTotalValidRidesAndPayoutEarnings ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Kernel.Prelude.Int -> Kernel.Types.Common.HighPrecMoney -> Kernel.Types.Id.Id Domain.Types.Person.Driver -> m ())
updateTotalValidRidesAndPayoutEarnings totalValidActivatedRides totalPayoutEarnings driverId = do
  _now <- getCurrentTime
  updateOneWithKV
    [ Se.Set Beam.totalValidActivatedRides totalValidActivatedRides,
      Se.Set Beam.totalPayoutEarnings (Kernel.Prelude.roundToIntegral totalPayoutEarnings),
      Se.Set Beam.totalPayoutEarningsAmount (Kernel.Prelude.Just totalPayoutEarnings),
      Se.Set Beam.updatedAt _now
    ]
    [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]

findByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Driver -> m (Maybe Domain.Types.DriverStats.DriverStats))
findByPrimaryKey driverId = do findOneWithKV [Se.And [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]]

updateByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.DriverStats.DriverStats -> m ())
updateByPrimaryKey (Domain.Types.DriverStats.DriverStats {..}) = do
  _now <- getCurrentTime
  updateWithKV
    [ Se.Set Beam.bonusEarned (Kernel.Prelude.roundToIntegral bonusEarned),
      Se.Set Beam.bonusEarnedAmount (Kernel.Prelude.Just bonusEarned),
      Se.Set Beam.coinCovertedToCashLeft (Kernel.Prelude.Just coinCovertedToCashLeft),
      Se.Set Beam.currency (Kernel.Prelude.Just currency),
      Se.Set Beam.distanceUnit (Kernel.Prelude.Just distanceUnit),
      Se.Set Beam.earningsMissed (Kernel.Prelude.roundToIntegral earningsMissed),
      Se.Set Beam.earningsMissedAmount (Kernel.Prelude.Just earningsMissed),
      Se.Set Beam.favRiderCount favRiderCount,
      Se.Set Beam.idleSince idleSince,
      Se.Set Beam.isValidRating isValidRating,
      Se.Set Beam.lateNightTrips lateNightTrips,
      Se.Set Beam.ridesCancelled ridesCancelled,
      Se.Set Beam.totalCoinsConvertedCash (Kernel.Prelude.Just totalCoinsConvertedCash),
      Se.Set Beam.totalDistance (getTotalDistance totalDistance),
      Se.Set Beam.totalEarnings (Kernel.Prelude.roundToIntegral totalEarnings),
      Se.Set Beam.totalEarningsAmount (Kernel.Prelude.Just totalEarnings),
      Se.Set Beam.totalRatingScore totalRatingScore,
      Se.Set Beam.totalRatings totalRatings,
      Se.Set Beam.totalPayoutEarnings (Kernel.Prelude.roundToIntegral totalPayoutEarnings),
      Se.Set Beam.totalPayoutEarningsAmount (Kernel.Prelude.Just totalPayoutEarnings),
      Se.Set Beam.totalReferralCounts totalReferralCounts,
      Se.Set Beam.totalRides totalRides,
      Se.Set Beam.totalRidesAssigned totalRidesAssigned,
      Se.Set Beam.totalValidActivatedRides totalValidActivatedRides,
      Se.Set Beam.updatedAt _now
    ]
    [Se.And [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]]
