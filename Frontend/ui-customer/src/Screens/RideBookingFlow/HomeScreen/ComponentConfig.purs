{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.RideBookingFlow.HomeScreen.Config where

import Common.Types.App
import Language.Strings
import Prelude
import PrestoDOM
import Animation.Config as AnimConfig
import Common.Types.App (LazyCheck(..))
import Components.Banner as Banner
import Components.MessagingView as MessagingView
import Components.BannerCarousel as BannerCarousel
import Components.ChatView as ChatView
import Components.ChooseYourRide as ChooseYourRide
import Components.DriverInfoCard (DriverInfoCardData)
import Components.DriverInfoCard as DriverInfoCard
import Components.EmergencyHelp as EmergencyHelp
import Components.ErrorModal as ErrorModal
import Components.MenuButton as MenuButton
import Components.PopUpModal as PopUpModal
import Components.PrimaryButton as PrimaryButton
import Components.QuoteListModel as QuoteListModel
import Components.RateCard as RateCard
import Components.RatingCard as RatingCard
import Components.RequestInfoCard as RequestInfoCard
import Components.RideCompletedCard as RideCompletedCard
import Components.SearchLocationModel as SearchLocationModel
import Components.LocationTagBarV2 as LocationTagBar
import Components.SelectListModal as CancelRidePopUpConfig
import Components.SourceToDestination as SourceToDestination
import Components.Referral as ReferralComponent
import Control.Monad.Except (runExcept)
import Data.Array ((!!), sortBy, mapWithIndex, elem, length)
import Data.Array as DA
import Data.Either (Either(..))
import Data.Function.Uncurried (runFn3)
import Data.Int (toNumber)
import Data.Int as INT
import Data.Maybe (Maybe(..), fromMaybe, isJust, maybe)
import Data.String as DS
import DecodeUtil (getAnyFromWindow)
import Effect (Effect)
import Engineering.Helpers.Commons as EHC
import Engineering.Helpers.Suggestions (getSuggestionsfromKey, emChatSuggestion, chatSuggestion)
import Font.Size as FontSize
import Font.Style as FontStyle
import Foreign.Class (class Encode)
import Foreign.Generic (decodeJSON, encodeJSON)
import Helpers.Utils (fetchImage, FetchImageFrom(..), parseFloat, getCityNameFromCode, getCityFromString, isWeekend, getCityFromString, getCityConfig)
import Helpers.Utils as HU
import JBridge as JB
import Language.Types (STR(..))
import MerchantConfig.Utils as MU
import PrestoDOM (Accessiblity(..))
import PrestoDOM.Types.DomAttributes (Corners(..))
import Resources.Constants (getKmMeter, emergencyContactInitialChatSuggestionId)
import Screens.Types (DriverInfoCard, Stage(..), ZoneType(..), TipViewData, TipViewStage(..), TipViewProps, City(..), ReferralStatus(..))
import Screens.Types as ST
import Storage (KeyStore(..), getValueToLocalStore, isLocalStageOn, setValueToLocalStore)
import Styles.Colors as Color
import Common.Types.App (LazyCheck(..))
import Engineering.Helpers.Suggestions (getSuggestionsfromKey)
import Components.ChooseVehicle.Controller as ChooseVehicle
import Foreign.Generic (decode, encode, Foreign, decodeJSON, encodeJSON, class Decode, class Encode)
import Data.Either (Either(..))
import Font.Style (Style(..))
import Services.API as API
import Data.Lens ((^.))
import Accessor (_fareBreakup, _description, _rideEndTime, _amount, _serviceTierName)
import Resources.Localizable.EN(getEN)
import Engineering.Helpers.Utils as EHU
import Mobility.Prelude
import Locale.Utils
import Screens.RideBookingFlow.HomeScreen.BannerConfig (getBannerConfigs, getDriverInfoCardBanners)
import Components.PopupWithCheckbox.Controller as PopupWithCheckboxController 
import LocalStorage.Cache (getValueFromCache)
import ConfigProvider
import Accessor (_contents, _description, _place_id, _toLocation, _lat, _lon, _estimatedDistance, _rideRating, _driverName, _computedPrice, _otpCode, _distance, _maxFare, _estimatedFare, _estimateId, _vehicleVariant, _estimateFareBreakup, _title, _priceWithCurrency, _totalFareRange, _maxFare, _minFare, _nightShiftRate, _nightShiftEnd, _nightShiftMultiplier, _nightShiftStart, _specialLocationTag, _createdAt)
import Data.Lens ((^.), view)
import Components.ServiceTierCard.View as ServiceTierCard

shareAppConfig :: ST.HomeScreenState -> PopUpModal.Config
shareAppConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
      gravity = CENTER,
      margin = MarginHorizontal 24 24,
      buttonLayoutMargin = Margin 16 0 16 20,
      primaryText {
        text = getString YOUR_RIDE_HAS_STARTED
      , margin = MarginHorizontal 16 16},
      secondaryText {
        text = getString(ENJOY_RIDING_WITH_US)
      , margin = MarginVertical 12 24
      , color = Color.black700},
      option1 {
        text = getString(MAYBE_LATER)
      , width = V $ (((EHC.screenWidth unit)-92)/2)
      , background = Color.white900
      , strokeColor = Color.black500
      , color = Color.black700
      },
      option2 {
        text = getString(SHARE_APP)
      , width = V $ (((EHC.screenWidth unit)-92)/2)
      , color = state.data.config.primaryTextColor
      , strokeColor = state.data.config.primaryBackground
      , background = state.data.config.primaryBackground
      , margin = MarginLeft 12
      },
      cornerRadius = Corners 15.0 true true true true,
      coverImageConfig {
        imageUrl = fetchImage FF_ASSET "ic_share_app"
      , visibility = VISIBLE
      , margin = Margin 16 20 16 24
      , width = MATCH_PARENT
      , height = V 200
      }
  }
  in popUpConfig'

cancelAppConfig :: ST.HomeScreenState -> PopUpModal.Config
cancelAppConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
      gravity = BOTTOM,
      dismissPopup =true,
      optionButtonOrientation = "VERTICAL",
      buttonLayoutMargin = Margin 16 0 16 20,
      primaryText {
        text = distanceString <> getString PLEASE_CONTACT_THE_DRIVER_BEFORE_CANCELLING
      , margin = Margin 16 20 16 20},
      secondaryText { visibility = GONE },
      option1 {
        text = getString CALL_DRIVER
      , color = state.data.config.primaryTextColor
      , background = state.data.config.primaryBackground
      , strokeColor = Color.transparent
      , textStyle = FontStyle.SubHeading1
      , width = MATCH_PARENT
      , enableRipple = true
      },
      option2 {
        text = getString CANCEL_RIDE
      , textStyle = FontStyle.SubHeading1
      , color = Color.black700
      , background = Color.white900
      , strokeColor = Color.transparent
      , width = MATCH_PARENT
      , margin = Margin 0 0 0 0
      },
      cornerRadius = Corners 15.0 true true false false,
      coverImageConfig {
        imageUrl = fetchImage FF_ASSET $ if state.data.driverInfoCardState.distance <= 500
                    then if state.data.driverInfoCardState.vehicleVariant == "AUTO_RICKSHAW"  then "ny_ic_driver_near_auto" else "ny_ic_driver_near"
                    else if state.data.driverInfoCardState.vehicleVariant == "AUTO_RICKSHAW" then  "ny_ic_driver_started_auto" else "ny_ic_driver_started"
      , visibility = VISIBLE
      , margin = Margin 16 20 16 24
      , width = MATCH_PARENT
      , height = V 200
      }
  }
  in popUpConfig'
      where distanceString = getDistanceString state.data.driverInfoCardState.distance (fromMaybe 0 state.data.driverInfoCardState.initDistance) state.props.zoneType.priorityTag


getDistanceString :: Int -> Int -> ZoneType -> String
getDistanceString currDistance initDistance zoneType
  | currDistance <= 15 =  getString DRIVER_IS_NEAR_YOUR_LOCATION
  | currDistance <= 500 = (if zoneType == METRO then
                              getString DRIVER_PREFERRED_YOUR_SPECIAL_REQUEST_AND_IS_JUST
                            else
                              getString YOUR_DRIVER_IS_JUST
                            ) <> show currDistance <> getString M_AWAY
  | otherwise = if zoneType == METRO then
                  getString THE_DRIVER_PREFERRED_YOUR_SPECIAL_REQUEST_AND_IS_ALREADY_ON_THE_WAY_TO_YOUR_LOCATION
                else
                  getString DRIVER_IS_ALREADY_ON_THE_WAY_TO_YOUR_LOCATION

skipButtonConfig :: ST.HomeScreenState -> PrimaryButton.Config
skipButtonConfig state =
  let
    config = PrimaryButton.config
    buttonText =
      if state.data.ratingViewState.selectedYesNoButton == boolToInt state.props.nightSafetyFlow && issueFaced
      then
        REPORT_ISSUE_
      else
        DONE
    primaryButtonConfig' =
      config
        { textConfig
          { text = getString buttonText
          , accessibilityHint = "Done : Button"
          , color = state.data.config.primaryTextColor
          }
        , background = state.data.config.primaryBackground
        , margin = MarginTop 22
        , id = "SkipButton"
        , enableLoader = (JB.getBtnLoader "SkipButton")
        , visibility = boolToVisibility $ doneButtonVisibility || state.data.ratingViewState.doneButtonVisibility
        , isClickable = issueFaced || state.data.ratingViewState.selectedRating > 0 || getSelectedYesNoButton state >= 0
        , alpha = if issueFaced || (state.data.ratingViewState.selectedRating >= 1) || getSelectedYesNoButton state >= 0 then 1.0 else 0.4
        , enableRipple = issueFaced || state.data.ratingViewState.selectedRating > 0 || getSelectedYesNoButton state >= 0
        , rippleColor = Color.rippleShade
        }
  in
    primaryButtonConfig'
  where 
      issueFaced =  state.data.ratingViewState.issueFacedView
      showOfferedAssistancePopUp = state.props.showOfferedAssistancePopUp
      doneButtonVisibility = case issueFaced, showOfferedAssistancePopUp of 
                                  false, false -> true
                                  _, _ -> false

getSelectedYesNoButton :: ST.HomeScreenState -> Int
getSelectedYesNoButton state = state.data.ratingViewState.selectedYesNoButton

maybeLaterButtonConfig :: ST.HomeScreenState -> PrimaryButton.Config
maybeLaterButtonConfig state =
  let
    issueFaced =  state.data.ratingViewState.issueFacedView
    config = PrimaryButton.config
    primaryButtonConfig' =
      config
        { textConfig
          { text = ""
          , textFromHtml =  Just ("<u>" <> (getString MAYBE_LATER) <> "<u>")
          , accessibilityHint = "Maybe Later : Button"
          , color = Color.black650
          }
        , background = Color.white900
        , id = "MaybeLaterButton"
        , margin = (Margin 0 0 0 0)
        }
  in
    primaryButtonConfig'

updateProfileConfig :: ST.HomeScreenState -> PrimaryButton.Config
updateProfileConfig state =
  let
    config = PrimaryButton.config
    primaryButtonConfig' =
      config
        { textConfig
          { text = getString UPDATE_PROFILE
          , accessibilityHint = "Update Profile : Button"
          , color = state.data.config.primaryTextColor
          }
        , background = Color.black900
        , margin = MarginTop 8
        , id = "UpdateProfile"
        }
  in
    primaryButtonConfig'

whereToButtonConfig :: ST.HomeScreenState -> PrimaryButton.Config
whereToButtonConfig state =
  let
    config = PrimaryButton.config
    primaryButtonConfig' = config
      { textConfig
        { text = (getString WHERE_TO)
        , width = MATCH_PARENT
        , gravity = LEFT
        , color = state.data.config.primaryTextColor
        , accessibilityHint = "Where To : Button"
        }
      , height = V 60
      , gravity = CENTER_VERTICAL
      , cornerRadius = 8.0
      , margin = (MarginHorizontal 16 16)
      , isClickable = true
      , isPrefixImage = true
      , background = state.data.config.primaryBackground
      , prefixImageConfig
        { imageUrl = fetchImage FF_ASSET "ny_ic_bent_right_arrow"
        , height = V 16
        , width = V 21
        , margin = (Margin 17 0 17 0)
        }
      , id = "WheretoButton"
      }
  in primaryButtonConfig'

