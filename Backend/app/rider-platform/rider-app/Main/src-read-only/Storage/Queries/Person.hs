{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.Person (module Storage.Queries.Person, module ReExport) where

import qualified Data.Time
import qualified Domain.Types.Person
import Kernel.Beam.Functions
import Kernel.External.Encryption
import qualified Kernel.External.Payment.Interface.Types
import qualified Kernel.External.Whatsapp.Interface.Types
import Kernel.Prelude
import qualified Kernel.Prelude
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Kernel.Utils.Version
import qualified Sequelize as Se
import qualified Storage.Beam.Person as Beam
import Storage.Queries.PersonExtra as ReExport

create :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.Person.Person -> m ())
create = createWithKV

createMany :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => ([Domain.Types.Person.Person] -> m ())
createMany = traverse_ create

deleteById :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
deleteById id = do deleteWithKV [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

findById :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Person -> m (Maybe Domain.Types.Person.Person))
findById id = do findOneWithKV [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

findByReferralCode :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Text -> m (Maybe Domain.Types.Person.Person))
findByReferralCode referralCode = do findOneWithKV [Se.Is Beam.referralCode $ Se.Eq referralCode]

findPersonByCustomerReferralCode :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Text -> m (Maybe Domain.Types.Person.Person))
findPersonByCustomerReferralCode customerReferralCode = do findOneWithKV [Se.Is Beam.customerReferralCode $ Se.Eq customerReferralCode]

