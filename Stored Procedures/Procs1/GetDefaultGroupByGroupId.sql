-- =============================================
-- Author:		Vasudev Patel
-- Create date: 13 Dec 2016
-- Description:	
--  Exec: GetDefaultGroupByGroupId 170,313
-- =============================================
CREATE PROCEDURE [dbo].[GetDefaultGroupByGroupId]
	@GroupId BIGINT,
	@AppUserId BIGINT
AS
BEGIN
SELECT  
		ISNULL(Dc.Id,0) AS Id
		,G.Id  AS GroupId,
        G.GroupName,
		CONVERT(VARCHAR(10),ISNULL(DC.ContactId,0))+ '_' + (CASE dc.IsGroup WHEN 1 THEN 'True' ELSE 'False' END) AS ContactId
FROM    dbo.[Group] AS G LEFT JOIN
		dbo.DefaultContact AS DC ON G.Id = DC.GroupId AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0
WHERE   G.Id = @GroupId
        AND G.IsDeleted = 0;
END