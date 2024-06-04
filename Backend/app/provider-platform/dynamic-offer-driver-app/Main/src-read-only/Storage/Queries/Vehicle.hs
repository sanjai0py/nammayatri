{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.Vehicle (module Storage.Queries.Vehicle, module ReExport) where

import qualified Domain.Types.Person
import qualified Domain.Types.ServiceTierType
import qualified Domain.Types.Vehicle
import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Sequelize as Se
import qualified Storage.Beam.Vehicle as Beam
import Storage.Queries.VehicleExtra as ReExport

create :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.Vehicle.Vehicle -> m ())
create = createWithKV

createMany :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => ([Domain.Types.Vehicle.Vehicle] -> m ())
createMany = traverse_ create

findById :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Person -> m (Maybe Domain.Types.Vehicle.Vehicle))
findById (Kernel.Types.Id.Id driverId) = do findOneWithKV [Se.Is Beam.driverId $ Se.Eq driverId]

findByRegistrationNo :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Text -> m (Maybe Domain.Types.Vehicle.Vehicle))
findByRegistrationNo registrationNo = do findOneWithKV [Se.Is Beam.registrationNo $ Se.Eq registrationNo]

updateAirConditioned :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateAirConditioned airConditioned (Kernel.Types.Id.Id driverId) = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.airConditioned airConditioned, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateOxygen :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateOxygen oxygen (Kernel.Types.Id.Id driverId) = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.oxygen oxygen, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateSelectedServiceTiers :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => ([Domain.Types.ServiceTierType.ServiceTierType] -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateSelectedServiceTiers selectedServiceTiers (Kernel.Types.Id.Id driverId) = do
  _now <- getCurrentTime
  updateOneWithKV [Se.Set Beam.selectedServiceTiers selectedServiceTiers, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateVariantAndServiceTiers ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Domain.Types.Vehicle.Variant -> [Domain.Types.ServiceTierType.ServiceTierType] -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateVariantAndServiceTiers variant selectedServiceTiers (Kernel.Types.Id.Id driverId) = do
  _now <- getCurrentTime
  updateOneWithKV [Se.Set Beam.variant variant, Se.Set Beam.selectedServiceTiers selectedServiceTiers, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateVehicleModel :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Text -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateVehicleModel model (Kernel.Types.Id.Id driverId) = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.model model, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateVehicleName :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Text -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateVehicleName vehicleName (Kernel.Types.Id.Id driverId) = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.vehicleName vehicleName, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateVehicleVariant :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.Vehicle.Variant -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateVehicleVariant variant (Kernel.Types.Id.Id driverId) = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.variant variant, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

updateVentilator :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateVentilator ventilator (Kernel.Types.Id.Id driverId) = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.ventilator ventilator, Se.Set Beam.updatedAt _now] [Se.Is Beam.driverId $ Se.Eq driverId]

findByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Person -> m (Maybe Domain.Types.Vehicle.Vehicle))
findByPrimaryKey (Kernel.Types.Id.Id driverId) = do findOneWithKV [Se.And [Se.Is Beam.driverId $ Se.Eq driverId]]

updateByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.Vehicle.Vehicle -> m ())
updateByPrimaryKey (Domain.Types.Vehicle.Vehicle {..}) = do
  _now <- getCurrentTime
  updateWithKV
    [ Se.Set Beam.airConditioned airConditioned,
      Se.Set Beam.capacity capacity,
      Se.Set Beam.category category,
      Se.Set Beam.color color,
      Se.Set Beam.energyType energyType,
      Se.Set Beam.luggageCapacity luggageCapacity,
      Se.Set Beam.make make,
      Se.Set Beam.merchantId (Kernel.Types.Id.getId merchantId),
      Se.Set Beam.model model,
      Se.Set Beam.oxygen oxygen,
      Se.Set Beam.registrationCategory registrationCategory,
      Se.Set Beam.registrationNo registrationNo,
      Se.Set Beam.selectedServiceTiers selectedServiceTiers,
      Se.Set Beam.size size,
      Se.Set Beam.variant variant,
      Se.Set Beam.vehicleClass vehicleClass,
      Se.Set Beam.vehicleName vehicleName,
      Se.Set Beam.vehicleRating vehicleRating,
      Se.Set Beam.ventilator ventilator,
      Se.Set Beam.merchantOperatingCityId (Kernel.Types.Id.getId <$> merchantOperatingCityId),
      Se.Set Beam.createdAt createdAt,
      Se.Set Beam.updatedAt _now
    ]
    [Se.And [Se.Is Beam.driverId $ Se.Eq (Kernel.Types.Id.getId driverId)]]
