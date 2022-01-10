-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Sep 2015>
-- Description:	<Description,,>
-- Call SP:		GetEstablishmentByActivityForReports 3, ''
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentByActivityForReports]
    @ActivityId BIGINT ,
    @Search NVARCHAR(50)
AS
    BEGIN
        DECLARE @QuestionnaireId BIGINT;
        SELECT  @QuestionnaireId = Eg.QuestionnaireId
        FROM    dbo.EstablishmentGroup AS Eg
        WHERE   Id = @ActivityId;

        SELECT  E.Id ,
                E.EstablishmentName
        FROM    dbo.EstablishmentGroup AS Eg
                INNER JOIN dbo.Establishment AS E ON E.EstablishmentGroupId = Eg.Id
        WHERE   Eg.QuestionnaireId = @QuestionnaireId
                AND E.IsDeleted = 0
                AND Eg.IsDeleted = 0
                AND E.EstablishmentName LIKE '%' + @Search + '%'
        GROUP BY E.Id ,
                E.EstablishmentName
        ORDER BY E.EstablishmentName;
    END;