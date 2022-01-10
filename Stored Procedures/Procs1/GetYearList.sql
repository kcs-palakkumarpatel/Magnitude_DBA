-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Sep 2015>
-- Description:	<Description,,GetYearList>
-- =============================================
CREATE PROCEDURE [dbo].[GetYearList]
AS
    BEGIN
        SELECT  ISNULL(DATEPART(YEAR, CreatedOn), 0) AS [Year]
        FROM    dbo.AnswerMaster
        GROUP BY DATEPART(YEAR, CreatedOn)
        ORDER BY [Year] DESC;
    END;