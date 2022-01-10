-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingAll>
-- Call SP    :	GetHeaderSettingAll
-- =============================================
CREATE PROCEDURE [dbo].[GetHeaderSettingAll]
AS
    BEGIN        SELECT  dbo.[HeaderSetting].[HeaderSettingId] AS HeaderSettingId ,
                dbo.[HeaderSetting].[GroupId] AS GroupId ,
                dbo.[Group].GroupName ,
                dbo.[HeaderSetting].[EstablishmentGroupId] AS ActivityId ,
                dbo.[EstablishmentGroup].EstablishmentGroupName AS ActivityName ,
                dbo.[HeaderSetting].[HeaderName] AS HeaderName ,
                dbo.[HeaderSetting].[HeaderValue] AS HeaderValue,
			    ISNULL(dbo.[HeaderSetting].LabelColor,'') AS LabelColor,
				ISNULL(dbo.[HeaderSetting].IsLabel,0) AS IsLabel
        FROM    dbo.[HeaderSetting]  WITH(NOLOCK)
                INNER JOIN dbo.[Group]  WITH(NOLOCK) ON dbo.[Group].Id = dbo.[HeaderSetting].GroupId
                INNER JOIN dbo.[EstablishmentGroup]  WITH(NOLOCK) ON dbo.[EstablishmentGroup].Id = dbo.[HeaderSetting].EstablishmentGroupId
        WHERE   dbo.[HeaderSetting].IsDeleted = 0;    END;
