module MerchantConfig.Types where

import Common.Types.Config
import Common.Types.App
import Foreign.Object (Object)

type AppConfig = AppConfigCustomer CommonAppConfig

type AppConfigCustomer a =
  {
    primaryTextColor :: String,
    primaryBackground :: String,
    estimateConfirmText :: String,
    autoConfirmingLoaderColor :: String,
    quoteListModelBackground :: String,
    quoteListModel :: QuoteListConfig,
    profileBackground :: String,
    showPickUpandDrop :: Boolean,
    profileName :: String,
    profileImage :: String,
    profileCompletion :: String,
    profileArrowImage :: String,
    showProfileStatus :: Boolean,
    feedbackBackground :: String,
    sideBarList :: Array String,
    rateCardColor :: String,
    showHamMenu :: Boolean,
    showQuoteFindingText :: Boolean,
    nyBrandingVisibility :: Boolean,
    fontType :: String,
    languageList :: Array Language,
    confirmPickUpLocationBorder ::String,
    bannerConfig :: BannerViewState,
    popupBackground :: String,
    cancelRideColor :: String,
    infoIconUrl :: String,
    profileEditGravity :: String,
    merchantLogo :: String,
    logs :: Array String,
    searchLocationConfig :: SearchLocationConfig,
    quoteListItemConfig :: QuoteListItemConfig,
    alertDialogPrimaryColor :: String,
    driverInfoConfig :: DriverInfoConfig,
    ratingConfig :: RatingConfig,
    primaryButtonCornerRadius :: Number,
    cancelSearchTextColor :: String,
    cancelReasonConfig :: CancelReasonConfig,
    terminateBtnConfig :: TerminateBtnConfig,
    suggestedTripsAndLocationConfig  :: SuggestedDestinationAndTripsConfig,
    showDeleteAccount :: Boolean
  , autoSelectBackground :: String
  , showGenderBanner :: Boolean
  , enableMockLocation :: Boolean
  , specialLocationView :: Boolean
  , callOptions :: Array String
  , autoVariantEnabled :: Boolean
  , showDisabilityBanner :: Boolean
  , mapConfig :: MapConfig
  , metroTicketingConfig :: Array MetroConfig
  , enableWhatsappOTP :: Array String
  , notifyRideConfirmationConfig :: NotifyRideConfirmationConfig
  , estimateAndQuoteConfig :: EstimateAndQuoteConfig
  , isAdvancedBookingEnabled :: Boolean
  , customerTip :: CustomerTip
  , feature :: Features
  , rideCompletedCardConfig :: RideCompletedCardConfig
  , purpleRideConfig :: PurpleRideConfig
  , geoCoder :: GeoCoderConfig
  , shareAppConfig :: ShareAppConfig
  , homeScreen :: HomeScreen
  , locationTagBar :: LocationTagBarConfig
  , cityConfig :: Array CityConfig
  , driverLocationPolling :: DriverLocationPollingConfig
  , banners :: Banners
  , tipDisplayDuration :: Int
  , tipsEnabled :: Boolean
  , tipEnabledCities :: Array String
  , maxVehicleIconsToShowOnMap :: Int
  , referral :: ReferalConfig
  , safety :: Safety
  , enableBookAny :: Boolean
  , acPopupConfig :: AcPopupConfig
  , showCheckoutRentalBanner :: Boolean
  | a
  }

type ReferalConfig = {
  domain :: String,
  customerAppId :: String
}

type GeoCoderConfig = {
  enableLLtoAddress :: Boolean,
  enableAddressToLL :: Boolean
}

type NotifyRideConfirmationConfig = {
  notify :: Boolean,
  autoGeneratedText :: String
}

type QuoteListItemConfig = {
  primaryButtonCorner :: Number,
  expiresColor :: String,
  driverImagebg :: String,
  vehicleHeight :: Int,
  vehicleWidth :: Int
}

type RatingConfig = {
  secondaryButtonTextColor :: String,
  secondaryButtonStroke :: String,
  buttonCornerRadius :: Number
}

type CancelReasonConfig = {
  secondaryButtonTextColor :: String,
  secondaryButtonStroke :: String,
  buttonCornerRadius :: Number
}

type DriverInfoConfig = {
  ratingTextColor :: String,
  ratingBackground :: String,
  ratingStroke :: String,
  ratingCornerRadius :: Number,
  callBackground :: String,
  showTrackingButton :: Boolean,
  callButtonStroke :: String,
  cardStroke :: String,
  otpStroke :: String,
  showNumberPlatePrefix :: Boolean,
  showNumberPlateSuffix :: Boolean,
  callHeight :: Int,
  callWidth :: Int
, numberPlateBackground :: String
, showCancelPrevention :: Boolean
, specialZoneQuoteExpirySeconds :: Int
, footerVisibility :: Boolean
, footerImageUrl :: String
, footerBackgroundColor :: String
}

