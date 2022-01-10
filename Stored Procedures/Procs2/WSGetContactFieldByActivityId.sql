-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactFieldByActivityId 3
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactFieldByActivityId] @ActivityId BIGINT
AS
    BEGIN
        SELECT  Q.Id ,
                Q.IsDisplayInSummary ,
                Q.IsDisplayInDetail ,
                Q.IsGroupField ,
                Q.Position ,
                Q.QuestionTypeId ,
                Q.QuestionTitle ,
                Q.ShortName
        FROM    dbo.EstablishmentGroup AS Eg
                OUTER APPLY dbo.Split(Eg.ContactQuestion, ',') AS CQ
                INNER JOIN dbo.ContactQuestions AS Q ON Q.Id = CQ.Data
        WHERE   Eg.Id = @ActivityId
                AND Q.IsDeleted = 0
				ORDER BY Q.Position;
    END;