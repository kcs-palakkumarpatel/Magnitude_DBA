-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingById>
-- Call SP    :	GetHeaderSettingByGroupId 201
-- =============================================
CREATE PROCEDURE [dbo].[GetHeaderSettingByGroupId] @GroupId BIGINT
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
        WHERE WAH.Id IN ( 1, 2, 17, 33, 34 )
              AND HS.IsDeleted = 0
    ) AS HD
    GROUP BY HeaderId,
             GroupId,
             HeaderName,
             HeaderValue,
             HD.LabelColor,
             HD.IsLabel;
END;
