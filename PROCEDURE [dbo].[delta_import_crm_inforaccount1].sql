USE [EDW_STAGE]
GO
/****** Object:  StoredProcedure [dbo].[delta_import_crm_inforaccount1]    Script Date: 12/27/2023 9:53:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




----------------------------------------------------------
ALTER PROCEDURE [dbo].[delta_import_crm_inforaccount1]
 @load_date [smalldatetime] = NULL,
 @server [varchar](50) = 'SRV_ICRM',
 @owner [varchar](50) = 'sysdba',
 @database [varchar](50) = 'SalesLogix',
 @sourcesystem [varchar](50) = 'CRM',
 @cleanupTempTables [int] = 1,
 @debug [int] = 0,
 @min_date [datetime] = NULL
WITH EXECUTE AS CALLER
AS
/***************************************************************************************************************
* Procedure:  delta_import_crm_inforaccount
 * Purpose:  To import Data using a delta methodololgy
 * Author:   PSSC\MGC
 * CreateDate:  07/19/2018
 * Modifications:
 * Date   Author   Purpose
 * 
 * 
 *
 * --TESTING SCRIPTS:
--EXECUTE
DECLARE @load_date smalldatetime; SELECT @load_date = [loadDateDt] FROM [dbo].[dim_LoadDate]
DECLARE @min_date datetime; SET @min_date = convert(datetime, convert(varchar(30), dateadd(yy, -30, @load_date), 101))
DECLARE @return_value int
EXEC @return_value = [dbo].delta_import_crm_inforaccount1
  @load_date  = @load_date,
  @server   = N'SRV_ICRM',
  @owner   = N'sysdba',
  @database  = N'SalesLogix',
  @sourcesystem = N'CRM',
  @debug   = 0,
  @min_date  = @min_date
SELECT 'Return Value' = @return_value

 History of modifications:

 Name					Date				Project						Remarks
MGC			12/03/2019			EDW Maintenance				Original Procedure
 *
 ***************************************************************************************************************/
SET NOCOUNT ON
--DECLARE @load_date smalldatetime; DECLARE @min_date datetime
DECLARE @sourcesystem_id int
DECLARE @countSource int
DECLARE @countDest  int
DECLARE @countDelta  int
DECLARE @cmd   varchar(max)
DECLARE @rowcount  int;
DECLARE @log_v_main  int;
DECLARE @log_value  int;
DECLARE @log_step  int;
DECLARE @message  varchar(50);
DECLARE @type   varchar(50);
DECLARE @proc_name  varchar(50);
DECLARE @step_name  varchar(50);
DECLARE @tbl   varchar(128)
DECLARE @destDB   varchar(128)
DECLARE @dateValue1   datetime
DECLARE @dateValue2   datetime
DECLARE @dateValue3   datetime
DECLARE @dateValue4   datetime
DECLARE @loaddttm   datetime2

SET  @destDB   = db_name()


SET  @proc_name  = OBJECT_NAME(@@PROCID)

SET  @step_name  = 'PROCEDURE'
SET  @message  = 'PROCEDURE'
SET  @type   = 'PROCEDURE'
SET  @rowcount  = 0
EXEC @log_v_main = dbo.logProcessActivity
        @log_v_main
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount
SET  @step_name  = 'SETUP'
SET  @message  = 'SETUP'
SET  @type   = 'SETUP'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

--Set the load_date, sourcesystem_id, min_date and delta date where not set
--DECLARE @log_value int; DECLARE @proc_name sysname; DECLARE @step_name varchar(256); DECLARE @message varchar(256); DECLARE @type varchar(256); DECLARE @rowcount int', 1'
--DECLARE @countSource int; DECLARE @countDest int; DECLARE @load_date smalldatetime; DECLARE @min_date datetime; DECLARE @log_step varchar(256); DECLARE @cmd varchar(max)
--DECLARE @sourcesystem varchar(200)
--DECLARE @sourcesystem_id int


 /**** CRM_PSSCACCOUNT ****/

SET  @countSource = 0
SET  @countDest  = 0
SELECT  @sourcesystem_id = sourcesystem_id FROM dbo.dim_SourceSystems WHERE sourcesystem = @sourcesystem


IF  @load_date IS NULL OR @load_date = ''
   SELECT @load_date = [loadDateDt] FROM [dbo].[dim_LoadDate]
SELECT @loaddttm  = [currentDttm] FROM [dbo].[dim_LoadDate]

IF  @min_date IS NULL OR @min_date = ''
 BEGIN
  IF 'ModifyDate' != 'NULL'
   SELECT @datevalue1 = max(ModifyDate) FROM dbo.CRM_PSSCACCOUNT1 WITH (NOLOCK) WHERE ModifyDate < = getdate()
 AND sourcesystem_id = @sourcesystem_id
  ELSE
   SELECT @datevalue1 = dateadd(yy, -30, @load_date)

  IF 'NULL' != 'NULL'
   SELECT @datevalue2 = max(getdate()) FROM dbo.CRM_PSSCACCOUNT1 WITH (NOLOCK) WHERE ModifyDate < = getdate()
 AND sourcesystem_id = @sourcesystem_id
  ELSE
   SELECT @datevalue2 = @datevalue1

  IF 'NULL' != 'NULL'
   SELECT @datevalue3 = max(getdate()) FROM dbo.CRM_PSSCACCOUNT1 WITH (NOLOCK) WHERE ModifyDate < = getdate()
 AND sourcesystem_id = @sourcesystem_id
  ELSE
   SELECT @datevalue3 = @datevalue1

  IF 'NULL' != 'NULL'
   SELECT @datevalue4 = max(getdate()) FROM dbo.CRM_PSSCACCOUNT1 WITH (NOLOCK) WHERE ModifyDate < = getdate()
 AND sourcesystem_id = @sourcesystem_id
  ELSE
   SELECT @datevalue4 = @datevalue1


  SELECT @min_date = DATEADD(hh, -6, COALESCE(dbo.fn_GetMaxDttm( @datevalue1, dbo.fn_GetMaxDttm( @datevalue2, dbo.fn_GetMaxDttm( @datevalue3, @datevalue4) ) ), dateadd(dd, -200, getdate())))

 END

EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

/***************************************************************************************************************/
/***************************************************************************************************************/



SET  @step_name  = 'CRM_PSSCACCOUNT1'
SET  @message  = 'Clear Records'
SET  @type   = 'DELETE'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount


--CREATE the delta table in local db if it does not exist
SET  @tbl = 'CRM_PSSCACCOUNT1'
BEGIN
   EXEC  dbo.cloneTable
      @source_server  = N'',
      @source_db   = N'EDW_STAGE',
      @source_table  = 'CRM_PSSCACCOUNT1',
      @source_owner  = 'dbo',
      @dest_db   = N'EDW_STAGE',
      @dest_Owner   = 'dbo',
      @table_suffix  = N'',
      @table_prefix  = N'XD_',
      @force_load_date = 0,
      @debug    = 0
    --SET @cmd = 'DELETE FROM dbo.CRM_PSSCACCOUNT WHERE load_date < ( SELECT max(load_date) FROM dbo.CRM_PSSCACCOUNT WITH (NOLOCK))'
    --EXECUTE (@cmd)
END



BEGIN
   EXEC  dbo.cloneTable
      @source_server  = N'',
      @source_db   = N'EDW_STAGE',
      @source_table  = 'CRM_PSSCACCOUNT1',
      @source_owner  = 'dbo',
      @dest_db   = N'EDW_STAGE',
      @dest_Owner   = 'dbo',
      @table_suffix  = N'',
      @table_prefix  = N'XA_',
      @force_load_date = 0,
      @debug    = 0
    --SET @cmd = 'DELETE FROM dbo.CRM_PSSCACCOUNT WHERE load_date < ( SELECT max(load_date) FROM dbo.CRM_PSSCACCOUNT WITH (NOLOCK))'
    --EXECUTE (@cmd)
END



EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @@ROWCOUNT




SET  @message	= 'COUNT Records in Source'
SET  @type		= 'COUNT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

EXECUTE dbo.logTableCounts @servername = @server , @dbname = @database, @tablename = 'PSSCACCOUNT', @count = NULL, @desc = 'SOURCE'
       , @sourcesystem_id = @sourcesystem_id

SELECT @countSource = .dbo.fn_getlastcount (@server, @database, 'PSSCACCOUNT', COALESCE(@sourcesystem_id, 0) )

EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @countSource


SET  @message  = 'Delete Records that were removed from the source'
SET  @type   = 'COUNT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount


SET  @cmd = 'INSERT INTO dbo.XD_CRM_PSSCACCOUNT1' + char(10)
SET  @cmd = @cmd + 'SELECT dw.*' + char(10)
SET  @cmd = @cmd + ' FROM dbo.CRM_PSSCACCOUNT1 dw' + char(10)
SET  @cmd = @cmd + ' LEFT JOIN OPENQUERY(' + @server + ', ''SELECT [ACCOUNTID]' + char(10)
SET  @cmd = @cmd + ' FROM [' + @database + '].[sysdba].[PSSCACCOUNT]'') src' + char(10)
SET  @cmd = @cmd + ' ON  src.[ACCOUNTID] = dw.[ACCOUNTID]' + char(10)
SET  @cmd = @cmd + ' WHERE src.[ACCOUNTID] IS NULL' + char(10)
SET  @cmd = @cmd + ' AND dw.sourcesystem_id = ' + convert(varchar, @sourcesystem_id) + char(10)

EXECUTE (@cmd)


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @countSource


SET  @message  = 'INSERT Records in Delta table'
SET  @type   = 'INSERT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

