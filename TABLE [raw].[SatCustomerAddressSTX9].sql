USE [EDW_DV]
GO

/****** Object:  Table [raw].[SatCustomerAddressSTX9]    Script Date: 12/27/2022 9:35:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [raw].[SatCustomerAddressSTX9](
	[customerHashKey] [char](40) NOT NULL,
	[loadDate] [datetime2](7) NOT NULL,
	[loadEndDate] [datetime2](7) NULL,
	[recordSource] [varchar](100) NOT NULL,
	[hashDiff] [char](40) NOT NULL,
	[cus_name] [varchar](40) NULL,
	[cus_addr1] [varchar](40) NULL,
	[cus_addr2] [varchar](40) NULL,
	[cus_city] [varchar](30) NULL,
	[cus_state] [varchar](30) NULL,
	[cus_zip] [varchar](15) NULL,
	[cus_country] [varchar](3) NULL,
	[cus_county] [varchar](26) NULL,
	[cus_phone] [varchar](25) NULL,
	[cus_fax] [varchar](25) NULL,
	[cus_addr3] [varchar](40) NULL,
	[cus_addr4] [varchar](40) NULL,
 CONSTRAINT [PK_SatCustomerAddressSTX9] PRIMARY KEY CLUSTERED 
(
	[customerHashKey] ASC,
	[loadDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [SECONDARY]
) ON [SECONDARY]
GO

ALTER TABLE [raw].[SatCustomerAddressSTX9]  WITH NOCHECK ADD  CONSTRAINT [FK_SatCustomerAddressSTX9_HubCustomer] FOREIGN KEY([customerHashKey])
REFERENCES [raw].[HubCustomer] ([customerHashKey])
GO

ALTER TABLE [raw].[SatCustomerAddressSTX9] CHECK CONSTRAINT [FK_SatCustomerAddressSTX9_HubCustomer]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date a row was added to the table' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'loadDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date a row is replaced by an updated row for the same HashKey' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'loadEndDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifies a source pointing to either the original source system or "SYS" indicating a derived row.' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'recordSource'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_addr1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_addr2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_city'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_state'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_zip'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_country'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_county'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_phone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_fax'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_addr3'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sourced from Softrax9.Customer from a column of the same name' , @level0type=N'SCHEMA',@level0name=N'raw', @level1type=N'TABLE',@level1name=N'SatCustomerAddressSTX9', @level2type=N'COLUMN',@level2name=N'cus_addr4'
GO


