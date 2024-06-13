module API.Dashboard.Management.Issue where

import qualified API.UI.Issue as AUI
import qualified Domain.Types.Merchant as DM
import Environment
import qualified IssueManagement.API.Dashboard.Issue as IMD
import qualified IssueManagement.Common as Common
import qualified IssueManagement.Common.Dashboard.Issue as Common
import qualified IssueManagement.Domain.Action.Dashboard.Issue as DIssue
import IssueManagement.Domain.Types.Issue.IssueCategory
import IssueManagement.Domain.Types.Issue.IssueMessage
import IssueManagement.Domain.Types.Issue.IssueOption
import IssueManagement.Domain.Types.Issue.IssueReport
import Kernel.Prelude
import Kernel.Types.APISuccess (APISuccess)
import qualified Kernel.Types.Beckn.Context as Context
import Kernel.Types.Common
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import Servant hiding (Unauthorized, throwError)
import Storage.Beam.IssueManagement ()
import Storage.Beam.SystemConfigs ()
import qualified Storage.CachedQueries.Merchant as Merchant
import qualified Storage.CachedQueries.Merchant.MerchantOperatingCity as CQMOC

type API = IMD.DashboardIssueAPI

handler :: ShortId DM.Merchant -> Context.City -> FlowServer API
handler merchantId city =
  issueCategoryList merchantId city
    :<|> issueList merchantId city
    :<|> issueInfo merchantId city
    :<|> issueInfoV2 merchantId city
    :<|> issueUpdate merchantId city
    :<|> issueAddComment merchantId city
    :<|> issueFetchMedia merchantId city
    :<|> ticketStatusCallBack merchantId city
    :<|> createIssueCategory merchantId city
    :<|> updateIssueCategory merchantId city
    :<|> createIssueOption merchantId city
    :<|> updateIssueOption merchantId city
    :<|> upsertIssueMessage merchantId city
    :<|> uploadIssueMessageMediaFiles merchantId city

dashboardIssueHandle :: DIssue.ServiceHandle Flow
dashboardIssueHandle =
  DIssue.ServiceHandle
    { findPersonById = AUI.castPersonById,
      findByMerchantShortIdAndCity = castfindByMerchantShortIdAndCity,
      findMerchantConfig = AUI.buildMerchantConfig
    }

castfindByMerchantShortIdAndCity :: (CacheFlow m r, EsqDBFlow m r) => ShortId Common.Merchant -> Context.City -> m (Maybe Common.MerchantOperatingCity)
castfindByMerchantShortIdAndCity (ShortId merchantShortId) opCity = do
  merchantOpCity <- CQMOC.findByMerchantShortIdAndCity (ShortId merchantShortId) opCity
  return $ fmap castMerchantOperatingCity merchantOpCity
  where
    castMerchantOperatingCity moCity =
      Common.MerchantOperatingCity
        { id = cast moCity.id,
          city = moCity.city,
          merchantId = cast moCity.merchantId
        }

issueCategoryList ::
  ShortId DM.Merchant ->
  Context.City ->
  FlowHandler Common.IssueCategoryListRes
issueCategoryList (ShortId merchantShortId) opCity = withFlowHandlerAPI $ DIssue.issueCategoryList (ShortId merchantShortId) opCity Common.DRIVER

issueList ::
  ShortId DM.Merchant ->
  Context.City ->
  Maybe Int ->
  Maybe Int ->
  Maybe Common.IssueStatus ->
  Maybe (Id IssueCategory) ->
  Maybe Text ->
  FlowHandler Common.IssueReportListResponse
issueList (ShortId merchantShortId) opCity mbLimit mbOffset mbStatus mbCategoryId mbAssignee = withFlowHandlerAPI $ DIssue.issueList (ShortId merchantShortId) opCity mbLimit mbOffset mbStatus (cast <$> mbCategoryId) mbAssignee dashboardIssueHandle Common.DRIVER

issueInfo ::
  ShortId DM.Merchant ->
  Context.City ->
  Id IssueReport ->
  FlowHandler Common.IssueInfoRes
issueInfo (ShortId merchantShortId) opCity issueReportId = withFlowHandlerAPI $ DIssue.issueInfo (ShortId merchantShortId) opCity (Just issueReportId) Nothing dashboardIssueHandle Common.DRIVER

issueInfoV2 ::
  ShortId DM.Merchant ->
  Context.City ->
  Maybe (Id IssueReport) ->
  Maybe (ShortId IssueReport) ->
  FlowHandler Common.IssueInfoRes
