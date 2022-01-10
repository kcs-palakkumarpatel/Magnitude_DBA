-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingById>
-- Call SP    :	GetHeaderSettingById 2
-- =============================================
CREATE PROCEDURE [dbo].[GetHeaderSettingById]
    @HeaderSettingId BIGINT
AS
    BEGIN        SELECT  [HeaderSettingId] AS HeaderSettingId ,
                [GroupId] AS GroupId ,
				[EstablishmentGroupId] AS ActivityId ,
                [HeaderName] AS HeaderName ,
                [HeaderValue] AS HeaderValue,
				ISNULL(LabelColor,'') AS LabelColor,
				ISNULL(IsLabel,0) AS IsLabel
        FROM    dbo.[HeaderSetting]
        WHERE   [HeaderSettingId] = @HeaderSettingId;    END;