primaryButtonRequestRideConfig :: ST.HomeScreenState -> PrimaryButton.Config
primaryButtonRequestRideConfig state =
  let
    config = PrimaryButton.config
    primaryButtonConfig' =
      config
        { textConfig
          { text = if state.props.repeatRideTimer /= "0" && not DS.null state.props.repeatRideTimerId 
                    then ((getString REQUESTING_RIDE_IN) <> " " <> state.props.repeatRideTimer <> "s") 
                    else if state.props.repeatRideTimer == "0" then (getString REQUESTING_RIDE) <> "..." 
                    else (getString REQUEST_RIDE)
          , color = state.data.config.primaryTextColor
          , accessibilityHint = "Request Ride : Button"
          }
        , cornerRadius = state.data.config.primaryButtonCornerRadius
        , margin = (Margin 0 32 0 0)
        , id = "RequestRideButton"
        , background = state.data.config.primaryBackground
        , enableRipple = true
        , rippleColor = Color.rippleShade
        }
  in
    primaryButtonConfig'

primaryButtonConfirmPickupConfig :: ST.HomeScreenState -> PrimaryButton.Config
primaryButtonConfirmPickupConfig state =
  let
    config = PrimaryButton.config
    primaryButtonConfig' =
      config
        { textConfig
          { text = (getString CONFIRM_LOCATION)
          , color = state.data.config.primaryTextColor
          , accessibilityHint = "Confirm PickUp Location : Button"
          }
        , cornerRadius = state.data.config.primaryButtonCornerRadius
        , margin = (MarginTop 8)
        , id = "ConfirmLocationButton"
        , background = state.data.config.primaryBackground
        , enableRipple = true
        , rippleColor = Color.rippleShade
        }
  in
    primaryButtonConfig'



cancelRidePopUpConfig :: ST.HomeScreenState -> CancelRidePopUpConfig.Config
cancelRidePopUpConfig state =
  let
    cancelRideconfig = CancelRidePopUpConfig.config
    lastIndex = (DA.length state.props.cancellationReasons) - 1
    cancelRideConfig = state.data.config.cancelReasonConfig
  in
    CancelRidePopUpConfig.config
        { selectionOptions = state.props.cancellationReasons
        , showAllOptionsText = (getString SHOW_ALL_OPTIONS)
        , primaryButtonTextConfig
          { firstText = getString WAIT_FOR_DRIVER
          , secondText = getString CANCEL_RIDE
          }
        , activeIndex = state.props.cancelRideActiveIndex
        , activeReasonCode = Just state.props.cancelReasonCode
        , isLimitExceeded = DS.length state.props.cancelDescription >= 100
        , cornerRadius = cancelRideConfig.buttonCornerRadius
        , isSelectButtonActive =
          ( case state.props.cancelRideActiveIndex of
              Just cancelRideIndex -> true
              Nothing -> false
          )
        , headingTextConfig{
          text = getString CANCEL_RIDE <> "?"
        }
        , subHeadingTextConfig{
          text = getString PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL
        }
        , hint = getString HELP_US_WITH_YOUR_REASON
        , strings
          { mandatory = getString MANDATORY
          , limitReached = getString MAX_CHAR_LIMIT_REACHED <> " 100 " <> getString OF <> " 100"
          }
        , config = state.data.config
        }

genderBannerConfig :: forall action. ST.HomeScreenState -> action -> BannerCarousel.Config action
genderBannerConfig state action =
  let
    config = BannerCarousel.config action
    config' = config
      {
        backgroundColor = Color.lightMintGreen
      , title = (getString COMPLETE_YOUR_PROFILE_FOR_A_PERSONALISED_RIDE_EXPERIENCE)
      , titleColor = Color.elfGreen
      , actionText = (getString UPDATE_NOW)
      , actionTextColor = Color.elfGreen
      , imageUrl = "ny_ic_banner_gender_feat"
      , type = BannerCarousel.Gender
      }
  in config'

rentalBannerConfig :: ST.HomeScreenState -> Banner.Config
rentalBannerConfig state =
  let
    config = Banner.config
    config' = config
      {
        backgroundColor = Color.blue600
      , stroke = "1," <> Color.grey900
      , imageHeight = V 43
      , imageWidth = V 66
      , imagePadding = PaddingVertical 0 0
      , title = "Rental booking at " <> (maybe "" (_.rentalsScheduledAt) state.data.rentalsInfo)
      , titleColor = Color.blue800
      , actionTextVisibility = false
      , cornerRadius = 8.0
      , imageUrl = fetchImage FF_COMMON_ASSET "ny_ic_rental_booking"
      , imageMargin = MarginRight 0
      }
  in config'

disabilityBannerConfig :: forall a. ST.HomeScreenState -> a -> BannerCarousel.Config a
disabilityBannerConfig state action =
  let
    config = BannerCarousel.config action
    config' = config
      {
        backgroundColor = Color.paleLavender
      , title = (getString NOW_GET_ASSISTED_RIDES)
      , titleColor = Color.purple
      , actionText = (getString UPDATE_PROFILE)
      , actionTextColor = Color.purple
      , imageUrl = "ny_ic_accessibility_banner_img"
      , type = BannerCarousel.Disability
      }
  in config'
  
sosSetupBannerConfig :: forall a. ST.HomeScreenState -> a -> BannerCarousel.Config a
sosSetupBannerConfig state action =
  let
    config = BannerCarousel.config action

    bannerConfig =
      case state.props.sosBannerType of
        Just ST.SETUP_BANNER -> {title: getString COMPLETE_YOUR_NAMMA_SAFETY_SETUP_FOR_SAFE_RIDE_EXPERIENCE, actionText: getString SETUP_NOW, image : "ny_ic_banner_sos"}
        Just ST.MOCK_DRILL_BANNER -> {title: getString COMPLETE_YOUR_TEST_DRILL, actionText: getString TEST_DRILL, image : "ny_ic_mock_drill_banner"}
        Nothing -> {title: "", actionText: "", image : ""}

    config' =
      config
        { backgroundColor = Color.lightMintGreen
        , title = bannerConfig.title
        , titleColor = Color.elfGreen
        , actionText = bannerConfig.actionText
        , actionTextColor = Color.elfGreen
        , imageUrl = fetchImage FF_ASSET bannerConfig.image
        , type = BannerCarousel.Safety
        }
  in
    config'



metroBannerConfig :: forall a. ST.HomeScreenState -> a -> BannerCarousel.Config a
metroBannerConfig state action =
  let
    config = BannerCarousel.config action
    config' = config
      {
        backgroundColor = Color.blue600'
      , title = getString BOOK_METRO_WITH_NY_NOW
      , titleColor = Color.blue800
      , actionText = getString BOOK_NOW
      , actionTextColor = Color.blue700
      -- , actionTextBackgroundColour = Color.blue800
      , actionTextCornerRadius = "12.0"
      , imageUrl = fetchImage FF_ASSET "ny_ic_metro_banner"
      , margin = MarginTop 0
      , imageHeight = V 100
      , imageWidth = V 120
      , padding = Padding 0 2 5 5
      , imagePadding = PaddingLeft 24
      , type = BannerCarousel.MetroTicket
      }
  in config'

ticketBannerConfig :: forall action. ST.HomeScreenState -> action -> BannerCarousel.Config action
ticketBannerConfig state action =
  let
    config = BannerCarousel.config action
    config' = config
      {
        backgroundColor = "#FFF6DE"
      , title = "Book Millennium Jetty, Heritage cruise and Alipore  zoo tickets "
      , titleColor = Color.black800
      , actionText = "Book Now"
      , actionTextColor = Color.black900
      , imageUrl = fetchImage FF_ASSET "ny_ic_zoo_banner"
      , margin = MarginTop 0
      , imageHeight = V 75
      , imageWidth = V 60
      , padding = Padding 0 5 5 5
      , type = BannerCarousel.ZooTicket
      }
  in config'

metroTicketBannerConfig :: ST.HomeScreenState -> Banner.Config
metroTicketBannerConfig state = 
  let
    config = Banner.config
    config' = config
      {
        backgroundColor = Color.blue600'
      , title = "Book metro tickets with \nNamma Yatri Now!"
      , titleColor = Color.blue800
      , actionText = "Book Now"
      , actionTextColor = Color.white900
      , actionTextBackgroundColor = Color.blue800
      , actionTextCornerRadius = 12.0
      , imageUrl = fetchImage FF_ASSET "ny_ic_metro_banner"
      , margin = MarginTop 0
      , imageHeight = V 100
      , imageWidth = V 120
      , padding = Padding 0 2 5 5
      , imagePadding = PaddingLeft 24
      }
  in config'
reportIssuePopUpConfig :: ST.HomeScreenState -> CancelRidePopUpConfig.Config
reportIssuePopUpConfig state =
  let
    reportIssueConfig = CancelRidePopUpConfig.config
    reportIssueConfig' =
      reportIssueConfig
        { selectionOptions = options
        , primaryButtonTextConfig
          { firstText = getString GO_BACK_
          , secondText = getString SUBMIT
          }
        , activeIndex = state.data.ratingViewState.issueReportActiveIndex
        , activeReasonCode = state.data.ratingViewState.issueReasonCode
        , isLimitExceeded = false
        , isSelectButtonActive =
          ( case state.data.ratingViewState.issueReportActiveIndex of
              Just issueReportActiveIndex -> true
              Nothing -> false
          )
        , headingTextConfig{
          text = getString REPORT_ISSUE_
        }
        , subHeadingTextConfig{
          text = getString PLEASE_TELL_US_WHAT_WENT_WRONG
        }
        , hint = getString HELP_US_WITH_YOUR_REASON
        , strings
          { mandatory = getString MANDATORY
          , limitReached = ((getString MAX_CHAR_LIMIT_REACHED) <> " 100 " <> (getString OF) <> " 100")
          }
        }
  in
    reportIssueConfig'
  where options = if state.props.nightSafetyFlow then safetyIssueOptions false else reportIssueOptions state