type SearchLocationConfig = {
  searchLocationTheme :: String,
  setLocationOnMapColor :: String,
  strokeColor :: String,
  enableLocationTagbar :: String,
  resultsCardCornerRadius :: Number,
  showRateCardDetails :: Boolean,
  backgroundColor :: String,
  separatorColor :: String,
  editTextColor :: String,
  showAdditionalChargesText :: Boolean,
  lottieHeight :: Int,
  lottieWidth :: Int,
  primaryButtonHeight :: Int
, backArrow :: String
, crossIcon :: String
, editTextBackground :: String
, editTextDefaultColor :: String
, hintColor :: String
, showSeparator :: Boolean
, showChargeDesc :: Boolean
, enableRateCard :: Boolean
, clearTextImage :: String
}

type QuoteListConfig = {
  backgroundColor :: String,
  textColor :: String,
  loaderColor :: String,
  otpTextBackground :: String,
  otpBackground :: String,
  otpTextColor :: String,
  otpTitleColor :: String,
  selectRideTextColor :: String,
  lineImage :: String,
  lottieHeight :: Int,
  lottieWidth :: Int,
  topMargin :: Int,
  noQuotesImageHeight :: Int,
  noQuotesImageWidth :: Int,
  closeIcon :: String,
  showSeparator :: Boolean,
  separatorColor :: String
}
 
type SuggestedDestinationAndTripsConfig = {
  geohashLimitForMap :: Int,
  geohashPrecision :: Int,
  maxLocationsToBeShown :: Int,
  minLocationsToBeShown :: Int,
  maxTripsToBeShown :: Int,
  minTripsToBeShown :: Int,
  locationsToBeStored :: Int,
  tripsToBeStored :: Int,
  frequencyWeight :: Number,
  tripDistanceThreshold :: Number,
  repeatRideTime :: Int,
  autoScrollTime :: Int,
  tripWithinXDist :: Number,
  locationWithinXDist :: Number,
  destinationGeohashPrecision :: Int
}

type Language =  {
  name :: String,
  value :: String,
  subTitle :: String
 }

type BannerViewState = {
  backgroundColor :: String,
  title :: String,
  titleColor :: String,
  actionText :: String,
  actionTextColor :: String,
  imageUrl :: String
}
type TerminateBtnConfig = {
    visibility :: Boolean,
    title :: String,
    imageUrl :: String,
    backgroundColor :: String
}

type EstimateAndQuoteConfig = {
  variantTypes :: Array (Array String),
  variantOrder :: Array String,
  enableOnlyAuto :: Boolean,
  showNearByDrivers :: Boolean,
  enableBookingPreference :: Boolean, 
  textColor :: String,
  showInfoIcon :: Boolean,
  variantInfo :: VariantConfig,
  genericLoaderLottie :: String
}

type CustomerTip = {
  auto :: Boolean,
  cabs :: Boolean
}

type Features = {
  enableAutoReadOtp :: Boolean ,
  enableZooTicketBookingFlow :: Boolean,
  enableSuggestions :: Boolean,
  enableLiveDashboard :: Boolean,
  enableShareRide :: Boolean,
  enableChat :: Boolean,
  enableEmergencyContacts :: Boolean,
  enableReferral :: Boolean,
  enableSupport :: Boolean,
  enableShareApp:: Boolean,
  enableReAllocation :: Boolean,
  forceLogReferrerUrl :: Boolean,
  enableSelfServe :: Boolean,
  enableAdditionalServices :: Boolean,
  enableSafetyFlow :: Boolean,
  shareWithEmergencyContacts :: Boolean,
  enableAutoReferral :: Boolean,
  enableRepeatTripBackfilling :: Boolean,
  enableCustomerSupportForSafety :: Boolean,
  enableSpecialPickup :: Boolean,
  enableAcPopup :: Boolean,
  enableRentalReallocation :: Boolean,
  enableEditDestination :: Boolean
  }

type RideCompletedCardConfig = {
  topCard :: TopCardConfig
, showCallSupport :: Boolean
}

type TopCardConfig = {
  gradient :: String
, enableGradient :: Boolean
, background :: String
, titleColor :: String
, rideDescription :: RideDescriptionConfig
, horizontalLineColor :: String
}

