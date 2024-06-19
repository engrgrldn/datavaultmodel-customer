USE [EDW_DV]
GO

/****** Object:  Table [raw].[HubCustomer]    Script Date: 12/27/2023 9:25:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[HubCustomer](
	[customerHashKey] [char](40) NOT NULL,
	[loadDate] [datetime2](7) NOT NULL,
	[recordSource] [varchar](100) NOT NULL,
	[combinedCustomerCode] [varchar](30) NOT NULL,
	[customerCode] [varchar](20) NOT NULL,
	[customerGroupCode] [varchar](10) NULL,
 CONSTRAINT [HubCustomer_PK] PRIMARY KEY CLUSTERED 
(
	[customerHashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [SECONDARY],
 CONSTRAINT [HubCustomer_UK1] UNIQUE NONCLUSTERED 
(
	[combinedCustomerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [SECONDARY]
) ON [SECONDARY]
GO

ALTER TABLE [raw].[HubCustomer] ADD  DEFAULT ('1') FOR [customerGroupCode]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Calculated as HashBytes(<Primary Key Values>)' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'customerHashKey'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date a row was added to the table' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'loadDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifies a source pointing to either the original source system or "SYS" indicating a derived row.' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'recordSource'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Combined Key of customerCode and customerGroupCode.  This value is presumably what is passed to hashbytes to generate the HashKey' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'combinedCustomerCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This column is sourced from the originating system and is used to derive the Hash Key within this table.  It represents the business key for this object type.' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'customerCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This column is sourced from the originating system and is used to derive the Hash Key within this table.  It represents the business key for this object type.' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer', @level2type=N'COLUMN',@level2name=N'customerGroupCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Hub for Business Keys collected from various systems' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'HubCustomer'
GO