logOutPopUpModelConfig :: ST.HomeScreenState -> PopUpModal.Config
logOutPopUpModelConfig state =
  case state.props.isPopUp of
    ST.Logout ->
      let
        config' = PopUpModal.config
        popUpConfig' =
          config'
            { primaryText { text = (getString LOGOUT_) }
            , secondaryText { text = (getString ARE_YOU_SURE_YOU_WANT_TO_LOGOUT) }
            , option1 {
                background = state.data.config.popupBackground
              , strokeColor = state.data.config.primaryBackground
              , color = state.data.config.primaryBackground
              , text = (getString GO_BACK_)
              , enableRipple = true
              }
            , option2 {
                color = state.data.config.primaryTextColor
              , strokeColor = state.data.config.primaryBackground
              , background = state.data.config.primaryBackground
              , text = (getString LOGOUT_)
              , enableRipple = true
              }
            }
      in
        popUpConfig'
    ST.TipsPopUp -> do 
      let tipConfig = getTipConfig state.data.selectedEstimatesObject.vehicleVariant
          isTipEnabled = state.data.config.tipsEnabled && (DA.length tipConfig.customerTipArray) > 0 
          customerTipArray = tipConfig.customerTipArray
          customerTipArrayWithValues = tipConfig.customerTipArrayWithValues
      PopUpModal.config{
          optionButtonOrientation = "VERTICAL"
          , dismissIconMargin = Margin 0 0 14 13
          , dismissIconVisibility = if isLocalStageOn ST.QuoteList then GONE else VISIBLE
          , backgroundClickable = true
          , customerTipAvailable = state.data.selectedEstimatesObject.providerType == ONUS 
          , fareEstimateText = getString FARE_ESTIMATE
          , tipSelectedText = getString TIP_SELECTED
          , fareEstimate = getValueToLocalStore FARE_ESTIMATE_DATA
          , tipSelected = if state.props.customerTip.tipActiveIndex == 0 then "-" else " ₹"<> (show (fromMaybe 0 (customerTipArrayWithValues DA.!! state.props.customerTip.tipActiveIndex)))
          , dismissPopup = true
          , customerTipArray = customerTipArray
          , customerTipArrayWithValues = customerTipArrayWithValues
          , isTipEnabled = isTipEnabled
          , primaryText {
              text = if isLocalStageOn ST.QuoteList then (getString TRY_AGAIN <> "?") else getString SEARCH_AGAIN_WITH_A_TIP
            , textStyle = FontStyle.Heading1
            },
          secondaryText {
              text = (getString BOOST_YOUR_RIDE_CHANCES_AND_HELP_DRIVERS_WITH_TIPS)
            , color = Color.black650
            , visibility = boolToVisibility $ isTipEnabled
            }
          , tipLayoutMargin = (Margin 22 2 22 22)
          , buttonLayoutMargin = (MarginHorizontal 16 16)
          , activeIndex = state.props.customerTip.tipActiveIndex
          , isVisible = state.props.tipViewProps.isVisible
          , isTipPopup = true
          , tipButton {
                background = Color.white900
              , color = Color.black800
              , strokeColor = Color.grey900
              , padding = (Padding 16 12 16 12)
            },
          option1 {
            text = if (not isTipEnabled) then getString SEARCH_AGAIN else if state.props.customerTip.tipActiveIndex == 0 then getString SEARCH_AGAIN_WITHOUT_A_TIP else getTipString state customerTipArrayWithValues
          , width = MATCH_PARENT
          , color = state.data.config.primaryTextColor
          , strokeColor = state.data.config.primaryBackground
          , background = state.data.config.primaryBackground
          , padding = (Padding 0 10 0 10)
          },
          option2 {
            text = if (isLocalStageOn ST.QuoteList) then (getString HOME) else  (getString CANCEL_SEARCH)
          , width = MATCH_PARENT
          , background = Color.white900
          , strokeColor = Color.white900
          , margin = MarginTop 14
          , padding = PaddingBottom $ getBottomMargin
          , color = Color.black650
          , height = WRAP_CONTENT
          },
          cornerRadius = (Corners 15.0 true true false false)
      }
    _ ->
      let
        config' = PopUpModal.config
        popUpConfig' =
          config'
            { primaryText { text = if (isLocalStageOn ST.QuoteList) then ((getString TRY_AGAIN) <> "?") else ((getString CANCEL_SEARCH) <> "?")}
            , buttonLayoutMargin = (MarginHorizontal 16 16)
            , dismissPopup = true
            , optionButtonOrientation = if(isLocalStageOn ST.QuoteList || isLocalStageOn ST.FindingQuotes || state.data.iopState.providerSelectionStage) then  "VERTICAL" else "HORIZONTAL"
            , secondaryText { text = if (isLocalStageOn ST.QuoteList) then (getString TRY_LOOKING_FOR_RIDES_AGAIN) else (getString CANCEL_ONGOING_SEARCH)}
            , option1 {
              text = if (isLocalStageOn ST.QuoteList) then (getString YES_TRY_AGAIN) else (getString YES_CANCEL_SEARCH)
            , width = MATCH_PARENT
            , color = state.data.config.primaryTextColor
            , strokeColor = state.data.config.primaryBackground
            , background = state.data.config.primaryBackground
            , padding = (Padding 0 10 0 10)
            , enableRipple = true
            }
            , option2 {
               text = if (isLocalStageOn ST.QuoteList) then (getString HOME) else (getString NO_DONT)
              , width = MATCH_PARENT
              , background = Color.white900
              , strokeColor = Color.white900
              , margin = MarginTop $ if (isLocalStageOn ST.QuoteList || isLocalStageOn ST.FindingQuotes) then 14 else 3
              , color = Color.black650
              , padding = if (isLocalStageOn ST.QuoteList || isLocalStageOn ST.FindingQuotes) then (PaddingBottom getBottomMargin) else (Padding 0 0 0 0)
             }
            }
      in
        popUpConfig'
  where getTipString :: ST.HomeScreenState -> Array Int -> String
        getTipString state customerTipArrayWithValues = do
          let tip = show (fromMaybe 0 (customerTipArrayWithValues DA.!! state.props.customerTip.tipActiveIndex))
          case (getLanguageLocale languageKey) of
            "EN_US" -> getString SEARCH_AGAIN_WITH  <> " +₹"<> tip <>" "<> getString TIP
            _ -> "+₹"<> tip <>" "<>(getString TIP) <> " " <> getString SEARCH_AGAIN_WITH


getBottomMargin :: Int
getBottomMargin = if EHC.safeMarginBottom == 0 then 24 else (EHC.safeMarginBottom)

distanceOusideLimitsConfig :: ST.HomeScreenState -> PopUpModal.Config
distanceOusideLimitsConfig state =
  let
    config' = PopUpModal.config
    popUpConfig' =
      config'
        { backgroundClickable = false
        , primaryText
          { text = (getString DESTINATION_OUTSIDE_LIMITS)
          , margin = (Margin 16 20 16 0)
          }
        , secondaryText
          { text = (getString DROP_LOCATION_FAR_AWAY)
          , margin = (Margin 0 16 0 20)
          }
        , option1 { visibility = false }
        , option2 {
            background = state.data.config.primaryBackground
          , strokeColor = state.data.config.primaryBackground
          , color = state.data.config.primaryTextColor
          , text = (getString CHANGE_DROP_LOCATION)
          , margin = (Margin 16 0 16 EHC.safeMarginBottom)
          , enableRipple = true
          }
        }
  in
    popUpConfig'

pickUpFarFromCurrentLocationConfig :: ST.HomeScreenState -> PopUpModal.Config
pickUpFarFromCurrentLocationConfig state =
  let
    config' = PopUpModal.config
    popUpConfig' =
      config'
        { backgroundClickable = false
        , primaryText
          { text = getString YOU_SEEM_TO_BE_FAR_FROM_PICK_UP
          , margin = (Margin 16 20 16 0)
          }
        , secondaryText
          { text = getString ARE_YOU_SURE_YOU_WANT_TO_PROCEED_WITH_THE_BOOKING
          , margin = (Margin 0 16 0 20)
          }
        , option1 {
            background = state.data.config.popupBackground
          , strokeColor = state.data.config.primaryBackground
          , color = state.data.config.primaryBackground
          , text = (getString GO_BACK_)
          }
        , option2 {
            color = state.data.config.primaryTextColor
          , strokeColor = state.data.config.primaryBackground
          , background = state.data.config.primaryBackground
          , text = (getString BOOK_RIDE_)
          }
        }
  in
    popUpConfig'

shortDistanceConfig :: ST.HomeScreenState -> PopUpModal.Config
shortDistanceConfig state =
  let
    config' = PopUpModal.config
    popUpConfig' =
      config'
        { backgroundClickable = false
        , primaryText
          { text = (getString YOUR_TRIP_IS_TOO_SHORT_YOU_ARE_JUST) <> HU.toStringJSON (state.props.distance) <> (getString METERS_AWAY_FROM_YOUR_DESTINATION)
          , margin = (Margin 16 20 16 0)
          }
        , secondaryText
          { text = (getString YOU_CAN_TAKE_A_WALK_OR_CONTINUE_WITH_RIDE_BOOKING)
          , margin = (Margin 0 16 0 20)
          }
        , option1 {
            background = state.data.config.popupBackground
          , strokeColor = state.data.config.primaryBackground
          , color = state.data.config.primaryBackground
          , text = (getString GO_BACK_)
          , enableRipple = true
          }
        , option2 {
            color = state.data.config.primaryTextColor
          , strokeColor = state.data.config.primaryBackground
          , background = state.data.config.primaryBackground
          , text = (getString BOOK_RIDE_)
          , enableRipple = true
          }
        }
  in
    popUpConfig'

isMockLocationConfig :: ST.HomeScreenState -> ErrorModal.Config
isMockLocationConfig state =
  let
    config = ErrorModal.config
    appConfig = state.data.config
    errorModalConfig' =
      config
        { height = MATCH_PARENT 
        , background = Color.white900
        , stroke = ("1," <> Color.borderGreyColor)
        , imageConfig
          { imageUrl = fetchImage FF_ASSET "ny_ic_location_unserviceable"
          , height = V 99
          , width = V 133
          , margin = Margin 0 50 0 20
          }
        , errorConfig
          { text = if state.props.isMockLocation then "Unable to get your location!" else (getString LOCATION_UNSERVICEABLE)
          , color = Color.black800
          , margin = MarginBottom 5
          }
        , errorDescriptionConfig
          { text = if state.props.isMockLocation then "Turn off any Mock Location app you might be using and restart the app." else getString $ CURRENTLY_WE_ARE_LIVE_IN_ "CURRENTLY_WE_ARE_LIVE_IN_"
          , color = Color.black700
          , margin = Margin 20 0 20 (40 + EHC.safeMarginBottom)
          }
        , buttonConfig
          { text = getString CHANGE_LOCATION
          , margin = Margin 16 0 16 (20 + EHC.safeMarginBottom)
          , background = state.data.config.primaryBackground
          , color = state.data.config.primaryTextColor
          , visibility = GONE
          }
        }
  in
    errorModalConfig'

waitTimeInfoCardConfig :: ST.HomeScreenState -> RequestInfoCard.Config
waitTimeInfoCardConfig state = let
  waitTimeConfig = textConfig $ state.data.currentSearchResultType == ST.QUOTES
  config = RequestInfoCard.config
  requestInfoCardConfig' = config{
    title {
      text = getString waitTimeConfig.title,
      accessibilityHint = getEN waitTimeConfig.title
    }
  , primaryText {
      text = getString waitTimeConfig.primaryText,
      padding = Padding 16 16 0 0,
      textStyle = FontStyle.ParagraphText,
      color = Color.black700,
      accessibilityHint = getEN waitTimeConfig.primaryText
    }
  , secondaryText {
      text = getString waitTimeConfig.secondaryText,
      visibility = VISIBLE,
      padding = PaddingLeft 16,
      color = Color.black700,
      textStyle = FontStyle.ParagraphText,
      width = (V $ JB.getWidthFromPercent 75),
      accessibilityHint = getEN waitTimeConfig.secondaryText
    }
  , imageConfig {
      imageUrl = fetchImage FF_ASSET "ny_ic_wait_timer",
      height = V 130,
      width = V 130,
      padding = Padding 0 2 2 0
    }
  , buttonConfig {
      text = getString GOT_IT,
      padding = PaddingVertical 16 20,
      accessibilityHint = (getEN GOT_IT) <> " : Button"
    }
  }
  in requestInfoCardConfig'
  where textConfig :: Boolean -> {title :: STR, primaryText :: STR, secondaryText :: STR}
        textConfig isQuotes = if isQuotes then {title : OTP_EXPIRE_TIMER, primaryText : SHOWS_FOR_HOW_LONG_YOUR_OTP_, secondaryText : IF_YOUR_OTP_EXPIRES_}
                              else {title : WAIT_TIMER, primaryText : HOW_LONG_DRIVER_WAITED_FOR_PICKUP, secondaryText : YOU_WILL_PAY_FOR_EVERY_MINUTE}

