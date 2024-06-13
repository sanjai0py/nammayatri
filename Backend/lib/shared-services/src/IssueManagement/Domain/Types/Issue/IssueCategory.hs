{-# LANGUAGE TemplateHaskell #-}

module IssueManagement.Domain.Types.Issue.IssueCategory where

import Data.OpenApi
import EulerHS.Prelude hiding (id)
import IssueManagement.Common
import Kernel.Beam.Lib.UtilsTH
import Kernel.Types.Id
import Kernel.Utils.Common

data IssueCategory = IssueCategory
  { id :: Id IssueCategory,
    category :: Text,
    logoUrl :: Text,
    priority :: Int,
    merchantId :: Id Merchant,
    categoryType :: CategoryType,
    isActive :: Bool,
    maxAllowedRideAge :: Maybe Seconds,
    createdAt :: UTCTime,
    updatedAt :: UTCTime
  }
  deriving (Generic, FromJSON, ToJSON, Show, Eq)

data CategoryType = Category | FAQ
  deriving (Generic, FromJSON, ToJSON, Show, Eq, Read, Ord, ToSchema)

$(mkBeamInstancesForEnum ''CategoryType)