issueInfoV2 (ShortId merchantShortId) opCity mbIssueReportId mbIssueReportShortId = withFlowHandlerAPI $ DIssue.issueInfo (ShortId merchantShortId) opCity mbIssueReportId mbIssueReportShortId dashboardIssueHandle Common.DRIVER

issueUpdate ::
  ShortId DM.Merchant ->
  Context.City ->
  Id IssueReport ->
  Common.IssueUpdateByUserReq ->
  FlowHandler APISuccess
issueUpdate (ShortId merchantShortId) opCity issueReportId req =
  withFlowHandlerAPI $ do
    merchant <- runInReplica $ Merchant.findByShortId (ShortId merchantShortId) >>= fromMaybeM (MerchantNotFound merchantShortId)
    DIssue.issueUpdate (ShortId merchantShortId) opCity (cast issueReportId) dashboardIssueHandle req (cast merchant.id)

issueAddComment ::
  ShortId DM.Merchant ->
  Context.City ->
  Id IssueReport ->
  Common.IssueAddCommentByUserReq ->
  FlowHandler APISuccess
issueAddComment (ShortId merchantShortId) opCity issueReportId req =
  withFlowHandlerAPI $ do
    merchant <- runInReplica $ Merchant.findByShortId (ShortId merchantShortId) >>= fromMaybeM (MerchantNotFound merchantShortId)
    DIssue.issueAddComment (ShortId merchantShortId) opCity (cast issueReportId) dashboardIssueHandle req (cast merchant.id)

issueFetchMedia :: ShortId DM.Merchant -> Context.City -> Text -> FlowHandler Text
issueFetchMedia (ShortId merchantShortId) _opCity = withFlowHandlerAPI . DIssue.issueFetchMedia (ShortId merchantShortId)

ticketStatusCallBack :: ShortId DM.Merchant -> Context.City -> Common.TicketStatusCallBackReq -> FlowHandler APISuccess
ticketStatusCallBack (ShortId _merchantShortId) _opCity req = withFlowHandlerAPI $ DIssue.ticketStatusCallBack req dashboardIssueHandle Common.DRIVER

createIssueCategory :: ShortId DM.Merchant -> Context.City -> Common.CreateIssueCategoryReq -> FlowHandler APISuccess
createIssueCategory (ShortId merchantShortId) city req = withFlowHandlerAPI $ DIssue.createIssueCategory (ShortId merchantShortId) city req Common.DRIVER

updateIssueCategory :: ShortId DM.Merchant -> Context.City -> Id IssueCategory -> Common.UpdateIssueCategoryReq -> FlowHandler APISuccess
updateIssueCategory (ShortId merchantShortId) city issueCategoryId req = withFlowHandlerAPI $ DIssue.updateIssueCategory (ShortId merchantShortId) city issueCategoryId req Common.DRIVER

createIssueOption :: ShortId DM.Merchant -> Context.City -> Id IssueCategory -> Id IssueMessage -> Common.CreateIssueOptionReq -> FlowHandler APISuccess
createIssueOption (ShortId merchantShortId) city issueCategoryId issueMessageId req = withFlowHandlerAPI $ DIssue.createIssueOption (ShortId merchantShortId) city issueCategoryId issueMessageId req Common.DRIVER

updateIssueOption :: ShortId DM.Merchant -> Context.City -> Id IssueOption -> Common.UpdateIssueOptionReq -> FlowHandler APISuccess
updateIssueOption (ShortId merchantShortId) city issueOptionId req = withFlowHandlerAPI $ DIssue.updateIssueOption (ShortId merchantShortId) city issueOptionId req Common.DRIVER

upsertIssueMessage :: ShortId DM.Merchant -> Context.City -> Maybe (Id IssueMessage) -> Common.UpsertIssueMessageReq -> FlowHandler APISuccess
upsertIssueMessage (ShortId merchantShortId) city mbIssueMessageId req = withFlowHandlerAPI $ DIssue.upsertIssueMessage (ShortId merchantShortId) city mbIssueMessageId req Common.DRIVER

uploadIssueMessageMediaFiles :: ShortId DM.Merchant -> Context.City -> Common.IssueMessageMediaFileUploadListReq -> FlowHandler APISuccess
uploadIssueMessageMediaFiles (ShortId merchantShortId) city req = withFlowHandlerAPI $ DIssue.uploadIssueMessageMediaFiles (ShortId merchantShortId) city req dashboardIssueHandle Common.DRIVER