rateCardConfig :: ST.HomeScreenState -> RateCard.Config
rateCardConfig state =
  let
    config' = RateCard.config
    bangaloreCode = HU.getCityCodeFromCity Bangalore
    city = getCityFromString $ getValueToLocalStore CUSTOMER_LOCATION
    rateCardConfig' =
      config'
        { isNightShift = state.data.rateCard.isNightShift
        , currentRateCardType = state.data.rateCard.currentRateCardType
        , onFirstPage = state.data.rateCard.onFirstPage
        , showDetails = state.data.config.searchLocationConfig.showRateCardDetails
        , description = if state.data.rateCard.isNightShift then (getString $ NIGHT_TIME_CHARGES state.data.rateCard.nightChargeFrom state.data.rateCard.nightChargeTill) else (getString $ DAY_TIME_CHARGES state.data.rateCard.nightChargeTill state.data.rateCard.nightChargeFrom )
        , buttonText = Just if state.data.rateCard.currentRateCardType == DefaultRateCard then (getString GOT_IT) else (getString GO_BACK_)
        , title = case MU.getMerchant FunctionCall of
                      MU.NAMMAYATRI ->  case city of
                                        Delhi -> getString RATE_CARD
                                        Kochi -> getVehicleTitle state.data.rateCard.vehicleVariant
                                        Hyderabad -> getString RATE_CARD
                                        Chennai -> getVehicleTitle state.data.rateCard.vehicleVariant
                                        Pondicherry -> getString RATE_CARD
                                        Bangalore -> getString RATE_CARD
                                        _ -> getString RATE_CARD
                      MU.YATRI -> getVehicleTitle state.data.rateCard.vehicleVariant
                      _ -> ""
        , fareList = 
            state.data.rateCard.extraFare 
        , driverAdditions = state.data.rateCard.driverAdditions
        , otherOptions  = otherOptions $ not DA.null state.data.rateCard.driverAdditions
        , fareInfoDescription = state.data.rateCard.fareInfoDescription
        , additionalStrings = [
          {key : "DRIVER_ADDITIONS_OPTIONAL", val : (getString DRIVER_ADDITIONS_OPTIONAL)},
          {key : "THE_DRIVER_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC", val : (getString THE_DRIVER_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC)},
          {key : "DRIVER_ADDITIONS_ARE_CALCULATED_AT_RATE", val : (if (state.data.rateCard.vehicleVariant /= "AUTO_RICKSHAW") 
                                                                    then getString DRIVER_ADDITION_LIMITS_ARE_IN_INCREMENTS
                                                                   else getString $ DRIVER_ADDITIONS_ARE_CALCULATED_AT_RATE "DRIVER_ADDITIONS_ARE_CALCULATED_AT_RATE" )},
          {key : "DRIVER_MAY_NOT_CHARGE_THIS_ADDITIONAL_FARE", val : (getString DRIVER_MAY_NOT_CHARGE_THIS_ADDITIONAL_FARE)},
          {key : "FARE_UPDATE_POLICY", val : (getString FARE_UPDATE_POLICY)},
          {key : "YOU_MAY_SEE_AN_UPDATED_FINAL_FARE_DUE_TO_ANY_OF_THE_BELOW_REASONS", val : (getString YOU_MAY_SEE_AN_UPDATED_FINAL_FARE_DUE_TO_ANY_OF_THE_BELOW_REASONS)},
          {key : "REASON_CHANGE_IN_ROUTE", val : ("<span style=\"color:black;\">" <> (getString REASON_CHANGE_IN_ROUTE_A) <> "</span>" <> (getString REASON_CHANGE_IN_ROUTE_B))},
          {key : "TOLL_OR_PARKING_CHARGES", val : (getString TOLL_OR_PARKING_CHARGES)},
          {key : "TOLL_CHARGES", val : (getString TOLL_CHARGES)},
          {key : "TOLL_CHARGES_DESC", val : (getString TOLL_CHARGES_DESC)},
          {key : "PARKING_CHARGES", val : (getString PARKING_CHARGES)},
          {key : "PARKING_CHARGES_DESC", val : (getString PARKING_CHARGES_DESC)}]
          <> if state.data.rateCard.vehicleVariant == "AUTO_RICKSHAW" && state.data.config.searchLocationConfig.showChargeDesc then [{key : "CHARGE_DESCRIPTION", val : (getString ERNAKULAM_LIMIT_CHARGE)}] else []
        }
  in
    rateCardConfig'
  where     
    otherOptions :: Boolean -> Array FareList
    otherOptions showAdditions = (if showAdditions then 
                                    [ {key : "DRIVER_ADDITIONS", val : (getString DRIVER_ADDITIONS)}] 
                                    else [])
                                  <>  [{key : "TOLL_OR_PARKING_CHARGES", val : getString TOLL_OR_PARKING_CHARGES }]

getVehicleTitle :: String -> String
getVehicleTitle vehicle =
  (case vehicle of
    "HATCHBACK" -> (getString HATCHBACK)
    "SUV" -> (getString SUV)
    "SEDAN" -> (getString SEDAN)
    "AUTO_RICKSHAW" -> (getString AUTO_RICKSHAW)
    _ -> "") <> " - " <> (getString RATE_CARD)


estimateChangedPopupConfig :: ST.HomeScreenState -> PopUpModal.Config
estimateChangedPopupConfig state =
  let
    config' = PopUpModal.config
    popUpConfig' =
      config'
        { primaryText { text = (getString ESTIMATES_CHANGED) }
        , secondaryText { text = (getString ESTIMATES_REVISED_TO) <> "₹" <> (show state.data.suggestedAmount) <> if state.data.rateCard.additionalFare > 0 then "-" <> "₹" <> (show $ (state.data.suggestedAmount + state.data.rateCard.additionalFare)) else "" }
        , option1 {
            background = state.data.config.primaryTextColor
          , strokeColor = state.data.config.primaryBackground
          , color = state.data.config.primaryBackground
          , text = (getString GO_HOME_)
          }
        , option2 {
            color = state.data.config.primaryTextColor
          , strokeColor = state.data.config.primaryBackground
          , background = state.data.config.primaryBackground
          , text = (getString CONTINUE)
          }
        }
  in
    popUpConfig'

driverInfoCardViewState :: ST.HomeScreenState -> DriverInfoCard.DriverInfoCardState
driverInfoCardViewState state = { props:
                                  { currentStage: state.props.currentStage
                                  , trackingEnabled: state.props.isInApp
                                  , unReadMessages : state.props.unReadMessages
                                  , showCallPopUp: state.props.showCallPopUp
                                  , isSpecialZone: state.props.isSpecialZone
                                  , estimatedTime : state.data.rideDuration
                                  , zoneType : state.props.zoneType.priorityTag
                                  , currentSearchResultType : state.data.currentSearchResultType
                                  , merchantCity : state.props.city
                                  , showBanner : state.props.currentStage == RideStarted
                                  , isChatWithEMEnabled : state.props.isChatWithEMEnabled
                                  }
                              , data: driverInfoTransformer state
                            }

messagingViewConfig :: ST.HomeScreenState -> MessagingView.Config
messagingViewConfig state = let
  config = MessagingView.config
  primaryContact = DA.head $  DA.filter (\item -> (item.enableForShareRide || item.enableForFollowing) && (item.priority == 0)) (fromMaybe [] state.data.contactList)
  messagingViewConfig' = config {
    userConfig
    { userName = if state.props.isChatWithEMEnabled 
                    then case primaryContact of
                            Nothing -> state.data.driverInfoCardState.driverName
                            Just contact -> contact.name
                    else state.data.driverInfoCardState.driverName
    , receiver = if state.props.isChatWithEMEnabled 
                    then case primaryContact of
                            Nothing -> "Driver"
                            Just contact -> contact.name
                    else "Driver"
    }
  , feature 
    { sendMessageActive = state.props.sendMessageActive
    , canSendSuggestion = state.props.canSendSuggestion
    , showAutoGeneratedText = (getValueToLocalStore NOTIFIED_CUSTOMER == "true") && isJust state.data.driverInfoCardState.eta && (HU.secondsToHms $ fromMaybe 0 state.data.driverInfoCardState.eta) /= "--"
    , enableSuggestions = state.data.config.feature.enableSuggestions
    , showVehicleDetails = not state.props.isChatWithEMEnabled 
    }
  , messages = state.data.messages
  , messagesSize = state.data.messagesSize
  , vehicleNo = HU.makeNumber $ state.data.driverInfoCardState.registrationNumber     
  , chatSuggestionsList = getChatSuggestions state
  , hint = (getString MESSAGE)
  , languageKey = (getLanguageLocale languageKey)
  , rideConfirmedAt = state.data.driverInfoCardState.startedAt
  , autoGeneratedText = state.data.config.notifyRideConfirmationConfig.autoGeneratedText <> (HU.secondsToHms $ fromMaybe 0 state.data.driverInfoCardState.eta)
  , driverRating = show $ state.data.driverInfoCardState.rating
  , fareAmount = show $ state.data.driverInfoCardState.price
  , config = state.data.config
  , peekHeight = if state.data.infoCardPeekHeight == 0 then getDefaultPeekHeight state else state.data.infoCardPeekHeight
  , otp = state.data.driverInfoCardState.otp
  , suggestionKey = if state.props.isChatWithEMEnabled then emChatSuggestion else chatSuggestion
  }
  in messagingViewConfig'

getDefaultPeekHeight :: ST.HomeScreenState -> Int  --TODO Update these before final push
getDefaultPeekHeight state = do
  let isQuotes = state.data.currentSearchResultType == ST.QUOTES
      height = case state.props.currentStage == ST.RideAccepted of 
                  true -> if isQuotes then 285 else 381
                  false -> if isQuotes then 377 else 368
  height + if state.data.config.driverInfoConfig.footerVisibility then 44 else 0

metersToKm :: Int -> Boolean -> String
metersToKm distance towardsDrop =
  if (distance <= 10) then
    (if towardsDrop then (getString AT_DROP) else (getString AT_PICKUP))
  else if (distance < 1000) then (HU.toStringJSON distance <> " m " <> (getString AWAY_C)) else (HU.parseFloat ((INT.toNumber distance) / 1000.0)) 2 <> " km " <> (getString AWAY_C)


driverInfoTransformer :: ST.HomeScreenState -> DriverInfoCardData
driverInfoTransformer state =
  let cardState = state.data.driverInfoCardState
  in
    { otp : cardState.otp
    , driverName : (DS.toUpper (DS.take 1 cardState.driverName)) <> (DS.toLower (DS.drop 1 cardState.driverName))
    , eta : cardState.eta
    , vehicleDetails : cardState.vehicleDetails
    , registrationNumber : cardState.registrationNumber
    , rating : cardState.rating
    , startedAt : cardState.startedAt
    , endedAt : cardState.endedAt
    , source : cardState.source
    , destination : cardState.destination
    , rideId : cardState.rideId
    , price : cardState.price
    , sourceLat : cardState.sourceLat
    , sourceLng : cardState.sourceLng
    , destinationLat : cardState.destinationLat
    , destinationLng : cardState.destinationLng
    , driverLat : cardState.driverLat
    , driverLng : cardState.driverLng
    , distance : cardState.distance
    , waitingTime : cardState.waitingTime
    , driverArrived : cardState.driverArrived
    , estimatedDistance : cardState.estimatedDistance
    , driverArrivalTime : cardState.driverArrivalTime
    , estimatedDropTime : ""
    , isSpecialZone : state.props.isSpecialZone
    , isLocationTracking : state.props.isLocationTracking
    , bookingCreatedAt : cardState.createdAt
    , bppRideId : ""
    , driverNumber : cardState.driverNumber
    , merchantExoPhone : cardState.merchantExoPhone
    , config : state.data.config
    , vehicleVariant : cardState.vehicleVariant
    , defaultPeekHeight : getDefaultPeekHeight state
    , bottomSheetState : state.props.currentSheetState
    , bannerData : state.data.bannerData
    , bannerArray : getDriverInfoCardBanners state DriverInfoCard.BannerCarousel
    , vehicleModel : cardState.vehicleModel
    , vehicleColor : cardState.vehicleColor
    , serviceTierName : cardState.serviceTierName
    , providerName : cardState.providerName
    , providerType : cardState.providerType
    }

emergencyHelpModelViewState :: ST.HomeScreenState -> EmergencyHelp.EmergencyHelpModelState
emergencyHelpModelViewState state = { showContactSupportPopUp: state.props.emergencyHelpModelState.showContactSupportPopUp
                                , showCallPolicePopUp: state.props.emergencyHelpModelState.showCallPolicePopUp
                                , showCallContactPopUp: state.props.emergencyHelpModelState.showCallContactPopUp
                                , emergencyContactData: state.props.emergencyHelpModelState.emergencyContactData
                                , currentlySelectedContact: state.props.emergencyHelpModelState.currentlySelectedContact
                                , showCallSuccessfulPopUp : state.props.emergencyHelpModelState.showCallSuccessfulPopUp
                                , config : state.data.config
                                }

