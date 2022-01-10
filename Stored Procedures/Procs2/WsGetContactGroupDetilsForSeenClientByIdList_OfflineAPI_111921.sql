
/*
EXEC dbo.WsGetContactGroupDetilsForSeenClientByIdList_OfflineAPI '1702,1724'
Drop procedure WsGetContactGroupDetilsForSeenClientByIdList_OfflineAPI
*/

CREATE PROCEDURE [dbo].[WsGetContactGroupDetilsForSeenClientByIdList_OfflineAPI_111921]
    @ContactGroupIdList VARCHAR(MAX)
AS
BEGIN
	IF OBJECT_ID('tempdb..#tempContact', 'u') IS NOT NULL  
	DROP TABLE #tempContact  
	CREATE TABLE #tempContact(
		[ContactGroupId] [BIGINT] NOT NULL
	)
	INSERT INTO #tempContact
	(
	    ContactGroupId
	)
	SELECT Data FROM dbo.Split(@ContactGroupIdList,',');
	DECLARE @Max INT, @Id BIGINT = 0;
	SELECT @Max = COUNT(*) FROM #tempContact;

	IF OBJECT_ID('tempdb..#temp', 'u') IS NOT NULL  
	DROP TABLE #temp  
	CREATE TABLE #temp(
		QuestionId [BIGINT] NOT NULL,
		QuestionTypeId [int] NOT NULL,
		QuestionTitle NVARCHAR(250) NOT NULL,
		Detail NVARCHAR(MAX),
		LastUsedOn DATETIME,
		ContactGroupId BIGINT NOT NULL
	)

	WHILE(@Max > 0)
	BEGIN
		SELECT TOP 1 @Id = ContactGroupId FROM #tempContact ;
		INSERT INTO #temp
		(
		    QuestionId,
		    QuestionTypeId,
		    QuestionTitle,
		    Detail,
		    LastUsedOn,
			ContactGroupId
		)
		SELECT  -1 AS QuestionId ,
			-1 AS QuestionTypeId ,
			'Group Name' AS QuestionTitle ,
			ContactGropName AS Detail,
			LastUsedOn,
			@Id AS ContactGroupId
		FROM dbo.ContactGroup
		WHERE Id = @Id
		UNION
		SELECT  Cq.Id AS QuestionId ,
			Cq.QuestionTypeId ,
			QuestionTitle ,
			dbo.GetContactDetailsForGroup(@Id, Cq.Id) AS Detail,
			NULL as LastUsedOn,
			@Id AS ContactGroupId
		FROM  dbo.ContactGroupRelation AS CGR
		INNER JOIN dbo.ContactMaster AS Cm ON CGR.ContactMasterId = Cm.Id
		INNER JOIN dbo.ContactDetails AS Cd ON Cm.Id = Cd.ContactMasterId 
		INNER JOIN dbo.ContactQuestions AS Cq ON Cd.ContactQuestionId = Cq.Id
		WHERE Cd.IsDeleted = 0
		AND CGR.IsDeleted = 0
		AND Cm.IsDeleted = 0
		AND Cq.IsDeleted = 0
		AND IsDisplayInSummary = 1
		AND ContactGroupId = @Id
		GROUP BY Cq.Id ,Cq.QuestionTypeId ,QuestionTitle;
		SET @Max = @Max - 1;
		DELETE FROM #tempContact WHERE ContactGroupId = @Id;
	END
	
	SELECT * FROM #temp;
END

