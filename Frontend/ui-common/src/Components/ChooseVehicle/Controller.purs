module Components.ChooseVehicle.Controller where

import Prelude (class Eq, class Show )
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Foreign.Generic (decode, encode, class Decode, class Encode)
import Presto.Core.Utils.Encoding (defaultEnumDecode, defaultEnumEncode)
import PrestoDOM (Margin(..))
import Data.Maybe (Maybe(..))
import Common.Types.App (RateCardType(..), FareList)
import Common.Types.App as CT

data Action
  = NoAction Config
  | OnSelect Config
  | OnImageClick
  | ShowRateCard Config
  | OnEditClick
  | ServicesOnClick Config String

type Config
  = { vehicleImage :: String
    , isSelected :: Boolean
    , vehicleVariant :: String
    , vehicleType :: String
    , capacity :: String
    , price :: String
    , isCheckBox :: Boolean
    , isEnabled :: Boolean
    , index :: Int
    , activeIndex :: Int
    , id :: String
    , maxPrice :: Maybe Int
    , minPrice :: Maybe Int
    , basePrice :: Int
    , showInfo :: Boolean
    , searchResultType :: SearchType
    , isBookingOption :: Boolean
    , pickUpCharges :: Number 
    , tollCharge :: Number
    , serviceTierShortDesc :: Maybe String
    , serviceTierName :: Maybe String
    , extraFare :: Array FareList
    , additionalFare :: Int
    , driverAdditions :: Array FareList
    , fareInfoDescription :: Array String
    , isNightShift :: Boolean
    , nightChargeTill :: String
    , nightChargeFrom :: String
    , airConditioned :: Maybe Boolean
    , showEditButton :: Boolean
    , editBtnText :: String
    , layoutMargin :: Margin 
    , providerName :: String
    , providerId :: String
    , providerType :: CT.ProviderType
    , singleVehicle :: Boolean
    , priceShimmer :: Boolean
    , availableServices :: Array String
    , services :: Array String
    , selectedServices :: Array String
    , currentEstimateHeight :: Int
    , selectedEstimateHeight :: Int
    }

data SearchType = QUOTES | ESTIMATES

derive instance genericSearchType :: Generic SearchType _
instance eqSearchType :: Eq SearchType where eq = genericEq
instance showSearchType :: Show SearchType where show = genericShow
instance encodeSearchType :: Encode SearchType where encode = defaultEnumEncode
instance decodeSearchType :: Decode SearchType where decode = defaultEnumDecode


config :: Config
config =
  { vehicleImage: ""
  , isSelected: false
  , vehicleVariant: ""
  , vehicleType: ""
  , capacity: ""
  , price: ""
  , isCheckBox: false
  , isEnabled: true
  , activeIndex: 0
  , index: 0
  , id: ""
  , maxPrice : Nothing
  , minPrice : Nothing
  , basePrice : 0 
  , showInfo : false
  , searchResultType : QUOTES
  , isBookingOption : false
  , pickUpCharges : 0.0
  , layoutMargin : MarginHorizontal 12 12
  , tollCharge : 0.0
  , serviceTierShortDesc : Nothing
  , serviceTierName : Nothing
  , extraFare: []
  , additionalFare: 0
  , fareInfoDescription: []
  , driverAdditions: []
  , isNightShift : false
  , nightChargeTill : ""
  , nightChargeFrom : ""
  , airConditioned : Nothing
  , showEditButton : false
  , editBtnText : ""
  , providerName : ""
  , providerId : ""
  , providerType : CT.ONUS
  , singleVehicle : false
  , priceShimmer : true
  , availableServices : []
  , services : [] 
  , selectedServices : []
  , currentEstimateHeight : 184 
  , selectedEstimateHeight : 0
  }