ratingCardViewState :: ST.HomeScreenState -> RatingCard.RatingCardConfig
ratingCardViewState state = {
   data: state.data.rideRatingState {
    rating = state.data.ratingViewState.selectedRating, 
    feedbackList = state.data.rideRatingState.feedbackList
  } 
  , feedbackPillData : customerFeedbackPillData state
  , primaryButtonConfig : PrimaryButton.config {
    textConfig{
      text = getString SUBMIT_FEEDBACK
    , color = state.data.config.primaryTextColor
    },
    background = state.data.config.primaryBackground,
    margin = MarginHorizontal 16 16,
    isClickable = if state.data.ratingViewState.selectedRating == 0 then false else true,
    alpha = if not (state.data.ratingViewState.selectedRating< 1) then 1.0 else 0.4
    , id = "RateYourDriverButton"
    , enableLoader = (JB.getBtnLoader "RateYourDriverButton")
    , enableRipple = true
    , rippleColor = Color.rippleShade
  }
  , showProfileImg : true
  , title : getRateYourRideString ( getString RATE_YOUR_RIDE_WITH) state.data.rideRatingState.driverName
  , feedbackPlaceHolder : getString ANYTHING_THAT_YOU_WOULD_LIKE_TO_TELL_US
  , showFeedbackPill : true
  , overallFeedbackArray : [(getString TERRIBLE_EXPERIENCE), (getString POOR_EXPERIENCE),(getString NEEDS_IMPROVEMENT), (getString ALMOST_PERFECT), (getString AMAZING)]
  , accessibility : ENABLE
  , closeImgVisible : GONE
}

getRateYourRideString :: String -> String -> String 
getRateYourRideString str driverName = case getLanguageLocale languageKey of 
    "EN_US" -> str <> " " <> driverName
    _   -> driverName <> " " <> str

searchLocationModelViewState :: ST.HomeScreenState -> SearchLocationModel.SearchLocationModelState
searchLocationModelViewState state = { isSearchLocation: state.props.isSearchLocation
                                    , locationList: state.data.locationList
                                    , source: state.data.source
                                    , destination: state.data.destination
                                    , isSource: state.props.isSource
                                    , isSrcServiceable: state.props.isSrcServiceable
                                    , isDestServiceable: state.props.isDestServiceable
                                    , isRideServiceable: state.props.isRideServiceable
                                    , savedlocationList: state.data.savedLocations
                                    , appConfig : state.data.config
                                    , logField : state.data.logField
                                    , crossBtnSrcVisibility: state.props.searchLocationModelProps.crossBtnSrcVisibility
                                    , crossBtnDestVisibility: state.props.searchLocationModelProps.crossBtnDestVisibility
                                    , isAutoComplete: state.props.searchLocationModelProps.isAutoComplete
                                    , showLoader: state.props.searchLocationModelProps.showLoader
                                    , prevLocation: state.data.searchLocationModelData.prevLocation
                                    , currentLocationText : state.props.currentLocation.place 
                                    }

quoteListModelViewState :: ST.HomeScreenState -> QuoteListModel.QuoteListModelState
quoteListModelViewState state = let vehicleVariant = state.data.selectedEstimatesObject.vehicleVariant
                                    tipConfig = getTipConfig state.data.selectedEstimatesObject.vehicleVariant
                                in
                                { source: state.data.source
                                , destination: state.data.destination
                                , quoteListModel: state.data.quoteListModelState
                                , selectedQuote: state.props.selectedQuote
                                , autoSelecting: state.props.autoSelecting
                                , searchExpire: state.props.searchExpire
                                , showProgress : (DA.null state.data.quoteListModelState) && isLocalStageOn FindingQuotes
                                , tipViewProps : getTipViewProps state
                                , findingRidesAgain : state.props.findingRidesAgain
                                , progress : state.props.findingQuotesProgress
                                , appConfig : state.data.config
                                , vehicleVariant : vehicleVariant
                                , city : state.props.city
                                , customerTipArray : tipConfig.customerTipArray
                                , customerTipArrayWithValues : tipConfig.customerTipArrayWithValues
                                , providerSelectionStage : state.data.iopState.providerSelectionStage
                                , quoteList : state.data.specialZoneQuoteList
                                , selectProviderTimer : state.data.iopState.timerVal
                                , selectedEstimatesObject : state.data.selectedEstimatesObject
                                , showAnim : not $ state.data.iopState.showMultiProvider && isLocalStageOn FindingQuotes
                                , animEndTime : state.data.currentCityConfig.iopConfig.autoSelectTime
                                }

rideRequestAnimConfig :: AnimConfig.AnimConfig
rideRequestAnimConfig =
  let
    config = AnimConfig.animConfig
    rideRequestAnimConfig' =
      config
        { duration = 300
        , fromY = 10
        }
  in
    rideRequestAnimConfig'

rideCompletedAnimConfig :: AnimConfig.AnimConfig
rideCompletedAnimConfig =
  let
    config = AnimConfig.animConfig
    rideCompletedAnimConfig' =
      config
        { duration = 400
        , fromScaleY = 2.5
        , toScaleX = 1.0
        , fromScaleX = 2.5
        , toScaleY = 1.0
        }
  in
    rideCompletedAnimConfig'

autoAnimConfig :: AnimConfig.AnimConfig
autoAnimConfig =
  let
    config = AnimConfig.animConfig
    autoAnimConfig' =
      config
        { duration = 400
        , toScaleX = 1.0
        , toScaleY = 1.0
        }
  in
    autoAnimConfig'

callSupportConfig :: ST.HomeScreenState ->  PopUpModal.Config
callSupportConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
    gravity = CENTER
  , cornerRadius = (Corners 15.0 true true true true)
  , margin = (MarginHorizontal 16 16)
  , primaryText {
      text = getString CONTACT_SUPPORT <>"?"
    }
  , secondaryText {
      text = getString $ YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT "YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT"
    , margin = (Margin 24 12 24 12)
    , color = Color.black700
    }
  , option1 {
      text =  getString CANCEL_
    , background = state.data.config.popupBackground
    , strokeColor = state.data.config.primaryBackground
    , color = state.data.config.primaryBackground
    , enableRipple = true
    }
  , option2 {
      text =  getString CALL_SUPPORT
    , color = state.data.config.primaryTextColor
    , strokeColor = state.data.config.primaryBackground
    , background = state.data.config.primaryBackground
    , margin = (MarginLeft 12)
    , enableRipple = true
    }
  }
  in popUpConfig'

confirmAndBookButtonConfig :: ST.HomeScreenState -> PrimaryButton.Config
confirmAndBookButtonConfig state = 
  PrimaryButton.config
    { textConfig
        { text = getBtnTextWithTimer state
        , color = Color.yellow900
        , accessibilityHint = "Confirm And Book Button"
        }
    , id = "ConfirmAndBookButton"
    , background = Color.black900
    , margin = MarginTop 16
    , enableRipple = true
    , rippleColor = Color.rippleShade
    }
  where
    getBtnTextWithTimer state = 
      if state.props.repeatRideTimer /= "0" && not DS.null state.props.repeatRideTimerId 
      then ((getString REQUESTING_RIDE_IN) <> " " <> state.props.repeatRideTimer <> "s") 
      else if state.props.repeatRideTimer == "0" 
           then (getString REQUESTING_RIDE) <> "..." 
           else (getString REQUEST_RIDE)

zoneTimerExpiredConfig :: ST.HomeScreenState ->  PopUpModal.Config
zoneTimerExpiredConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
    gravity = CENTER
  , cornerRadius = Corners 16.0 true true true true
  , margin = Margin 24 32 24 0
  , primaryText {
      text = (getString OTP_EXPIRED) -- "OTP Expired"
    }
  , secondaryText {
      text = (getString OTP_EXPIRED_DESCRIPTION)--"Your ride OTP expired. Please book again to get a ride"
    , margin = Margin 16 4 16 24
    , color = Color.black700
    }
  , option1 {
      visibility = false
    }
  , option2 {
      text =  getString OK_GOT_IT
    , margin = (MarginHorizontal 16 16)
    }
  }
  in popUpConfig'

menuButtonConfig :: ST.HomeScreenState -> JB.Location -> MenuButton.Config
menuButtonConfig state item = let
    config = MenuButton.config
    menuButtonConfig' = config {
      titleConfig{
          text = item.place
        , gravity = CENTER_VERTICAL
      }
    , accessibilityHint = item.place
    , radioButtonConfig {
        height = V 16
        , width = V 16
        , cornerRadius = 8.0
        , buttonWidth = V 8
        , buttonHeight = V 8
        , buttonColor = Color.positive
        , margin = (MarginRight 15)
        , activeStroke = ("2," <> Color.positive)
      }
      , id = item.place
      , lat = item.lat
      , lng = item.lng
      , leftsidebutton = true
      , padding = (Padding 14 14 14 14)
      , cornerRadius = 6.0
      , height = WRAP_CONTENT
      , width = MATCH_PARENT
      , isSelected = item.place == state.props.defaultPickUpPoint
      , layoutStroke = ("1," <> if item.place == state.props.defaultPickUpPoint then Color.blue700' else Color.grey900)
      , layoutBg =  if item.place == state.props.defaultPickUpPoint then Color.blue600 else Color.white900
    }
    in menuButtonConfig'

chooseYourRideConfig :: ST.HomeScreenState -> ChooseYourRide.Config
chooseYourRideConfig state = 
  let tipConfig = getTipConfig state.data.selectedEstimatesObject.vehicleVariant
      city = getValueToLocalStore CUSTOMER_LOCATION
  in
  ChooseYourRide.config
  {
    rideDistance = state.data.rideDistance,
    rideDuration = state.data.rideDuration,
    activeIndex = state.data.selectedEstimatesObject.index,
    quoteList = state.data.specialZoneQuoteList,
    showTollExtraCharges = state.props.hasToll,
    nearByDrivers = state.data.nearByDrivers,
    showPreferences = state.data.showPreferences,
    bookingPreferenceEnabled = state.data.config.estimateAndQuoteConfig.enableBookingPreference && state.props.city == Bangalore,
    flowWithoutOffers = state.props.flowWithoutOffers,
    enableSingleEstimate = state.data.config.enableSingleEstimate,
    selectedEstimateHeight = state.props.selectedEstimateHeight,
    zoneType = state.props.zoneType.sourceTag,
    tipViewProps = getTipViewProps state,
    tipForDriver = state.props.customerTip.tipForDriver,
    customerTipArray = tipConfig.customerTipArray,
    customerTipArrayWithValues = tipConfig.customerTipArrayWithValues,
    enableTips = state.data.config.tipsEnabled && (elem city state.data.config.tipEnabledCities) && (DA.length tipConfig.customerTipArray) > 0 && not state.data.iopState.showMultiProvider,
    showMultiProvider = state.data.iopState.showMultiProvider
  }

specialLocationConfig :: String -> String -> Boolean -> PolylineAnimationConfig -> JB.MapRouteConfig
specialLocationConfig srcIcon destIcon isAnim animConfig = JB.mapRouteConfig {
    sourceSpecialTagIcon = srcIcon
  , destSpecialTagIcon = destIcon
  , vehicleSizeTagIcon = HU.getVehicleSize unit
  , isAnimation = isAnim
  , autoZoom = true
  , polylineAnimationConfig = animConfig
}

setTipViewData :: Encode TipViewData => TipViewData -> Effect Unit
setTipViewData object = void $ pure $ setValueToLocalStore TIP_VIEW_DATA (encodeJSON object)

getTipViewData :: String -> Maybe TipViewData
getTipViewData dummy =
  case runExcept (decodeJSON (getValueToLocalStore TIP_VIEW_DATA) :: _ TipViewData) of
    Right res -> Just res
    Left err -> Nothing

