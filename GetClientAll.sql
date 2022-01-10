
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetClientAll>
-- Call SP    :	GetClientAll
-- =============================================
CREATE PROCEDURE [dbo].[GetClientAll]
AS
BEGIN
SELECT  dbo.[Client].[Id] AS Id , dbo.[Client].[ClientName] AS ClientName , dbo.[Client].[SurName] AS SurName , dbo.[Client].[NickName] AS NickName , dbo.[Client].[EmailId] AS EmailId , dbo.[Client].[CountryCode] AS CountryCode , dbo.[Client].[MobileNo] AS MobileNo , dbo.[Client].[Password] AS Password , dbo.[Client].[BirthDate] AS BirthDate , dbo.[Client].[AnniversaryDate] AS AnniversaryDate , dbo.[Client].[Address] AS Address , dbo.[Client].[City] AS City , dbo.[Client].[MeasurementDate] AS MeasurementDate , dbo.[Client].[PreferredCallTime] AS PreferredCallTime , dbo.[Client].[ImageName] AS ImageName , dbo.[Client].[SignName] AS SignName , dbo.[Client].[UserId] AS UserId , dbo.[Client].[IsActive] AS IsActive , dbo.[Client].[IsVerified] AS IsVerified , dbo.[Client].[TimeOffSet] AS TimeOffSet , dbo.[Client].[Gender] AS Gender , dbo.[Client].[IsPromotionalSMS] AS IsPromotionalSMS  FROM dbo.[Client] 
 WHERE dbo.[Client].IsDeleted = 0
END