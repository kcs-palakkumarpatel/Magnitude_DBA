-- =============================================
-- Author:		Vasudev Patel
-- Create date: 14 Dec 2016
-- Description:	Get Default Contact By App user id and Type id
-- Exec:  GetDefaultContactByAppUserId 4489,'A'
-- =============================================
CREATE PROCEDURE [dbo].[GetDefaultContactByAppUserId] 
	-- Add the parameters for the stored procedure here
	@AppUserId BIGINT,
	@Type VARCHAR(1)

AS
BEGIN
IF(@Type = 'G')
	BEGIN
		SELECT GroupId,ActivityId,EstablishmentId,ContactId,AppUserId,IsGroup FROM dbo.DefaultContact WHERE AppUserId = @AppUserId AND GroupId IS NOT null AND IsDeleted = 0 AND ContactId !=0
	END
    ELSE IF(@Type = 'A')
	BEGIN
		SELECT GroupId,ActivityId,EstablishmentId,ContactId,AppUserId,IsGroup FROM dbo.DefaultContact WHERE AppUserId = @AppUserId AND ActivityId IS NOT null AND IsDeleted = 0 AND  ContactId !=0
	END
	IF(@Type = 'E')
	BEGIN
		SELECT GroupId,ActivityId,EstablishmentId,ContactId,AppUserId,IsGroup FROM dbo.DefaultContact WHERE AppUserId = @AppUserId AND EstablishmentId IS NOT NULL AND IsDeleted = 0 AND ContactId !=0
END
END
