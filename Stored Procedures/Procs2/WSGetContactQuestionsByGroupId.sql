-- =============================================  
-- Author:  <Author,,GD>  
-- Create date: <Create Date,,15 Oct 2015>  
-- Description: <Description,,>  
-- Call SP:  WSGetContactQuestionsByGroupId 201, 0  
-- =============================================  
CREATE PROCEDURE [dbo].[WSGetContactQuestionsByGroupId]
    @GroupId BIGINT ,  
    @ContactMasterId BIGINT  
AS  
    BEGIN  
        DECLARE @Url NVARCHAR(150);  
        SELECT  @Url = KeyValue + 'ContactQuestions/'  
        FROM    dbo.AAAAConfigSettings  
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';  
  
        SELECT DISTINCT  
                CQ.Id AS QuestionId ,  
                CQ.QuestionTypeId ,  
                QuestionTitle ,  
                ShortName ,  
                [Required] ,  
                [MaxLength] ,  
                ISNULL(Hint, '') AS Hint ,  
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType ,  
                IsTitleBold ,  
                IsTitleItalic ,  
                IsTitleUnderline ,  
                TitleTextColor ,  
                Position ,  
                IsGroupField ,  
                ISNULL(D.ContactOptionId, '') AS ContactOptionId ,  
                ISNULL(D.Detail, '') AS Detail ,  
                Margin ,  
                FontSize ,  
                ISNULL(@Url + ImagePath, '') AS ImagePath,
				CQ.IsDisplayInDetail AS DisplayInDetail,
				CQ.IsDisplayInSummary AS DisplayInList,
				CQ.IsCommentCompulsory AS IsCommentCompulsory,
				CQ.IsDecimal AS IsDecimal
        FROM    dbo.EstablishmentGroup AS Eg  
                OUTER APPLY dbo.Split(Eg.ContactQuestion, ',') AS AQ  
                INNER JOIN dbo.[Group] AS G ON G.Id = Eg.GroupId  
                INNER JOIN dbo.Contact AS C ON C.Id = G.ContactId  
                INNER JOIN dbo.ContactQuestions AS CQ ON CQ.ContactId = C.Id  
                                                         AND CQ.IsDeleted = 0  
                                                         AND AQ.Data = CQ.Id  
                LEFT OUTER JOIN dbo.ContactDetails D ON D.ContactQuestionId = CQ.Id  
                                                        AND ContactMasterId = @ContactMasterId  
                                                        AND D.IsDeleted = 0  
        WHERE   Eg.GroupId = @GroupId  AND CQ.QuestionTypeId IN (4,11,10)
		ORDER BY position;
    END;  
