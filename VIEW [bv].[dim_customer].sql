USE [EDW_BV]
GO

/****** Object:  View [bv].[dim_customer]    Script Date: 12/27/2023 9:22:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [bv].[dim_customer]
AS
/*
	Fill in the below for tracking purposes

	@Author:		
	@DateCreated:	
	
	@Comments:			
	
	@Changelog:
	Date				Name				Project		Remarks

*/

WITH accountcustomer AS (
		SELECT	DISTINCT 
				customerhashkey			= NULL	--src.[DupeCustomerHashKey]
			,	mastercustomerhashkey	= NULL	--src.[MasterCustomerHashKey]
		--FROM	EDW_DV.bv.[SALnkCustomer] src
		--INNER JOIN	EDW_DV.bv.satsalnkcustomer sat
		--ON		src.[SALnkCustomerHashKey]		= sat.[SALnkCustomerHashKey]
		--AND		sat.loadenddate					IS NULL
		--AND		sat.isdeleted					= 0
		--WHERE	src.DupeCustomerHashKey			= '370BCE11D7AB8E660E8EC99988B0FC497267B14F'

		--select	* from edw_dv.raw.HubCustomer where recordSource  = 'default'
	)
, stxcust AS (
		SELECT	customerhashKey							= hcust.customerHashKey   --	ad.customerHashKey
			,	cust_loaddate							= dbo.Get_Max_Date(hcust.loadDate, stx.loadDate, stx_status.loadDate, satCstx.loadDate, satsms.loadDate, gns.LoadDate, NULL, NULL, NULL, NULL)
			,	accounthashkey							= CONVERT(char(40), COALESCE(stxOnAcct.mastercustomerhashkey, site_acct.AccountHashKey, 'F944DCD635F9801F7AC90A407FBC479964DEC024'))
			,	site_addresshashkey						= site_acct.Site_AddressHashKey
			--,	mastercustomerhashkey					= COALESCE(site_acct.AccountHashKey, hcust.customerhashKey)   --	ad.mastercustomerHashKey
			--,	cust_territoryhashkey					= '?'   --	TerritoryHashKey
			,	cust_source								= CASE WHEN hcust.RecordSource   = 'STXRP' THEN 'STX9' ELSE hcust.recordSource END-- 
			--,	cust_source_code						= hcust.customerGroupCode   -- 
			,	cust_uid								= hcust.combinedcustomerCode
			,	cust_code								= hcust.customerCode   -- 
			,	cust_group_code							= hcust.customerGroupCode   -- 
			--,	cust_ownerid							= satCstx.cus_sal_cd   -- 
			,	cust_name								= COALESCE(cus_name, '')
			,	cust_address1							= COALESCE(stx.cus_addr1, '')
			,	cust_address2							= COALESCE(stx.cus_addr2, '')
			,	cust_address3							= COALESCE(stx.cus_addr3, '')
			,	cust_address4							= COALESCE(stx.cus_addr4, '')
			,	cust_city								= COALESCE(stx.cus_city,  '')
			,	cust_state								= COALESCE(stx.cus_state, '')
			,	cust_postal_code						= COALESCE(stx.cus_zip,   '')
			,	cust_country_code						= COALESCE(country.countrycode, '')
			--,	cust_country							= COALESCE(stx.cus_country, '')
			--,	cust_country							= COALESCE(country.countryName, '')
			--,	cust_region								= country.[countryRegion]   -- 
			,	cust_county								= COALESCE(stx.cus_county, '')
			,	cust_phone								= COALESCE(stx.cus_phone, '')
			,	cust_fax								= COALESCE(stx.cus_fax, '')
			,	cust_contact							= COALESCE(satCstx.cus_contact, '')
			--,	cust_salescode							= team.acctmgr --satCstx.cus_sal_cd
			--,	cust_sxsalescode2						= team.corecsm --satCstx.sx_cus_sal_cd2
			--,	cust_sxsalescode3						= team.sdm		satCstx.sx_cus_sal_cd3
			,	cust_class								= stx_status.[cus_class]
			--,	cust_subclass							= stx_status.[cus_sub_class]
			,	cust_status								= COALESCE(codeStatus.codeDisplayValue, 'Unknown')   -- 
			,	cust_category							= stx_status.[cus_category]
			,	cust_active_date						= stx_status.[cus_active_dt]
			,	cust_inactive_date						= stx_status.[cus_inactive_dt]
			,	cust_credit_hold						= stx_status.[cus_credit_hold]
			,	cust_currency_code						= stx_status.[cus_curr_cd]
			,	cust_term_code							= stx_status.[cus_term_cd]
			,	cust_territory_code						= stx_status.[cus_terr_cd]
			,	cust_registration_no					= stx_status.[cus_registration_no]
			,	cust_laststatement_no					= satsms.last_statement_nbr   -- 
			,	cust_laststatement_date					= satsms.last_statement_date   -- 
			,	cust_lastmaintuser_id					= COALESCE(satsms.last_maint_user_id, '')
			,	cust_mt_adoption_score					= COALESCE(gns.mt_product_adoption_score, '')
			,	cust_csm_subjective_health_score		= gns.csm_subjective_health_score	
			,	cust_csm_subjective_health_score_label	= gns.csm_subjective_health_score_label			
			,	cust_luminary							= COALESCE(gns.luminary_label, '')
			,	cust_gns_id								= gns.gsid
			,	cust_company_code						= stx_status.[cus_company]
			,	cust_price_type							= stx_status.[cus_price_type]
			,	cust_sentiment_score					= gns.customer_sentiment_score
			--SELECT	count(*)
		FROM	(	SELECT	*
					FROM	EDW_DV.raw.Hubcustomer
					WHERE	recordsource IN ('SMS', 'STX9', 'STXRP')
					--AND		customerHashKey		= '370BCE11D7AB8E660E8EC99988B0FC497267B14F'
				) hcust
		INNER JOIN	EDW_DV.raw.SatcustomerAddressSTX9 stx
		ON		hcust.customerHashKey		= stx.customerHashKey
		AND		stx.loadEndDate				IS NULL
		INNER JOIN	EDW_DV.[raw].SatcustomerStatusSTX9 stx_status
		ON		hcust.customerHashKey		= stx_status.customerHashKey
		AND		stx_status.LoadEndDate		IS NULL
		LEFT JOIN	EDW_DV.raw.SatcustomerContactsSTX9 satCstx
		ON		stx.customerHashKey			= satCstx.customerHashKey
		AND		satCstx.loadEndDate			IS NULL
		LEFT JOIN	(	
						SELECT	site_acct.*
						FROM	EDW_DV.raw.LnkSiteAccountcustomer_Current  site_acct
						WHERE	1			= 1
						--AND	customerHashKey			= 'F2B8776DBECB0270C8D2A6659F7C66DAE9154277'
						--AND		site_acct.currentcustomer		= 1
						--AND		site_acct.SelectedCustomer		= 1

					) site_acct
		ON		hcust.customerHashKey		= site_acct.customerHashKey
		LEFT JOIN	accountcustomer stxOnAcct
		ON		hcust.customerHashKey		= stxOnAcct.customerHashKey
		LEFT JOIN	EDW_DV.[raw].[RefCountryNameMap]  cnm
		ON		cnm.[countryNameAlternate]	= COALESCE(stx.cus_country, '')
		AND		cnm.LoadEndDate				IS NULL
		LEFT JOIN	EDW_DV.[raw].[RefCountry] country
		ON		cnm.CountryCode				= country.countrycode
		AND		country.LoadEndDate				IS NULL
		LEFT JOIN	EDW_DV.[bv].CodeDefinition codeStatus
		ON		codeStatus.codeType				= 'customerStatus'
		AND		codeStatus.codeValue				= COALESCE(stx_status.cus_Category, '')
		LEFT JOIN	EDW_DV.[raw].SatcustomerStatusSMS satsms
		ON		hcust.customerhashkey			= satsms.customerhashkey
		AND		satsms.LoadEndDate				IS NULL
		LEFT JOIN	EDW_DV.raw.SatCustomerDetailGNS gns
		ON		hcust.customerHashKey			= gns.CustomerHashKey
		AND		gns.loadEndDate					IS NULL
	)
