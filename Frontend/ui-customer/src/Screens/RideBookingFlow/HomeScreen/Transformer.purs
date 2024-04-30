{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.HomeScreen.Transformer where

import Prelude

import Accessor (_contents, _description, _place_id, _toLocation, _lat, _lon, _estimatedDistance, _rideRating, _driverName, _computedPrice, _otpCode, _distance, _maxFare, _estimatedFare, _estimateId, _vehicleVariant, _estimateFareBreakup, _title, _price, _totalFareRange, _maxFare, _minFare, _nightShiftRate, _nightShiftEnd, _nightShiftMultiplier, _nightShiftStart, _specialLocationTag, _createdAt)

import Components.ChooseVehicle (Config, config, SearchType(..)) as ChooseVehicle
import Components.QuoteListItem.Controller (config) as QLI
import Components.SettingSideBar.Controller (SettingSideBarState, Status(..))
import Data.Array (mapWithIndex, filter, head, find)
import Data.Array as DA
import Data.Int (toNumber, round, fromString)
import Data.Lens ((^.), view)
import Data.Ord
import Data.Eq
import Data.Maybe (Maybe(..), fromMaybe, isJust, maybe)
import Data.String (Pattern(..), drop, indexOf, length, split, trim, null)
import Data.Function.Uncurried (runFn1)
import Helpers.Utils (parseFloat, withinTimeRange,isHaveFare, getVehicleVariantImage, getDistanceBwCordinates, getCityConfig)
import Engineering.Helpers.Commons (convertUTCtoISC, getExpiryTime, getCurrentUTC, getMapsLanguageFormat)
import Language.Strings (getString)
import Language.Types (STR(..))
import PrestoDOM (Visibility(..))
import Resources.Constants (DecodeAddress(..), decodeAddress, getValueByComponent, getWard, getVehicleCapacity, getFaresList, getKmMeter, fetchVehicleVariant, getAddressFromBooking)
import Screens.HomeScreen.ScreenData (dummyAddress, dummyLocationName, dummySettingBar, dummyZoneType)
import Screens.Types (DriverInfoCard, LocationListItemState, LocItemType(..), LocationItemType(..), NewContacts, Contact, VehicleVariant(..), TripDetailsScreenState, SearchResultType(..), HomeScreenState(..), MyRidesScreenState(..), Trip(..), QuoteListItemState(..), City(..))
import Services.API (AddressComponents(..), BookingLocationAPIEntity, DeleteSavedLocationReq(..), DriverOfferAPIEntity(..), EstimateAPIEntity(..), GetPlaceNameResp(..), LatLong(..), OfferRes, OfferRes(..), PlaceName(..), Prediction, QuoteAPIContents(..), QuoteAPIEntity(..), RideAPIEntity(..), RideBookingAPIDetails(..), RideBookingRes(..), SavedReqLocationAPIEntity(..), SpecialZoneQuoteAPIDetails(..), FareRange(..), LatLong(..), EstimateFares(..), RideBookingListRes(..), GetEmergContactsReq(..), GetEmergContactsResp(..), ContactDetails(..))
import Services.Backend as Remote
import Types.App(FlowBT,  GlobalState(..), ScreenType(..))
import Storage ( setValueToLocalStore, getValueToLocalStore, KeyStore(..))
import JBridge (fromMetersToKm, getLatLonFromAddress, Location, differenceBetweenTwoUTCInMinutes)
import Helpers.Utils (fetchImage, FetchImageFrom(..), getCityFromString)
import Screens.MyRidesScreen.ScreenData (dummyIndividualCard)
import Common.Types.App (LazyCheck(..), Paths, FareList)
import MerchantConfig.Utils (Merchant(..), getMerchant)
import Resources.Localizable.EN (getEN)
import MerchantConfig.Types (EstimateAndQuoteConfig)
import Engineering.Helpers.BackTrack (liftFlowBT)
import Engineering.Helpers.LogEvent
import Control.Monad.Except.Trans (lift)
import Presto.Core.Types.Language.Flow (Flow(..), getLogFields)
import ConfigProvider
import Locale.Utils
import Data.Either (Either(..))
import Screens.NammaSafetyFlow.Components.SafetyUtils (getDefaultPriorityList)
import Mobility.Prelude as MP
import Data.Function.Uncurried (runFn2)
import Helpers.SpecialZoneAndHotSpots (getSpecialTag)
import Common.Types.App as CT

getLocationList :: Array Prediction -> Array LocationListItemState
getLocationList prediction = map (\x -> getLocation x) prediction

getLocation :: Prediction -> LocationListItemState
getLocation prediction = {
    prefixImageUrl : fetchImage FF_ASSET "ny_ic_loc_grey"
  , postfixImageUrl : fetchImage FF_ASSET "ny_ic_fav"
  , postfixImageVisibility : true
  , title : (fromMaybe "" ((split (Pattern ",") (prediction ^. _description)) DA.!! 0))
  , subTitle : (drop ((fromMaybe 0 (indexOf (Pattern ",") (prediction ^. _description))) + 2) (prediction ^. _description))
  , placeId : prediction ^._place_id
  , lat : Nothing
  , lon : Nothing
  , description : prediction ^. _description
  , tag : ""
  , tagType : Just $ show LOC_LIST
  , cardType : Nothing
  , address : ""
  , tagName : ""
  , isEditEnabled : true
  , savedLocation : ""
  , placeName : ""
  , isClickable : true
  , alpha : 1.0
  , fullAddress : dummyAddress
  , locationItemType : Just PREDICTION
  , distance : Just (fromMetersToKm (fromMaybe 0 (prediction ^._distance)))
  , showDistance : Just $ checkShowDistance (fromMaybe 0 (prediction ^._distance))
  , actualDistance : (prediction ^._distance)
  , frequencyCount : Nothing
  , recencyDate : Nothing
  , locationScore : Nothing
}

checkShowDistance :: Int ->  Boolean
checkShowDistance distance = (distance > 0 && distance <= 50000)

getQuoteList :: Array QuoteAPIEntity -> City -> Array QuoteListItemState
getQuoteList quotesEntity city = (map (\x -> (getQuote x city)) quotesEntity)

getQuote :: QuoteAPIEntity -> City -> QuoteListItemState
getQuote (QuoteAPIEntity quoteEntity) city = do
  case (quoteEntity.quoteDetails)^._contents of
    (ONE_WAY contents) -> QLI.config
    (SPECIAL_ZONE contents) -> QLI.config
    (DRIVER_OFFER contents) -> 
      let (DriverOfferAPIEntity quoteDetails) = contents
          expiryTime = (getExpiryTime quoteDetails.validTill isForLostAndFound) -4
          timeLeft = fromMaybe 0 quoteDetails.durationToPickup
      in {  seconds : expiryTime
          , id : quoteEntity.id
          , timer : show expiryTime
          , timeLeft : timeLeft/60
          , driverRating : fromMaybe 0.0 quoteDetails.rating
          , profile : ""
          , price :  show quoteEntity.estimatedTotalFare
          , vehicleType : "auto"
          , driverName : quoteDetails.driverName
          , selectedQuote : Nothing
          , appConfig : getAppConfig appConfig
          , city : city
        }

getDriverInfo :: Maybe String -> RideBookingRes -> Boolean -> DriverInfoCard
getDriverInfo vehicleVariant (RideBookingRes resp) isQuote =
  let (RideAPIEntity rideList) = fromMaybe  dummyRideAPIEntity ((resp.rideList) DA.!! 0)
  in  {
        otp : if isQuote then fromMaybe "" ((resp.bookingDetails)^._contents ^._otpCode) else rideList.rideOtp
      , driverName : if length (fromMaybe "" ((split (Pattern " ") (rideList.driverName)) DA.!! 0)) < 4 then
                        (fromMaybe "" ((split (Pattern " ") (rideList.driverName)) DA.!! 0)) <> " " <> (fromMaybe "" ((split (Pattern " ") (rideList.driverName)) DA.!! 1)) else
                          (fromMaybe "" ((split (Pattern " ") (rideList.driverName)) DA.!! 0))
      , eta : Nothing
      , currentSearchResultType : if isQuote then QUOTES else ESTIMATES
      , vehicleDetails : rideList.vehicleModel
      , registrationNumber : rideList.vehicleNumber
      , rating : (fromMaybe 0.0 rideList.driverRatings)
      , startedAt : (convertUTCtoISC resp.createdAt "h:mm A")
      , endedAt : (convertUTCtoISC resp.updatedAt "h:mm A")
      , source : decodeAddress (Booking resp.fromLocation)
      , destination : decodeAddress (Booking (resp.bookingDetails ^._contents^._toLocation))
      , rideId : rideList.id
      , price : resp.estimatedTotalFare
      , sourceLat : resp.fromLocation ^._lat
      , sourceLng : resp.fromLocation ^._lon
      , destinationLat : (resp.bookingDetails ^._contents^._toLocation ^._lat)
      , destinationLng : (resp.bookingDetails ^._contents^._toLocation ^._lon)
      , sourceAddress : getAddressFromBooking resp.fromLocation
      , destinationAddress : getAddressFromBooking (resp.bookingDetails ^._contents^._toLocation)
      , estimatedDistance : parseFloat ((toNumber (fromMaybe 0 (resp.bookingDetails ^._contents ^._estimatedDistance)))/1000.0) 2
      , createdAt : resp.createdAt
      , driverLat : 0.0
      , driverLng : 0.0
      , distance : 0
      , waitingTime : "--"
      , driverArrived : false
      , driverArrivalTime : 0
      , bppRideId : rideList.bppRideId
      , driverNumber : rideList.driverNumber
      , merchantExoPhone : resp.merchantExoPhone
      , initDistance : Nothing
      , config : getAppConfig appConfig
      , providerName : resp.agencyName
      , providerType : maybe CT.ONUS (\valueAdd -> if valueAdd then CT.ONUS else CT.OFFUS) resp.isValueAddNP -- get from API
      , vehicleVariant : if rideList.vehicleVariant /= "" 
                            then rideList.vehicleVariant 
                         else
                            fromMaybe "" vehicleVariant
      , status : rideList.status
      , serviceTierName : resp.serviceTierName
      , vehicleModel : rideList.vehicleModel
      , vehicleColor : rideList.vehicleColor
      }

encodeAddressDescription :: String -> String -> Maybe String -> Maybe Number -> Maybe Number -> Array AddressComponents -> SavedReqLocationAPIEntity
encodeAddressDescription address tag placeId lat lon addressComponents = do
    let totalAddressComponents = DA.length $ split (Pattern ", ") address
        splitedAddress = split (Pattern ", ") address

    SavedReqLocationAPIEntity{
                    "area": (splitedAddress DA.!!(totalAddressComponents-4) ),
                    "areaCode": Just (getValueByComponent addressComponents "postal_code") ,
                    "building": (splitedAddress DA.!!(totalAddressComponents-6) ),
                    "city": (splitedAddress DA.!!(totalAddressComponents-3) ),
                    "country": (splitedAddress DA.!!(totalAddressComponents-1) ),
                    "state" : (splitedAddress DA.!!(totalAddressComponents-2) ),
                    "door": if totalAddressComponents > 7  then (splitedAddress DA.!!0 ) <>(splitedAddress DA.!!1) else if totalAddressComponents == 7 then (splitedAddress DA.!!0 ) else  Just "",
                    "street": (splitedAddress DA.!!(totalAddressComponents-5) ),
                    "lat" : (fromMaybe 0.0 lat),
                    "lon" : (fromMaybe 0.0 lon),
                    "tag" : tag,
                    "placeId" : placeId,
                    "ward" : if DA.null addressComponents then
                        getWard Nothing (splitedAddress DA.!! (totalAddressComponents - 4)) (splitedAddress DA.!! (totalAddressComponents - 5)) (splitedAddress DA.!! (totalAddressComponents - 6))
                      else
                        Just $ getValueByComponent addressComponents "sublocality"
                }


dummyRideAPIEntity :: RideAPIEntity
dummyRideAPIEntity = RideAPIEntity{
  computedPrice : Nothing,
  status : "NEW",
  vehicleModel : "",
  createdAt : "",
  driverNumber : Nothing,
  shortRideId : "",
  driverRegisteredAt : Nothing,
  vehicleNumber : "",
  rideOtp : "",
  driverName : "",
  chargeableRideDistance : Nothing,
  vehicleVariant : "",
  driverRatings : Nothing,
  vehicleColor : "",
  id : "",
  updatedAt : "",
  rideStartTime : Nothing,
  rideEndTime : Nothing,
  rideRating : Nothing,
  driverArrivalTime : Nothing,
  bppRideId : ""
  }

isForLostAndFound :: Boolean
isForLostAndFound = false



getPlaceNameResp :: String -> Maybe String -> Number -> Number -> LocationListItemState -> FlowBT String GetPlaceNameResp
getPlaceNameResp address placeId lat lon item = do
  case item.locationItemType of
    Just PREDICTION -> getPlaceNameRes
    _ -> checkLatLon
  where
    getPlaceNameRes :: FlowBT String GetPlaceNameResp
    getPlaceNameRes =
      case placeId of
        Just placeID  -> checkLatLonFromAddress placeID
        Nothing       ->  pure $ makePlaceNameResp lat lon
    
    checkLatLonFromAddress :: String -> FlowBT String GetPlaceNameResp
    checkLatLonFromAddress placeID = do
      let {latitude, longitude} = runFn1 getLatLonFromAddress address
      config <- getAppConfigFlowBT appConfig
      logField_ <- lift $ lift $ getLogFields
      if latitude /= 0.0 && longitude /= 0.0 && config.geoCoder.enableAddressToLL then do
        void $ liftFlowBT $ logEvent logField_ "ny_geocode_address_ll_found"
        pure $ makePlaceNameResp latitude longitude
      else do
        void $ liftFlowBT $ logEvent logField_ "ny_geocode_address_ll_fallback"
        Remote.placeNameBT (Remote.makePlaceNameReqByPlaceId placeID $ getMapsLanguageFormat $ getLanguageLocale languageKey)
    
    checkLatLon :: FlowBT String GetPlaceNameResp
    checkLatLon = 
      case item.lat, item.lon of
        Nothing, Nothing -> getPlaceNameRes
        Just 0.0, Just 0.0 -> getPlaceNameRes
        _ , _ -> pure $ makePlaceNameResp lat lon

makePlaceNameResp :: Number ->  Number -> GetPlaceNameResp
makePlaceNameResp lat lon =
  GetPlaceNameResp
  ([  PlaceName {
          formattedAddress : "",
          location : LatLong {
            lat : lat,
            lon : lon
          },
          plusCode : Nothing,
          addressComponents : [],
          placeId : Nothing
        }
        ])

getUpdatedLocationList :: Array LocationListItemState -> Maybe String -> Array LocationListItemState
getUpdatedLocationList locationList placeId = (map
                            (\item ->
                                ( item  {postfixImageUrl = if (item.placeId == placeId || item.postfixImageUrl == "ic_fav_red") then "ny_ic_fav_red" else "ic_fav" } )
                            ) (locationList))

transformSavedLocations :: Array LocationListItemState -> FlowBT String Unit
transformSavedLocations array = case DA.head array of
            Just item -> do
              case item.lat , item.lon , item.fullAddress.ward of
                Just 0.0 , Just 0.0 , Nothing ->
                  updateSavedLocation item 0.0 0.0
                Just 0.0 , Just 0.0 , Just _ ->
                  updateSavedLocation item 0.0 0.0
                Just lat , Just lon , Nothing ->
                  updateSavedLocation item lat lon
                Nothing, Nothing, Nothing ->
                  updateSavedLocation item 0.0 0.0
                _ , _ , _-> pure unit
              transformSavedLocations (DA.drop 1 array)
            Nothing -> pure unit

updateSavedLocation :: LocationListItemState -> Number -> Number -> FlowBT String Unit
updateSavedLocation item lat lon = do
  let placeId = item.placeId
      address = item.description
      tag = item.tag
  resp <- Remote.deleteSavedLocationBT (DeleteSavedLocationReq (trim item.tag))
  (GetPlaceNameResp placeNameResp) <- getPlaceNameResp item.address item.placeId lat lon item
  let (PlaceName placeName) = (fromMaybe dummyLocationName (placeNameResp DA.!! 0))
  let (LatLong placeLatLong) = (placeName.location)
  _ <- Remote.addSavedLocationBT (encodeAddressDescription address tag (item.placeId) (Just placeLatLong.lat) (Just placeLatLong.lon) placeName.addressComponents)
  _ <- pure $ setValueToLocalStore RELOAD_SAVED_LOCATION "true"
  pure unit

transformContactList :: Array NewContacts -> Array Contact
transformContactList contacts = map (\x -> getContact x) contacts

getContact :: NewContacts -> Contact
getContact contact = {
    name : contact.name
  , phoneNo : contact.number
}

getSpecialZoneQuotes :: Array OfferRes -> EstimateAndQuoteConfig -> Array ChooseVehicle.Config
getSpecialZoneQuotes quotes estimateAndQuoteConfig = mapWithIndex (\index item -> getSpecialZoneQuote item index) (getFilteredQuotes quotes estimateAndQuoteConfig)

getSpecialZoneQuote :: OfferRes -> Int -> ChooseVehicle.Config
getSpecialZoneQuote quote index =
  let estimatesConfig = (getAppConfig appConfig).estimateAndQuoteConfig
  in 
  case quote of
    Quotes body -> let (QuoteAPIEntity quoteEntity) = body.onDemandCab
      in ChooseVehicle.config {
        vehicleImage = getVehicleVariantImage quoteEntity.vehicleVariant
      , isSelected = (index == 0)
      , vehicleVariant = quoteEntity.vehicleVariant
      , price = (getCurrency appConfig) <> (show quoteEntity.estimatedTotalFare)
      , activeIndex = 0
      , index = index
      , id = trim quoteEntity.id
      , capacity = getVehicleCapacity quoteEntity.vehicleVariant
      , showInfo = estimatesConfig.showInfoIcon
      , searchResultType = ChooseVehicle.QUOTES
      , pickUpCharges = 0
      , serviceTierName = quoteEntity.serviceTierName
      , serviceTierShortDesc = quoteEntity.serviceTierShortDesc
      , airConditioned = Nothing
      }
    Metro body -> ChooseVehicle.config
    Public body -> ChooseVehicle.config

getEstimateList :: Array EstimateAPIEntity -> EstimateAndQuoteConfig -> Maybe Int -> Int -> Array ChooseVehicle.Config
getEstimateList quotes estimateAndQuoteConfig count activeIndex = 
  let mbCount = fromMaybe 0 count
      isFareRange = isFareRangePresent quotes
  in
  mapWithIndex (\index item -> getEstimates item index isFareRange mbCount activeIndex) (getFilteredEstimate quotes estimateAndQuoteConfig)

isFareRangePresent :: Array EstimateAPIEntity -> Boolean
isFareRangePresent estimates = DA.length (DA.filter (\(EstimateAPIEntity estimate) ->
         case estimate.totalFareRange of
                Nothing -> false
                Just (FareRange fareRange) -> not (fareRange.minFare == fareRange.maxFare )) estimates) > 0

getFilteredEstimate :: Array EstimateAPIEntity -> EstimateAndQuoteConfig -> Array EstimateAPIEntity
getFilteredEstimate estimates estimateAndQuoteConfig =
  let filteredEstimate = case (getMerchant FunctionCall) of
                            YATRISATHI -> DA.concat (map (\variant -> filterEstimateByVariants variant estimates) (estimateAndQuoteConfig.variantTypes :: Array (Array String)))
                            _          -> estimates
      sortWithFare = DA.sortWith (\(EstimateAPIEntity estimate) -> getFareFromEstimate (EstimateAPIEntity estimate)) filteredEstimate
  in sortEstimateWithVariantOrder sortWithFare estimateAndQuoteConfig.variantOrder
  where
    sortEstimateWithVariantOrder :: Array EstimateAPIEntity -> Array String -> Array EstimateAPIEntity
    sortEstimateWithVariantOrder estimates orderList =
      let orderListLength = DA.length orderList
          mappedEstimates = map (\(EstimateAPIEntity estimate) -> 
                              let orderNumber = fromMaybe (orderListLength + 1) (DA.elemIndex estimate.vehicleVariant orderList)
                                  isNY = if estimate.isValueAddNP == Just true then 0 else 1
                              in {item : (EstimateAPIEntity estimate), order : orderNumber * 10 + isNY}
                            ) estimates
          sortedEstimates = DA.sortWith (\mappedEstimate -> mappedEstimate.order) mappedEstimates
      in map (\sortedEstimate -> sortedEstimate.item) sortedEstimates

    filterEstimateByVariants :: Array String -> Array EstimateAPIEntity -> Array EstimateAPIEntity
    filterEstimateByVariants variant estimates = DA.take 1 (sortEstimateWithVariantOrder (DA.filter (\(EstimateAPIEntity item) -> DA.any (_ == item.vehicleVariant) variant) estimates) variant)


getFareFromEstimate :: EstimateAPIEntity -> Int
getFareFromEstimate (EstimateAPIEntity estimate) = do
  case estimate.totalFareRange of
    Nothing -> estimate.estimatedTotalFare
    Just (FareRange fareRange) -> if fareRange.minFare == fareRange.maxFare then estimate.estimatedTotalFare
                                                      else fareRange.minFare


getFilteredQuotes :: Array OfferRes -> EstimateAndQuoteConfig -> Array OfferRes
getFilteredQuotes quotes estimateAndQuoteConfig =
  let filteredArray = (case (getMerchant FunctionCall) of
                          YATRISATHI -> DA.concat (map (\variant -> filterQuoteByVariants variant quotes) (estimateAndQuoteConfig.variantTypes :: Array (Array String)))
                          _ -> quotes)
  in sortQuoteWithVariantOrder filteredArray estimateAndQuoteConfig.variantOrder
  where
    sortQuoteWithVariantOrder :: Array OfferRes -> Array String -> Array OfferRes
    sortQuoteWithVariantOrder quotes orderList =
      let orderListLength = DA.length orderList
          mappedQuotes = map (\quote -> case quote of
                                          Quotes body ->
                                            let (QuoteAPIEntity quoteEntity) = body.onDemandCab
                                                orderNumber = fromMaybe (orderListLength + 1) (DA.elemIndex quoteEntity.vehicleVariant orderList)
                                            in {item : Just quote, order : orderNumber}
                                          _ -> {item : Nothing, order : orderListLength}
                                ) quotes
          filterMappedQuotes = filter (\quote -> isJust quote.item) mappedQuotes
          sortedQuotes = DA.sortWith (\mappedQuote -> mappedQuote.order) filterMappedQuotes
      in DA.catMaybes $ map (\sortedEstimate -> sortedEstimate.item) sortedQuotes
    
    filterQuoteByVariants :: Array String -> Array OfferRes -> Array OfferRes
    filterQuoteByVariants variant quotes = DA.take 1 (sortQuoteWithVariantOrder (DA.filter(\item -> case item of
                                                                                                      Quotes body -> do
                                                                                                        let (QuoteAPIEntity quoteEntity) = body.onDemandCab
                                                                                                        DA.any (_ == quoteEntity.vehicleVariant) variant
                                                                                                      _ -> false
                                                                                          ) quotes) variant)

getEstimates :: EstimateAPIEntity -> Int -> Boolean -> Int -> Int -> ChooseVehicle.Config
getEstimates (EstimateAPIEntity estimate) index isFareRange count activeIndex  =
  let currency = getCurrency appConfig
      estimateAndQuoteConfig = (getAppConfig appConfig).estimateAndQuoteConfig
      config = getCityConfig (getAppConfig appConfig).cityConfig (getValueToLocalStore CUSTOMER_LOCATION)
      estimateFareBreakup = fromMaybe [] estimate.estimateFareBreakup
      pickUpCharges = fetchPickupCharges estimateFareBreakup
      extraFare = getFareBreakupList (EstimateAPIEntity estimate)
      fareMultiplier = if nightCharges then nightShiftMultiplier else 1.0
      additionalFare = maybe 20 calculateFareRangeDifference (estimate.totalFareRange)
      calculateFareRangeDifference fareRange = fareRange ^. _maxFare - fareRange ^. _minFare
      nightShiftRate = estimate.nightShiftRate
      nightShiftStart = maybe "" (view _nightShiftStart >>> fromMaybe "") nightShiftRate
      nightShiftEnd = maybe "" (view _nightShiftEnd >>> fromMaybe "") nightShiftRate
      nightShiftMultiplier = maybe 0.0 (view _nightShiftMultiplier >>> fromMaybe 0.0) nightShiftRate
      nightCharges = if isJust nightShiftRate 
                      then withinTimeRange nightShiftStart nightShiftEnd (convertUTCtoISC(getCurrentUTC "") "HH:mm:ss")
                      else false
      baseFare = maybe 0 calculateBaseFare (find hasBaseDistanceFare estimateFareBreakup)
      hasBaseDistanceFare item = item ^. _title == "BASE_DISTANCE_FARE"
      baseDistance = maybe 0 (view _price) (find hasBaseDistanceFare estimateFareBreakup)
      calculateBaseFare baseDistFare = round $ (toNumber $ baseDistFare ^. _price) * fareMultiplier
      extractFare f = case estimate.totalFareRange of
                        Just (FareRange fareRange) -> Just (f fareRange)
                        _ -> Nothing
  in ChooseVehicle.config {
        vehicleImage = getVehicleVariantImage estimate.vehicleVariant
      , vehicleVariant = estimate.vehicleVariant
      , price = case estimate.totalFareRange of
                Nothing -> currency <> (show estimate.estimatedTotalFare)
                Just (FareRange fareRange) -> if fareRange.minFare == fareRange.maxFare then currency <> (show estimate.estimatedTotalFare)
                                              else  currency <> (show fareRange.minFare) <> " - " <> currency <> (show fareRange.maxFare)
      , activeIndex = activeIndex
      , index = index
      , id = trim estimate.id
      , capacity = getVehicleCapacity estimate.vehicleVariant
      , showInfo = config.estimateAndQuoteConfig.showInfoIcon
      , basePrice = estimate.estimatedTotalFare
      , searchResultType = if isFareRange then ChooseVehicle.ESTIMATES else ChooseVehicle.QUOTES
      , pickUpCharges = pickUpCharges
      , tollCharge = fetchTollCharge estimateFareBreakup
      , serviceTierName =  mapServiceTierName estimate.vehicleVariant estimate.isValueAddNP estimate.serviceTierName
      , serviceTierShortDesc = mapServiceTierShortDesc estimate.vehicleVariant estimate.isValueAddNP estimate.serviceTierShortDesc
      , extraFare = extraFare
      , additionalFare = additionalFare
      , nightShiftMultiplier = nightShiftMultiplier
      , nightCharges = nightCharges
      , baseFare = baseFare
      , providerName = fromMaybe "" estimate.providerName
      , providerId = fromMaybe "" estimate.providerId
      , providerType = maybe CT.OFFUS (\valueAdd -> if valueAdd then CT.ONUS else CT.OFFUS) estimate.isValueAddNP
      , maxPrice = extractFare _.maxFare
      , minPrice = extractFare _.minFare
      , priceShimmer = count /= 1 
      }

mapServiceTierName :: String -> Maybe Boolean -> Maybe String -> Maybe String
mapServiceTierName vehicleVariant isValueAddNP serviceTierName = 
  case isValueAddNP of
    Just true -> serviceTierName -- NY Service Tier Name
    _ -> case vehicleVariant of
      "HATCHBACK" -> Just "Non - AC Mini"
      "SEDAN" -> Just "Sedan"
      "SUV" -> Just "XL Cab"
      "AUTO_RICKSHAW" -> Just "Auto"
      _ -> serviceTierName

mapServiceTierShortDesc :: String -> Maybe Boolean -> Maybe String -> Maybe String
mapServiceTierShortDesc vehicleVariant isValueAddNP serviceTierShortDesc = 
  case isValueAddNP of
    Just true -> serviceTierShortDesc -- NY Service Tier Short Desc
    _ -> case vehicleVariant of
      "HATCHBACK" -> Just "Budget friendly"
      "SEDAN" -> Just "AC, Premium Comfort"
      "SUV" -> Just "AC, Extra Spacious"
      "AUTO_RICKSHAW" -> Just "Easy Commute"
      _ -> serviceTierShortDesc

dummyFareRange :: FareRange
dummyFareRange = FareRange{
   maxFare : 0,
   minFare : 0
}


getTripDetailsState :: RideBookingRes -> TripDetailsScreenState -> TripDetailsScreenState
getTripDetailsState (RideBookingRes ride) state = do
  let (RideAPIEntity rideDetails) = (fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0))
      timeVal = (convertUTCtoISC (fromMaybe ride.createdAt ride.rideStartTime) "HH:mm:ss")
      nightChargesVal = (withinTimeRange "22:00:00" "5:00:00" timeVal)
      baseDistanceVal = (getKmMeter (fromMaybe 0 (rideDetails.chargeableRideDistance)))
      updatedFareList = getFaresList ride.fareBreakup baseDistanceVal
      city = getCityFromString $ getValueToLocalStore CUSTOMER_LOCATION
      nightChargeFrom = if city == Delhi then "11 PM" else "10 PM"
      nightChargeTill = "5 AM"
      nightCharges = if rideDetails.vehicleVariant == "AUTO_RICKSHAW" 
                          then 1.5 
                          else 1.1
      endTime = fromMaybe "" rideDetails.rideEndTime
      startTime = fromMaybe "" rideDetails.rideStartTime
  state {
    data {
      tripId = rideDetails.shortRideId,
      date = (convertUTCtoISC (ride.createdAt) "ddd, Do MMM"),
      time = (convertUTCtoISC (fromMaybe (ride.createdAt) ride.rideStartTime ) "h:mm A"),
      source= decodeAddress (Booking ride.fromLocation),
      destination= (decodeAddress (Booking (ride.bookingDetails ^._contents^._toLocation))),
      rating= (fromMaybe 0 ((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _rideRating)),
      driverName =((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _driverName) ,
      totalAmount = ("₹ " <> show (fromMaybe (0) ((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _computedPrice))),
      selectedItem = dummyIndividualCard{
        status = ride.status,
        faresList = getFaresList ride.fareBreakup (getKmMeter (fromMaybe 0 (rideDetails.chargeableRideDistance))),
        rideId = rideDetails.id,
        date = (convertUTCtoISC (ride.createdAt) "ddd, Do MMM"),
        time = (convertUTCtoISC (fromMaybe (ride.createdAt) ride.rideStartTime ) "h:mm A"),
        source= decodeAddress (Booking ride.fromLocation),
        destination= (decodeAddress (Booking (ride.bookingDetails ^._contents^._toLocation))),
        rating= (fromMaybe 0 ((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _rideRating)),
        driverName =((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _driverName),
        rideStartTime = (convertUTCtoISC startTime "h:mm A"),
        rideEndTime = (convertUTCtoISC endTime "h:mm A"),
        vehicleNumber = rideDetails.vehicleNumber,
        totalAmount = ("₹ " <> show (fromMaybe (0) ((fromMaybe dummyRideAPIEntity (ride.rideList DA.!!0) )^. _computedPrice))),
        shortRideId = rideDetails.shortRideId,
        baseDistance = baseDistanceVal,
        referenceString = (if (nightChargesVal && (getMerchant FunctionCall) /= YATRI) then (show nightCharges) <> (getEN $ DAYTIME_CHARGES_APPLICABLE_AT_NIGHT nightChargeFrom nightChargeTill) else "")
                        <> (if (isHaveFare "DRIVER_SELECTED_FARE" (updatedFareList)) then "\n\n" <> (getEN DRIVERS_CAN_CHARGE_AN_ADDITIONAL_FARE_UPTO) else "")
                        <> (if (isHaveFare "WAITING_OR_PICKUP_CHARGES" updatedFareList) then "\n\n" <> (getEN WAITING_CHARGE_DESCRIPTION) else "")
                        <> (if (isHaveFare "EARLY_END_RIDE_PENALTY" (updatedFareList)) then "\n\n" <> (getEN EARLY_END_RIDE_CHARGES_DESCRIPTION) else "")
                        <> (if (isHaveFare "CUSTOMER_SELECTED_FARE" ((updatedFareList))) then "\n\n" <> (getEN CUSTOMER_TIP_DESCRIPTION) else "")
                        <> (if isHaveFare "TOLL_CHARGES" updatedFareList then "\n\n" <> "⁺" <> (getEN TOLL_CHARGES_DESC) else ""),
        merchantExoPhone = ride.merchantExoPhone,
        serviceTierName = ride.serviceTierName,
        totalTime = show (runFn2 differenceBetweenTwoUTCInMinutes endTime startTime) <> " min",
        vehicleModel = rideDetails.vehicleModel,
        rideStartTimeUTC = fromMaybe "" ride.rideStartTime,
        rideEndTimeUTC = fromMaybe "" ride.rideEndTime
      },
      vehicleVariant = fetchVehicleVariant rideDetails.vehicleVariant
    }
  }


getNearByDrivers :: Array EstimateAPIEntity -> Array Paths
getNearByDrivers estimates = DA.nub (getCoordinatesFromEstimates [] estimates)
  where
    getCoordinatesFromEstimates :: Array Paths -> Array EstimateAPIEntity -> Array Paths
    getCoordinatesFromEstimates paths [] = paths
    getCoordinatesFromEstimates paths estimates =
      let firstItem = estimates DA.!! 0
          remainingItem = DA.drop 1 estimates
      in
        case firstItem of
          Just estimate -> getCoordinatesFromEstimates (paths <> (getCoordinatesFromEstimate estimate)) remainingItem
          Nothing       -> paths

    getCoordinatesFromEstimate :: EstimateAPIEntity -> Array Paths
    getCoordinatesFromEstimate (EstimateAPIEntity estimate) =
      let latLngs = estimate.driversLatLong
      in
        map (\(LatLong item) -> { lat : item.lat, lng : item.lon }) latLngs

dummyEstimateEntity :: EstimateAPIEntity
dummyEstimateEntity =
  EstimateAPIEntity
    { agencyNumber: ""
    , createdAt: ""
    , discount: Nothing
    , estimatedTotalFare: 0
    , agencyName: ""
    , vehicleVariant: ""
    , estimatedFare: 0
    , tripTerms: []
    , id: ""
    , agencyCompletedRidesCount: Nothing
    , estimateFareBreakup: Nothing
    , totalFareRange: Nothing
    , nightShiftRate: Nothing
    , specialLocationTag: Nothing
    , driversLatLong : []
    , serviceTierShortDesc: Nothing
    , serviceTierName : Nothing
    , airConditioned : Nothing
    , providerName : Nothing
    , providerId : Nothing
    , isValueAddNP : Nothing
    }

getTripFromRideHistory :: MyRidesScreenState -> Trip
getTripFromRideHistory state = {
    source :  state.data.selectedItem.source
  , destination : state.data.selectedItem.destination
  , sourceAddress : getAddressFromBooking state.data.selectedItem.sourceLocation
  , destinationAddress : getAddressFromBooking state.data.selectedItem.destinationLocation
  , sourceLat : state.data.selectedItem.sourceLocation^._lat
  , sourceLong : state.data.selectedItem.sourceLocation^._lon
  , destLat : state.data.selectedItem.destinationLocation^._lat
  , destLong : state.data.selectedItem.destinationLocation^._lon
  , isSpecialZone : state.data.selectedItem.isSpecialZone
  , frequencyCount : Nothing
  , recencyDate : Nothing
  , locationScore : Nothing
  , vehicleVariant : Just $ show state.data.selectedItem.vehicleVariant
  , serviceTierNameV2 : state.data.selectedItem.serviceTierName
  }

fetchPickupCharges :: Array EstimateFares -> Int 
fetchPickupCharges estimateFareBreakup = 
  let 
    deadKmFare = find (\a -> a ^. _title == "DEAD_KILOMETER_FARE") estimateFareBreakup
  in 
    maybe 0 (\fare -> fare ^. _price) deadKmFare


fetchTollCharge :: Array EstimateFares -> Int
fetchTollCharge estimateFareBreakup = 
  let 
    tollCharge = find (\a -> a ^. _title == "TOLL_CHARGES") estimateFareBreakup
  in 
    maybe 0 (\fare -> fare ^. _price) tollCharge

getActiveBooking :: Flow GlobalState (Maybe RideBookingRes)
getActiveBooking = do
  eiResp <- Remote.rideBookingList "1" "0" "true"
  pure $ 
    case eiResp of
      Right (RideBookingListRes listResp) -> DA.head $ listResp.list
      Left _ -> Nothing
  
getFormattedContacts :: FlowBT String (Array NewContacts)
getFormattedContacts = do
  (GetEmergContactsResp res) <- Remote.getEmergencyContactsBT GetEmergContactsReq
  pure $ getDefaultPriorityList $ map (\(ContactDetails item) -> {
      number: item.mobileNumber,
      name: item.name,
      isSelected: true,
      enableForFollowing: fromMaybe false item.enableForFollowing,
      enableForShareRide: fromMaybe false item.enableForShareRide,
      onRide : fromMaybe false item.onRide,
      priority: fromMaybe 1 item.priority
    }) res.defaultEmergencyNumbers

getFareBreakupList ::  EstimateAPIEntity -> Array FareList
getFareBreakupList (EstimateAPIEntity estimate) = 
  [ { key : getString $ MIN_FARE_UPTO $ show (baseDistance / 1000) <> "km", val : "₹" <> show baseFare }]
  <> (map constructExtraFareBreakup extraFareBreakup)
  <> (if tollCharge > 0 then [{ key : getString TOLL_CHARGES_ESTIMATED, val : "₹" <> (show $ fetchTollCharge fareBreakup) }] else [])
  <> [ { key : getString PICKUP_CHARGE, val : "₹" <> (show $ fetchPickupCharges fareBreakup) }]
  <> [ { key : getString $ WAITING_CHARGE_LIMIT $ show freeWaitingTime, val : "₹" <> show waitingCharge <> "/min"  }]
  where 
    fareBreakup = fromMaybe [] estimate.estimateFareBreakup
    extraFareBreakup = DA.sortBy compareByLimit $ DA.mapMaybe (\item -> if MP.startsWith "EXTRA_PER_KM_STEP_FARE_" (item ^. _title) 
                                                                          then Just $ parseStepFare item 
                                                                          else Nothing) fareBreakup
    compareByLimit a b = compare a.lLimit b.lLimit
    baseFare = maybe 0 calculateBaseFare (find hasBaseDistanceFare fareBreakup)
    hasBaseDistanceFare item = item ^. _title == "BASE_DISTANCE_FARE"
    fareMultiplier = if nightCharges then 
                        if estimate.vehicleVariant == "AUTO_RICKSHAW" 
                          then 1.5 
                          else 1.1
                     else 1.0
    nightShiftRate = estimate.nightShiftRate
    nightShiftStart = maybe "" (view _nightShiftStart >>> fromMaybe "") nightShiftRate
    nightShiftEnd = maybe "" (view _nightShiftEnd >>> fromMaybe "") nightShiftRate
    nightShiftMultiplier = maybe 0.0 (view _nightShiftMultiplier >>> fromMaybe 0.0) nightShiftRate
    nightCharges = if isJust nightShiftRate 
                    then withinTimeRange nightShiftStart nightShiftEnd (convertUTCtoISC(getCurrentUTC "") "HH:mm:ss")
                    else false
    hasBaseDistance item = item ^. _title == "BASE_DISTANCE"
    baseDistance = maybe 0 (view _price) (find hasBaseDistance fareBreakup)
    calculateBaseFare baseDistFare = round $ (toNumber $ baseDistFare ^. _price) * fareMultiplier
    freeWaitingTime = maybe 0 getPrice (find (\item -> item ^. _title == "FREE_WAITING_TIME_IN_MINUTES") fareBreakup)
    waitingCharge = maybe 0 getPrice (find (\item -> item ^. _title == "WAITING_CHARGE_PER_MIN") fareBreakup)
    tollCharge = fetchTollCharge fareBreakup
    getPrice item = item ^. _price

    parseStepFare :: EstimateFares -> StepFare
    parseStepFare item = 
      let title = item ^. _title
          price = item ^. _price
          trimmedTitle = drop (length "EXTRA_PER_KM_STEP_FARE_") title
          limits = split (Pattern "_") trimmedTitle
          upperlimit = case limits DA.!! 1 of
                        Just "Above" -> "+"
                        Just limit -> "-" <> show ((fromMaybe 0 $ fromString limit)/1000) <> "km"
                        Nothing -> ""
          lowerlimit = case (limits DA.!! 0) of
                        Just limit -> fromMaybe 0 $ fromString limit
                        Nothing -> 0
      in { lLimit : lowerlimit, uLimit : upperlimit, price : price }

    constructExtraFareBreakup :: StepFare -> FareList
    constructExtraFareBreakup item = 
      let lowerlimit = show (item.lLimit/1000) <> "km"
      in { key : getString $ FARE_FOR $ lowerlimit <> item.uLimit, val : "₹" <> (show $ round $ fareMultiplier * (toNumber item.price)) }

type StepFare = 
  { lLimit :: Int,
    uLimit :: String,
    price :: Int
  }