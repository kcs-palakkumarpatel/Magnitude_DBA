/*
 =============================================
 Author		:	Hitesh Darji	
 Create date:	22-Feb-2017
 Description:	Search keywords
 Call SP    :	WSSearchKeyword 'CF', 429, 'good'
 =============================================
*/
CREATE PROCEDURE [dbo].[WSSearchKeyword]
    @Category VARCHAR(3) ,
    @ActivityId BIGINT ,
    @SearchText VARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  TOP 50 SA.Keyword
        FROM    dbo.SearchAnalytics SA
        WHERE   SA.Category = @Category
                AND SA.ActivityId = @ActivityId
                AND SA.Keyword LIKE '%' + @SearchText + '%'
				ORDER BY SA.EntryDate DESC
        SET NOCOUNT OFF;
    END;
