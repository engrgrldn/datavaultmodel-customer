USE [EDW_DV]
GO
/****** Object:  StoredProcedure [raw].[load_satCustomerStatus_ICRM]    Script Date: 12/27/2023 9:46:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [raw].[load_satCustomerStatus_ICRM]
AS

/*
	This procedure will load a satellite as defined in the procedure name
		from a sourcesystem - also in the procedure name.
	All satellites are loaded individually with Separate Stored Procedures for different SourceSystems

	The procedure name will be parsed to get the sourcesystem - important to have this correct.

	Fill in the below for tracking purposes

	@Author:		MGC
	@DateCreated:	February 22, 2017
	
	@Comments:		The load of the satellite will pull initial SMS information necessary to identify customer records.

*/
SET NOCOUNT ON

--Global Procedure Variables
DECLARE	@proc_name		varchar(50);
DECLARE	@cmd			varchar(max)
DECLARE	@recordSource	varchar(100)


SET		@proc_name		= OBJECT_NAME(@@PROCID)
SET		@recordSource	= @proc_name

--Following the naming convention of the SP's, we will be retrieving the sourcesystem name following the final underscore.
WHILE	charindex('_', @recordSource) > 0 

	BEGIN
		SET		@recordSource	= SUBSTRING(@recordSource, charindex('_', @recordSource) + 1, 100)
	END


--Logging Variables
DECLARE @log_proc		int;
DECLARE	@log_level1		int;
DECLARE	@log_level2		int;
DECLARE	@step_name		varchar(50);
DECLARE	@message		varchar(50);
DECLARE	@type			varchar(50);
DECLARE @rowcount		int;

--Procedure Specific Variables
DECLARE	@sourcesystem_id	int

--END Variable Declarations


--Log the Procedure Start

SET		@rowcount		= 0
EXEC	@log_proc = dbo.logProcessActivity
				@logDWID			= @log_proc
			,	@logSource			= @proc_name
			,	@logStep			= 'PROCEDURE'
			,	@logMsg				= 'PROCEDURE'
			,	@logActionType		= 'PROCEDURE'
			,	@logCount			= 0


BEGIN -- INSERT NEW INTO HUB
	SET		@step_name		= 'HUB INSERT'
	SET		@message		= 'INSERT New Records into SATELLITE'
	SET		@type			= 'INSERT'
	SET		@rowcount		= 0
	EXEC	@log_level1 = dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT

