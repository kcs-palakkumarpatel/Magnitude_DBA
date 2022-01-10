
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetClientById>
-- Call SP    :	GetClientById
-- =============================================
CREATE PROCEDURE [dbo].[GetClientById]
@Id BIGINT
AS
BEGIN
SELECT  [Id] AS Id, [ClientName] AS ClientName, [SurName] AS SurName, [NickName] AS NickName, [EmailId] AS EmailId, [CountryCode] AS CountryCode, [MobileNo] AS MobileNo, [Password] AS Password, [BirthDate] AS BirthDate, [AnniversaryDate] AS AnniversaryDate, [Address] AS Address, [City] AS City, [MeasurementDate] AS MeasurementDate, [PreferredCallTime] AS PreferredCallTime, [ImageName] AS ImageName, [SignName] AS SignName, [UserId] AS UserId, [IsActive] AS IsActive, [IsVerified] AS IsVerified, [TimeOffSet] AS TimeOffSet, [Gender] AS Gender, [IsPromotionalSMS] AS IsPromotionalSMS FROM dbo.[Client] WHERE [Id] = @Id
END