type RideDescriptionConfig = {
  background :: String
, textColor :: String
}

type MapConfig = {
  locateOnMapConfig :: LocateOnMapConfigs,
  labelTextSize :: Int,
  animationDuration :: Int,
  vehicleMarkerSize :: Int,
  labelTheme :: String
}

type MetroConfig = {
  cityName :: String
, cityCode :: String
, customEndTime :: String
, customDates :: Array String 
, metroStationTtl :: Int
, metroHomeBannerImage :: String
, metroBookingBannerImage :: String
, bookingStartTime :: String
, bookingEndTime :: String
, ticketLimit :: {
    roundTrip :: Int
  , oneWay :: Int
}
}

type LocateOnMapConfigs = {
  dottedLineConfig :: DottedLineConfig
, apiTriggerRadius :: Number
, pickUpToSourceThreshold :: Number
, hotSpotConfig :: HotSpotConfig
}

type DottedLineConfig = {
  visible :: Boolean,
  range :: Int,
  color :: String
}

type PurpleRideConfig = {
  genericVideoUrl :: String,
  visualImpairmentVideo :: String,
  physicalImpairmentVideo :: String,
  hearingImpairmentVideo :: String
}

type HomeScreen = {
  primaryBackground :: String,
  pickUpViewColor :: String,
  header :: HomeScreenHeader,
  bannerViewVisibility :: Boolean,
  whereToButton :: WhereToButton,
  pickupLocationTextColor :: String,
  isServiceablePopupFullScreen :: Boolean,
  showAdditionalServicesNew :: Boolean
}

type HomeScreenHeader = {
  menuButtonBackground :: String,
  showLogo :: Boolean,
  titleColor :: String,
  showSeparator :: Boolean
}

type WhereToButton = {
  margin :: MarginConfig,
  shadow :: ShadowConfig
}

type MarginConfig = {
  top :: Int,
  bottom :: Int,
  left :: Int,
  right :: Int
}
type ShadowConfig = {
  color :: String,
  blur :: Number,
  x :: Number,
  y :: Number,
  spread :: Number,
  opacity :: Number
}

type ShareAppConfig = {
  title :: String
, description :: String
}

type LocationTagBarConfig = {
  cornerRadius :: Number
, textColor :: String
, stroke:: String
}

type VariantConfig = {
  hatchback :: VariantInfo,
  sedan :: VariantInfo,
  suv :: VariantInfo,
  autoRickshaw :: VariantInfo,
  taxi :: VariantInfo,
  taxiPlus :: VariantInfo,
  bookAny :: VariantInfo
}

type VariantInfo = {
  name :: String,
  image :: String,
  leftViewImage :: String
}

type HotSpotConfig = {
  goToNearestPointWithinRadius :: Number,
  showHotSpotsWithinRadius :: Number,
  enableHotSpot :: Boolean,
  updateHotSpotOutSideRange :: Number
}

type CityConfig = {
  cityName :: String,
  cityCode :: String,
  geoCodeConfig :: GeoCodeConfig,
  enableRentals :: Boolean,
  enableIntercity :: Boolean,
  enableCabs :: Boolean,
  iopConfig :: InteroperabilityConfig,
  estimateAndQuoteConfig :: EstimateConfig,
  featureConfig :: CityBasedFeatures,
  referral :: ReferalConfig,
  dashboardUrl :: String,
  appLogo :: String,
  appLogoLight :: String,
  enableAcViews :: Boolean,
  waitingChargeConfig :: WaitingChargeConfig,
  rentalWaitingChargeConfig :: WaitingChargeConfig
}

type CityBasedFeatures = {
  enableCabBanner :: Boolean,
  showExploreCity :: Boolean
}

type EstimateConfig = {
  showInfoIcon :: Boolean
}

type GeoCodeConfig = {
  radius :: Int,
  strictBounds :: Boolean
}

type DriverLocationPollingConfig = {
  retryExpFactor :: Int
}

type Banners = {
  homeScreenSafety :: Boolean,
  homeScreenCabLaunch :: Boolean
}

type Safety = {
  pastRideInterval :: Int
}

type InteroperabilityConfig = {
  enable :: Boolean,
  autoSelectTime :: Int
}

type AcPopupConfig = {
  enableAcPopup :: Boolean,
  enableNonAcPopup :: Boolean,
  showAfterTime :: Int
}

type WaitingChargeConfig = {
  auto :: WaitingCharge,
  cabs :: WaitingCharge
}

type WaitingCharge = {
  freeMinutes :: Number,
  perMinCharges :: Number
}