-- =============================================
-- Author:		APIGetEstablishmentByEstablishmentName
-- Create date: 
-- Description:	
-- APIGetEstablishmentByEstablishmentName z, 6021
-- =============================================
CREATE PROCEDURE [dbo].[APIGetEstablishmentByEstablishmentName] 
	-- Add the parameters for the stored procedure here
	@EstablishmentName NVARCHAR(MAX),
	@ActivityId BIGINT
AS
BEGIN
	SELECT top 1 isnull(id,0) FROM dbo.Establishment WHERE EstablishmentGroupId = @ActivityId and EstablishmentName LIKE '%' + @EstablishmentName + '%' and isDeleted = 0;
END