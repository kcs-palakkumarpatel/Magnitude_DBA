-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactGroupDetailsByContactGroupId 5
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactGroupDetailsByContactGroupId]
    @ContactGroupId BIGINT
AS 
    BEGIN
        DECLARE @ContactMasterId BIGINT ,
            @GroupName NVARCHAR(255)
        SELECT  @ContactMasterId = ISNULL(CGR.ContactMasterId, 0) ,
                @GroupName = Cg.ContactGropName
        FROM    dbo.ContactGroup AS Cg
                LEFT OUTER JOIN dbo.ContactGroupRelation AS CGR ON Cg.Id = CGR.ContactGroupId AND CGR.IsDeleted = 0
        WHERE   Cg.IsDeleted = 0
                AND Cg.Id = @ContactGroupId

        SELECT  -1 AS QuestionId ,
                4 AS QuestionTypeId ,
                @GroupName AS Detail
        UNION
        SELECT  ContactQuestionId AS QuestionId ,
                CD.QuestionTypeId ,
                Detail
        FROM    dbo.ContactGroupDetails AS CD
                INNER JOIN dbo.ContactQuestions AS Cq ON CD.ContactQuestionId = Cq.Id
        WHERE   CD.IsDeleted = 0
                AND ContactGroupId = @ContactGroupId
                AND IsGroupField = 1 AND Cq.IsDeleted = 0
    END