getTipViewProps :: ST.HomeScreenState -> TipViewProps
getTipViewProps state =
  let tipViewProps = state.props.tipViewProps { isVisible = state.data.selectedEstimatesObject.providerType == ONUS && state.props.tipViewProps.isVisible } -- confirm if shown for blr only 
  in
  case tipViewProps.stage of
    DEFAULT ->  tipViewProps{ stage = DEFAULT
                            , onlyPrimaryText = false
                            , isprimaryButtonVisible = false
                            , primaryText = getString ADD_A_TIP_TO_FIND_A_RIDE_QUICKER
                            , secondaryText = getString IT_SEEMS_TO_BE_TAKING_LONGER_THAN_USUAL
                            }
    TIP_AMOUNT_SELECTED -> tipViewProps{ stage = TIP_AMOUNT_SELECTED
                                       , onlyPrimaryText = false
                                       , isprimaryButtonVisible = true
                                       , primaryText = getString ADD_A_TIP_TO_FIND_A_RIDE_QUICKER
                                       , secondaryText = getString IT_SEEMS_TO_BE_TAKING_LONGER_THAN_USUAL
                                       , primaryButtonText = getTipViewText tipViewProps state (getString CONTINUE_SEARCH_WITH)
                                       }
    TIP_ADDED_TO_SEARCH -> tipViewProps{ onlyPrimaryText = true, isprimaryButtonVisible = false, primaryText = (getTipViewText tipViewProps state (getString SEARCHING_WITH)) <> "." }
    RETRY_SEARCH_WITH_TIP -> tipViewProps{ onlyPrimaryText = true , isprimaryButtonVisible = false, primaryText = (getTipViewText tipViewProps state (getString SEARCHING_WITH)) <> "." }


getTipViewText :: TipViewProps -> ST.HomeScreenState -> String -> String
getTipViewText tipViewProps state prefixString = do
  let tipConfig = getTipConfig state.data.selectedEstimatesObject.vehicleVariant
      tip = show (fromMaybe 0 (tipConfig.customerTipArrayWithValues !! tipViewProps.activeIndex))
  if tip == "0" then 
    case tipViewProps.stage of
      TIP_AMOUNT_SELECTED -> getString CONTINUE_SEARCH_WITH_NO_TIP
      _ -> getString SEARCHING_WITH_NO_TIP
  else  
    case (getLanguageLocale languageKey) of
      "EN_US" -> prefixString <> (if tipViewProps.stage == TIP_AMOUNT_SELECTED then " +₹" else " ₹")<>tip<>" "<> (getString TIP)
      _ -> "+₹"<>tip<>" "<>(getString TIP) <> " " <> prefixString

requestInfoCardConfig :: ST.HomeScreenState -> RequestInfoCard.Config
requestInfoCardConfig _ = let
  config = RequestInfoCard.config
  requestInfoCardConfig' = config{
    title {
      text = getString CHOOSE_BETWEEN_MULTIPLE_RIDES
    }
  , primaryText {
      text = getString ENABLE_THIS_FEATURE_TO_CHOOSE_YOUR_RIDE
    }
  , imageConfig {
      imageUrl = fetchImage FF_ASSET "ny_ic_select_offer",
      height = V 122,
      width = V 116
    }
  , buttonConfig {
      text = getString GOT_IT
    }
  , backgroundColor = Color.transparent
  , gravity = RIGHT
  , padding = PaddingLeft 16
  }
  in requestInfoCardConfig'

multipleProvidersInfo :: ST.HomeScreenState -> RequestInfoCard.Config
multipleProvidersInfo _ = let
  config = RequestInfoCard.config
  requestInfoCardConfig' = config{
    title {
      text = getString CHOOSE_BETWEEN_PROVIDERS 
    }
  , primaryText {
      text = getString CHOOSE_BETWEEN_PROVIDERS_DESC
    }
  , imageConfig {
      imageUrl = fetchImage FF_ASSET "ny_ic_multiple_providers",
      height = V 122,
      width = V 116
    }
  , buttonConfig {
      text = getString GOT_IT
    }
  , backgroundColor = Color.transparent
  , gravity = RIGHT
  , padding = PaddingLeft 16
  }
  in requestInfoCardConfig'

reportIssueOptions :: ST.HomeScreenState -> Array OptionButtonList -- need to modify
reportIssueOptions state =
  [ { reasonCode: "DRIVER_WAS_NOT_READY_TO_GO"
    , description: getString DRIVER_WAS_NOT_READY_TO_GO
    , textBoxRequired : false
    , subtext : Nothing
    }
  , { reasonCode: "ASKING_FOR_MORE_MONEY"
    , description: getString ASKING_FOR_MORE_MONEY
    , textBoxRequired : false
    , subtext : Nothing
    }
  , { reasonCode: "AUTO_BROKEN"
    , description: getString VEHICLE_BROKEN
    , textBoxRequired : false
    , subtext : Nothing
    }
  , { reasonCode: "OTHER"
    , description: getString OTHER
    , textBoxRequired : false
    , subtext : Nothing
    }
  ]

sourceToDestinationConfig :: ST.HomeScreenState -> SourceToDestination.Config
sourceToDestinationConfig state = let 
  config = SourceToDestination.config
  sourceToDestinationConfig' = config
    { sourceImageConfig {
        imageUrl = fetchImage FF_COMMON_ASSET "ny_ic_source_dot"
      , margin = MarginTop 3
      , width = V 18
      , height = V 18
      }
    , sourceTextConfig {
        text = getTripTitle state.data.source
      , padding = Padding 2 0 2 2
      , margin = MarginHorizontal 12 15
      , color = Color.black800
      , ellipsize = true
      , maxLines = 1
      , textStyle = Body1
      }
    , rideStartedAtConfig {
        text = getTripSubTitle state.data.source
      , color = Color.black700
      , visibility = VISIBLE
      , padding = Padding 2 0 2 2
      , margin = MarginHorizontal 12 15
      , maxLines = 1
      , ellipsize = true
    }
    , rideEndedAtConfig {
      text = getTripSubTitle state.data.destination
    , color = Color.black700
    , visibility = VISIBLE
    , padding = Padding 2 0 2 2
    , margin = MarginHorizontal 12 15
    , maxLines = 1
    , ellipsize = true
    }
    , destinationImageConfig {
        imageUrl = fetchImage FF_COMMON_ASSET "ny_ic_destination"
      , margin = MarginTop 3
      , width = V 20
      , height = V 23
      }
    , destinationTextConfig {
        text = getTripTitle state.data.destination
      , padding = Padding 2 0 2 2
      , margin = MarginHorizontal 12 15
      , color = Color.black800
      , ellipsize = true
      , maxLines = 1
      , textStyle = Body1
      }
    , horizontalSeperatorConfig {
        visibility = VISIBLE
      , background = Color.grey900
      , padding = Padding 2 0 2 2
      , margin = Margin 12 12 15 9
      }
    }
  in sourceToDestinationConfig'
  where
    getTripTitle :: String -> String
    getTripTitle destination = 
      maybe "" identity $ DA.head $ DS.split (DS.Pattern ",") destination

    getTripSubTitle :: String -> String
    getTripSubTitle destination = 
      (DS.drop ((fromMaybe 0 (DS.indexOf (DS.Pattern ",") (destination))) + 2) (destination))

chooseVehicleConfig :: ST.HomeScreenState -> ChooseVehicle.Config
chooseVehicleConfig state = let
  config = ChooseVehicle.config
  selectedEstimates = state.data.selectedEstimatesObject
  isSingleEstimate = selectedEstimates.vehicleVariant == "AUTO_RICKSHAW" && ((DA.length state.data.specialZoneQuoteList) == 1) && state.data.config.enableSingleEstimate
  chooseVehicleConfig' = config
    { vehicleImage = HU.getVehicleVariantImage selectedEstimates.vehicleVariant
    , isSelected = true
    , vehicleVariant = selectedEstimates.vehicleVariant
    , vehicleType = selectedEstimates.vehicleType
    , capacity = selectedEstimates.capacity
    , price = selectedEstimates.price
    , isCheckBox = false
    , isEnabled = true
    , index = selectedEstimates.index
    , activeIndex = selectedEstimates.activeIndex
    , id = selectedEstimates.id
    , maxPrice = selectedEstimates.maxPrice
    , basePrice = selectedEstimates.basePrice
    , showInfo = selectedEstimates.showInfo
    , searchResultType = selectedEstimates.searchResultType
    , isBookingOption = false
    , pickUpCharges = selectedEstimates.pickUpCharges 
    , layoutMargin = Margin 0 0 0 0
    , isSingleEstimate = isSingleEstimate
    , tollCharge = selectedEstimates.tollCharge
    , serviceTierName = selectedEstimates.serviceTierName
    , serviceTierShortDesc = selectedEstimates.serviceTierShortDesc
    , airConditioned = selectedEstimates.airConditioned
    , extraFare = selectedEstimates.extraFare
    , driverAdditions = selectedEstimates.driverAdditions
    , showEditButton = true
    , editBtnText = getString CHANGE
    }
  in chooseVehicleConfig'

rideCompletedCardConfig :: ST.HomeScreenState -> RideCompletedCard.Config 
rideCompletedCardConfig state = 
  let topCardConfig = state.data.config.rideCompletedCardConfig.topCard
      topCardGradient = if topCardConfig.enableGradient then [state.data.config.primaryBackground, state.data.config.primaryBackground, topCardConfig.gradient, state.data.config.primaryBackground] else [topCardConfig.background,topCardConfig.background]
      waitingChargesApplied = isJust $ DA.find (\entity  -> entity ^._description == "WAITING_OR_PICKUP_CHARGES") (state.data.ratingViewState.rideBookingRes ^._fareBreakup)
      headerConfig = mkHeaderConfig state.props.nightSafetyFlow state.props.showOfferedAssistancePopUp
      appName = fromMaybe state.data.config.appData.name $ runFn3 getAnyFromWindow "appName" Nothing Just
      isRecentRide = EHC.getExpiryTime (fromMaybe "" (state.data.ratingViewState.rideBookingRes ^. _rideEndTime)) true / 60 < state.data.config.safety.pastRideInterval
      actualTollCharge =  maybe 0 (\obj ->  obj^._amount) $ DA.find (\entity  -> entity ^._description == "TOLL_CHARGES") (state.data.ratingViewState.rideBookingRes ^._fareBreakup)
      serviceTier = fromMaybe "" (state.data.ratingViewState.rideBookingRes ^. _serviceTierName)
  in RideCompletedCard.config {
        isDriver = false,
        customerIssueCard{
          reportIssueView = state.data.ratingViewState.openReportIssue,
          issueFaced = state.data.ratingViewState.issueFacedView,
          selectedYesNoButton = state.data.ratingViewState.selectedYesNoButton,
          reportIssuePopUpConfig = reportIssuePopUpConfig state,
          title = headerConfig.title,
          subTitle = headerConfig.subTitle,
          option1Text = getString REPORT_ISSUE_,
          option2Text = getString GET_CALLBACK_FROM_US,
          yesText = getString YES,
          noText = getString NO,
          wasOfferedAssistanceCardView = state.props.showOfferedAssistancePopUp && not state.props.nightSafetyFlow,
          isNightRide = state.props.nightSafetyFlow,
          showCallSupport = state.data.config.rideCompletedCardConfig.showCallSupport
        },
        topCard {
          title =  getString RIDE_COMPLETED,
          titleColor = topCardConfig.titleColor,
          finalAmount = state.data.finalAmount,
          initalAmount = state.data.driverInfoCardState.price,
          fareUpdatedVisiblity = state.data.finalAmount /= state.data.driverInfoCardState.price && state.props.estimatedDistance /= Nothing,
          gradient = topCardGradient,
          infoPill {
            text = getFareUpdatedStr state.data.rideRatingState.distanceDifference waitingChargesApplied,
            background = topCardConfig.rideDescription.background,
            color = topCardConfig.rideDescription.textColor,
            image = fetchImage FF_COMMON_ASSET "ny_ic_parallel_arrows",
            imageVis = VISIBLE,
            visible = if state.data.finalAmount == state.data.driverInfoCardState.price || state.props.estimatedDistance == Nothing then GONE else VISIBLE
          },
          bottomText =  getString RIDE_DETAILS
        },
        customerBottomCard {
          title = getRateYourRideString (getString RATE_YOUR_RIDE_WITH) state.data.rideRatingState.driverName,
          subTitle = (getString $ YOUR_FEEDBACK_HELPS_US appName),
          selectedRating = state.data.ratingViewState.selectedRating,
          visible = not state.data.ratingViewState.issueFacedView
        },
        primaryButtonConfig = skipButtonConfig state,
        enableContactSupport = state.data.config.feature.enableSupport,
        showSafetyCenter = state.data.config.feature.enableSafetyFlow && isRecentRide && not state.props.isSafetyCenterDisabled,
        safetyTitle = getString SAFETY_CENTER,
        needHelpText = getString NEED_HELP,
        serviceTierAndAC = serviceTier
      , toll {
          actualAmount = actualTollCharge
        , text =if actualTollCharge > 0 then getString TOLL_CHARGES_INCLUDED  else getString TOLL_ROAD_CHANGED -- Handle after design finalized 
        , visibility = boolToVisibility $ actualTollCharge > 0 || (getValueToLocalStore HAS_TOLL_CHARGES == "true") 
        , image = fetchImage FF_COMMON_ASSET "ny_ic_grey_toll"
        , imageVisibility = boolToVisibility $ actualTollCharge > 0 
        }
      }
  where 
    mkHeaderConfig :: Boolean -> Boolean -> {title :: String, subTitle :: String}
    mkHeaderConfig isNightSafety offeredAssistance = case isNightSafety, offeredAssistance of
                                                      true,_ -> {title : getString DID_YOU_HAVE_A_SAFE_JOURNEY, subTitle : getString TRIP_WAS_SAFE_AND_WORRY_FREE}
                                                      _,true -> {title : getString DID_THE_DRIVER_OFFER_ASSISTANCE, subTitle : getString WAS_THE_DRIVER_UNDERSTANDING_OF_YOUR_NEEDS}
                                                      _,_ -> {title : getString DID_YOU_FACE_ANY_ISSUE, subTitle : getString WE_NOTICED_YOUR_RIDE_ENDED_AWAY} 

