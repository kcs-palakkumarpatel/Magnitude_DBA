-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingById>
-- Call SP    :	GetHeaderSettingByGroupId 201
-- =============================================
CREATE PROCEDURE [dbo].[GetHeaderSettingByGroupId_17Sept2021] @GroupId BIGINT
AS
BEGIN
    SELECT *
    FROM
    (
        SELECT ISNULL(HS.HeaderId, WAH.Id) AS HeaderId,
               ISNULL([GroupId], 0) AS GroupId,
               ISNULL([HeaderName], WAH.LabelName) AS HeaderName,
               ISNULL([HeaderValue], '') AS HeaderValue,
               ISNULL(HS.LabelColor, '') AS LabelColor,
               ISNULL(HS.IsLabel, '') AS IsLabel
        FROM dbo.WebAppHeaders AS WAH
            LEFT JOIN dbo.[HeaderSetting] AS HS
                ON WAH.LabelName = HS.HeaderName
                   AND GroupId = @GroupId
        WHERE EXISTS (Select  WAH.Id from dbo.WebAppHeaders where  WAH.Id = 1 OR  WAH.Id = 2 OR  WAH.Id = 17OR  WAH.Id = 33 OR  WAH.Id = 34 )
              AND HS.IsDeleted = 0
    ) AS HD
    GROUP BY HeaderId,
             GroupId,
             HeaderName,
             HeaderValue,
             HD.LabelColor,
             HD.IsLabel;
END;
