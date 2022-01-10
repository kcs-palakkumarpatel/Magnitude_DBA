CREATE PROCEDURE [dbo].[WSGetContactQuestionsByActivityIdAndContactGroupID]    
    @ActivityId BIGINT ,    
    @ContactMasterId BIGINT  ,  
    @ContactGroupID BIGINT  
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
                --ISNULL(D.ContactOptionId, '') AS ContactOptionId ,    
                CASE WHEN CQ.IsGroupField =1 THEN  ISNULL(CGD.ContactOptionId, '') ELSE ISNULL(D.ContactOptionId,'') END AS ContactOptionId ,   
                --ISNULL(D.Detail, '') AS Detail ,    
                CASE WHEN CQ.IsGroupField =1 THEN  ISNULL(CGD.Detail, '') ELSE ISNULL(D.Detail,'') END AS Detail ,   
                Margin ,    
                FontSize ,    
                ISNULL(@Url + ImagePath, '') AS ImagePath    ,
				CQ.IsCommentCompulsory AS IsCommentCompulsory
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
                LEFT OUTER JOIN dbo.ContactGroupDetails CGD ON cgd.ContactQuestionId = cq.Id  AND  cgd.ContactGroupId=@ContactGroupID  
        WHERE   Eg.Id = @ActivityId   
    END;
