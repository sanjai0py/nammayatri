{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Beam.Plan where

import qualified Database.Beam as B
import qualified Domain.Types.Extra.Plan
import qualified Domain.Types.Plan
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Common
import Tools.Beam.UtilsTH

data PlanT f = PlanT
  { basedOnEntity :: B.C f Domain.Types.Plan.BasedOnEntity,
    cgstPercentage :: B.C f Kernel.Types.Common.HighPrecMoney,
    description :: B.C f Kernel.Prelude.Text,
    eligibleForCoinDiscount :: B.C f Kernel.Prelude.Bool,
    freeRideCount :: B.C f Kernel.Prelude.Int,
    frequency :: B.C f Domain.Types.Plan.Frequency,
    id :: B.C f Kernel.Prelude.Text,
    isDeprecated :: B.C f Kernel.Prelude.Bool,
    isOfferApplicable :: B.C f Kernel.Prelude.Bool,
    maxAmount :: B.C f Kernel.Types.Common.HighPrecMoney,
    maxCreditLimit :: B.C f Kernel.Types.Common.HighPrecMoney,
    maxMandateAmount :: B.C f Kernel.Types.Common.HighPrecMoney,
    merchantId :: B.C f Kernel.Prelude.Text,
    merchantOpCityId :: B.C f Kernel.Prelude.Text,
    name :: B.C f Kernel.Prelude.Text,
    paymentMode :: B.C f Domain.Types.Plan.PaymentMode,
    planBaseAmount :: B.C f Domain.Types.Extra.Plan.PlanBaseAmount,
    planType :: B.C f Domain.Types.Plan.PlanType,
    registrationAmount :: B.C f Kernel.Types.Common.HighPrecMoney,
    serviceName :: B.C f Domain.Types.Plan.ServiceNames,
    sgstPercentage :: B.C f Kernel.Types.Common.HighPrecMoney,
    subscribedFlagToggleAllowed :: B.C f Kernel.Prelude.Bool
  }
  deriving (Generic, B.Beamable)

instance B.Table PlanT where
  data PrimaryKey PlanT f = PlanId (B.C f Kernel.Prelude.Text) deriving (Generic, B.Beamable)
  primaryKey = PlanId . id

type Plan = PlanT Identity

$(enableKVPG ''PlanT ['id] [['merchantId], ['paymentMode]])

$(mkTableInstances ''PlanT "plan")
