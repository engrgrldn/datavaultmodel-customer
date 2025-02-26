USE [EDW_DV]
GO
/****** Object:  StoredProcedure [raw].[load_hubCustomer_ICRM]    Script Date: 12/27/2023 9:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












ALTER PROCEDURE [raw].[load_hubCustomer_ICRM]
AS


/*
	This procedure will load a hub as defined in the procedure name
		from a sourcesystem - also in the procedure name.
	All hubs are loaded individually with Separate Stored Procedures for different SourceSystems

	The procedure name will be parsed to get the sourcesystem - important to have this correct.

	Fill in the below for tracking purposes

	@Author:		Ion Tabirta
	@DateCreated:	August 21, 2016
	
	@Comments:		Loads Customer hub from current ICRM PSSCaccount table.
					HashKey represents the value of AccountID field. 

*/
SET NOCOUNT ON

--Global Procedure Variables
DECLARE	@proc_name		varchar(50);
DECLARE	@cmd			varchar(max)
DECLARE	@recordSource	varchar(100)

SET		@proc_name		= OBJECT_NAME(@@PROCID)
SET		@recordSource	= SUBSTRING(@proc_name, charindex('_', @proc_name , 6) + 1, 100)

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
EXEC	@log_proc = dbo.logProcessActivity
				@logDWID			= @log_proc
			,	@logSource			= @proc_name
			,	@logStep			= 'PROCEDURE'
			,	@logMsg				= 'PROCEDURE'
			,	@logActionType		= 'PROCEDURE'
			,	@logCount			= 0


BEGIN -- INSERT NEW INTO HUB
	SET		@step_name		= 'HUB INSERT'
	SET		@message		= 'INSERT New Records into HUB'
	SET		@type			= 'INSERT'
	SET		@rowcount		= 0
	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @@ROWCOUNT;
	
	--DECLARE	@recordSource varchar(20); SET @recordSource = 'ICRM';
	WITH sourceData AS (
			SELECT [customerHashKey]		= CONVERT(CHAR(40), HASHBYTES('SHA1', UPPER(CONVERT(nvarchar(200), RTRIM(COALESCE(src.AccountId, ''))))) ,2) 
					,[combinedCustomerCode]	= src.AccountId
					,[customerCode]			= src.AccountId
					,[customerGroupCode]		= ''
			--SELECT COUNT(*)
			FROM	(	SELECT	distinct AccountID
						FROM	[EDW_STAGE].dbo.CRM_ACCOUNT
					) src
	)
	--select	count(*), customerHashKey from sourcedata group by customerHashKey HAVING COUNT(*) > 1
,	NewRecords AS (
			SELECT	src.*
			FROM	sourceData src
			LEFT JOIN	raw.HubCustomer hub
			ON		src.customerHashKey		= hub.CustomerHashKey
			WHERE	hub.CustomerHashKey		IS NULL
	)
	--SELECT	* FROM NewRecords

		INSERT INTO [raw].[HubCustomer]
				   ([customerHashKey]
				   ,[loadDate]
				   ,[recordSource]
				   ,[combinedCustomerCode]
				   ,[customerCode]
				   ,[customerGroupCode])
		--DECLARE	@recordSource varchar(20); SET @recordSource = 'ICRM'
		SELECT [customerHashKey]		= CONVERT(CHAR(40), HASHBYTES('SHA1', UPPER(CONVERT(nvarchar(200), RTRIM(COALESCE(src.[customerCode], ''))))) ,2) 
			  ,[loadDate]				= getdate()
			  ,[recordSource]			= @recordSource
			  ,[combinedCustomerCode]	= src.[customerCode]
			  ,[customerCode]			= src.[customerCode]
			  ,[customerGroupCode]		= ''
		--SELECT COUNT(*)
		FROM	NewRecords src
		
		

		SET		@rowcount		= @@ROWCOUNT

		PRINT	'Customers Added:	' + convert(varchar(10), @rowcount)

	EXEC	@log_level1 = BI_UTIL.dbo.logProcessActivity
							  @log_level1
							, @proc_name
							, @step_name
							, @message
							, @type
							, @ROWCOUNT


END -- INSERT NEW INTO HUB




--Log the Procedure End

EXEC	@log_proc = dbo.logProcessActivity
				@logDWID			= @log_proc
			,	@logSource			= @proc_name
			,	@logStep			= 'PROCEDURE'
			,	@logMsg				= 'PROCEDURE'
			,	@logActionType		= 'PROCEDURE'
			,	@logCount			= 0



RETURN 0

/*

	SELECT	*
	FROM	(	SELECT	AccountID FROM EDW_STAGE.dbo.CRM_ACCOUNT ) crm
	LEFT JOIN	raw.HubCustomer hub
	ON		crm.AccountID		= hub.CustomerCode
	WHERE	hub.CustomerCode	IS NULL

*/