SET  @cmd = 'SELECT BI_Load_Date = ''' + convert(varchar(20), @load_date) + '''
  , sourcesystem_id  = ''' + convert(varchar(20), @sourcesystem_id) + '''
  , source.*
FROM OPENQUERY(' + @server + ', ''SELECT 
	 [ACCOUNTID]
      ,[CREATEUSER]
      ,[CREATEDATE]
      ,[MODIFYUSER]
      ,[MODIFYDATE]
      ,[SALESFORCEID]
      ,[ISDELETED]
      ,[DELETEDDATE]
      ,[PHOTOURL]
      ,[ISPARTNERPORTALAUTHROIZED]
      ,[ALLIANCEAGREEMENT]
      ,[ALLIANCETYPE]
      ,[AUDITINGINPROGRESS]
      ,[ACCOUNTCLASS]
      ,[IPNPARTNERCHANNELTIER]
      ,[LASTACTIVITYDATE]
      ,[LASTCALLACTIVITYDATE]
      ,[DECISIONLOCATION]
      ,[FORMALIZATIONDATE]
      ,[NAHEALTHCARE]
      ,[INBOUNDINTEGRATIONERROR]
      ,[LASTDATEVERIFIED]
      ,[MAINTENANCESTATUS]
      ,[HCMTEAMCOMMENTS]
      ,[OUTOFBUSINESS]
      ,[OUTBOUNDINTEGRATIONERROR]
      ,[SOFTRAXID]
      ,[SOFTRAXCOUNTRY]
      ,[SUBINDUSTRY]
      ,[SUBREGION]
      ,[HEATID]
      ,[SFDCUNIQUEID]
      ,[ACCOUNTVALIDATED]
      ,[DEFAULTPARTNERTYPE]
      ,[SOFTRAXIDUSEDESCRIPTION]
      ,[PSSCAQUISITIONS]
      ,[EMAILDOMAIN]
      ,[SOFTRAXCURRENCY]
      ,[SECCODEID]
      ,[OWNER_LINE_OF_BUSINESS]
      ,[OWNERSUBLINEOFBUSINESS]
      ,[APACSTRATEGIC]
      ,[LOCAL_SIC_DESCRIPTION]
      ,[TOTAL_GLOBAL_EMPLOYEES]
      ,[PO_REQUIRED]
      ,[CONTRACTUALLY_NONREFERENCABLE]
      ,[IS_ANALYSTMEDIA]
      ,[IS_PSSC_COMPETITOR]
      ,[IS_PSSC_CONSULTANT]
      ,[IS_UNIVERSITY]
      ,[KEY_ACCOUNT_LINE_OF_BUSINESS]
      ,[KEY_ACCOUNT]
      ,[KEY_TARGET_ACCOUNT_LOB]
      ,[FORMERCUSTOMER]
      ,[STX_CUST_CD]
      ,[STX_CUS_GRP_CD]
      ,[STX_CUS_GRP]
      ,[STX_CUSTOMER_CATEGORY]
      ,[STX_CUSTOMER_NUMBER]
      ,[STX_FORMALIZE]
      ,[EDU_ALLIANCE_PRGM]
      ,[EUVAT_REGNUMBER]
      ,[KEYACCOUNTNOTES]
      ,[INDUSTRY_OVERRIDE]
      ,[SUBINDUSTRY_OVERRIDE]
      ,[SICCODEOVERRIDE]
      ,[KEY_ACCOUNT_DELIST_REASON]
      ,[FORMERPARTNER]
      ,[LICENSE_COMMISSIONMARGIN]
      ,[NUMBER_PSSC_CUSTOMERS]
      ,[PARTNER_GROUPS]
      ,[PARTNER_INDUSTRY_FOCUS]
      ,[PARTNER_INDUSTRY_SUB_FOCUS]
      ,[PARTNER_STATUS]
      ,[PARTNER_TYPES]
      ,[PUBLIC_SECTOR_AGREEMENT]
      ,[SELLTHROUGH_AGREEMENT]
      ,[SUPPORT_COMMISSIONMARGIN]
      ,[PUBLIC_SECTOR_TIER]
      ,[TOTAL_REVENUE_GROWTH]
      ,[ALLIANCE_PARTNER]
      ,[ENABLE_PARTNER_AUTHORIZATIONS]
      ,[SELECTION_CONSULTANT]
      ,[SIGNED_NDA]
      ,[NUMBER_OF_SIGNED_SFDC_LICENSES]
      ,[CRM_PARTNER]
      ,[AGREEMENTDATE]
      ,[ALLIANCEAGREEMENTTYPE]
      ,[ALLIANCE_PTNR_AGRMENT]
      ,[ALLIANCE_PRTNR_GRP]
      ,[ALLIANCEREGIONS]
      ,[ANCILLARYAGREEMENTS]
      ,[BUSINESSPLANDATE]
      ,[BUS_PLAN_REN_DATE]
      ,[CHANNELAGREEMENT]
      ,[CLOUDSUITECERTIFIED]
      ,[ICS_SCV_AGR_TYP]
      ,[ICS_SVC_CR_PTNR_AGRM]
      ,[ICS_SVC_PTNR_LVL]
      ,[MINORITY_FIRM]
      ,[PARTNER_PROGRAM_TYPE]
      ,[OVER60DAYSPASTDUEAR]
      ,[CREDITLIMIT]
      ,[CREDITLIMITCURRENCY]
      ,[AVAILABLECREDITLIMIT]
      ,[TOTALAR]
      ,[FISCALYEAR]
      ,[GLOBALREVENUE]
      ,[PUB_STD_ENRL]
      ,[PUB_POP]
      ,[MFG_AFTER_MKT_SVC]
      ,[MFG_AUTOMOTIVE_TIER]
      ,[MFG_NO_SITES]
      ,[MFG_OEM_CUST_SUP]
      ,[MFG_PIM_MFG_TYPE]
      ,[MFG_PRIM_SVC_TYPE]
      ,[MFG_REG_COMP_STNDS]
      ,[MFG_NO_ENGINEERS]
      ,[MFG_MANUFACTURER]
      ,[MFG_ISMFGLOC]
      ,[ICS_ACCOUNT_TYPE]
      ,[ICS_OWNER]
      ,[ICS_SEG]
      ,[ICS_REV_IND]
      ,[ICS_REV_SCTR]
      ,[ICS_REV_IND_OVREX]
      ,[ICS_REV_IND_OVR]
      ,[ICS_SLS_OWNR_OVREX]
      ,[ICS_SLS_OWNR_OVR]
      ,[HSP_HOTEL_CHAIN]
      ,[HSP_HOTEL_CODE]
      ,[HSP_MANAGEMENT]
      ,[HSP_NO_HOTELS]
      ,[HSP_NO_ROOMS]
      ,[HSP_PRICE_POINT]
      ,[HCR_NO_OF_BEDS]
      ,[HCM_ACCT_DEFN]
      ,[HCM_ACCOUNT_TIER]
      ,[GT_NEXUS_ACC_TYP]
      ,[GT_NEXUS_ACT_OPP]
      ,[GT_NEXUS_OPP_VALUE]
      ,[GT_NEXS_ACT_OID]
      ,[FAS_BUSINESS_MODEL]
      ,[FAS_MULTIBRAND]
      ,[FAS_OWN_RETAIL_STORES]
      ,[FAS_RET_SUP_TO]
      ,[FAS_NO_OF_STORES]
      ,[FAS_IS_FASH_BUS]
      ,[EQP_DEALER]
      ,[EQP_NO_OF_BRANCHES]
      ,[EQP_OEM_COMP_REP]
      ,[EQP_RENTAL]
      ,[EQP_TRD_GRP_MEMB]
      ,[EQP_SERVICE_PROVIDER]
      ,[EQP_NO_OF_WAREHOUSES]
      ,[EQP_NO_OF_TRUCKS]
      ,[FIN_INTERNATIONAL_LOCS]
      ,[FIN_MULT_LOB]
      ,[FIN_MULT_REGREPORTNEEDS]
      ,[EMEA_OPP_OWNR]
      ,[EMEA_STRAT_ACCT]
      ,[ROE_OVR]
      ,[ROE_OVR_EXPL]
      ,[NA_PUB_SECT]
      ,[LOB_OVR]
      ,[JOC_COMPANY]
      ,[APAC_NAMED_ACCT]
      ,[HOSPITALITY]
      ,[NA_MEDIA_ENTR]
      ,[NA_RETAIL]
      ,[FIN_SVCS_IN_ACCT]
      ,[NA_BANKING]
      ,[PRF_SRVC_IND_ACCT]
      ,[EMEA_STRAT_ACCT_OWNR]
      ,[ROE_LINE_OF_BUS]
      ,[CONTRACTVEHICLE]
      ,[ICS_CORE_PTNR_AGRM]
      ,[SOFTRAXMODIFIEDDATE]
      ,[SOFTRAXSTATE]
      ,[SYNCHRONIZEWITHSOFTRAX]
      ,[DATAMANAGEMENT]
      ,[HC_LIFESCIENCESELIGIBLE]
      ,[ACTIVE_ONMFGPRIMARYPRODUCT]
      ,[LOCALIZEDADDRESSLINES]
      ,[LOCALIZEDCITY]
      ,[LOCALIZEDCOUNTRY]
      ,[LOCALIZEDCOUNTY]
      ,[LOCALIZEDPOSTALCODE]
      ,[LOCALIZEDSTATE]
      ,[ACTIVEOPPCOUNT]
      ,[LASTPURCHASEDATE]
      ,[KEYACCOUNTPROSPECTREP]
      ,[ACCTPLANCLDEXECSPONSOR]
      ,[ACCTPLANCLDCUSTOMEREXEC]
      ,[ACCTPLANCLDFEEDBACK2SPONSOR]
      ,[ACCTPLANCLDROADBLOCKS]
      ,[ACCTPLANCLDCUSTOMERSTATUS]
      ,[ACCTPLANCLDLICENSEGMID]
      ,[ACCTPLANCLDSDMID]
      ,[ACCTPLANCLDCSMID]
      ,[ACCTPLANCLDPRODUCTS]
      ,[ACCTPLANCLDACV]
      ,[ACCTPLANCLDTARGETDATE]
      ,[ACCTPLANCLDMEETCADESTFLG]
      ,[ACCTPLANCLDINITIALCONTFLG]
      ,[ACCTPLANCLDWAVE1FLG]
      ,[ACCOUNTCOMPETITOR1NAME]
      ,[ACCOUNTCOMPETITOR2NAME]
      ,[SUBSCRIPTIONSTATUS]
      ,[ACCTPLANGOALSOBJFD2]
      ,[ACCTPLANBUSSEGMENTS1]
      ,[ACCTPLANREGPRECOVERAGE1]
      ,[ACCTPLANANNUALREVENUE1]
      ,[ACCTPLANCURYEARPERFTREND1]
      ,[ACCTPLANMAJORPSSCSOLFP1]
      ,[ACCTPLANMAJORCOMPSOLFP1]
      ,[ACCTPLANGOALSOBJFD1]
      ,[ACCTPLANBUSSEGMENTS2]
      ,[ACCTPLANREGPRECOVERAGE2]
      ,[ACCTPLANANNUALREVENUE2]
      ,[ACCTPLANCURYEARPERFTREND2]
      ,[ACCTPLANMAJORPSSCSOLFP2]
      ,[ACCTPLANMAJORCOMPSOLFP2]
      ,[SUBSCRIPTIONMAINTSTATUS]
      ,[ACCTPLANCLDWAVE2FLG]
      ,[ACCTPLANCLDFIELDREFSTATUS]
      ,[PREVIOUSYEARGLOBALREVENUE]
      ,[UNIQUEID]
      ,[ACCTPLANMANAGERSIGNOFF]
      ,[ACCOUNTPLANREQUIREDSERVICES]
      ,[ACCOUNTPLANREQUIREDLICENSE]
      ,[ACCOUNTPLANLASTMODIFEDUSER]
      ,[ACCOUNTPLANLASTMODIFIED]
      ,[ACCOUNTPLANSIGNOFFMANAGER]
      ,[ACCOUNTPLANSIGNOFFMGRSERVICE]
      ,[ACCOUNTPLANSIGNOFFMGRSERVICEDATE]
      ,[PARTNERREPMAILONOPINFLUENCE]
      ,[ACTIVEONSRVPRIMARYPRODUCT]
      ,[PRIMARYPARTNERID]
      ,[ISPRIMARYDUPMASTERACCOUNT]
      ,[PRIMARYDUPMASTERACCOUNTID]
      ,[ALLOWUPDATEONDUPLICATE]
      ,[PRIMARYPARTNERNAME]
      ,[HEALTHCARESEGMENTATION]
      ,[GTNSAM]
      ,[GTNBDM]
      ,[GTNGAM]
      ,[GTNSC]
      ,[UPGRADEXISTARGET]
      ,[UPGRADEXCURPRIMARYPRODUCT]
      ,[UPGRADEXCURRELEASEINUSE]
      ,[UPGRADEXUPGRADESTATUS]
      ,[UPGRADEXSTARTYEAR]
      ,[UPGRADEXUPGRADECOMMENTS]
      ,[UPGRADEXDEPLOYMENTPREF]
      ,[SREXECSPONSORACCOUNT]
      ,[SREXECUTIVESPONSOR]
      ,[VPSPONSOR]
      ,[CUSTOMEREXECUTIVESPONSOR]
      ,[CUSTOMERROADMAPCOMPLETE]
      ,[CUSTOMER360REVCOMPLETE]
      ,[CUSTOMER360REVCOMPLETEDATE]
      ,[CUSTOMERROADMAPCOMPLETEDATE]
      ,[CUSTOMERBIANNUALMTGDATE]
      ,[EXECSPONSORCLIENTSTATUS]
      ,[EXECSPONSORATRISKREASON]
      ,[EXECSPONSORSTRESSEDREASON]
      ,[EXECSPONSORADVOCATETYPE]
      ,[EXECSPONSORPRODUCTLINE]
      ,[EXECSPONSORPOTENTIALISSUES]
      ,[EXECSPONSORREQUIRED]
FROM [' + @database + '].[sysdba].[PSSCACCOUNT] WITH (NOLOCK)
WHERE COALESCE(ModifyDate, getdate())  >= ''''' + convert(varchar(50), @min_date) + '''''



'' ) source'



--Insert the set of changed records into dbo.CRM_PSSCACCOUNT
INSERT INTO dbo.XA_CRM_PSSCACCOUNT1
(
   [BI_load_date]
      ,[sourcesystem_id]
      ,[ACCOUNTID]
      ,[CREATEUSER]
      ,[CREATEDATE]
      ,[MODIFYUSER]
      ,[MODIFYDATE]
      ,[SALESFORCEID]
      ,[ISDELETED]
      ,[DELETEDDATE]
      ,[PHOTOURL]
      ,[ISPARTNERPORTALAUTHROIZED]
      ,[ALLIANCEAGREEMENT]
      ,[ALLIANCETYPE]
      ,[AUDITINGINPROGRESS]
      ,[ACCOUNTCLASS]
      ,[IPNPARTNERCHANNELTIER]
      ,[LASTACTIVITYDATE]
      ,[LASTCALLACTIVITYDATE]
      ,[DECISIONLOCATION]
      ,[FORMALIZATIONDATE]
      ,[NAHEALTHCARE]
      ,[INBOUNDINTEGRATIONERROR]
      ,[LASTDATEVERIFIED]
      ,[MAINTENANCESTATUS]
      ,[HCMTEAMCOMMENTS]
      ,[OUTOFBUSINESS]
      ,[OUTBOUNDINTEGRATIONERROR]
      ,[SOFTRAXID]
      ,[SOFTRAXCOUNTRY]
      ,[SUBINDUSTRY]
      ,[SUBREGION]
      ,[HEATID]
      ,[SFDCUNIQUEID]
      ,[ACCOUNTVALIDATED]
      ,[DEFAULTPARTNERTYPE]
      ,[SOFTRAXIDUSEDESCRIPTION]
      ,[PSSCAQUISITIONS]
      ,[EMAILDOMAIN]
      ,[SOFTRAXCURRENCY]
      ,[SECCODEID]
      ,[OWNER_LINE_OF_BUSINESS]
      ,[OWNERSUBLINEOFBUSINESS]
      ,[APACSTRATEGIC]
      ,[LOCAL_SIC_DESCRIPTION]
      ,[TOTAL_GLOBAL_EMPLOYEES]
      ,[PO_REQUIRED]
      ,[CONTRACTUALLY_NONREFERENCABLE]
      ,[IS_ANALYSTMEDIA]
      ,[IS_PSSC_COMPETITOR]
      ,[IS_PSSC_CONSULTANT]
      ,[IS_UNIVERSITY]
      ,[KEY_ACCOUNT_LINE_OF_BUSINESS]
      ,[KEY_ACCOUNT]
      ,[KEY_TARGET_ACCOUNT_LOB]
      ,[FORMERCUSTOMER]
      ,[STX_CUST_CD]
      ,[STX_CUS_GRP_CD]
      ,[STX_CUS_GRP]
      ,[STX_CUSTOMER_CATEGORY]
      ,[STX_CUSTOMER_NUMBER]
      ,[STX_FORMALIZE]
      ,[EDU_ALLIANCE_PRGM]
      ,[EUVAT_REGNUMBER]
      ,[KEYACCOUNTNOTES]
      ,[INDUSTRY_OVERRIDE]
      ,[SUBINDUSTRY_OVERRIDE]
      ,[SICCODEOVERRIDE]
      ,[KEY_ACCOUNT_DELIST_REASON]
      ,[FORMERPARTNER]
      ,[LICENSE_COMMISSIONMARGIN]
      ,[NUMBER_PSSC_CUSTOMERS]
      ,[PARTNER_GROUPS]
      ,[PARTNER_INDUSTRY_FOCUS]
      ,[PARTNER_INDUSTRY_SUB_FOCUS]
      ,[PARTNER_STATUS]
      ,[PARTNER_TYPES]
      ,[PUBLIC_SECTOR_AGREEMENT]
      ,[SELLTHROUGH_AGREEMENT]
      ,[SUPPORT_COMMISSIONMARGIN]
      ,[PUBLIC_SECTOR_TIER]
      ,[TOTAL_REVENUE_GROWTH]
      ,[ALLIANCE_PARTNER]
      ,[ENABLE_PARTNER_AUTHORIZATIONS]
      ,[SELECTION_CONSULTANT]
      ,[SIGNED_NDA]
      ,[NUMBER_OF_SIGNED_SFDC_LICENSES]
      ,[CRM_PARTNER]
      ,[AGREEMENTDATE]
      ,[ALLIANCEAGREEMENTTYPE]
      ,[ALLIANCE_PTNR_AGRMENT]
      ,[ALLIANCE_PRTNR_GRP]
      ,[ALLIANCEREGIONS]
      ,[ANCILLARYAGREEMENTS]
      ,[BUSINESSPLANDATE]
      ,[BUS_PLAN_REN_DATE]
      ,[CHANNELAGREEMENT]
      ,[CLOUDSUITECERTIFIED]
      ,[ICS_SCV_AGR_TYP]
      ,[ICS_SVC_CR_PTNR_AGRM]
      ,[ICS_SVC_PTNR_LVL]
      ,[MINORITY_FIRM]
      ,[PARTNER_PROGRAM_TYPE]
      ,[OVER60DAYSPASTDUEAR]
      ,[CREDITLIMIT]
      ,[CREDITLIMITCURRENCY]
      ,[AVAILABLECREDITLIMIT]
      ,[TOTALAR]
      ,[FISCALYEAR]
      ,[GLOBALREVENUE]
      ,[PUB_STD_ENRL]
      ,[PUB_POP]
      ,[MFG_AFTER_MKT_SVC]
      ,[MFG_AUTOMOTIVE_TIER]
      ,[MFG_NO_SITES]
      ,[MFG_OEM_CUST_SUP]
      ,[MFG_PIM_MFG_TYPE]
      ,[MFG_PRIM_SVC_TYPE]
      ,[MFG_REG_COMP_STNDS]
      ,[MFG_NO_ENGINEERS]
      ,[MFG_MANUFACTURER]
      ,[MFG_ISMFGLOC]
      ,[ICS_ACCOUNT_TYPE]
      ,[ICS_OWNER]
      ,[ICS_SEG]
      ,[ICS_REV_IND]
      ,[ICS_REV_SCTR]
      ,[ICS_REV_IND_OVREX]
      ,[ICS_REV_IND_OVR]
      ,[ICS_SLS_OWNR_OVREX]
      ,[ICS_SLS_OWNR_OVR]
      ,[HSP_HOTEL_CHAIN]
      ,[HSP_HOTEL_CODE]
      ,[HSP_MANAGEMENT]
      ,[HSP_NO_HOTELS]
      ,[HSP_NO_ROOMS]
      ,[HSP_PRICE_POINT]
      ,[HCR_NO_OF_BEDS]
      ,[HCM_ACCT_DEFN]
      ,[HCM_ACCOUNT_TIER]
      ,[GT_NEXUS_ACC_TYP]
      ,[GT_NEXUS_ACT_OPP]
      ,[GT_NEXUS_OPP_VALUE]
      ,[GT_NEXS_ACT_OID]
      ,[FAS_BUSINESS_MODEL]
      ,[FAS_MULTIBRAND]
      ,[FAS_OWN_RETAIL_STORES]
      ,[FAS_RET_SUP_TO]
      ,[FAS_NO_OF_STORES]
      ,[FAS_IS_FASH_BUS]
      ,[EQP_DEALER]
      ,[EQP_NO_OF_BRANCHES]
      ,[EQP_OEM_COMP_REP]
      ,[EQP_RENTAL]
      ,[EQP_TRD_GRP_MEMB]
      ,[EQP_SERVICE_PROVIDER]
      ,[EQP_NO_OF_WAREHOUSES]
      ,[EQP_NO_OF_TRUCKS]
      ,[FIN_INTERNATIONAL_LOCS]
      ,[FIN_MULT_LOB]
      ,[FIN_MULT_REGREPORTNEEDS]
      ,[EMEA_OPP_OWNR]
      ,[EMEA_STRAT_ACCT]
      ,[ROE_OVR]
      ,[ROE_OVR_EXPL]
      ,[NA_PUB_SECT]
      ,[LOB_OVR]
      ,[JOC_COMPANY]
      ,[APAC_NAMED_ACCT]
      ,[HOSPITALITY]
      ,[NA_MEDIA_ENTR]
      ,[NA_RETAIL]
      ,[FIN_SVCS_IN_ACCT]
      ,[NA_BANKING]
      ,[PRF_SRVC_IND_ACCT]
      ,[EMEA_STRAT_ACCT_OWNR]
      ,[ROE_LINE_OF_BUS]
      ,[CONTRACTVEHICLE]
      ,[ICS_CORE_PTNR_AGRM]
      ,[SOFTRAXMODIFIEDDATE]
      ,[SOFTRAXSTATE]
      ,[SYNCHRONIZEWITHSOFTRAX]
      ,[DATAMANAGEMENT]
      ,[HC_LIFESCIENCESELIGIBLE]
      ,[ACTIVE_ONMFGPRIMARYPRODUCT]
      ,[LOCALIZEDADDRESSLINES]
      ,[LOCALIZEDCITY]
      ,[LOCALIZEDCOUNTRY]
      ,[LOCALIZEDCOUNTY]
      ,[LOCALIZEDPOSTALCODE]
      ,[LOCALIZEDSTATE]
      ,[ACTIVEOPPCOUNT]
      ,[LASTPURCHASEDATE]
      ,[KEYACCOUNTPROSPECTREP]
      ,[ACCTPLANCLDEXECSPONSOR]
      ,[ACCTPLANCLDCUSTOMEREXEC]
      ,[ACCTPLANCLDFEEDBACK2SPONSOR]
      ,[ACCTPLANCLDROADBLOCKS]
      ,[ACCTPLANCLDCUSTOMERSTATUS]
      ,[ACCTPLANCLDLICENSEGMID]
      ,[ACCTPLANCLDSDMID]
      ,[ACCTPLANCLDCSMID]
      ,[ACCTPLANCLDPRODUCTS]
      ,[ACCTPLANCLDACV]
      ,[ACCTPLANCLDTARGETDATE]
      ,[ACCTPLANCLDMEETCADESTFLG]
      ,[ACCTPLANCLDINITIALCONTFLG]
      ,[ACCTPLANCLDWAVE1FLG]
      ,[ACCOUNTCOMPETITOR1NAME]
      ,[ACCOUNTCOMPETITOR2NAME]
      ,[SUBSCRIPTIONSTATUS]
      ,[ACCTPLANGOALSOBJFD2]
      ,[ACCTPLANBUSSEGMENTS1]
      ,[ACCTPLANREGPRECOVERAGE1]
      ,[ACCTPLANANNUALREVENUE1]
      ,[ACCTPLANCURYEARPERFTREND1]
      ,[ACCTPLANMAJORPSSCSOLFP1]
      ,[ACCTPLANMAJORCOMPSOLFP1]
      ,[ACCTPLANGOALSOBJFD1]
      ,[ACCTPLANBUSSEGMENTS2]
      ,[ACCTPLANREGPRECOVERAGE2]
      ,[ACCTPLANANNUALREVENUE2]
      ,[ACCTPLANCURYEARPERFTREND2]
      ,[ACCTPLANMAJORPSSCSOLFP2]
      ,[ACCTPLANMAJORCOMPSOLFP2]
      ,[SUBSCRIPTIONMAINTSTATUS]
      ,[ACCTPLANCLDWAVE2FLG]
      ,[ACCTPLANCLDFIELDREFSTATUS]
      ,[PREVIOUSYEARGLOBALREVENUE]
      ,[UNIQUEID]
      ,[ACCTPLANMANAGERSIGNOFF]
      ,[ACCOUNTPLANREQUIREDSERVICES]
      ,[ACCOUNTPLANREQUIREDLICENSE]
      ,[ACCOUNTPLANLASTMODIFEDUSER]
      ,[ACCOUNTPLANLASTMODIFIED]
      ,[ACCOUNTPLANSIGNOFFMANAGER]
      ,[ACCOUNTPLANSIGNOFFMGRSERVICE]
      ,[ACCOUNTPLANSIGNOFFMGRSERVICEDATE]
      ,[PARTNERREPMAILONOPINFLUENCE]
      ,[ACTIVEONSRVPRIMARYPRODUCT]
      ,[PRIMARYPARTNERID]
      ,[ISPRIMARYDUPMASTERACCOUNT]
      ,[PRIMARYDUPMASTERACCOUNTID]
      ,[ALLOWUPDATEONDUPLICATE]
      ,[PRIMARYPARTNERNAME]
      ,[HEALTHCARESEGMENTATION]
      ,[GTNSAM]
      ,[GTNBDM]
      ,[GTNGAM]
      ,[GTNSC]
      ,[UPGRADEXISTARGET]
      ,[UPGRADEXCURPRIMARYPRODUCT]
      ,[UPGRADEXCURRELEASEINUSE]
      ,[UPGRADEXUPGRADESTATUS]
      ,[UPGRADEXSTARTYEAR]
      ,[UPGRADEXUPGRADECOMMENTS]
      ,[UPGRADEXDEPLOYMENTPREF]
      ,[SREXECSPONSORACCOUNT]
      ,[SREXECUTIVESPONSOR]
      ,[VPSPONSOR]
      ,[CUSTOMEREXECUTIVESPONSOR]
      ,[CUSTOMERROADMAPCOMPLETE]
      ,[CUSTOMER360REVCOMPLETE]
      ,[CUSTOMER360REVCOMPLETEDATE]
      ,[CUSTOMERROADMAPCOMPLETEDATE]
      ,[CUSTOMERBIANNUALMTGDATE]
      ,[EXECSPONSORCLIENTSTATUS]
      ,[EXECSPONSORATRISKREASON]
      ,[EXECSPONSORSTRESSEDREASON]
      ,[EXECSPONSORADVOCATETYPE]
      ,[EXECSPONSORPRODUCTLINE]
      ,[EXECSPONSORPOTENTIALISSUES]
      ,[EXECSPONSORREQUIRED]
 )
EXECUTE (@cmd)


SET  @rowcount = @@ROWCOUNT
SET  @countDelta = @rowcount

EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount





--Delete records no longer in the source system


SET  @message  = 'Clear Records in EDW_STAGE'
SET  @type   = 'DELETE'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

DELETE FROM base
 FROM dbo.CRM_PSSCACCOUNT1 base WITH (NOLOCK)
 INNER JOIN dbo.XD_CRM_PSSCACCOUNT1 keys WITH (NOLOCK)
  ON base.[ACCOUNTID] = keys.[ACCOUNTID]
  AND keys.sourcesystem_id  = base.sourcesystem_id
  AND keys.sourcesystem_id  = @sourcesystem_id


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @@ROWCOUNT


SET  @message  = 'Clear Records in EDW_STAGE'
SET  @type   = 'DELETE'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

DELETE FROM base
 FROM dbo.CRM_PSSCACCOUNT1 base WITH (NOLOCK)
 INNER JOIN dbo.XA_CRM_PSSCACCOUNT1 keys WITH (NOLOCK)
  ON base.[ACCOUNTID] = keys.[ACCOUNTID]
  AND keys.sourcesystem_id  = base.sourcesystem_id
  AND keys.sourcesystem_id  = @sourcesystem_id


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @@ROWCOUNT


--Update the load_date for all reamining records


SET  @message  = 'LOAD DATE ON EDW_STAGE'
SET  @type   = 'UPDATE'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

--UPDATE dbo.CRM_PSSCACCOUNT
--SET  load_date  = @load_date
--WHERE load_date  != @load_date


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @@ROWCOUNT


--Insert the records from the delta table


SET  @message  = 'New Records in EDW_STAGE'
SET  @type   = 'INSERT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

INSERT INTO dbo.CRM_PSSCACCOUNT1
SELECT new_recs.*
FROM dbo.XA_CRM_PSSCACCOUNT1 new_recs WITH (NOLOCK)
--WHERE load_date  = @load_date
--AND new_recs.sourcesystem_id  = @sourcesystem_id

SET  @rowcount=@@ROWCOUNT

EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

-- Get a count of records in the EDW_STAGE table
SET  @message  = 'Count Records in EDW_STAGE'
SET  @type   = 'COUNT'
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , 0

SELECT @countDest  = count(*)
FROM dbo.CRM_PSSCACCOUNT1 WITH (NOLOCK)
WHERE sourcesystem_id  = @sourcesystem_id

EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @countDest



-- Section to catch any missing records (in the event of an empty table or gap in loading times )
/******************************************************************************************************************************/


SET  @message  = 'ADD Missing Records'
SET  @type   = 'INSERT'
SET  @rowcount  = 0
EXEC @log_step = dbo.logProcessActivity
        @log_step
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount


IF @countSource  > @countDest
BEGIN --Add Missing Records

   SET  @rowcount = 0

   SET  @message  = 'Discover Missing Records'
   SET  @type   = 'INSERT'
   SET  @rowcount  = 0
   EXEC @log_value = dbo.logProcessActivity
           @log_value
         , @proc_name
         , @step_name
         , @message
         , @type
         , @rowcount




   EXEC @log_value = dbo.logProcessActivity
           @log_value
         , @proc_name
         , @step_name
         , @message
         , @type
         , @rowcount


   SET  @message  = 'Add Missing Records in EDW_STAGE'
   SET  @type   = 'INSERT'
   SET  @rowcount  = 0
   EXEC @log_value = dbo.logProcessActivity
           @log_value
         , @proc_name
         , @step_name
         , @message
         , @type
         , @rowcount


   BEGIN

    -- Insert anything new into the EXT OP table that's come up

   SET  @cmd = 'SELECT BI_Load_Date = ''' + convert(varchar(20), @load_date) + '''
  , sourcesystem_id  = ''' + convert(varchar(20), @sourcesystem_id) + '''
  , source.*
   FROM OPENQUERY( ' + @server + ', ''SELECT
         [ACCOUNTID]  = LEFT(LTRIM(RTRIM([ACCOUNTID])),12)
         , [CREATEUSER]  = LEFT(LTRIM(RTRIM([CREATEUSER])),12)
         , [CREATEDATE]  
         , [MODIFYUSER]  = LEFT(LTRIM(RTRIM([MODIFYUSER])),12)
         , [MODIFYDATE]  
         , [SALESFORCEID]  = LEFT(LTRIM(RTRIM([SALESFORCEID])),48)
         , [ISDELETED]  = LEFT(LTRIM(RTRIM([ISDELETED])),1)
         , [DELETEDDATE]  
         , [PHOTOURL]  = LEFT(LTRIM(RTRIM([PHOTOURL])),128)
         , [ISPARTNERPORTALAUTHROIZED]  = LEFT(LTRIM(RTRIM([ISPARTNERPORTALAUTHROIZED])),1)
         , [ALLIANCEAGREEMENT]  = LEFT(LTRIM(RTRIM([ALLIANCEAGREEMENT])),64)
         , [ALLIANCETYPE]  = LEFT(LTRIM(RTRIM([ALLIANCETYPE])),64)
         , [AUDITINGINPROGRESS]  = LEFT(LTRIM(RTRIM([AUDITINGINPROGRESS])),1)
         , [ACCOUNTCLASS]  = LEFT(LTRIM(RTRIM([ACCOUNTCLASS])),64)
         , [IPNPARTNERCHANNELTIER]  = LEFT(LTRIM(RTRIM([IPNPARTNERCHANNELTIER])),64)
         , [LASTACTIVITYDATE]  
         , [LASTCALLACTIVITYDATE]  
         , [DECISIONLOCATION]  = LEFT(LTRIM(RTRIM([DECISIONLOCATION])),1)
         , [FORMALIZATIONDATE]  
         , [NAHEALTHCARE]  = LEFT(LTRIM(RTRIM([NAHEALTHCARE])),1)
         , [INBOUNDINTEGRATIONERROR]  
         , [LASTDATEVERIFIED]  
         , [MAINTENANCESTATUS]  = LEFT(LTRIM(RTRIM([MAINTENANCESTATUS])),64)
         , [HCMTEAMCOMMENTS]  = LEFT(LTRIM(RTRIM([HCMTEAMCOMMENTS])),1000)
         , [OUTOFBUSINESS]  = LEFT(LTRIM(RTRIM([OUTOFBUSINESS])),1)
         , [OUTBOUNDINTEGRATIONERROR]  
         , [SOFTRAXID]  = LEFT(LTRIM(RTRIM([SOFTRAXID])),25)
         , [SOFTRAXCOUNTRY]  = LEFT(LTRIM(RTRIM([SOFTRAXCOUNTRY])),3)
         , [SUBINDUSTRY]  = LEFT(LTRIM(RTRIM([SUBINDUSTRY])),150)
         , [SUBREGION]  = LEFT(LTRIM(RTRIM([SUBREGION])),150)
         , [HEATID]  = LEFT(LTRIM(RTRIM([HEATID])),255)
         , [SFDCUNIQUEID]  = LEFT(LTRIM(RTRIM([SFDCUNIQUEID])),30)
         , [ACCOUNTVALIDATED]  = LEFT(LTRIM(RTRIM([ACCOUNTVALIDATED])),1)
         , [DEFAULTPARTNERTYPE]  = LEFT(LTRIM(RTRIM([DEFAULTPARTNERTYPE])),64)
         , [SOFTRAXIDUSEDESCRIPTION]  = LEFT(LTRIM(RTRIM([SOFTRAXIDUSEDESCRIPTION])),255)
         , [PSSCAQUISITIONS]  
         , [EMAILDOMAIN]  = LEFT(LTRIM(RTRIM([EMAILDOMAIN])),255)
         , [SOFTRAXCURRENCY]  = LEFT(LTRIM(RTRIM([SOFTRAXCURRENCY])),3)
         , [SECCODEID]  = LEFT(LTRIM(RTRIM([SECCODEID])),12)
         , [OWNER_LINE_OF_BUSINESS]  = LEFT(LTRIM(RTRIM([OWNER_LINE_OF_BUSINESS])),1300)
         , [OWNERSUBLINEOFBUSINESS]  = LEFT(LTRIM(RTRIM([OWNERSUBLINEOFBUSINESS])),1300)
         , [APACSTRATEGIC]  = LEFT(LTRIM(RTRIM([APACSTRATEGIC])),1)
         , [LOCAL_SIC_DESCRIPTION]  = LEFT(LTRIM(RTRIM([LOCAL_SIC_DESCRIPTION])),255)
         , [TOTAL_GLOBAL_EMPLOYEES]  
         , [PO_REQUIRED]  = LEFT(LTRIM(RTRIM([PO_REQUIRED])),1)
         , [CONTRACTUALLY_NONREFERENCABLE]  = LEFT(LTRIM(RTRIM([CONTRACTUALLY_NONREFERENCABLE])),1)
         , [IS_ANALYSTMEDIA]  = LEFT(LTRIM(RTRIM([IS_ANALYSTMEDIA])),1)
         , [IS_PSSC_COMPETITOR]  = LEFT(LTRIM(RTRIM([IS_PSSC_COMPETITOR])),1)
         , [IS_PSSC_CONSULTANT]  = LEFT(LTRIM(RTRIM([IS_PSSC_CONSULTANT])),1)
         , [IS_UNIVERSITY]  = LEFT(LTRIM(RTRIM([IS_UNIVERSITY])),1)
         , [KEY_ACCOUNT_LINE_OF_BUSINESS]  = LEFT(LTRIM(RTRIM([KEY_ACCOUNT_LINE_OF_BUSINESS])),255)
         , [KEY_ACCOUNT]  = LEFT(LTRIM(RTRIM([KEY_ACCOUNT])),1)
         , [KEY_TARGET_ACCOUNT_LOB]  = LEFT(LTRIM(RTRIM([KEY_TARGET_ACCOUNT_LOB])),255)
         , [FORMERCUSTOMER]  = LEFT(LTRIM(RTRIM([FORMERCUSTOMER])),1)
         , [PRIMARY_INSIDE_SALES_REPID]  = LEFT(LTRIM(RTRIM([PRIMARY_INSIDE_SALES_REPID])),12)
         , [STX_CUST_CD]  = LEFT(LTRIM(RTRIM([STX_CUST_CD])),10)
         , [STX_CUS_GRP_CD]  = LEFT(LTRIM(RTRIM([STX_CUS_GRP_CD])),6)
         , [STX_CUS_GRP]  = LEFT(LTRIM(RTRIM([STX_CUS_GRP])),6)
         , [STX_CUSTOMER_CATEGORY]  = LEFT(LTRIM(RTRIM([STX_CUSTOMER_CATEGORY])),1300)
         , [STX_CUSTOMER_NUMBER]  = LEFT(LTRIM(RTRIM([STX_CUSTOMER_NUMBER])),30)
         , [STX_FORMALIZE]  = LEFT(LTRIM(RTRIM([STX_FORMALIZE])),1)
         , [EDU_ALLIANCE_PRGM]  = LEFT(LTRIM(RTRIM([EDU_ALLIANCE_PRGM])),64)
         , [EUVAT_REGNUMBER]  = LEFT(LTRIM(RTRIM([EUVAT_REGNUMBER])),50)
         , [KEYACCOUNTNOTES]  
         , [INDUSTRY_OVERRIDE]  = LEFT(LTRIM(RTRIM([INDUSTRY_OVERRIDE])),150)
         , [SUBINDUSTRY_OVERRIDE]  = LEFT(LTRIM(RTRIM([SUBINDUSTRY_OVERRIDE])),150)
         , [SICCODEOVERRIDE]  = LEFT(LTRIM(RTRIM([SICCODEOVERRIDE])),12)
         , [KEY_ACCOUNT_DELIST_REASON]  = LEFT(LTRIM(RTRIM([KEY_ACCOUNT_DELIST_REASON])),255)
         , [FORMERPARTNER]  = LEFT(LTRIM(RTRIM([FORMERPARTNER])),1)
         , [LICENSE_COMMISSIONMARGIN]  
         , [NUMBER_PSSC_CUSTOMERS]  
         , [PARTNER_GROUPS]  
         , [PARTNER_INDUSTRY_FOCUS]  = LEFT(LTRIM(RTRIM([PARTNER_INDUSTRY_FOCUS])),50)
         , [PARTNER_INDUSTRY_SUB_FOCUS]  = LEFT(LTRIM(RTRIM([PARTNER_INDUSTRY_SUB_FOCUS])),50)
         , [PARTNER_STATUS]  = LEFT(LTRIM(RTRIM([PARTNER_STATUS])),100)
         , [PARTNER_TYPES]  
         , [PUBLIC_SECTOR_AGREEMENT]  = LEFT(LTRIM(RTRIM([PUBLIC_SECTOR_AGREEMENT])),255)
         , [SELLTHROUGH_AGREEMENT]  = LEFT(LTRIM(RTRIM([SELLTHROUGH_AGREEMENT])),255)
         , [SUPPORT_COMMISSIONMARGIN]  
         , [PUBLIC_SECTOR_TIER]  = LEFT(LTRIM(RTRIM([PUBLIC_SECTOR_TIER])),255)
         , [TOTAL_REVENUE_GROWTH]  
         , [ALLIANCE_PARTNER]  = LEFT(LTRIM(RTRIM([ALLIANCE_PARTNER])),1)
         , [ENABLE_PARTNER_AUTHORIZATIONS]  = LEFT(LTRIM(RTRIM([ENABLE_PARTNER_AUTHORIZATIONS])),1)
         , [SELECTION_CONSULTANT]  = LEFT(LTRIM(RTRIM([SELECTION_CONSULTANT])),1)
         , [SIGNED_NDA]  = LEFT(LTRIM(RTRIM([SIGNED_NDA])),1)
         , [NUMBER_OF_SIGNED_SFDC_LICENSES]  
         , [CRM_PARTNER]  = LEFT(LTRIM(RTRIM([CRM_PARTNER])),1)
         , [AGREEMENTDATE]  
         , [ALLIANCEAGREEMENTTYPE]  = LEFT(LTRIM(RTRIM([ALLIANCEAGREEMENTTYPE])),64)
         , [ALLIANCE_PTNR_AGRMENT]  = LEFT(LTRIM(RTRIM([ALLIANCE_PTNR_AGRMENT])),64)
         , [ALLIANCE_PRTNR_GRP]  = LEFT(LTRIM(RTRIM([ALLIANCE_PRTNR_GRP])),64)
         , [ALLIANCEREGIONS]  = LEFT(LTRIM(RTRIM([ALLIANCEREGIONS])),255)
         , [ANCILLARYAGREEMENTS]  = LEFT(LTRIM(RTRIM([ANCILLARYAGREEMENTS])),255)
         , [BUSINESSPLANDATE]  
         , [BUS_PLAN_REN_DATE]  
         , [CHANNELAGREEMENT]  = LEFT(LTRIM(RTRIM([CHANNELAGREEMENT])),64)
         , [CLOUDSUITECERTIFIED]  = LEFT(LTRIM(RTRIM([CLOUDSUITECERTIFIED])),64)
         , [ICS_SCV_AGR_TYP]  = LEFT(LTRIM(RTRIM([ICS_SCV_AGR_TYP])),64)
         , [ICS_SVC_CR_PTNR_AGRM]  = LEFT(LTRIM(RTRIM([ICS_SVC_CR_PTNR_AGRM])),64)
         , [ICS_SVC_PTNR_LVL]  = LEFT(LTRIM(RTRIM([ICS_SVC_PTNR_LVL])),64)
         , [MINORITY_FIRM]  = LEFT(LTRIM(RTRIM([MINORITY_FIRM])),64)
         , [PARTNER_PROGRAM_TYPE]  = LEFT(LTRIM(RTRIM([PARTNER_PROGRAM_TYPE])),64)
         , [OVER60DAYSPASTDUEAR]  
         , [CREDITLIMIT]  
         , [CREDITLIMITCURRENCY]  = LEFT(LTRIM(RTRIM([CREDITLIMITCURRENCY])),25)
         , [AVAILABLECREDITLIMIT]  
         , [TOTALAR]  
         , [FISCALYEAR]  = LEFT(LTRIM(RTRIM([FISCALYEAR])),25)
         , [GLOBALREVENUE]  
         , [PUB_STD_ENRL]  
         , [PUB_POP]  
         , [MFG_AFTER_MKT_SVC]  = LEFT(LTRIM(RTRIM([MFG_AFTER_MKT_SVC])),1)
         , [MFG_AUTOMOTIVE_TIER]  = LEFT(LTRIM(RTRIM([MFG_AUTOMOTIVE_TIER])),255)
         , [MFG_NO_SITES]  
         , [MFG_OEM_CUST_SUP]  
         , [MFG_PIM_MFG_TYPE]  = LEFT(LTRIM(RTRIM([MFG_PIM_MFG_TYPE])),255)
         , [MFG_PRIM_SVC_TYPE]  = LEFT(LTRIM(RTRIM([MFG_PRIM_SVC_TYPE])),255)
         , [MFG_REG_COMP_STNDS]  
         , [MFG_NO_ENGINEERS]  
         , [MFG_MANUFACTURER]  = LEFT(LTRIM(RTRIM([MFG_MANUFACTURER])),255)
         , [MFG_ISMFGLOC]  = LEFT(LTRIM(RTRIM([MFG_ISMFGLOC])),1)
         , [ICS_ACCOUNT_TYPE]  = LEFT(LTRIM(RTRIM([ICS_ACCOUNT_TYPE])),255)
         , [ICS_OWNER]  = LEFT(LTRIM(RTRIM([ICS_OWNER])),12)
         , [ICS_SEG]  = LEFT(LTRIM(RTRIM([ICS_SEG])),255)
         , [ICS_REV_IND]  = LEFT(LTRIM(RTRIM([ICS_REV_IND])),255)
         , [ICS_REV_SCTR]  = LEFT(LTRIM(RTRIM([ICS_REV_SCTR])),255)
         , [ICS_REV_IND_OVREX]  = LEFT(LTRIM(RTRIM([ICS_REV_IND_OVREX])),500)
         , [ICS_REV_IND_OVR]  = LEFT(LTRIM(RTRIM([ICS_REV_IND_OVR])),1)
         , [ICS_SLS_OWNR_OVREX]  = LEFT(LTRIM(RTRIM([ICS_SLS_OWNR_OVREX])),500)
         , [ICS_SLS_OWNR_OVR]  = LEFT(LTRIM(RTRIM([ICS_SLS_OWNR_OVR])),1)
         , [HSP_HOTEL_CHAIN]  = LEFT(LTRIM(RTRIM([HSP_HOTEL_CHAIN])),255)
         , [HSP_HOTEL_CODE]  = LEFT(LTRIM(RTRIM([HSP_HOTEL_CODE])),255)
         , [HSP_MANAGEMENT]  = LEFT(LTRIM(RTRIM([HSP_MANAGEMENT])),255)
         , [HSP_NO_HOTELS]  
         , [HSP_NO_ROOMS]  
         , [HSP_PRICE_POINT]  = LEFT(LTRIM(RTRIM([HSP_PRICE_POINT])),255)
         , [HCR_NO_OF_BEDS]  
         , [HCM_ACCT_DEFN]  = LEFT(LTRIM(RTRIM([HCM_ACCT_DEFN])),1000)
         , [HCM_ACCOUNT_TIER]  = LEFT(LTRIM(RTRIM([HCM_ACCOUNT_TIER])),255)
         , [GT_NEXUS_ACC_TYP]  = LEFT(LTRIM(RTRIM([GT_NEXUS_ACC_TYP])),255)
         , [GT_NEXUS_ACT_OPP]  = LEFT(LTRIM(RTRIM([GT_NEXUS_ACT_OPP])),1)
         , [GT_NEXUS_OPP_VALUE]  
         , [GT_NEXS_ACT_OID]  = LEFT(LTRIM(RTRIM([GT_NEXS_ACT_OID])),12)
         , [FAS_BUSINESS_MODEL]  = LEFT(LTRIM(RTRIM([FAS_BUSINESS_MODEL])),255)
         , [FAS_MULTIBRAND]  = LEFT(LTRIM(RTRIM([FAS_MULTIBRAND])),1)
         , [FAS_OWN_RETAIL_STORES]  = LEFT(LTRIM(RTRIM([FAS_OWN_RETAIL_STORES])),1)
         , [FAS_RET_SUP_TO]  
         , [FAS_NO_OF_STORES]  = LEFT(LTRIM(RTRIM([FAS_NO_OF_STORES])),64)
         , [FAS_IS_FASH_BUS]  = LEFT(LTRIM(RTRIM([FAS_IS_FASH_BUS])),1)
         , [EQP_DEALER]  = LEFT(LTRIM(RTRIM([EQP_DEALER])),1)
         , [EQP_NO_OF_BRANCHES]  
         , [EQP_OEM_COMP_REP]  
         , [EQP_RENTAL]  = LEFT(LTRIM(RTRIM([EQP_RENTAL])),1)
         , [EQP_TRD_GRP_MEMB]  = LEFT(LTRIM(RTRIM([EQP_TRD_GRP_MEMB])),1500)
         , [EQP_SERVICE_PROVIDER]  = LEFT(LTRIM(RTRIM([EQP_SERVICE_PROVIDER])),1)
         , [EQP_NO_OF_WAREHOUSES]  
         , [EQP_NO_OF_TRUCKS]  
         , [FIN_INTERNATIONAL_LOCS]  
         , [FIN_MULT_LOB]  = LEFT(LTRIM(RTRIM([FIN_MULT_LOB])),1)
         , [FIN_MULT_REGREPORTNEEDS]  
         , [EMEA_OPP_OWNR]  = LEFT(LTRIM(RTRIM([EMEA_OPP_OWNR])),255)
         , [EMEA_STRAT_ACCT]  = LEFT(LTRIM(RTRIM([EMEA_STRAT_ACCT])),1)
         , [ROE_OVR]  = LEFT(LTRIM(RTRIM([ROE_OVR])),1)
         , [ROE_OVR_EXPL]  = LEFT(LTRIM(RTRIM([ROE_OVR_EXPL])),255)
         , [NA_PUB_SECT]  = LEFT(LTRIM(RTRIM([NA_PUB_SECT])),1)
         , [LOB_OVR]  = LEFT(LTRIM(RTRIM([LOB_OVR])),1)
         , [JOC_COMPANY]  = LEFT(LTRIM(RTRIM([JOC_COMPANY])),1)
         , [APAC_NAMED_ACCT]  = LEFT(LTRIM(RTRIM([APAC_NAMED_ACCT])),1)
         , [HOSPITALITY]  = LEFT(LTRIM(RTRIM([HOSPITALITY])),1)
         , [NA_MEDIA_ENTR]  = LEFT(LTRIM(RTRIM([NA_MEDIA_ENTR])),1)
         , [NA_RETAIL]  = LEFT(LTRIM(RTRIM([NA_RETAIL])),1)
         , [FIN_SVCS_IN_ACCT]  = LEFT(LTRIM(RTRIM([FIN_SVCS_IN_ACCT])),1)
         , [NA_BANKING]  = LEFT(LTRIM(RTRIM([NA_BANKING])),1)
         , [PRF_SRVC_IND_ACCT]  = LEFT(LTRIM(RTRIM([PRF_SRVC_IND_ACCT])),1)
         , [EMEA_STRAT_ACCT_OWNR]  = LEFT(LTRIM(RTRIM([EMEA_STRAT_ACCT_OWNR])),18)
         , [ROE_LINE_OF_BUS]  = LEFT(LTRIM(RTRIM([ROE_LINE_OF_BUS])),64)
         , [CONTRACTVEHICLE]  = LEFT(LTRIM(RTRIM([CONTRACTVEHICLE])),64)
         , [ICS_CORE_PTNR_AGRM]  = LEFT(LTRIM(RTRIM([ICS_CORE_PTNR_AGRM])),64)
         , [SOFTRAXMODIFIEDDATE]  
         , [SOFTRAXSTATE]  = LEFT(LTRIM(RTRIM([SOFTRAXSTATE])),64)
         , [SYNCHRONIZEWITHSOFTRAX]  = LEFT(LTRIM(RTRIM([SYNCHRONIZEWITHSOFTRAX])),1)
         , [DATAMANAGEMENT]  = LEFT(LTRIM(RTRIM([DATAMANAGEMENT])),200)
         , [HC_LIFESCIENCESELIGIBLE]  = LEFT(LTRIM(RTRIM([HC_LIFESCIENCESELIGIBLE])),1)
         , [ACTIVE_ONMFGPRIMARYPRODUCT]  = LEFT(LTRIM(RTRIM([ACTIVE_ONMFGPRIMARYPRODUCT])),1)
         , [LOCALIZEDADDRESSLINES]  
         , [LOCALIZEDCITY]  = LEFT(LTRIM(RTRIM([LOCALIZEDCITY])),50)
         , [LOCALIZEDCOUNTRY]  = LEFT(LTRIM(RTRIM([LOCALIZEDCOUNTRY])),50)
         , [LOCALIZEDCOUNTY]  = LEFT(LTRIM(RTRIM([LOCALIZEDCOUNTY])),100)
         , [LOCALIZEDPOSTALCODE]  = LEFT(LTRIM(RTRIM([LOCALIZEDPOSTALCODE])),25)
         , [LOCALIZEDSTATE]  = LEFT(LTRIM(RTRIM([LOCALIZEDSTATE])),50)
         , [ACTIVEOPPCOUNT]  
         , [LASTPURCHASEDATE]  
         , [KEYACCOUNTPROSPECTREP]  = LEFT(LTRIM(RTRIM([KEYACCOUNTPROSPECTREP])),12)
         , [ACCTPLANCLDEXECSPONSOR]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDEXECSPONSOR])),12)
         , [ACCTPLANCLDCUSTOMEREXEC]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDCUSTOMEREXEC])),12)
         , [ACCTPLANCLDFEEDBACK2SPONSOR]  
         , [ACCTPLANCLDROADBLOCKS]  
         , [ACCTPLANCLDCUSTOMERSTATUS]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDCUSTOMERSTATUS])),64)
         , [ACCTPLANCLDLICENSEGMID]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDLICENSEGMID])),12)
         , [ACCTPLANCLDSDMID]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDSDMID])),12)
         , [ACCTPLANCLDCSMID]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDCSMID])),12)
         , [ACCTPLANCLDPRODUCTS]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDPRODUCTS])),256)
         , [ACCTPLANCLDACV]  
         , [ACCTPLANCLDTARGETDATE]  
         , [ACCTPLANCLDMEETCADESTFLG]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDMEETCADESTFLG])),5)
         , [ACCTPLANCLDINITIALCONTFLG]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDINITIALCONTFLG])),5)
         , [ACCTPLANCLDWAVE1FLG]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDWAVE1FLG])),5)
         , [ACCOUNTCOMPETITOR1NAME]  = LEFT(LTRIM(RTRIM([ACCOUNTCOMPETITOR1NAME])),255)
         , [ACCOUNTCOMPETITOR2NAME]  = LEFT(LTRIM(RTRIM([ACCOUNTCOMPETITOR2NAME])),255)
         , [SUBSCRIPTIONSTATUS]  = LEFT(LTRIM(RTRIM([SUBSCRIPTIONSTATUS])),64)
         , [ACCTPLANGOALSOBJFD2]  = LEFT(LTRIM(RTRIM([ACCTPLANGOALSOBJFD2])),4000)
         , [ACCTPLANBUSSEGMENTS1]  = LEFT(LTRIM(RTRIM([ACCTPLANBUSSEGMENTS1])),4000)
         , [ACCTPLANREGPRECOVERAGE1]  = LEFT(LTRIM(RTRIM([ACCTPLANREGPRECOVERAGE1])),4000)
         , [ACCTPLANANNUALREVENUE1]  
         , [ACCTPLANCURYEARPERFTREND1]  = LEFT(LTRIM(RTRIM([ACCTPLANCURYEARPERFTREND1])),4000)
         , [ACCTPLANMAJORPSSCSOLFP1]  = LEFT(LTRIM(RTRIM([ACCTPLANMAJORPSSCSOLFP1])),4000)
         , [ACCTPLANMAJORCOMPSOLFP1]  = LEFT(LTRIM(RTRIM([ACCTPLANMAJORCOMPSOLFP1])),4000)
         , [ACCTPLANGOALSOBJFD1]  = LEFT(LTRIM(RTRIM([ACCTPLANGOALSOBJFD1])),4000)
         , [ACCTPLANBUSSEGMENTS2]  = LEFT(LTRIM(RTRIM([ACCTPLANBUSSEGMENTS2])),4000)
         , [ACCTPLANREGPRECOVERAGE2]  = LEFT(LTRIM(RTRIM([ACCTPLANREGPRECOVERAGE2])),4000)
         , [ACCTPLANANNUALREVENUE2]  
         , [ACCTPLANCURYEARPERFTREND2]  = LEFT(LTRIM(RTRIM([ACCTPLANCURYEARPERFTREND2])),4000)
         , [ACCTPLANMAJORPSSCSOLFP2]  = LEFT(LTRIM(RTRIM([ACCTPLANMAJORPSSCSOLFP2])),4000)
         , [ACCTPLANMAJORCOMPSOLFP2]  = LEFT(LTRIM(RTRIM([ACCTPLANMAJORCOMPSOLFP2])),4000)
         , [SUBSCRIPTIONMAINTSTATUS]  = LEFT(LTRIM(RTRIM([SUBSCRIPTIONMAINTSTATUS])),64)
         , [ACCTPLANCLDWAVE2FLG]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDWAVE2FLG])),5)
         , [ACCTPLANCLDFIELDREFSTATUS]  = LEFT(LTRIM(RTRIM([ACCTPLANCLDFIELDREFSTATUS])),12)
         , [PREVIOUSYEARGLOBALREVENUE]  
         , [UNIQUEID]  = LEFT(LTRIM(RTRIM([UNIQUEID])),32)
         , [ACCTPLANMANAGERSIGNOFF]  
         , [ACCOUNTPLANREQUIREDSERVICES]  = LEFT(LTRIM(RTRIM([ACCOUNTPLANREQUIREDSERVICES])),1)
         , [ACCOUNTPLANREQUIREDLICENSE]  = LEFT(LTRIM(RTRIM([ACCOUNTPLANREQUIREDLICENSE])),1)
         , [ACCOUNTPLANLASTMODIFEDUSER]  = LEFT(LTRIM(RTRIM([ACCOUNTPLANLASTMODIFEDUSER])),12)
         , [ACCOUNTPLANLASTMODIFIED]  
         , [ACCOUNTPLANSIGNOFFMANAGER]  = LEFT(LTRIM(RTRIM([ACCOUNTPLANSIGNOFFMANAGER])),12)
         , [ACCOUNTPLANSIGNOFFMGRSERVICE]  = LEFT(LTRIM(RTRIM([ACCOUNTPLANSIGNOFFMGRSERVICE])),64)
         , [ACCOUNTPLANSIGNOFFMGRSERVICEDATE]  
         , [PARTNERREPMAILONOPINFLUENCE]  = LEFT(LTRIM(RTRIM([PARTNERREPMAILONOPINFLUENCE])),1)
         , [ACTIVEONSRVPRIMARYPRODUCT]  = LEFT(LTRIM(RTRIM([ACTIVEONSRVPRIMARYPRODUCT])),1)
         , [PRIMARYPARTNERID]  = LEFT(LTRIM(RTRIM([PRIMARYPARTNERID])),12)
         , [ISPRIMARYDUPMASTERACCOUNT]  = LEFT(LTRIM(RTRIM([ISPRIMARYDUPMASTERACCOUNT])),1)
         , [PRIMARYDUPMASTERACCOUNTID]  = LEFT(LTRIM(RTRIM([PRIMARYDUPMASTERACCOUNTID])),12)
         , [ALLOWUPDATEONDUPLICATE]  = LEFT(LTRIM(RTRIM([ALLOWUPDATEONDUPLICATE])),1)
         , [PRIMARYPARTNERNAME]  = LEFT(LTRIM(RTRIM([PRIMARYPARTNERNAME])),255)
         , [HEALTHCARESEGMENTATION]  = LEFT(LTRIM(RTRIM([HEALTHCARESEGMENTATION])),64)
         , [GTNSAM]  = LEFT(LTRIM(RTRIM([GTNSAM])),12)
         , [GTNBDM]  = LEFT(LTRIM(RTRIM([GTNBDM])),12)
         , [GTNGAM]  = LEFT(LTRIM(RTRIM([GTNGAM])),12)
         , [GTNSC]  = LEFT(LTRIM(RTRIM([GTNSC])),12)
         , [UPGRADEXISTARGET]  = LEFT(LTRIM(RTRIM([UPGRADEXISTARGET])),1)
         , [UPGRADEXCURPRIMARYPRODUCT]  = LEFT(LTRIM(RTRIM([UPGRADEXCURPRIMARYPRODUCT])),64)
         , [UPGRADEXCURRELEASEINUSE]  = LEFT(LTRIM(RTRIM([UPGRADEXCURRELEASEINUSE])),64)
         , [UPGRADEXUPGRADESTATUS]  = LEFT(LTRIM(RTRIM([UPGRADEXUPGRADESTATUS])),64)
         , [UPGRADEXSTARTYEAR]  = LEFT(LTRIM(RTRIM([UPGRADEXSTARTYEAR])),64)
         , [UPGRADEXUPGRADECOMMENTS]  = LEFT(LTRIM(RTRIM([UPGRADEXUPGRADECOMMENTS])),256)
         , [UPGRADEXDEPLOYMENTPREF]  = LEFT(LTRIM(RTRIM([UPGRADEXDEPLOYMENTPREF])),64)
         , [SREXECSPONSORACCOUNT]  = LEFT(LTRIM(RTRIM([SREXECSPONSORACCOUNT])),3)
         , [SREXECUTIVESPONSOR]  = LEFT(LTRIM(RTRIM([SREXECUTIVESPONSOR])),12)
         , [VPSPONSOR]  = LEFT(LTRIM(RTRIM([VPSPONSOR])),12)
         , [CUSTOMEREXECUTIVESPONSOR]  = LEFT(LTRIM(RTRIM([CUSTOMEREXECUTIVESPONSOR])),128)
         , [CUSTOMERROADMAPCOMPLETE]  = LEFT(LTRIM(RTRIM([CUSTOMERROADMAPCOMPLETE])),3)
         , [CUSTOMER360REVCOMPLETE]  = LEFT(LTRIM(RTRIM([CUSTOMER360REVCOMPLETE])),3)
         , [CUSTOMER360REVCOMPLETEDATE]  
         , [CUSTOMERROADMAPCOMPLETEDATE]  
         , [CUSTOMERBIANNUALMTGDATE]  
         , [EXECSPONSORCLIENTSTATUS]  = LEFT(LTRIM(RTRIM([EXECSPONSORCLIENTSTATUS])),64)
         , [EXECSPONSORATRISKREASON]  = LEFT(LTRIM(RTRIM([EXECSPONSORATRISKREASON])),256)
         , [EXECSPONSORSTRESSEDREASON]  = LEFT(LTRIM(RTRIM([EXECSPONSORSTRESSEDREASON])),64)
         , [EXECSPONSORADVOCATETYPE]  = LEFT(LTRIM(RTRIM([EXECSPONSORADVOCATETYPE])),64)
         , [EXECSPONSORPRODUCTLINE]  = LEFT(LTRIM(RTRIM([EXECSPONSORPRODUCTLINE])),64)
         , [EXECSPONSORPOTENTIALISSUES]  = LEFT(LTRIM(RTRIM([EXECSPONSORPOTENTIALISSUES])),128)
         , [EXECSPONSORREQUIRED]  = LEFT(LTRIM(RTRIM([EXECSPONSORREQUIRED])),1)
         , [KEYACCINDOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCINDOWNERID])),12)
         , [KEYACCBIRSTOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCBIRSTOWNERID])),12)
         , [KEYACCCXOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCCXOWNERID])),12)
         , [KEYACCEPMOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCEPMOWNERID])),12)
         , [KEYACCEAMOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCEAMOWNERID])),12)
         , [KEYACCHCMOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCHCMOWNERID])),12)
         , [KEYACCINDACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCINDACCCATEGORY])),64)
         , [KEYACCBIRSTACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCBIRSTACCCATEGORY])),64)
         , [KEYACCCXACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCCXACCCATEGORY])),64)
         , [KEYACCEPMACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCEPMACCCATEGORY])),64)
         , [KEYACCEAMACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCEAMACCCATEGORY])),64)
         , [KEYACCHCMACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCHCMACCCATEGORY])),64)
         , [KEYACCINDMODIFYDATE]  
         , [KEYACCBIRSTMODIFYDATE]  
         , [KEYACCCXMODIFYDATE]  
         , [KEYACCEPMMODIFYDATE]  
         , [KEYACCEAMMODIFYDATE]  
         , [KEYACCHCMMODIFYDATE]  
         , [CSM]  = LEFT(LTRIM(RTRIM([CSM])),12)
         , [STXMODIFYDATE]  
         , [KEYACCOWFMMODIFYDATE]  
         , [KEYACCWFMACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCWFMACCCATEGORY])),64)
         , [KEYACCWFMOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCWFMOWNERID])),12)
         , [KEYACCBIRSTACTIVITYDATE]  
         , [KEYACCCXACTIVITYDATE]  
         , [KEYACCEPMACTIVITYDATE]  
         , [KEYACCEAMACTIVITYDATE]  
         , [KEYACCWFMACTIVITYDATE]  
         , [KEYACCHCMACTIVITYDATE]  
         , [CUSTOMERSUCCESSMANAGERID]  = LEFT(LTRIM(RTRIM([CUSTOMERSUCCESSMANAGERID])),12)
         , [ACTIVEELITESKU]  = LEFT(LTRIM(RTRIM([ACTIVEELITESKU])),1)
         , [SOFTRAXSHIPTOPHONE]  = LEFT(LTRIM(RTRIM([SOFTRAXSHIPTOPHONE])),64)
         , [SOFTRAXSHIPTOCONTACT]  = LEFT(LTRIM(RTRIM([SOFTRAXSHIPTOCONTACT])),64)
         , [SOFTRAXCONTACTEMAIL]  = LEFT(LTRIM(RTRIM([SOFTRAXCONTACTEMAIL])),100)
         , [SOFTRAXMAINTENANCERENEWALFEE]  
         , [SUCCESSUPDATEDON]  
         , [GTNPLATFORMORG]  = LEFT(LTRIM(RTRIM([GTNPLATFORMORG])),100)
         , [GTNCOUNTERPARTY]  = LEFT(LTRIM(RTRIM([GTNCOUNTERPARTY])),1)
         , [GTNFSPACCOUNT]  = LEFT(LTRIM(RTRIM([GTNFSPACCOUNT])),1)
         , [KEYACCPLMOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCPLMOWNERID])),12)
         , [KEYACCTSOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCTSOWNERID])),12)
         , [KEYACCCPQOWNERID]  = LEFT(LTRIM(RTRIM([KEYACCCPQOWNERID])),12)
         , [KEYACCPLMACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCPLMACCCATEGORY])),64)
         , [KEYACCTSACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCTSACCCATEGORY])),64)
         , [KEYACCCPQACCCATEGORY]  = LEFT(LTRIM(RTRIM([KEYACCCPQACCCATEGORY])),64)
         , [KEYACCPLMMODIFYDATE]  
         , [KEYACCTSMODIFYDATE]  
         , [KEYACCCPQMODIFYDATE]  
         , [KEYACCPLMACTIVITYDATE]  
         , [KEYACCTSACTIVITYDATE]  
         , [KEYACCCPQACTIVITYDATE]  
		 , [ACCOUNTHEALTHSTATUS]
		 , [DRAGONSLAYERTARGET]
		 , [ATTENDEDPSSCUM]
		 , [COMPLETEDDRAGONSLAYERPRE]
		 , [GTNFSPPORTALACCESS]
		 , [BIRSTCSMID]
		 , [GTNBDGROUP]
		 , [KEYACCCLOVERLEAFACCCATEGORY]
		 , [KEYACCCLOVERLEAFMODIFYDATE]
		 , [KEYACCCLOVERLEAFOWNERID]
		 , [KEYACCCLOVERLEAFACTIVITYDATE]
		 , [RDCREMARKS]
		 , [RDCSENTDATE]
		 , [SENTTORDC]
		 , [SNAPSHOTDESCRIPTION]
		 , [GENERALNOTES]
		 , [VALUEANDADOPTION]
		 , [PEOPLEANDENDUSERS]
		 , [RISK]
		 , [FUTURE]
		 , [NOTREFERENCEABLEREASON]
		 , [REFERENCEAUDITCOMMENT]
		 , [REFERENCEAUDITSTATUS]
		 , [ISCUSTOMERREFERENCEABLE]
		 , [REFERENCEAUDITCONTACTID]
		 , [GAINSIGHTCUSTOMERID]
    FROM [' + @database + '].[sysdba].[PSSCACCOUNT] src  WITH (NOLOCK)'') source
    LEFT JOIN dbo.CRM_PSSCACCOUNT1 base WITH (NOLOCK)
    ON source.[ACCOUNTID] = base.[ACCOUNTID]
    
    
    
    
    
    
    
    AND base.sourcesystem_id  = ''' + convert(varchar(50), @sourcesystem_id) + '''
    WHERE base.[ACCOUNTID] IS NULL'
    /*INSERT INTO dbo.CRM_PSSCACCOUNT
    (
      [BK_Hash] 
      ,[loadDttm] 
      ,[load_date] 
      ,[sourcesystem_id] 
      ,[ACCOUNTID] 
      ,[CREATEUSER] 
      ,[CREATEDATE] 
      ,[MODIFYUSER] 
      ,[MODIFYDATE] 
      ,[SALESFORCEID] 
      ,[ISDELETED] 
      ,[DELETEDDATE] 
      ,[PHOTOURL] 
      ,[ISPARTNERPORTALAUTHROIZED] 
      ,[ALLIANCEAGREEMENT] 
      ,[ALLIANCETYPE] 
      ,[AUDITINGINPROGRESS] 
      ,[ACCOUNTCLASS] 
      ,[IPNPARTNERCHANNELTIER] 
      ,[LASTACTIVITYDATE] 
      ,[LASTCALLACTIVITYDATE] 
      ,[DECISIONLOCATION] 
      ,[FORMALIZATIONDATE] 
      ,[NAHEALTHCARE] 
      ,[INBOUNDINTEGRATIONERROR] 
      ,[LASTDATEVERIFIED] 
      ,[MAINTENANCESTATUS] 
      ,[HCMTEAMCOMMENTS] 
      ,[OUTOFBUSINESS] 
      ,[OUTBOUNDINTEGRATIONERROR] 
      ,[SOFTRAXID] 
      ,[SOFTRAXCOUNTRY] 
      ,[SUBINDUSTRY] 
      ,[SUBREGION] 
      ,[HEATID] 
      ,[SFDCUNIQUEID] 
      ,[ACCOUNTVALIDATED] 
      ,[DEFAULTPARTNERTYPE] 
      ,[SOFTRAXIDUSEDESCRIPTION] 
      ,[PSSCAQUISITIONS] 
      ,[EMAILDOMAIN] 
      ,[SOFTRAXCURRENCY] 
      ,[SECCODEID] 
      ,[OWNER_LINE_OF_BUSINESS] 
      ,[OWNERSUBLINEOFBUSINESS] 
      ,[APACSTRATEGIC] 
      ,[LOCAL_SIC_DESCRIPTION] 
      ,[TOTAL_GLOBAL_EMPLOYEES] 
      ,[PO_REQUIRED] 
      ,[CONTRACTUALLY_NONREFERENCABLE] 
      ,[IS_ANALYSTMEDIA] 
      ,[IS_PSSC_COMPETITOR] 
      ,[IS_PSSC_CONSULTANT] 
      ,[IS_UNIVERSITY] 
      ,[KEY_ACCOUNT_LINE_OF_BUSINESS] 
      ,[KEY_ACCOUNT] 
      ,[KEY_TARGET_ACCOUNT_LOB] 
      ,[FORMERCUSTOMER] 
      ,[PRIMARY_INSIDE_SALES_REPID] 
      ,[STX_CUST_CD] 
      ,[STX_CUS_GRP_CD] 
      ,[STX_CUS_GRP] 
      ,[STX_CUSTOMER_CATEGORY] 
      ,[STX_CUSTOMER_NUMBER] 
      ,[STX_FORMALIZE] 
      ,[EDU_ALLIANCE_PRGM] 
      ,[EUVAT_REGNUMBER] 
      ,[KEYACCOUNTNOTES] 
      ,[INDUSTRY_OVERRIDE] 
      ,[SUBINDUSTRY_OVERRIDE] 
      ,[SICCODEOVERRIDE] 
      ,[KEY_ACCOUNT_DELIST_REASON] 
      ,[FORMERPARTNER] 
      ,[LICENSE_COMMISSIONMARGIN] 
      ,[NUMBER_PSSC_CUSTOMERS] 
      ,[PARTNER_GROUPS] 
      ,[PARTNER_INDUSTRY_FOCUS] 
      ,[PARTNER_INDUSTRY_SUB_FOCUS] 
      ,[PARTNER_STATUS] 
      ,[PARTNER_TYPES] 
      ,[PUBLIC_SECTOR_AGREEMENT] 
      ,[SELLTHROUGH_AGREEMENT] 
      ,[SUPPORT_COMMISSIONMARGIN] 
      ,[PUBLIC_SECTOR_TIER] 
      ,[TOTAL_REVENUE_GROWTH] 
      ,[ALLIANCE_PARTNER] 
      ,[ENABLE_PARTNER_AUTHORIZATIONS] 
      ,[SELECTION_CONSULTANT] 
      ,[SIGNED_NDA] 
      ,[NUMBER_OF_SIGNED_SFDC_LICENSES] 
      ,[CRM_PARTNER] 
      ,[AGREEMENTDATE] 
      ,[ALLIANCEAGREEMENTTYPE] 
      ,[ALLIANCE_PTNR_AGRMENT] 
      ,[ALLIANCE_PRTNR_GRP] 
      ,[ALLIANCEREGIONS] 
      ,[ANCILLARYAGREEMENTS] 
      ,[BUSINESSPLANDATE] 
      ,[BUS_PLAN_REN_DATE] 
      ,[CHANNELAGREEMENT] 
      ,[CLOUDSUITECERTIFIED] 
      ,[ICS_SCV_AGR_TYP] 
      ,[ICS_SVC_CR_PTNR_AGRM] 
      ,[ICS_SVC_PTNR_LVL] 
      ,[MINORITY_FIRM] 
      ,[PARTNER_PROGRAM_TYPE] 
      ,[OVER60DAYSPASTDUEAR] 
      ,[CREDITLIMIT] 
      ,[CREDITLIMITCURRENCY] 
      ,[AVAILABLECREDITLIMIT] 
      ,[TOTALAR] 
      ,[FISCALYEAR] 
      ,[GLOBALREVENUE] 
      ,[PUB_STD_ENRL] 
      ,[PUB_POP] 
      ,[MFG_AFTER_MKT_SVC] 
      ,[MFG_AUTOMOTIVE_TIER] 
      ,[MFG_NO_SITES] 
      ,[MFG_OEM_CUST_SUP] 
      ,[MFG_PIM_MFG_TYPE] 
      ,[MFG_PRIM_SVC_TYPE] 
      ,[MFG_REG_COMP_STNDS] 
      ,[MFG_NO_ENGINEERS] 
      ,[MFG_MANUFACTURER] 
      ,[MFG_ISMFGLOC] 
      ,[ICS_ACCOUNT_TYPE] 
      ,[ICS_OWNER] 
      ,[ICS_SEG] 
      ,[ICS_REV_IND] 
      ,[ICS_REV_SCTR] 
      ,[ICS_REV_IND_OVREX] 
      ,[ICS_REV_IND_OVR] 
      ,[ICS_SLS_OWNR_OVREX] 
      ,[ICS_SLS_OWNR_OVR] 
      ,[HSP_HOTEL_CHAIN] 
      ,[HSP_HOTEL_CODE] 
      ,[HSP_MANAGEMENT] 
      ,[HSP_NO_HOTELS] 
      ,[HSP_NO_ROOMS] 
      ,[HSP_PRICE_POINT] 
      ,[HCR_NO_OF_BEDS] 
      ,[HCM_ACCT_DEFN] 
      ,[HCM_ACCOUNT_TIER] 
      ,[GT_NEXUS_ACC_TYP] 
      ,[GT_NEXUS_ACT_OPP] 
      ,[GT_NEXUS_OPP_VALUE] 
      ,[GT_NEXS_ACT_OID] 
      ,[FAS_BUSINESS_MODEL] 
      ,[FAS_MULTIBRAND] 
      ,[FAS_OWN_RETAIL_STORES] 
      ,[FAS_RET_SUP_TO] 
      ,[FAS_NO_OF_STORES] 
      ,[FAS_IS_FASH_BUS] 
      ,[EQP_DEALER] 
      ,[EQP_NO_OF_BRANCHES] 
      ,[EQP_OEM_COMP_REP] 
      ,[EQP_RENTAL] 
      ,[EQP_TRD_GRP_MEMB] 
      ,[EQP_SERVICE_PROVIDER] 
      ,[EQP_NO_OF_WAREHOUSES] 
      ,[EQP_NO_OF_TRUCKS] 
      ,[FIN_INTERNATIONAL_LOCS] 
      ,[FIN_MULT_LOB] 
      ,[FIN_MULT_REGREPORTNEEDS] 
      ,[EMEA_OPP_OWNR] 
      ,[EMEA_STRAT_ACCT] 
      ,[ROE_OVR] 
      ,[ROE_OVR_EXPL] 
      ,[NA_PUB_SECT] 
      ,[LOB_OVR] 
      ,[JOC_COMPANY] 
      ,[APAC_NAMED_ACCT] 
      ,[HOSPITALITY] 
      ,[NA_MEDIA_ENTR] 
      ,[NA_RETAIL] 
      ,[FIN_SVCS_IN_ACCT] 
      ,[NA_BANKING] 
      ,[PRF_SRVC_IND_ACCT] 
      ,[EMEA_STRAT_ACCT_OWNR] 
      ,[ROE_LINE_OF_BUS] 
      ,[CONTRACTVEHICLE] 
      ,[ICS_CORE_PTNR_AGRM] 
      ,[SOFTRAXMODIFIEDDATE] 
      ,[SOFTRAXSTATE] 
      ,[SYNCHRONIZEWITHSOFTRAX] 
      ,[DATAMANAGEMENT] 
      ,[HC_LIFESCIENCESELIGIBLE] 
      ,[ACTIVE_ONMFGPRIMARYPRODUCT] 
      ,[LOCALIZEDADDRESSLINES] 
      ,[LOCALIZEDCITY] 
      ,[LOCALIZEDCOUNTRY] 
      ,[LOCALIZEDCOUNTY] 
      ,[LOCALIZEDPOSTALCODE] 
      ,[LOCALIZEDSTATE] 
      ,[ACTIVEOPPCOUNT] 
      ,[LASTPURCHASEDATE] 
      ,[KEYACCOUNTPROSPECTREP] 
      ,[ACCTPLANCLDEXECSPONSOR] 
      ,[ACCTPLANCLDCUSTOMEREXEC] 
      ,[ACCTPLANCLDFEEDBACK2SPONSOR] 
      ,[ACCTPLANCLDROADBLOCKS] 
      ,[ACCTPLANCLDCUSTOMERSTATUS] 
      ,[ACCTPLANCLDLICENSEGMID] 
      ,[ACCTPLANCLDSDMID] 
      ,[ACCTPLANCLDCSMID] 
      ,[ACCTPLANCLDPRODUCTS] 
      ,[ACCTPLANCLDACV] 
      ,[ACCTPLANCLDTARGETDATE] 
      ,[ACCTPLANCLDMEETCADESTFLG] 
      ,[ACCTPLANCLDINITIALCONTFLG] 
      ,[ACCTPLANCLDWAVE1FLG] 
      ,[ACCOUNTCOMPETITOR1NAME] 
      ,[ACCOUNTCOMPETITOR2NAME] 
      ,[SUBSCRIPTIONSTATUS] 
      ,[ACCTPLANGOALSOBJFD2] 
      ,[ACCTPLANBUSSEGMENTS1] 
      ,[ACCTPLANREGPRECOVERAGE1] 
      ,[ACCTPLANANNUALREVENUE1] 
      ,[ACCTPLANCURYEARPERFTREND1] 
      ,[ACCTPLANMAJORPSSCSOLFP1] 
      ,[ACCTPLANMAJORCOMPSOLFP1] 
      ,[ACCTPLANGOALSOBJFD1] 
      ,[ACCTPLANBUSSEGMENTS2] 
      ,[ACCTPLANREGPRECOVERAGE2] 
      ,[ACCTPLANANNUALREVENUE2] 
      ,[ACCTPLANCURYEARPERFTREND2] 
      ,[ACCTPLANMAJORPSSCSOLFP2] 
      ,[ACCTPLANMAJORCOMPSOLFP2] 
      ,[SUBSCRIPTIONMAINTSTATUS] 
      ,[ACCTPLANCLDWAVE2FLG] 
      ,[ACCTPLANCLDFIELDREFSTATUS] 
      ,[PREVIOUSYEARGLOBALREVENUE] 
      ,[UNIQUEID] 
      ,[ACCTPLANMANAGERSIGNOFF] 
      ,[ACCOUNTPLANREQUIREDSERVICES] 
      ,[ACCOUNTPLANREQUIREDLICENSE] 
      ,[ACCOUNTPLANLASTMODIFEDUSER] 
      ,[ACCOUNTPLANLASTMODIFIED] 
      ,[ACCOUNTPLANSIGNOFFMANAGER] 
      ,[ACCOUNTPLANSIGNOFFMGRSERVICE] 
      ,[ACCOUNTPLANSIGNOFFMGRSERVICEDATE] 
      ,[PARTNERREPMAILONOPINFLUENCE] 
      ,[ACTIVEONSRVPRIMARYPRODUCT] 
      ,[PRIMARYPARTNERID] 
      ,[ISPRIMARYDUPMASTERACCOUNT] 
      ,[PRIMARYDUPMASTERACCOUNTID] 
      ,[ALLOWUPDATEONDUPLICATE] 
      ,[PRIMARYPARTNERNAME] 
      ,[HEALTHCARESEGMENTATION] 
      ,[GTNSAM] 
      ,[GTNBDM] 
      ,[GTNGAM] 
      ,[GTNSC] 
      ,[UPGRADEXISTARGET] 
      ,[UPGRADEXCURPRIMARYPRODUCT] 
      ,[UPGRADEXCURRELEASEINUSE] 
      ,[UPGRADEXUPGRADESTATUS] 
      ,[UPGRADEXSTARTYEAR] 
      ,[UPGRADEXUPGRADECOMMENTS] 
      ,[UPGRADEXDEPLOYMENTPREF] 
      ,[SREXECSPONSORACCOUNT] 
      ,[SREXECUTIVESPONSOR] 
      ,[VPSPONSOR] 
      ,[CUSTOMEREXECUTIVESPONSOR] 
      ,[CUSTOMERROADMAPCOMPLETE] 
      ,[CUSTOMER360REVCOMPLETE] 
      ,[CUSTOMER360REVCOMPLETEDATE] 
      ,[CUSTOMERROADMAPCOMPLETEDATE] 
      ,[CUSTOMERBIANNUALMTGDATE] 
      ,[EXECSPONSORCLIENTSTATUS] 
      ,[EXECSPONSORATRISKREASON] 
      ,[EXECSPONSORSTRESSEDREASON] 
      ,[EXECSPONSORADVOCATETYPE] 
      ,[EXECSPONSORPRODUCTLINE] 
      ,[EXECSPONSORPOTENTIALISSUES] 
      ,[EXECSPONSORREQUIRED] 
      ,[KEYACCINDOWNERID] 
      ,[KEYACCBIRSTOWNERID] 
      ,[KEYACCCXOWNERID] 
      ,[KEYACCEPMOWNERID] 
      ,[KEYACCEAMOWNERID] 
      ,[KEYACCHCMOWNERID] 
      ,[KEYACCINDACCCATEGORY] 
      ,[KEYACCBIRSTACCCATEGORY] 
      ,[KEYACCCXACCCATEGORY] 
      ,[KEYACCEPMACCCATEGORY] 
      ,[KEYACCEAMACCCATEGORY] 
      ,[KEYACCHCMACCCATEGORY] 
      ,[KEYACCINDMODIFYDATE] 
      ,[KEYACCBIRSTMODIFYDATE] 
      ,[KEYACCCXMODIFYDATE] 
      ,[KEYACCEPMMODIFYDATE] 
      ,[KEYACCEAMMODIFYDATE] 
      ,[KEYACCHCMMODIFYDATE] 
      ,[CSM] 
      ,[STXMODIFYDATE] 
      ,[KEYACCOWFMMODIFYDATE] 
      ,[KEYACCWFMACCCATEGORY] 
      ,[KEYACCWFMOWNERID] 
      ,[KEYACCBIRSTACTIVITYDATE] 
      ,[KEYACCCXACTIVITYDATE] 
      ,[KEYACCEPMACTIVITYDATE] 
      ,[KEYACCEAMACTIVITYDATE] 
      ,[KEYACCWFMACTIVITYDATE] 
      ,[KEYACCHCMACTIVITYDATE] 
      ,[CUSTOMERSUCCESSMANAGERID] 
      ,[ACTIVEELITESKU] 
      ,[SOFTRAXSHIPTOPHONE] 
      ,[SOFTRAXSHIPTOCONTACT] 
      ,[SOFTRAXCONTACTEMAIL] 
      ,[SOFTRAXMAINTENANCERENEWALFEE] 
      ,[SUCCESSUPDATEDON] 
      ,[GTNPLATFORMORG] 
      ,[GTNCOUNTERPARTY] 
      ,[GTNFSPACCOUNT] 
      ,[KEYACCPLMOWNERID] 
      ,[KEYACCTSOWNERID] 
      ,[KEYACCCPQOWNERID] 
      ,[KEYACCPLMACCCATEGORY] 
      ,[KEYACCTSACCCATEGORY] 
      ,[KEYACCCPQACCCATEGORY] 
      ,[KEYACCPLMMODIFYDATE] 
      ,[KEYACCTSMODIFYDATE] 
      ,[KEYACCCPQMODIFYDATE] 
      ,[KEYACCPLMACTIVITYDATE] 
      ,[KEYACCTSACTIVITYDATE] 
      ,[KEYACCCPQACTIVITYDATE] 
    )
    --EXECUTE (@cmd)*/

    SET  @rowcount = @@ROWCOUNT

    EXEC @log_value = dbo.logProcessActivity
            @log_value
          , @proc_name
          , @step_name
          , @message
          , @type
          , @rowcount

   END

END --Add Missing Records

SET  @message  = 'ADD Missing Records'
SET  @type   = 'INSERT'
EXEC @log_step  = dbo.logProcessActivity
        @log_step
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount


/******************************************************************************************************************************/


SET  @message  = 'Drop Temporary Tables '
SET  @type   = 'INSERT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount


IF @cleanupTempTables > 0
BEGIN --Temp Table Cleanup
 BEGIN TRY
  DROP TABLE dbo.XA_CRM_PSSCACCOUNT1
 END TRY
 BEGIN CATCH
  PRINT 'Unable to drop table XA_CRM_PSSCACCOUNT'
 END CATCH


 BEGIN TRY
  DROP TABLE dbo.XD_CRM_PSSCACCOUNT1
 END TRY
 BEGIN CATCH
  PRINT 'Unable to drop table XD_CRM_PSSCACCOUNT'
 END CATCH
END --Temp Table Cleanup


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount




SET  @message  = 'Count Records for Comparison'
SET  @type   = 'COUNT'
SET  @rowcount  = 0
EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

EXECUTE dbo.logTableCounts @servername = @@SERVERNAME, @dbname = 'EDW_STAGE', @tableName = 'XA_CRM_PSSCACCOUNT1', @count = @countDelta, @desc = 'DELTA', @load_date = @load_date
   , @sourcesystem_id = @sourcesystem_id
EXECUTE dbo.logTableCounts @servername = @server, @dbname = @database , @tableName = 'PSSCACCOUNT',@count = @countSource, @desc = 'SOURCE', @load_date = @load_date
   , @sourcesystem_id = @sourcesystem_id
EXECUTE dbo.logTableCounts @servername = @@SERVERNAME, @dbname = 'EDW_STAGE', @tableName = 'CRM_PSSCACCOUNT1', @count = @countDest, @desc = 'FINAL', @load_date = @load_date
   , @sourcesystem_id = @sourcesystem_id


EXEC @log_value = dbo.logProcessActivity
        @log_value
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount

SET  @step_name  = 'PROCEDURE'
SET  @message  = 'PROCEDURE'
SET  @type   = 'PROCEDURE'
SET  @rowcount  = 0
EXEC @log_v_main = dbo.logProcessActivity
        @log_v_main
      , @proc_name
      , @step_name
      , @message
      , @type
      , @rowcount





