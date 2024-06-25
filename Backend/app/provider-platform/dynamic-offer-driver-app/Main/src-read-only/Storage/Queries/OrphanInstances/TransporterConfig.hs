{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.OrphanInstances.TransporterConfig where

import qualified Data.Aeson
import qualified Domain.Types.Location
import qualified Domain.Types.TransporterConfig
import Kernel.Beam.Functions
import Kernel.External.Encryption
import qualified Kernel.External.Notification.FCM.Types
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Common
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Kernel.Utils.Common
import qualified Storage.Beam.TransporterConfig as Beam

instance FromTType' Beam.TransporterConfig Domain.Types.TransporterConfig.TransporterConfig where
  fromTType' (Beam.TransporterConfigT {..}) = do
    fcmUrl' <- Kernel.Prelude.parseBaseUrl fcmUrl
    pure $
      Just
        Domain.Types.TransporterConfig.TransporterConfig
          { aadhaarImageResizeConfig = (\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< aadhaarImageResizeConfig,
            aadhaarVerificationRequired = aadhaarVerificationRequired,
            acStatusCheckGap = acStatusCheckGap,
            actualRideDistanceDiffThreshold = actualRideDistanceDiffThreshold,
            actualRideDistanceDiffThresholdIfWithinPickupDrop = actualRideDistanceDiffThresholdIfWithinPickupDrop,
            allowDefaultPlanAllocation = allowDefaultPlanAllocation,
            approxRideDistanceDiffThreshold = approxRideDistanceDiffThreshold,
            arrivedPickupThreshold = fromMaybe 100 arrivedPickupThreshold,
            arrivedStopThreshold = arrivedStopThreshold,
            arrivingPickupThreshold = arrivingPickupThreshold,
            automaticRCActivationCutOff = automaticRCActivationCutOff,
            avgSpeedOfVehicle = (\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< avgSpeedOfVehicle,
            badDebtBatchSize = badDebtBatchSize,
            badDebtRescheduleTime = Kernel.Utils.Common.secondsToNominalDiffTime badDebtRescheduleTime,
            badDebtSchedulerTime = Kernel.Utils.Common.secondsToNominalDiffTime badDebtSchedulerTime,
            badDebtTimeThreshold = badDebtTimeThreshold,
            bankErrorExpiry = Kernel.Utils.Common.secondsToNominalDiffTime bankErrorExpiry,
            bookAnyVehicleDowngradeLevel = bookAnyVehicleDowngradeLevel,
            cacheOfferListByDriverId = cacheOfferListByDriverId,
            canAddCancellationFee = canAddCancellationFee,
            canDowngradeToHatchback = canDowngradeToHatchback,
            canDowngradeToSedan = canDowngradeToSedan,
            canDowngradeToTaxi = canDowngradeToTaxi,
            canSuvDowngradeToHatchback = fromMaybe False canSuvDowngradeToHatchback,
            canSuvDowngradeToTaxi = canSuvDowngradeToTaxi,
            canSwitchToInterCity = canSwitchToInterCity,
            canSwitchToRental = canSwitchToRental,
            cancellationDistDiff = cancellationDistDiff,
            cancellationFee = cancellationFee,
            cancellationFeeDisputeLimit = cancellationFeeDisputeLimit,
            cancellationTimeDiff = Kernel.Utils.Common.secondsToNominalDiffTime cancellationTimeDiff,
            checkImageExtractionForDashboard = checkImageExtractionForDashboard,
            coinConversionRate = coinConversionRate,
            coinExpireTime = Kernel.Utils.Common.secondsToNominalDiffTime coinExpireTime,
            coinFeature = coinFeature,
            considerDriversForSearch = considerDriversForSearch,
            considerSpecialZoneRideChargesInFreeTrial = considerSpecialZoneRideChargesInFreeTrial,
            considerSpecialZoneRidesForPlanCharges = considerSpecialZoneRidesForPlanCharges,
            createdAt = createdAt,
            crossTravelCities = crossTravelCities,
            currency = fromMaybe Kernel.Types.Common.INR currency,
            defaultPopupDelay = defaultPopupDelay,
            distanceUnit = Kernel.Prelude.fromMaybe Kernel.Types.Common.Meter distanceUnit,
            dlNumberVerification = dlNumberVerification,
            driverAutoPayExecutionTime = Kernel.Utils.Common.secondsToNominalDiffTime driverAutoPayExecutionTime,
            driverAutoPayExecutionTimeFallBack = Kernel.Utils.Common.secondsToNominalDiffTime driverAutoPayExecutionTimeFallBack,
            driverAutoPayNotificationTime = Kernel.Utils.Common.secondsToNominalDiffTime driverAutoPayNotificationTime,
            driverDistanceToPickupThresholdOnCancel = driverDistanceToPickupThresholdOnCancel,
            driverDistanceTravelledOnPickupThresholdOnCancel = driverDistanceTravelledOnPickupThresholdOnCancel,
            driverFeeCalculationTime = Kernel.Utils.Common.secondsToNominalDiffTime <$> driverFeeCalculationTime,
            driverFeeCalculatorBatchGap = Kernel.Utils.Common.secondsToNominalDiffTime <$> driverFeeCalculatorBatchGap,
            driverFeeCalculatorBatchSize = driverFeeCalculatorBatchSize,
            driverFeeMandateExecutionBatchSize = driverFeeMandateExecutionBatchSize,
            driverFeeMandateNotificationBatchSize = driverFeeMandateNotificationBatchSize,
            driverFeeOverlaySendingTimeLimitInDays = driverFeeOverlaySendingTimeLimitInDays,
            driverFeeRetryThresholdConfig = driverFeeRetryThresholdConfig,
            driverLocationAccuracyBuffer = driverLocationAccuracyBuffer,
            driverPaymentCycleBuffer = Kernel.Utils.Common.secondsToNominalDiffTime driverPaymentCycleBuffer,
            driverPaymentCycleDuration = Kernel.Utils.Common.secondsToNominalDiffTime driverPaymentCycleDuration,
            driverPaymentCycleStartTime = Kernel.Utils.Common.secondsToNominalDiffTime driverPaymentCycleStartTime,
            driverPaymentReminderInterval = Kernel.Utils.Common.secondsToNominalDiffTime driverPaymentReminderInterval,
            driverSmsReceivingLimit = (\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< driverSmsReceivingLimit,
            driverTimeSpentOnPickupThresholdOnCancel = driverTimeSpentOnPickupThresholdOnCancel,
            dropLocThreshold = dropLocThreshold,
            dummyFromLocation = fromMaybe Domain.Types.Location.dummyFromLocationData ((\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< dummyFromLocation),
            dummyToLocation = fromMaybe Domain.Types.Location.dummyToLocationData ((\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< dummyToLocation),
            editLocDriverPermissionNeeded = editLocDriverPermissionNeeded,
            editLocTimeThreshold = editLocTimeThreshold,
            emailOtpConfig = emailOtpConfig,
            enableDashboardSms = enableDashboardSms,
            enableFaceVerification = enableFaceVerification,
            enableTollCrossedNotifications = enableTollCrossedNotifications,
            enableUdfForOffers = enableUdfForOffers,
            fakeOtpEmails = fakeOtpEmails,
            fakeOtpMobileNumbers = fakeOtpMobileNumbers,
            fareRecomputeDailyExtraKmsThreshold = fareRecomputeDailyExtraKmsThreshold,
            fareRecomputeWeeklyExtraKmsThreshold = fareRecomputeWeeklyExtraKmsThreshold,
            fcmConfig = Kernel.External.Notification.FCM.Types.FCMConfig {fcmUrl = fcmUrl', fcmServiceAccount = fcmServiceAccount, fcmTokenKeyPrefix = fcmTokenKeyPrefix},
            freeTrialDays = freeTrialDays,
            includeDriverCurrentlyOnRide = includeDriverCurrentlyOnRide,
            isAvoidToll = isAvoidToll,
            isPlanMandatory = isPlanMandatory,
            kaptureDisposition = kaptureDisposition,
            kaptureQueue = kaptureQueue,
            languagesToBeTranslated = languagesToBeTranslated,
            mandateExecutionRescheduleInterval = Kernel.Utils.Common.secondsToNominalDiffTime mandateExecutionRescheduleInterval,
            mandateNotificationRescheduleInterval = Kernel.Utils.Common.secondsToNominalDiffTime mandateNotificationRescheduleInterval,
            mandateValidity = mandateValidity,
            mediaFileSizeUpperLimit = mediaFileSizeUpperLimit,
            mediaFileUrlPattern = mediaFileUrlPattern,
            merchantId = Kernel.Types.Id.Id merchantId,
            merchantOperatingCityId = Kernel.Types.Id.Id merchantOperatingCityId,
            minLocationAccuracy = minLocationAccuracy,
            minRidesForCancellationScore = minRidesForCancellationScore,
            minRidesToUnlist = minRidesToUnlist,
            nightSafetyEndTime = nightSafetyEndTime,
            nightSafetyRouteDeviationThreshold = nightSafetyRouteDeviationThreshold,
            nightSafetyStartTime = nightSafetyStartTime,
            notificationRetryCountThreshold = notificationRetryCountThreshold,
            notificationRetryEligibleErrorCodes = notificationRetryEligibleErrorCodes,
            notificationRetryTimeGap = Kernel.Utils.Common.secondsToNominalDiffTime notificationRetryTimeGap,
            numOfCancellationsAllowed = numOfCancellationsAllowed,
            onboardingRetryTimeInHours = onboardingRetryTimeInHours,
            onboardingTryLimit = onboardingTryLimit,
            openMarketUnBlocked = openMarketUnBlocked,
            orderAndNotificationStatusCheckFallBackTime = Kernel.Utils.Common.secondsToNominalDiffTime orderAndNotificationStatusCheckFallBackTime,
            orderAndNotificationStatusCheckTime = Kernel.Utils.Common.secondsToNominalDiffTime orderAndNotificationStatusCheckTime,
            orderAndNotificationStatusCheckTimeLimit = Kernel.Utils.Common.secondsToNominalDiffTime orderAndNotificationStatusCheckTimeLimit,
            overlayBatchSize = overlayBatchSize,
            pastDaysRideCounter = pastDaysRideCounter,
            pickupLocThreshold = pickupLocThreshold,
            placeNameCacheExpiryDays = placeNameCacheExpiryDays,
            popupDelayToAddAsPenalty = popupDelayToAddAsPenalty,
            ratingAsDecimal = ratingAsDecimal,
            rcLimit = rcLimit,
            recomputeIfPickupDropNotOutsideOfThreshold = recomputeIfPickupDropNotOutsideOfThreshold,
            referralLinkPassword = referralLinkPassword,
            refillVehicleModel = refillVehicleModel,
            rideTimeEstimatedThreshold = rideTimeEstimatedThreshold,
            routeDeviationThreshold = routeDeviationThreshold,
            scheduleRideBufferTime = Kernel.Utils.Common.secondsToNominalDiffTime scheduleRideBufferTime,
            searchRepeatLimit = searchRepeatLimit,
            snapToRoadConfidenceThreshold = snapToRoadConfidenceThreshold,
            specialDrivers = specialDrivers,
            specialLocationTags = specialLocationTags,
            specialZoneBookingOtpExpiry = specialZoneBookingOtpExpiry,
            stepFunctionToConvertCoins = stepFunctionToConvertCoins,
            subscription = subscription,
            subscriptionStartTime = subscriptionStartTime,
            thresholdCancellationPercentageToUnlist = thresholdCancellationPercentageToUnlist,
            thresholdCancellationScore = thresholdCancellationScore,
            timeDiffFromUtc = timeDiffFromUtc,
            toNotifyDriverForExtraKmsLimitExceed = toNotifyDriverForExtraKmsLimitExceed,
            updateNotificationStatusBatchSize = updateNotificationStatusBatchSize,
            updateOrderStatusBatchSize = updateOrderStatusBatchSize,
            updatedAt = updatedAt,
            upwardsRecomputeBuffer = upwardsRecomputeBuffer,
            useOfferListCache = useOfferListCache,
            useSilentFCMForForwardBatch = useSilentFCMForForwardBatch,
            useWithSnapToRoadFallback = useWithSnapToRoadFallback,
            variantsToEnableForSubscription = variantsToEnableForSubscription,
            volunteerSmsSendingLimit = (\val -> case Data.Aeson.fromJSON val of Data.Aeson.Success x -> Just x; Data.Aeson.Error _ -> Nothing) =<< volunteerSmsSendingLimit
          }

instance ToTType' Beam.TransporterConfig Domain.Types.TransporterConfig.TransporterConfig where
  toTType' (Domain.Types.TransporterConfig.TransporterConfig {..}) = do
    Beam.TransporterConfigT
      { Beam.aadhaarImageResizeConfig = Kernel.Prelude.toJSON <$> aadhaarImageResizeConfig,
        Beam.aadhaarVerificationRequired = aadhaarVerificationRequired,
        Beam.acStatusCheckGap = acStatusCheckGap,
        Beam.actualRideDistanceDiffThreshold = actualRideDistanceDiffThreshold,
        Beam.actualRideDistanceDiffThresholdIfWithinPickupDrop = actualRideDistanceDiffThresholdIfWithinPickupDrop,
        Beam.allowDefaultPlanAllocation = allowDefaultPlanAllocation,
        Beam.approxRideDistanceDiffThreshold = approxRideDistanceDiffThreshold,
        Beam.arrivedPickupThreshold = Just arrivedPickupThreshold,
        Beam.arrivedStopThreshold = arrivedStopThreshold,
        Beam.arrivingPickupThreshold = arrivingPickupThreshold,
        Beam.automaticRCActivationCutOff = automaticRCActivationCutOff,
        Beam.avgSpeedOfVehicle = Kernel.Prelude.toJSON <$> avgSpeedOfVehicle,
        Beam.badDebtBatchSize = badDebtBatchSize,
        Beam.badDebtRescheduleTime = Kernel.Utils.Common.nominalDiffTimeToSeconds badDebtRescheduleTime,
        Beam.badDebtSchedulerTime = Kernel.Utils.Common.nominalDiffTimeToSeconds badDebtSchedulerTime,
        Beam.badDebtTimeThreshold = badDebtTimeThreshold,
        Beam.bankErrorExpiry = Kernel.Utils.Common.nominalDiffTimeToSeconds bankErrorExpiry,
        Beam.bookAnyVehicleDowngradeLevel = bookAnyVehicleDowngradeLevel,
        Beam.cacheOfferListByDriverId = cacheOfferListByDriverId,
        Beam.canAddCancellationFee = canAddCancellationFee,
        Beam.canDowngradeToHatchback = canDowngradeToHatchback,
        Beam.canDowngradeToSedan = canDowngradeToSedan,
        Beam.canDowngradeToTaxi = canDowngradeToTaxi,
        Beam.canSuvDowngradeToHatchback = Just canSuvDowngradeToHatchback,
        Beam.canSuvDowngradeToTaxi = canSuvDowngradeToTaxi,
        Beam.canSwitchToInterCity = canSwitchToInterCity,
        Beam.canSwitchToRental = canSwitchToRental,
        Beam.cancellationDistDiff = cancellationDistDiff,
        Beam.cancellationFee = cancellationFee,
        Beam.cancellationFeeDisputeLimit = cancellationFeeDisputeLimit,
        Beam.cancellationTimeDiff = Kernel.Utils.Common.nominalDiffTimeToSeconds cancellationTimeDiff,
        Beam.checkImageExtractionForDashboard = checkImageExtractionForDashboard,
        Beam.coinConversionRate = coinConversionRate,
        Beam.coinExpireTime = Kernel.Utils.Common.nominalDiffTimeToSeconds coinExpireTime,
        Beam.coinFeature = coinFeature,
        Beam.considerDriversForSearch = considerDriversForSearch,
        Beam.considerSpecialZoneRideChargesInFreeTrial = considerSpecialZoneRideChargesInFreeTrial,
        Beam.considerSpecialZoneRidesForPlanCharges = considerSpecialZoneRidesForPlanCharges,
        Beam.createdAt = createdAt,
        Beam.crossTravelCities = crossTravelCities,
        Beam.currency = Just currency,
        Beam.defaultPopupDelay = defaultPopupDelay,
        Beam.distanceUnit = Kernel.Prelude.Just distanceUnit,
        Beam.dlNumberVerification = dlNumberVerification,
        Beam.driverAutoPayExecutionTime = Kernel.Utils.Common.nominalDiffTimeToSeconds driverAutoPayExecutionTime,
        Beam.driverAutoPayExecutionTimeFallBack = Kernel.Utils.Common.nominalDiffTimeToSeconds driverAutoPayExecutionTimeFallBack,
        Beam.driverAutoPayNotificationTime = Kernel.Utils.Common.nominalDiffTimeToSeconds driverAutoPayNotificationTime,
        Beam.driverDistanceToPickupThresholdOnCancel = driverDistanceToPickupThresholdOnCancel,
        Beam.driverDistanceTravelledOnPickupThresholdOnCancel = driverDistanceTravelledOnPickupThresholdOnCancel,
        Beam.driverFeeCalculationTime = Kernel.Utils.Common.nominalDiffTimeToSeconds <$> driverFeeCalculationTime,
        Beam.driverFeeCalculatorBatchGap = Kernel.Utils.Common.nominalDiffTimeToSeconds <$> driverFeeCalculatorBatchGap,
        Beam.driverFeeCalculatorBatchSize = driverFeeCalculatorBatchSize,
        Beam.driverFeeMandateExecutionBatchSize = driverFeeMandateExecutionBatchSize,
        Beam.driverFeeMandateNotificationBatchSize = driverFeeMandateNotificationBatchSize,
        Beam.driverFeeOverlaySendingTimeLimitInDays = driverFeeOverlaySendingTimeLimitInDays,
        Beam.driverFeeRetryThresholdConfig = driverFeeRetryThresholdConfig,
        Beam.driverLocationAccuracyBuffer = driverLocationAccuracyBuffer,
        Beam.driverPaymentCycleBuffer = Kernel.Utils.Common.nominalDiffTimeToSeconds driverPaymentCycleBuffer,
        Beam.driverPaymentCycleDuration = Kernel.Utils.Common.nominalDiffTimeToSeconds driverPaymentCycleDuration,
        Beam.driverPaymentCycleStartTime = Kernel.Utils.Common.nominalDiffTimeToSeconds driverPaymentCycleStartTime,
        Beam.driverPaymentReminderInterval = Kernel.Utils.Common.nominalDiffTimeToSeconds driverPaymentReminderInterval,
        Beam.driverSmsReceivingLimit = Kernel.Prelude.toJSON <$> driverSmsReceivingLimit,
        Beam.driverTimeSpentOnPickupThresholdOnCancel = driverTimeSpentOnPickupThresholdOnCancel,
        Beam.dropLocThreshold = dropLocThreshold,
        Beam.dummyFromLocation = Just $ toJSON dummyFromLocation,
        Beam.dummyToLocation = Just $ toJSON dummyToLocation,
        Beam.editLocDriverPermissionNeeded = editLocDriverPermissionNeeded,
        Beam.editLocTimeThreshold = editLocTimeThreshold,
        Beam.emailOtpConfig = emailOtpConfig,
        Beam.enableDashboardSms = enableDashboardSms,
        Beam.enableFaceVerification = enableFaceVerification,
        Beam.enableTollCrossedNotifications = enableTollCrossedNotifications,
        Beam.enableUdfForOffers = enableUdfForOffers,
        Beam.fakeOtpEmails = fakeOtpEmails,
        Beam.fakeOtpMobileNumbers = fakeOtpMobileNumbers,
        Beam.fareRecomputeDailyExtraKmsThreshold = fareRecomputeDailyExtraKmsThreshold,
        Beam.fareRecomputeWeeklyExtraKmsThreshold = fareRecomputeWeeklyExtraKmsThreshold,
        Beam.fcmServiceAccount = (.fcmServiceAccount) fcmConfig,
        Beam.fcmTokenKeyPrefix = (.fcmTokenKeyPrefix) fcmConfig,
        Beam.fcmUrl = Kernel.Prelude.showBaseUrl $ (.fcmUrl) fcmConfig,
        Beam.freeTrialDays = freeTrialDays,
        Beam.includeDriverCurrentlyOnRide = includeDriverCurrentlyOnRide,
        Beam.isAvoidToll = isAvoidToll,
        Beam.isPlanMandatory = isPlanMandatory,
        Beam.kaptureDisposition = kaptureDisposition,
        Beam.kaptureQueue = kaptureQueue,
        Beam.languagesToBeTranslated = languagesToBeTranslated,
        Beam.mandateExecutionRescheduleInterval = Kernel.Utils.Common.nominalDiffTimeToSeconds mandateExecutionRescheduleInterval,
        Beam.mandateNotificationRescheduleInterval = Kernel.Utils.Common.nominalDiffTimeToSeconds mandateNotificationRescheduleInterval,
        Beam.mandateValidity = mandateValidity,
        Beam.mediaFileSizeUpperLimit = mediaFileSizeUpperLimit,
        Beam.mediaFileUrlPattern = mediaFileUrlPattern,
        Beam.merchantId = Kernel.Types.Id.getId merchantId,
        Beam.merchantOperatingCityId = Kernel.Types.Id.getId merchantOperatingCityId,
        Beam.minLocationAccuracy = minLocationAccuracy,
        Beam.minRidesForCancellationScore = minRidesForCancellationScore,
        Beam.minRidesToUnlist = minRidesToUnlist,
        Beam.nightSafetyEndTime = nightSafetyEndTime,
        Beam.nightSafetyRouteDeviationThreshold = nightSafetyRouteDeviationThreshold,
        Beam.nightSafetyStartTime = nightSafetyStartTime,
        Beam.notificationRetryCountThreshold = notificationRetryCountThreshold,
        Beam.notificationRetryEligibleErrorCodes = notificationRetryEligibleErrorCodes,
        Beam.notificationRetryTimeGap = Kernel.Utils.Common.nominalDiffTimeToSeconds notificationRetryTimeGap,
        Beam.numOfCancellationsAllowed = numOfCancellationsAllowed,
        Beam.onboardingRetryTimeInHours = onboardingRetryTimeInHours,
        Beam.onboardingTryLimit = onboardingTryLimit,
        Beam.openMarketUnBlocked = openMarketUnBlocked,
        Beam.orderAndNotificationStatusCheckFallBackTime = Kernel.Utils.Common.nominalDiffTimeToSeconds orderAndNotificationStatusCheckFallBackTime,
        Beam.orderAndNotificationStatusCheckTime = Kernel.Utils.Common.nominalDiffTimeToSeconds orderAndNotificationStatusCheckTime,
        Beam.orderAndNotificationStatusCheckTimeLimit = Kernel.Utils.Common.nominalDiffTimeToSeconds orderAndNotificationStatusCheckTimeLimit,
        Beam.overlayBatchSize = overlayBatchSize,
        Beam.pastDaysRideCounter = pastDaysRideCounter,
        Beam.pickupLocThreshold = pickupLocThreshold,
        Beam.placeNameCacheExpiryDays = placeNameCacheExpiryDays,
        Beam.popupDelayToAddAsPenalty = popupDelayToAddAsPenalty,
        Beam.ratingAsDecimal = ratingAsDecimal,
        Beam.rcLimit = rcLimit,
        Beam.recomputeIfPickupDropNotOutsideOfThreshold = recomputeIfPickupDropNotOutsideOfThreshold,
        Beam.referralLinkPassword = referralLinkPassword,
        Beam.refillVehicleModel = refillVehicleModel,
        Beam.rideTimeEstimatedThreshold = rideTimeEstimatedThreshold,
        Beam.routeDeviationThreshold = routeDeviationThreshold,
        Beam.scheduleRideBufferTime = Kernel.Utils.Common.nominalDiffTimeToSeconds scheduleRideBufferTime,
        Beam.searchRepeatLimit = searchRepeatLimit,
        Beam.snapToRoadConfidenceThreshold = snapToRoadConfidenceThreshold,
        Beam.specialDrivers = specialDrivers,
        Beam.specialLocationTags = specialLocationTags,
        Beam.specialZoneBookingOtpExpiry = specialZoneBookingOtpExpiry,
        Beam.stepFunctionToConvertCoins = stepFunctionToConvertCoins,
        Beam.subscription = subscription,
        Beam.subscriptionStartTime = subscriptionStartTime,
        Beam.thresholdCancellationPercentageToUnlist = thresholdCancellationPercentageToUnlist,
        Beam.thresholdCancellationScore = thresholdCancellationScore,
        Beam.timeDiffFromUtc = timeDiffFromUtc,
        Beam.toNotifyDriverForExtraKmsLimitExceed = toNotifyDriverForExtraKmsLimitExceed,
        Beam.updateNotificationStatusBatchSize = updateNotificationStatusBatchSize,
        Beam.updateOrderStatusBatchSize = updateOrderStatusBatchSize,
        Beam.updatedAt = updatedAt,
        Beam.upwardsRecomputeBuffer = upwardsRecomputeBuffer,
        Beam.useOfferListCache = useOfferListCache,
        Beam.useSilentFCMForForwardBatch = useSilentFCMForForwardBatch,
        Beam.useWithSnapToRoadFallback = useWithSnapToRoadFallback,
        Beam.variantsToEnableForSubscription = variantsToEnableForSubscription,
        Beam.volunteerSmsSendingLimit = Kernel.Prelude.toJSON <$> volunteerSmsSendingLimit
      }
