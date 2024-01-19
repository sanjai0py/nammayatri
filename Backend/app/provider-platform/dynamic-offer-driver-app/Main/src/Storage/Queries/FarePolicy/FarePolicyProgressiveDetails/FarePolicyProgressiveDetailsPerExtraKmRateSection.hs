{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.FarePolicy.FarePolicyProgressiveDetails.FarePolicyProgressiveDetailsPerExtraKmRateSection where

import qualified Domain.Types.FarePolicy as DFP
import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Types.Id as KTI
import Kernel.Utils.Common
import Sequelize as Se
import qualified Storage.Beam.FarePolicy.FarePolicyProgressiveDetails.FarePolicyProgressiveDetailsPerExtraKmRateSection as BeamFPPDP

findById' :: (MonadFlow m, EsqDBFlow m r, CacheFlow m r) => KTI.Id DFP.FarePolicy -> m (Maybe BeamFPPDP.FullFarePolicyProgressiveDetailsPerExtraKmRateSection)
findById' farePolicyId' = findOneWithKV [Se.Is BeamFPPDP.farePolicyId $ Se.Eq (getId farePolicyId')]

findAll' ::
  (MonadFlow m, EsqDBFlow m r, CacheFlow m r) =>
  Id DFP.FarePolicy ->
  m [BeamFPPDP.FullFarePolicyProgressiveDetailsPerExtraKmRateSection]
findAll' farePolicyId = findAllWithOptionsKV [Se.Is BeamFPPDP.farePolicyId $ Se.Eq (getId farePolicyId)] (Se.Asc BeamFPPDP.startDistance) Nothing Nothing

updatePerExtraKmRate :: (MonadFlow m, EsqDBFlow m r, CacheFlow m r) => KTI.Id DFP.FarePolicy -> HighPrecMoney -> m ()
updatePerExtraKmRate farePolicyId' perExtraKmRate =
  updateWithKV
    [Se.Set BeamFPPDP.perExtraKmRate perExtraKmRate]
    [Se.Is BeamFPPDP.farePolicyId $ Se.Eq (getId farePolicyId')]

deleteAll' :: (MonadFlow m, EsqDBFlow m r, CacheFlow m r) => Id DFP.FarePolicy -> m ()
deleteAll' (Id farePolicyId) = deleteWithKV [Se.Is BeamFPPDP.farePolicyId $ Se.Eq farePolicyId]

instance FromTType' BeamFPPDP.FarePolicyProgressiveDetailsPerExtraKmRateSection BeamFPPDP.FullFarePolicyProgressiveDetailsPerExtraKmRateSection where
  fromTType' BeamFPPDP.FarePolicyProgressiveDetailsPerExtraKmRateSectionT {..} = do
    pure $
      Just
        ( KTI.Id farePolicyId,
          DFP.FPProgressiveDetailsPerExtraKmRateSection
            { startDistance = startDistance,
              perExtraKmRate = perExtraKmRate
            }
        )

instance ToTType' BeamFPPDP.FarePolicyProgressiveDetailsPerExtraKmRateSection BeamFPPDP.FullFarePolicyProgressiveDetailsPerExtraKmRateSection where
  toTType' (KTI.Id farePolicyId, DFP.FPProgressiveDetailsPerExtraKmRateSection {..}) =
    BeamFPPDP.FarePolicyProgressiveDetailsPerExtraKmRateSectionT
      { -- id = id,
        farePolicyId = farePolicyId,
        startDistance = startDistance,
        perExtraKmRate = perExtraKmRate
      }