getFareUpdatedStr :: Int -> Boolean -> String
getFareUpdatedStr diffInDist waitingChargeApplied = do
  let shorter = diffInDist > 0
      positiveDist = if shorter then diffInDist else -diffInDist
      distInKm = parseFloat (toNumber positiveDist / 1000.0) 2
      distanceChanged = diffInDist/= 0
  case waitingChargeApplied, distanceChanged of
    true, false -> getString FARE_UPDATED_WITH_CHARGES
    false, true -> getVarString (if shorter then FARE_UPDATED_WITH_SHORTER_DIST else FARE_UPDATED_WITH_LONGER_DIST) [distInKm]
    true , true -> getVarString (if shorter then FARE_UPDATED_WITH_CHARGES_SHORTER_DIST else FARE_UPDATED_WITH_CHARGES_LONGER_DIST) [distInKm]
    false, false -> getString FARE_UPDATED

customerFeedbackPillData :: ST.HomeScreenState -> Array (Array (Array RatingCard.FeedbackItem)) 
customerFeedbackPillData state = [feedbackPillDataWithRating1 state, feedbackPillDataWithRating2 state, feedbackPillDataWithRating3 state, feedbackPillDataWithRating4 state, feedbackPillDataWithRating5 state]

feedbackPillDataWithRating1 :: ST.HomeScreenState -> Array (Array RatingCard.FeedbackItem)
feedbackPillDataWithRating1 state = [
  [{id : "6", text : getString RUDE_DRIVER},
  {id : "1", text : getString FELT_UNSAFE},
  {id : "1", text : getString TOO_MANY_CALLS}],
  [{id : "6", text : getString RECKLESS_DRIVING},
  {id : "6", text : getString DRIVER_CHARGED_MORE}],
  ([{id : "1", text : getString LATE_DROP_OFF},
    {id : "1", text : getString LATE_PICK_UP}]
  <> acNotWorkingPill state)
]

acNotWorkingPill :: ST.HomeScreenState -> Array RatingCard.FeedbackItem
acNotWorkingPill state = 
  (case state.data.ratingViewState.rideBookingRes ^. _serviceTierName  of
      Just serviceTierName -> 
        if ServiceTierCard.showACDetails serviceTierName Nothing
          then [{id : "14", text : getString AC_TURNED_OFF}] 
          else []
      Nothing -> [])

feedbackPillDataWithRating2 :: ST.HomeScreenState -> Array (Array RatingCard.FeedbackItem)
feedbackPillDataWithRating2 state = [
  [{id : "7", text : getString RUDE_DRIVER},
  {id : "2", text : getString FELT_UNSAFE},
  {id : "2", text : getString TOO_MANY_CALLS}],
  [{id : "7", text : getString RECKLESS_DRIVING},
  {id : "7", text : getString DRIVER_CHARGED_MORE}],
  ([{id : "2", text : getString LATE_PICK_UP},
    {id : "2", text : getString LATE_DROP_OFF}]
  <> acNotWorkingPill state)
]

feedbackPillDataWithRating3 :: ST.HomeScreenState -> Array (Array RatingCard.FeedbackItem)
feedbackPillDataWithRating3 state = [
  [{id : "8", text : getString UNPROFESSIONAL_DRIVER},
  {id : "8", text : getString RASH_DRIVING}],
  [{id : "8", text : getString DRIVER_CHARGED_MORE},
  {id : "11", text : if state.data.vehicleVariant == "AUTO_RICKSHAW" then getString UNCOMFORTABLE_AUTO else getString UNCOMFORTABLE_CAB}],
  [{id : "3", text : getString TRIP_GOT_DELAYED},
  {id : "3", text : getString FELT_UNSAFE}]
]

feedbackPillDataWithRating4 :: ST.HomeScreenState -> Array (Array RatingCard.FeedbackItem)
feedbackPillDataWithRating4 state = [
  [{id : "9", text : getString POLITE_DRIVER},
  {id : "9", text : getString EXPERT_DRIVING}],
  [{id : "9", text : getString ASKED_FOR_EXTRA_FARE},
  {id : "11", text : if state.data.vehicleVariant == "AUTO_RICKSHAW" then getString UNCOMFORTABLE_AUTO else getString UNCOMFORTABLE_CAB}],
  [{id : "4", text : getString TRIP_GOT_DELAYED},
  {id : "4", text : getString SAFE_RIDE}]
]

feedbackPillDataWithRating5 :: ST.HomeScreenState -> Array (Array RatingCard.FeedbackItem)
feedbackPillDataWithRating5 state = [
  [{id : "10", text : getString POLITE_DRIVER},
  {id : "5", text : getString EXPERT_DRIVING}],
  [{id : "12", text : if state.data.vehicleVariant == "AUTO_RICKSHAW" then getString CLEAN_AUTO else getString CLEAN_CAB},
  {id : "10", text : getString ON_TIME}],
  [{id : "10", text : getString SKILLED_NAVIGATOR},
  {id : "5", text : getString SAFE_RIDE}]
]

getCarouselData :: ST.HomeScreenState -> Array CarouselData
getCarouselData state =
  map (\item -> 
    { imageConfig : { image : item.image , height : item.imageHeight , width : 200, bgColor : item.imageBgColor, cornerRadius : 8.0 },
      youtubeConfig : EHC.getYoutubeData{ videoId = item.videoLink , videoType = "PORTRAIT_VIDEO",  videoHeight = item.videoHeight},
      contentType : if item.videoLink == "" then "IMAGE" else "VIDEO" ,
      gravity : item.gravity ,
      backgroundColor : item.carouselBgColor,
      titleConfig : {
        text : item.title,
        textSize : 16,
        textColor : Color.black800,
        gravity : "CENTER",
        margin : { top : 16 , bottom : 0 , right : 16 , left : 16 }
      }, 
      descriptionConfig : {
        text : item.description, 
        textSize : item.descTextSize,
        textColor : Color.black700,
        gravity : "LEFT",
        margin : { top : 0 , bottom : 0 , right : 16 , left : 16 }
      }
    }) [ {image : "carousel_4" , videoLink : (EHC.getVideoID state.data.config.purpleRideConfig.genericVideoUrl), videoHeight : 690, imageHeight : 160, imageBgColor : Color.grey700, title:  (getString EDUCATIONAL_POP_UP_SLIDE_1_TITLE), description : (getString EDUCATIONAL_POP_UP_SLIDE_1_SUBTITLE) , descTextSize : 14 , carouselBgColor : Color.grey700, gravity : 0},
        {image : "ny_ic_blind_pickup" , videoLink : "" , videoHeight :  0, imageHeight :  160, imageBgColor :  Color.blue600, title :   (getString EDUCATIONAL_POP_UP_SLIDE_2_TITLE) , description :  (getString EDUCATIONAL_POP_UP_SLIDE_2_SUBTITLE) , descTextSize : 12, carouselBgColor :  Color.grey700,  gravity : 0},
        {image : "ny_ic_deaf_pickup" , videoLink : "" , videoHeight :  0, imageHeight :  160, imageBgColor :  Color.blue600, title :   (getString EDUCATIONAL_POP_UP_SLIDE_3_TITLE) , description :  (getString EDUCATIONAL_POP_UP_SLIDE_3_SUBTITLE) , descTextSize : 12 ,carouselBgColor :  Color.grey700,  gravity : 0},
        {image : "ny_ic_locomotor_arrival" , videoLink : "" , videoHeight :  0, imageHeight :  160, imageBgColor :  Color.blue600, title :   (getString EDUCATIONAL_POP_UP_SLIDE_4_TITLE) , description :  (getString EDUCATIONAL_POP_UP_SLIDE_4_SUBTITLE) , descTextSize : 12, carouselBgColor :  Color.grey700, gravity : 0},
        {image : "ny_ic_disability_illustration" , videoLink : "" , videoHeight :  0, imageHeight :  160, imageBgColor :  Color.white900, title :   (getString EDUCATIONAL_POP_UP_SLIDE_5_TITLE) , description :  (getString EDUCATIONAL_POP_UP_SLIDE_5_SUBTITLE) , descTextSize : 12 ,carouselBgColor :  Color.grey700, gravity : 0}
      ]

safetyIssueOptions :: Boolean -> Array OptionButtonList 
safetyIssueOptions forceEnglish =
  let getValue str = if forceEnglish then getEN str else getString str
  in
  [ { reasonCode: "DRIVER_BEHAVED_INAPPROPRIATELY"
    , description: getValue DRIVER_BEHAVED_INAPPROPRIATELY
    , textBoxRequired : false
    , subtext : Nothing
    }
  , { reasonCode: "I_DID_NOT_FEEL_SAFE"
    , description: getValue I_DID_NOT_FEEL_SAFE
    , textBoxRequired : false
    , subtext : Nothing
    }
  , { reasonCode: "OTHER"
    , description: getValue OTHER
    , textBoxRequired : false
    , subtext : Nothing
    }
  ]


getChatSuggestions :: ST.HomeScreenState -> Array String
getChatSuggestions state = do
  let didReceiverMessage = HU.didReceiverMessage FunctionCall
      lastMessage = DA.last state.data.messages
      currentUser = if state.props.isChatWithEMEnabled then (getValueFromCache (show CUSTOMER_ID) JB.getKeyInSharedPrefKeys) else "Customer"
      canShowSuggestions = case lastMessage of
        Just value -> (value.sentBy /= currentUser) || ((not state.props.isChatWithEMEnabled) && not didReceiverMessage)
        Nothing -> true
      isAtPickup = (metersToKm state.data.driverInfoCardState.distance (state.props.currentStage == RideStarted)) == getString AT_PICKUP
  if (DA.null state.data.chatSuggestionsList) && canShowSuggestions && state.props.canSendSuggestion then
    if state.props.isChatWithEMEnabled then do
      let hideInitial = not $ DA.null state.data.messages
      if didReceiverMessage && hideInitial then
        getSuggestionsfromKey emChatSuggestion emergencyContactInitialChatSuggestionId
      else if hideInitial then
        state.data.chatSuggestionsList
      else
        getSuggestionsfromKey emChatSuggestion emergencyContactInitialChatSuggestionId
    else if didReceiverMessage && (not $ DA.null state.data.messages) then
      if isAtPickup then getSuggestionsfromKey chatSuggestion "customerDefaultAP" else getSuggestionsfromKey chatSuggestion "customerDefaultBP"
    else if isAtPickup then
      getSuggestionsfromKey chatSuggestion "customerInitialAP"
    else do
      let hideInitial = not (DA.null state.data.messages) && not didReceiverMessage
      if (DA.null state.data.messages) && (EHC.getExpiryTime state.data.driverInfoCardState.createdAt true) > 30 then
        getSuggestionsfromKey chatSuggestion "customerInitialBP" --"customerInitialBP3" --TODO Revert during suggestions update
      else if hideInitial then
        getSuggestionsfromKey chatSuggestion "customerInitialBP" --"customerInitialBP2" --TODO Revert during suggestions update
      else
        getSuggestionsfromKey chatSuggestion "customerInitialBP" --"customerInitialBP1" --TODO Revert during suggestions update
  else
    state.data.chatSuggestionsList


