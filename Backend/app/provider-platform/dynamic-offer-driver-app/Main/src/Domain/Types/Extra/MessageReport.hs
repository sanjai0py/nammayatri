{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Domain.Types.Extra.MessageReport where

import Data.Aeson
import qualified Data.Aeson as A
import Data.ByteString
import qualified Data.Map as M
import qualified Database.Beam as B
import Database.Beam.Backend
import Database.Beam.Postgres
import Database.PostgreSQL.Simple.FromField (FromField (fromField))
import qualified Database.PostgreSQL.Simple.FromField as DPSF
import qualified Domain.Types.Message as Msg
import Domain.Types.Person (Driver)
import Kernel.Prelude
import Kernel.Types.Id
import Tools.Beam.UtilsTH (mkBeamInstancesForEnum)

-- Extra code goes here --

type MessageDynamicFieldsType = M.Map Text Text

fromFieldMessageDynamicFields ::
  DPSF.Field ->
  Maybe ByteString ->
  DPSF.Conversion MessageDynamicFieldsType
fromFieldMessageDynamicFields f mbValue = do
  value' <- fromField f mbValue
  case A.fromJSON value' of
    A.Success a -> pure a
    _ -> DPSF.returnError DPSF.ConversionFailed f "Conversion failed"

instance FromField MessageDynamicFieldsType where
  fromField = fromFieldMessageDynamicFields

instance HasSqlValueSyntax be A.Value => HasSqlValueSyntax be MessageDynamicFieldsType where
  sqlValueSyntax = sqlValueSyntax . A.toJSON

instance BeamSqlBackend be => B.HasSqlEqualityCheck be MessageDynamicFieldsType

instance FromBackendRow Postgres MessageDynamicFieldsType
