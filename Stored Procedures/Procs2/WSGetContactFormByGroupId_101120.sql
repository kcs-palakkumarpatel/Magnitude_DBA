/*
=============================================
Author:			<Vasu Patel>
Create date:	<29 Dec 2015>
Description:	<Get ContactFrom by UserGroupId>


Exec WSGetContactFormByGroupId 10008,'2016-01-01 04:32:07.647'

drop procedure WSGetContactFormByGroupId_101120
*/
CREATE PROCEDURE [dbo].[WSGetContactFormByGroupId_101120]
	@GroupId BIGINT,
	@LastServerDate DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Url NVARCHAR(150)
	DECLARE @ContactId INT = 0
	
	SELECT @ContactId =  ContactId FROM dbo.ContactQuestions where ISNULL(UpdatedOn,CreatedOn) >= @LastServerDate
    
	SELECT @Url = KeyValue + 'ContactQuestions/'  
    FROM dbo.AAAAConfigSettings  
    WHERE KeyName = 'DocViewerRootFolderPathCMS';  

    SELECT DISTINCT CQ.Id AS QuestionId,CQ.QuestionTypeId,QuestionTitle,ShortName,[Required],[MaxLength],
		ISNULL(Hint,'') AS Hint,ISNULL(OptionsDisplayType,'') AS OptionsDisplayType,IsTitleBold,IsTitleItalic,
		IsTitleUnderline,TitleTextColor,Position,IsGroupField,ISNULL(D.ContactOptionId,'') AS ContactOptionId,
		ISNULL(D.Detail,'') AS Detail,Margin,FontSize,ISNULL(@Url + CQ.ImagePath,'') AS ImagePath,
		CQ.IsDisplayInDetail AS DisplayInDetail,CQ.IsDisplayInSummary AS DisplayInList,
		CQ.IsCommentCompulsory AS IsCommentCompulsory
	FROM dbo.EstablishmentGroup AS Eg  
	OUTER APPLY dbo.Split(Eg.ContactQuestion,',') AS AQ  
	INNER JOIN dbo.[Group] AS G ON G.Id = Eg.GroupId  
	INNER JOIN dbo.Contact AS C ON C.Id = G.ContactId  
	INNER JOIN dbo.ContactQuestions AS CQ ON CQ.ContactId = C.Id AND CQ.IsDeleted = 0  AND AQ.Data = CQ.Id  
	LEFT OUTER JOIN dbo.ContactDetails D ON D.ContactQuestionId = CQ.Id  AND ContactMasterId = 0 AND D.IsDeleted = 0  
    WHERE g.id = @GroupId
	AND (ISNULL(Eg.UpdatedOn,Eg.CreatedOn) >= @LastServerDate
    /*--OR ISNULL(CQ.UpdatedOn,CQ.CreatedOn) >= @LastServerDate*/
	OR ISNULL(C.UpdatedOn,C.CreatedOn) >= @LastServerDate
	OR CQ.ContactId =  CASE @ContactId WHEN 0 THEN 0 ELSE @ContactId END 
	OR @LastServerDate IS NULL)
END