locationTagBarConfig :: ST.HomeScreenState -> LocationTagBar.LocationTagBarConfig
locationTagBarConfig state  = let 
  locTagList =
      map 
        (\item -> 
          { imageConfig : 
              { height : V 20
              , width : V 20
              , imageWithFallback : fetchImage FF_ASSET item.image
              } ,
            textConfig : 
              { text : item.text
              , fontStyle : FontStyle.Body1
              , fontSize : FontSize.a_14
              , color : Color.black800
              },
            stroke : "1," <> Color.grey700 ,
            cornerRadius : Corners 19.0 true true true true ,
            background : Color.transparent ,
            height : WRAP_CONTENT ,
            width : WRAP_CONTENT,
            padding : Padding 8 8 8 8 ,
            id : item.id
          })
        [ { image : "ny_ic_intercity", text : "Intercity", id : "INTER_CITY" },
          { image : "ny_ic_rental" , text : "Rentals", id : "RENTALS" },
          { image : "ny_ic_ambulance", text : "Ambulance", id : "AMBULANCE" }]
  in 
    { tagList : locTagList }
  
safetyAlertConfig :: ST.HomeScreenState -> PopUpModal.Config
safetyAlertConfig state =
  let
    config' = PopUpModal.config

    alertData = getSafetyAlertData state

    popUpConfig' =
      config'
        { dismissPopup = true
        , optionButtonOrientation = "VERTICAL"
        , buttonLayoutMargin = Margin 24 0 24 20
        , gravity = CENTER
        , margin = MarginHorizontal 20 20
        , primaryText
          { text = getString EVERYTHING_OKAY_Q
          , margin = Margin 16 0 16 10
          }
        , secondaryText
          { text = alertData.text
          , margin = MarginHorizontal 16 16
          }
        , option1
          { text = getString I_FEEL_SAFE
          , color = Color.yellow900
          , background = Color.black900
          , strokeColor = Color.transparent
          , width = MATCH_PARENT
          , margin = MarginVertical 20 10
          }
        , option2
          { text = getString I_NEED_HELP
          , color = Color.black700
          , background = Color.white900
          , width = MATCH_PARENT
          , margin = MarginBottom 10
          }
        , cornerRadius = Corners 15.0 true true true true
        , coverImageConfig
          { imageUrl = HU.fetchImage HU.FF_ASSET alertData.image
          , visibility = VISIBLE
          , margin = Margin 16 16 16 16
          , width = MATCH_PARENT
          , height = V 225
          }
        }
  in
    popUpConfig'

getSafetyAlertData :: ST.HomeScreenState -> { text :: String, image :: String }
getSafetyAlertData state = case state.props.safetyAlertType of
  Just ST.DEVIATION ->  { text: getString WE_NOTICED_YOUR_RIDE_IS_ON_DIFFERENT_ROUTE, image: if state.data.driverInfoCardState.vehicleVariant /= "AUTO_RICKSHAW" then "ny_ic_safety_alert_deroute_cab" else "ny_ic_safety_alert_deroute_auto" }
  Just ST.STATIONARY_VEHICLE -> { text: getString WE_NOTICED_YOUR_RIDE_HASNT_MOVED, image: if state.data.driverInfoCardState.vehicleVariant /= "AUTO_RICKSHAW" then "ny_ic_safety_alert_stationary_cab" else "ny_ic_safety_alert_stationary_auto" }
  _ -> { text: "", image: "" }

shareRideConfig :: ST.HomeScreenState -> PopupWithCheckboxController.Config
shareRideConfig state = let
  config = PopupWithCheckboxController.config
  appName = fromMaybe state.data.config.appData.name $ runFn3 getAnyFromWindow "appName" Nothing Just
  shareRideConfig' = config{
    title = getString SHARE_RIDE,
    description = getString $ SHARE_RIDE_DESCRIPTION appName,
    secondaryButtonText = getString SHARE_LINK,
    secondaryButtonImage = HU.fetchImage HU.FF_ASSET "ny_ic_share",
    secondaryButtonVisibliity = true, 
    contactList = fromMaybe [] state.data.contactList,
    primaryButtonConfig = shareRideButtonConfig state
  }
  in shareRideConfig'


shareRideButtonConfig :: ST.HomeScreenState -> PrimaryButton.Config
shareRideButtonConfig state =
  PrimaryButton.config
    { textConfig
      { text = getString $ SHARE_RIDE_WITH_CONTACT $ show numberOfSelectedContacts
      , accessibilityHint = "Share Ride Button"
      }
    , id = "ShareRideButton"
    , enableLoader = (JB.getBtnLoader "ShareRideButton")
    , margin = MarginTop 20
    , isClickable = numberOfSelectedContacts /= 0
    , alpha = if numberOfSelectedContacts /= 0 then 1.0 else 0.5
    }
  where
  numberOfSelectedContacts = DA.length $ DA.filter (\contact -> contact.isSelected) $ fromMaybe [] state.data.contactList

referralPopUpConfig :: ST.HomeScreenState -> ST.ReferralComponentState
referralPopUpConfig state =
  let stage' = case state.props.referral.referralStatus of
                REFERRAL_APPLIED -> ST.APPLIED_POPUP
                REFERRAL_ALREADY_APPLIED -> ST.ALREADY_APPLIED_POPUP
                NO_REFERRAL | state.props.referral.showAddReferralPopup -> ST.ENTER_REFERRAL_CODE
                _ -> ST.INVALID_POPUP
  in state.props.referralComponentProps{ stage = stage' }

type TipConfig = {
  customerTipArray :: Array String,
  customerTipArrayWithValues :: Array Int
} 

type TipVehicleConfig = {
  sedan :: TipConfig,
  suv :: TipConfig,
  hatchback :: TipConfig,
  autoRickshaw :: TipConfig,
  taxi :: TipConfig,
  taxiPlus :: TipConfig
}

getTipConfig :: String -> TipConfig
getTipConfig variant = do
  let city = HU.getCityFromString $ getValueToLocalStore CUSTOMER_LOCATION
  case city of 
    Bangalore -> bangaloreConfig variant
    Hyderabad -> hyderabadConfig variant
    _ -> defaultTipConfig variant

mkTipConfig :: Array Int -> TipConfig
mkTipConfig customerTipArrayWithValues = {
  customerTipArray: getTips customerTipArrayWithValues,
  customerTipArrayWithValues: customerTipArrayWithValues
}

getTips :: Array Int -> Array String
getTips arr = mapWithIndex (\index item -> if item == 0 then (getString NO_TIP) 
                                           else "₹" <> show item <> " " <> fromMaybe "🤩" (emoji !! index)) arr
  where
    emoji = [(getString NO_TIP), "🙂", "😀", "😃", "😁", "🤩"]
      
bangaloreConfig :: String -> TipConfig
bangaloreConfig variant = 
  case variant of
    "SEDAN" -> mkTipConfig []
    "SUV" -> mkTipConfig []
    "HATCHBACK" -> mkTipConfig []
    "AUTO_RICKSHAW" -> mkTipConfig [0, 10, 20, 30]
    "TAXI" -> mkTipConfig []
    "TAXI_PLUS" -> mkTipConfig []
    _ -> mkTipConfig []

hyderabadConfig :: String -> TipConfig
hyderabadConfig variant = 
  case variant of
    "SEDAN" -> mkTipConfig []
    "SUV" -> mkTipConfig []
    "HATCHBACK" -> mkTipConfig []
    "AUTO_RICKSHAW" -> mkTipConfig [0, 10, 20, 30]
    "TAXI" -> mkTipConfig []
    "TAXI_PLUS" -> mkTipConfig []
    _ -> mkTipConfig []

defaultTipConfig :: String -> TipConfig
defaultTipConfig variant = 
  case variant of
    "SEDAN" -> mkTipConfig []
    "SUV" -> mkTipConfig []
    "HATCHBACK" -> mkTipConfig []
    "AUTO_RICKSHAW" -> mkTipConfig [0, 10, 20, 30]
    "TAXI" -> mkTipConfig []
    "TAXI_PLUS" -> mkTipConfig []
    _ -> mkTipConfig []

specialZoneInfoPopupConfig :: ST.SpecialZoneInfoPopUp -> RequestInfoCard.Config
specialZoneInfoPopupConfig infoConfig = let
  config = RequestInfoCard.config
  specialZonePopupConfig = config{
      title {
        text = infoConfig.title
      }
    , primaryText {
        text = infoConfig.primaryText,
        padding = Padding 16 16 0 0,
        color = Color.black700
      }
    , secondaryText {
        text = infoConfig.secondaryText,
        visibility = VISIBLE,
        padding = PaddingLeft 16,
        color = Color.black700,
        textStyle = FontStyle.ParagraphText,
        width = (V $ JB.getWidthFromPercent 75)
      }
    , imageConfig {
        imageUrl = fetchImage FF_COMMON_ASSET infoConfig.icon,
        height = V 130,
        width = V 130,
        padding = Padding 0 2 2 0
      }
    , buttonConfig {
        text = infoConfig.primaryButtonText,
        padding = PaddingVertical 16 20
      }
  }
  in specialZonePopupConfig


generateReferralLink :: String -> String -> String -> String -> String -> String
generateReferralLink source medium term content campaign  =
  let config = getAppConfig appConfig 
      cityConfig = getCityFromString $ getValueToLocalStore CUSTOMER_LOCATION
      path = "link/rider/SJ8D"
      packageId = config.referral.customerAppId
      domain = config.referral.domain
  in domain <> path <> "?referrer=" 
      -- <> "utm_source%3D" <> source 
      -- <> "%26utm_medium%3D" <> medium 
      -- <> "%26utm_term%3D" <> term 
      -- <> "%26utm_content%3D" <> content 
      <> "utm_campaign%3D" <> campaign 
      -- <> "%26anid%3Dadmob&id=" <> packageId
-- TODO: Add the above query params when needed

acWorkingPopupConfig :: ST.HomeScreenState -> PopUpModal.Config
acWorkingPopupConfig state = let
  config = PopUpModal.config
  isAcCabRide = ServiceTierCard.showACDetails (fromMaybe "" state.data.driverInfoCardState.serviceTierName) Nothing
  primaryText_ = getString $ if isAcCabRide 
                   then HAS_YOUR_DRIVER_SET_THE_AC_AS_PER_YOUR_PREFERENCE 
                   else ENJOY_YOUR_BUDGET_FRIENDLY_NON_AC_RIDE
  optionOneText = getString $ if isAcCabRide 
                    then YES 
                    else OK_GOT_IT
  imageName = if isAcCabRide then "ny_ic_ac_preference_popup" else "ny_ic_non_ac_ride_popup"
  acWorkingPopupConfig' = config{
    dismissPopup = true,
    optionButtonOrientation = if isAcCabRide 
                               then "VERTICAL"
                               else "HORIZONTAL",
    buttonLayoutMargin = Margin 24 0 24 20,
    gravity = CENTER,
    margin = MarginHorizontal 20 20,
    backgroundClickable = true,
    primaryText{
      text = primaryText_,
      margin = MarginTop 0
    },
    secondaryText{
      visibility = GONE
    },
    option1{
      text = optionOneText,
      color = Color.yellow900,
      background = Color.black900,
      strokeColor = Color.transparent,
      width = MATCH_PARENT,
      margin = MarginVertical 20 10
    },
    option2{
      text = getString NO_REPORT_AN_ISSUE,
      color = Color.black700,
      background = Color.white900,
      width = MATCH_PARENT,
      margin = MarginBottom 10,
      visibility = isAcCabRide
    },
    cornerRadius = Corners 15.0 true true true true,
    coverImageConfig{
      imageUrl = HU.fetchImage HU.FF_ASSET imageName,
      visibility = VISIBLE,
      margin = Margin 16 16 16 0,
      width = MATCH_PARENT,
      height = V 225
    }
  }
  in acWorkingPopupConfig'