setIsNewFalse :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
setIsNewFalse isNew id = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.isNew isNew, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateAadhaarVerifiedState :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateAadhaarVerifiedState aadhaarVerified id = do
  _now <- getCurrentTime
  updateOneWithKV [Se.Set Beam.aadhaarVerified aadhaarVerified, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateAverageRating :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Int -> Kernel.Prelude.Int -> Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateAverageRating totalRatings totalRatingScore isValidRating id = do
  _now <- getCurrentTime
  updateOneWithKV
    [ Se.Set Beam.totalRatings totalRatings,
      Se.Set Beam.totalRatingScore totalRatingScore,
      Se.Set Beam.isValidRating isValidRating,
      Se.Set Beam.updatedAt _now
    ]
    [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateBlockedState :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateBlockedState blocked id = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.blocked blocked, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateCustomerPaymentId ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Kernel.Prelude.Maybe Kernel.External.Payment.Interface.Types.CustomerId -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateCustomerPaymentId customerPaymentId id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.customerPaymentId customerPaymentId, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateDeviceToken :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Text -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateDeviceToken deviceToken id = do _now <- getCurrentTime; updateWithKV [Se.Set Beam.deviceToken deviceToken, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateFollowsRide :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateFollowsRide followsRide id = do _now <- getCurrentTime; updateOneWithKV [Se.Set Beam.followsRide followsRide, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateHasDisability :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateHasDisability hasDisability id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.hasDisability hasDisability, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateIsValidRating :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateIsValidRating isValidRating id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.isValidRating isValidRating, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateReferralCodeAndReferredAt ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Kernel.Prelude.Maybe Kernel.Prelude.UTCTime -> Kernel.Prelude.Maybe Kernel.Prelude.Text -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateReferralCodeAndReferredAt referredAt referralCode id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.referredAt referredAt, Se.Set Beam.referralCode referralCode, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateSafetyDrillStatus :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateSafetyDrillStatus hasCompletedMockSafetyDrill id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.hasCompletedMockSafetyDrill hasCompletedMockSafetyDrill, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateWhatsappNotificationEnrollStatus ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Kernel.Prelude.Maybe Kernel.External.Whatsapp.Interface.Types.OptApiMethods -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateWhatsappNotificationEnrollStatus whatsappNotificationEnrollStatus id = do
  _now <- getCurrentTime
  updateWithKV [Se.Set Beam.whatsappNotificationEnrollStatus whatsappNotificationEnrollStatus, Se.Set Beam.updatedAt _now] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

findByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Types.Id.Id Domain.Types.Person.Person -> m (Maybe Domain.Types.Person.Person))
findByPrimaryKey id = do findOneWithKV [Se.And [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]]

updateByPrimaryKey :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Domain.Types.Person.Person -> m ())
updateByPrimaryKey (Domain.Types.Person.Person {..}) = do
  _now <- getCurrentTime
  updateWithKV
    [ Se.Set Beam.aadhaarVerified aadhaarVerified,
      Se.Set Beam.backendAppVersion backendAppVersion,
      Se.Set Beam.blocked blocked,
      Se.Set Beam.blockedAt (Data.Time.utcToLocalTime Data.Time.utc <$> blockedAt),
      Se.Set Beam.blockedByRuleId (Kernel.Types.Id.getId <$> blockedByRuleId),
      Se.Set Beam.blockedCount blockedCount,
      Se.Set Beam.clientBundleVersion (fmap Kernel.Utils.Version.versionToText clientBundleVersion),
      Se.Set Beam.clientConfigVersion (fmap Kernel.Utils.Version.versionToText clientConfigVersion),
      Se.Set Beam.clientOsType (clientDevice <&> (.deviceType)),
      Se.Set Beam.clientOsVersion (clientDevice <&> (.deviceVersion)),
      Se.Set Beam.clientSdkVersion (fmap Kernel.Utils.Version.versionToText clientSdkVersion),
      Se.Set Beam.createdAt createdAt,
      Se.Set Beam.currentCity (Kernel.Prelude.Just currentCity),
      Se.Set Beam.customerPaymentId customerPaymentId,
      Se.Set Beam.customerReferralCode customerReferralCode,
      Se.Set Beam.description description,
      Se.Set Beam.deviceToken deviceToken,
      Se.Set Beam.emailEncrypted (email <&> unEncrypted . (.encrypted)),
      Se.Set Beam.emailHash (email <&> (.hash)),
      Se.Set Beam.enabled enabled,
      Se.Set Beam.falseSafetyAlarmCount (Just falseSafetyAlarmCount),
      Se.Set Beam.firstName firstName,
      Se.Set Beam.followsRide followsRide,
      Se.Set Beam.gender gender,
      Se.Set Beam.hasCompletedMockSafetyDrill hasCompletedMockSafetyDrill,
      Se.Set Beam.hasCompletedSafetySetup hasCompletedSafetySetup,
      Se.Set Beam.hasDisability hasDisability,
      Se.Set Beam.hasTakenValidRide hasTakenValidRide,
      Se.Set Beam.identifier identifier,
      Se.Set Beam.identifierType identifierType,
      Se.Set Beam.isNew isNew,
      Se.Set Beam.isValidRating isValidRating,
      Se.Set Beam.language language,
      Se.Set Beam.lastName lastName,
      Se.Set Beam.merchantId (Kernel.Types.Id.getId merchantId),
      Se.Set Beam.merchantOperatingCityId ((Kernel.Prelude.Just . Kernel.Types.Id.getId) merchantOperatingCityId),
      Se.Set Beam.middleName middleName,
      Se.Set Beam.mobileCountryCode mobileCountryCode,
      Se.Set Beam.mobileNumberEncrypted (mobileNumber <&> unEncrypted . (.encrypted)),
      Se.Set Beam.mobileNumberHash (mobileNumber <&> (.hash)),
      Se.Set Beam.nightSafetyChecks nightSafetyChecks,
      Se.Set Beam.notificationToken notificationToken,
      Se.Set Beam.passwordHash passwordHash,
      Se.Set Beam.referralCode referralCode,
      Se.Set Beam.referredAt referredAt,
      Se.Set Beam.referredByCustomer referredByCustomer,
      Se.Set Beam.registeredViaPartnerOrgId (Kernel.Types.Id.getId <$> registeredViaPartnerOrgId),
      Se.Set Beam.registrationLat registrationLat,
      Se.Set Beam.registrationLon registrationLon,
      Se.Set Beam.role role,
      Se.Set Beam.safetyCenterDisabledOnDate safetyCenterDisabledOnDate,
      Se.Set Beam.shareEmergencyContacts shareEmergencyContacts,
      Se.Set Beam.shareTripWithEmergencyContactOption shareTripWithEmergencyContactOption,
      Se.Set Beam.totalRatingScore totalRatingScore,
      Se.Set Beam.totalRatings totalRatings,
      Se.Set Beam.unencryptedMobileNumber unencryptedMobileNumber,
      Se.Set Beam.updatedAt _now,
      Se.Set Beam.useFakeOtp useFakeOtp,
      Se.Set Beam.whatsappNotificationEnrollStatus whatsappNotificationEnrollStatus
    ]
    [Se.And [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]]
