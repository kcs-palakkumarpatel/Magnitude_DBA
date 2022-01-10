-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--GetContactMasterId '', '0822956607' 
-- NIRAV PARIKH - 6 OCT 2016 - Updated SP LOGIC
-- =============================================
CREATE PROCEDURE [dbo].[GetContactMasterId]
    @Email NVARCHAR(MAX) ,
    @MobileNo NVARCHAR(50)
AS
BEGIN
	DECLARE @MAPPINGID BIGINT, @GroupID BIGINT
	SELECT TOP 1 @MAPPINGID = MappingId FROM dbo.Scheduler WHERE IsRunning = 1
	
	SELECT TOP 1 @GroupID = GroupId  FROM ColumnMapping WHERE Id = @MAPPINGID

	IF(@Email != '' OR @Email IS NOT NULL)
		BEGIN
			--SELECT TOP 1 ContactMasterId FROM    dbo.ContactDetails WHERE   Detail = @Email AND QuestionTypeId IN (10,11);
			SELECT TOP 1 ContactMasterId FROM ContactMaster INNER JOIN ContactDetails ON ContactMasterId = ContactMaster.Id
			WHERE Detail = @Email AND QuestionTypeId IN (10,11) and GroupId = @GroupID;
        END
	ELSE IF(@MobileNo != '' OR @MobileNo IS NOT NULL)
		BEGIN
			--SELECT TOP 1 ContactMasterId FROM    dbo.ContactDetails WHERE   Detail = @MobileNo AND QuestionTypeId IN (10,11);
			SELECT TOP 1 ContactMasterId FROM ContactMaster INNER JOIN ContactDetails ON ContactMasterId = ContactMaster.Id
			WHERE Detail = @MobileNo AND QuestionTypeId IN (10,11) and GroupId = @GroupID;
		END
    ELSE
		BEGIN
			SELECT 0 AS ContactMasterId
        END
END