USE [EDW_DV]
GO

/****** Object:  Table [raw].[SatCustomerStatusSTX9]    Script Date: 12/27/2023 9:45:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[SatCustomerStatusSTX9](
	[customerHashKey] [char](40) NOT NULL,
	[loadDate] [datetime2](7) NOT NULL,
	[loadEndDate] [datetime2](7) NULL,
	[recordSource] [varchar](100) NOT NULL,
	[hashDiff] [char](40) NOT NULL,
	[cus_class] [varchar](10) NULL,
	[cus_sub_class] [varchar](10) NULL,
	[cus_status] [varchar](2) NULL,
	[cus_app_st] [varchar](2) NULL,
	[cus_category] [varchar](10) NULL,
	[cus_active_dt] [datetime] NULL,
	[cus_inactive_dt] [datetime] NULL,
	[cus_credit_hold] [char](1) NULL,
	[cus_curr_cd] [varchar](4) NOT NULL,
	[cus_term_cd] [varchar](10) NULL,
	[cus_terr_cd] [varchar](5) NULL,
	[cus_registration_no] [varchar](30) NULL,
	[cus_company] [varchar](6) NULL,
	[cus_price_type] [varchar](3) NULL,
 CONSTRAINT [PK_SatCustomerStatusSTX9] PRIMARY KEY CLUSTERED 
(
	[customerHashKey] ASC,
	[loadDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [SECONDARY]
) ON [SECONDARY]
GO

ALTER TABLE [raw].[SatCustomerStatusSTX9]  WITH NOCHECK ADD  CONSTRAINT [FK_SatCustomerStatusSTX9_HubCustomer] FOREIGN KEY([customerHashKey])
REFERENCES [raw].[HubCustomer] ([customerHashKey])
GO

ALTER TABLE [raw].[SatCustomerStatusSTX9] CHECK CONSTRAINT [FK_SatCustomerStatusSTX9_HubCustomer]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date a row was added to the table' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'loadDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date a row is replaced by an updated row for the same HashKey' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'loadEndDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifies a source pointing to either the original source system or "SYS" indicating a derived row.' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'recordSource'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_class'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_sub_class'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_status'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_app_st'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_category'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_active_dt'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_inactive_dt'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_credit_hold'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_curr_cd'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_term_cd'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_terr_cd'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerStatusSTX9', @level2type=N'COLUMN',@level2name=N'cus_registration_no'
GO