, smscust AS (
		SELECT	customerhashKey							= hcust.customerHashKey   --	ad.customerHashKey
			,	cust_loaddate							= dbo.Get_Max_Date(hcust.loadDate, sms.loadDate, satsms.loadDate, gns.LoadDate, NULL, NULL, NULL, NULL, NULL, NULL)
			,	accounthashkey							= CONVERT(char(40), COALESCE(site_acct.AccountHashKey, stxOnAcct.mastercustomerhashkey, 'F944DCD635F9801F7AC90A407FBC479964DEC024'))
			,	site_address_hashkey					= site_acct.Site_AddressHashKey
			,	cust_source								= CASE WHEN hcust.RecordSource   = 'STXRP' THEN 'STX9' ELSE hcust.recordSource END --hcust.RecordSource   -- 
			,	cust_uid								= hcust.combinedcustomerCode
			,	cust_code								= hcust.customerCode   -- 
			,	cust_group_code							= hcust.customerGroupCode   -- 
			,	cust_name								= COALESCE(sms.acct_name, '')
			,	cust_address1							= COALESCE(sms.addr_line_1, '')
			,	cust_address2							= COALESCE(sms.addr_line_2, '')
			,	cust_address3							= COALESCE(sms.addr_line_3, '')
			,	cust_address4							= COALESCE(sms.addr_line_4, '')
			,	cust_city								= COALESCE(sms.city_name,  '')
			,	cust_state								= COALESCE(sms.country_sub_entity_code, '')
			,	cust_postal_code						= COALESCE(sms.postal_code,   '')
			,	cust_country_code						= COALESCE(country.countrycode, '')
			,	cust_county								= COALESCE('', '')
			,	cust_phone								= '' --COALESCE(stx.cus_phone, '')
			,	cust_fax								= '' --COALESCE(stx.cus_fax, '')
			,	cust_contact							= '' --COALESCE(satCstx.cus_contact, '')
			,	cust_class								= '' --sms_status.[cus_class]
			,	cust_status								= '' --COALESCE(codeStatus.codeDisplayValue, 'Unknown')   -- 
			,	cust_category							= '' --sms_status.[cus_category]
			,	cust_active_date						= '' --sms_status.[cus_active_dt]
			,	cust_inactive_date						= '' --sms_status.[cus_inactive_dt]
			,	cust_credit_hold						= '' --sms_status.[cus_credit_hold]
			,	cust_currency_code						= '' --sms_status.[cus_curr_cd]
			,	cust_term_code							= '' --sms_status.[cus_term_cd]
			,	cust_territory_code						= '' --sms_status.[cus_terr_cd]
			,	cust_registration_no					= '' --sms_status.[cus_registration_no]
			,	cust_laststatement_no					= satsms.last_statement_nbr   -- 
			,	cust_laststatement_date					= satsms.last_statement_date   -- 
			,	cust_lastmaintuser_id					= COALESCE(satsms.last_maint_user_id, '')
			,	cust_mt_adoption_score					= COALESCE(gns.mt_product_adoption_score, '')
			,	cust_csm_subjective_health_score		= COALESCE(gns.csm_subjective_health_score, '')	
			,	cust_csm_subjective_health_score_label	= COALESCE(gns.csm_subjective_health_score_label, '')			
			,	cust_luminary							= COALESCE(gns.luminary_label, '')
			,	cust_gns_id								= gns.gsid
			,	cust_company_code						= ''
			,	cust_price_type							= ''
			,	cust_sentiment_score					= gns.customer_sentiment_score
			--SELECT	count(*)
		FROM	(	SELECT	hcust.*									--87,967
					FROM	EDW_DV.raw.Hubcustomer hcust
					LEFT JOIN	EDW_DV.raw.SatcustomerAddressSTX9 stx
					ON		hcust.customerHashKey		= stx.customerHashKey
					AND		stx.loadEndDate				IS NULL
					WHERE	hcust.recordsource IN ('SMS', 'STX', 'STXRP')
					AND		stx.customerHashKey			IS NULL
				) hcust
		INNER JOIN	EDW_DV.raw.SatCustomerAddressSMS sms
		ON		hcust.customerHashKey		= sms.customerHashKey
		AND		sms.loadEndDate				IS NULL
		--LEFT JOIN	EDW_DV.[raw].SatCustomerStatusSMS  sms_status
		--ON		hcust.customerHashKey		= sms_status.customerHashKey
		--AND		sms_status.LoadEndDate		IS NULL
		--LEFT JOIN	EDW_DV.raw.SatcustomerContacts satCstx
		--ON		stx.customerHashKey			= satCstx.customerHashKey
		--AND		satCstx.loadEndDate			IS NULL
		LEFT JOIN	(	
						SELECT	site_acct.*
						FROM	EDW_DV.raw.LnkSiteAccountcustomer_Current  site_acct
						WHERE	1			= 1
						--AND	customerHashKey			= 'F2B8776DBECB0270C8D2A6659F7C66DAE9154277'
						--AND		site_acct.currentcustomer		= 1
						--AND		site_acct.SelectedCustomer		= 1
						--WHERE	customerHashKey			= '000088DC759495AC85B572EDEF9C2651FD3BD737'

					) site_acct
		ON		hcust.customerHashKey		= site_acct.customerHashKey
		LEFT JOIN	accountcustomer stxOnAcct
		ON		hcust.customerHashKey		= stxOnAcct.customerHashKey
		LEFT JOIN	EDW_DV.[raw].[RefCountryNameMap]  cnm
		ON		cnm.[countryNameAlternate]	= COALESCE(sms.country_code, '')
		AND		cnm.LoadEndDate				IS NULL
		LEFT JOIN	EDW_DV.[raw].[RefCountry] country
		ON		cnm.CountryCode				= country.countrycode
		AND		country.LoadEndDate				IS NULL
		--LEFT JOIN	EDW_DV.[bv].CodeDefinition codeStatus
		--ON		codeStatus.codeType				= 'customerStatus'
		--AND		codeStatus.codeValue				= COALESCE(sms_status.cus_Category, '')
		LEFT JOIN	EDW_DV.[raw].SatcustomerStatusSMS satsms
		ON		hcust.customerhashkey			= satsms.customerhashkey
		AND		satsms.LoadEndDate				IS NULL
		LEFT JOIN	EDW_DV.raw.SatCustomerDetailGNS gns
		ON		hcust.customerHashKey			= gns.CustomerHashKey

	)

SELECT	*
FROM	stxcust
UNION ALL
SELECT	*
FROM	smscust

















GO