/*
--Example Insert Code
--All satellites are loaded individually with Separate Stored Procedures for different SourceSystems

*/
		INSERT INTO [raw].[SatCustomerStatusICRM]
           ([customerHashKey]
           ,[loadDate]
           ,[loadEndDate]
           ,[recordSource]
           ,[hashDiff]
		   ,[MaintenanceStatus]
		   ,[SubscriptionStatus]
		   ,[SubscriptionMaintStatus]
		   ,[PartnerStatus]
		   ,[SUCCESSUPDATEDON]
		   ,[ACTIVE_ONMFGPRIMARYPRODUCT])
			--DECLARE @recordSource varchar(100) SET @recordSource = 'ICRM'
		SELECT 
			[customerHashKey]		=	CONVERT(CHAR(40), HASHBYTES('SHA1', UPPER(CONVERT(nvarchar(200), RTRIM(COALESCE(src.AccountID, '')))) ),2)
           ,[loadDate]					=	getdate()
           ,[loadEndDate]				=	NULL	--Need to establish the date that will be considered a changed date for the record
           ,[recordSource]				=	@recordSource
           ,[hashDiff]					=	CONVERT(CHAR(40), HASHBYTES('SHA1',	 COALESCE(src.[MaintenanceStatus], '')
																		  +      COALESCE(src.[SubscriptionStatus], '')
																		  +      COALESCE(src.[SubscriptionMaintStatus], '')
																		  +      COALESCE(src.[Partner_Status], '')
																		  +		 COALESCE(CONVERT(varchar(1000), src.[SUCCESSUPDATEDON]), '')
																		  +      COALESCE(src.[ACTIVE_ONMFGPRIMARYPRODUCT], '')
																		), 2)
			
		   ,[MaintenanceStatus]			=	src.MaintenanceStatus
		   ,[SubscriptionStatus]		=	src.SubscriptionStatus
		   ,[SubscriptionMaintStatus]	=	src.SubscriptionMaintStatus
		   ,[PartnerStatus]				=	src.Partner_Status
		   ,[SUCCESSUPDATEDON]			=	src.[SUCCESSUPDATEDON]
		   ,[ACTIVE_ONMFGPRIMARYPRODUCT]=	src.[ACTIVE_ONMFGPRIMARYPRODUCT]
	FROM	(	SELECT	DISTINCT	AccountID
					,	src.MaintenanceStatus
					,	src.SubscriptionStatus
					,	src.SubscriptionMaintStatus
					,	src.Partner_Status
					,	src.[SUCCESSUPDATEDON]
					,	src.[ACTIVE_ONMFGPRIMARYPRODUCT]
				FROM	[EDW_STAGE].dbo.CRM_PSSCACCOUNT src
			) src
	INNER JOIN	[raw].HubCustomer hub
	ON		CONVERT(CHAR(40), HASHBYTES('SHA1', UPPER(CONVERT(nvarchar(200), RTRIM(COALESCE(src.AccountID, '')))) ),2)	=	hub.customerHashKey
	LEFT JOIN	[raw].[SatCustomerStatusICRM]	sat
	ON		hub.customerHashKey			=	sat.customerHashKey
	AND		sat.loadEndDate				IS NULL
	WHERE	sat.customerHashKey IS NULL
			OR	CONVERT(CHAR(40), HASHBYTES('SHA1',	 COALESCE(src.[MaintenanceStatus], '')
																		  +      COALESCE(src.[SubscriptionStatus], '')
																		  +      COALESCE(src.[SubscriptionMaintStatus], '')
																		  +      COALESCE(src.[Partner_Status], '')
																		  +		 COALESCE(CONVERT(varchar(1000), src.[SUCCESSUPDATEDON]), '')
																		  +      COALESCE(src.[ACTIVE_ONMFGPRIMARYPRODUCT], '')
																		), 2)
				!=	sat.hashDiff

END -- INSERT NEW INTO SATELLITE

EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							@log_level1
						, @proc_name
						, @step_name
						, @message
						, @type
						, @@ROWCOUNT


BEGIN -- UPDATE THE SATELLITE loadEndDate
	SET		@step_name		= 'UPDATE loadEndDate'
	SET		@message		= 'UPDATING TO DEPRECATE OUTDATED RECORDS'
	SET		@type			= 'UPDATE'
	SET		@rowcount		= 0
	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT

--Setting the loadEndDate for outdated records to 1 minute prior to the loadDate of the newest record.
	UPDATE	satOld
		SET		loadEndDate	=	DATEADD(MI, -1, sat.loadDate)
		FROM	[raw].[SatCustomerStatusICRM] sat
		INNER JOIN	[raw].[SatCustomerStatusICRM] satOld
		ON		sat.customerHashKey	=	satOld.customerHashKey
		AND		sat.loadDate		>	satOld.loadDate
		AND		satOld.loadEndDate	IS NULL


	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT



END -- UPDATE THE SATELLITE loadEndDate


BEGIN -- INSERT ERROR INTO SATELLITEERROR
	SET		@step_name		= 'HUB INSERT'
	SET		@message		= 'INSERT New Records into Satellite'
	SET		@type			= 'INSERT'
	SET		@rowcount		= 0
	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT


	/*
	--The current step will help identify the person records from different systems that have an issue upon loading.
	--This step is critical as it will allow to maintain the data integrity from the necessary systems as well as capture the "bad" records.

	*/

	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT



END -- INSERT ERROR INTO SATELLITE


--Log the Procedure End

EXEC	@log_proc = dbo.logProcessActivity
				@logDWID			= @log_proc
			,	@logSource			= @proc_name
			,	@logStep			= 'PROCEDURE'
			,	@logMsg				= 'PROCEDURE'
			,	@logActionType		= 'PROCEDURE'
			,	@logCount			= 0


RETURN 0
