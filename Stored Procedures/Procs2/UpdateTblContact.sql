-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateTblContact 240484
-- =============================================
CREATE PROCEDURE [dbo].[UpdateTblContact]
    @ContactMasterId BIGINT
AS 
    BEGIN
  IF EXISTS(SELECT 1 FROM tblContact WHERE ContactMasterId = @ContactMasterId)
		BEGIN
			DELETE FROM tblContact WHERE ContactMasterId = @ContactMasterId
		END

	DECLARE @ContactName NVARCHAR(MAX)
	DECLARE @ContactAllName NVARCHAR(MAX)
	DECLARE @ContactId INT
	DECLARE @Position INT

	SET @ContactName = ''
	SET @ContactAllName = ''

	SELECT @ContactName = @ContactName + (CASE WHEN ContactName <> '' THEN ',' + ContactName ELSE '' END) ,
	@ContactAllName = @ContactAllName +  (CASE WHEN ContactAllName <> '' THEN ',' + ContactAllName ELSE '' END) ,
	@ContactMasterId = ContactMasterId,
	@ContactId = ContactId,
	@Position = ContactPosition
	FROM (
		SELECT TOP 100 PERCENT CD.ContactMasterId,CQ.ContactId, CQ.Position As ContactPosition,
		(CASE WHEN CQ.IsDisplayInSummary = 1 THEN LTRIM(RTRIM(ISNULL(CD.Detail,''))) ELSE '' END) AS ContactName,
		LTRIM(RTRIM(ISNULL(CD.Detail,''))) AS ContactAllName 
		FROM dbo.ContactDetails AS CD
		INNER JOIN dbo.ContactQuestions AS CQ ON CQ.Id = CD.ContactQuestionId
		WHERE CQ.IsDeleted = 0
		AND CD.ContactMasterId = @ContactMasterId 
		ORDER BY CD.ContactMasterId,CQ.ContactId,CQ.Position ASC
	) A ORDER By A.ContactPosition

		
	IF @ContactMasterId IS NOT NULL 
	BEGIN
		INSERT INTO tblContact (ContactMasterId,ContactId,ContactName,ContactAllName)
		SELECT @ContactMasterId AS ContactMasterId,@ContactId AS ContactId,
		SUBSTRING(@ContactName,2,4000) AS ContactName,
		SUBSTRING(@ContactAllName,2,4000) AS ContactAllName
	END
 END