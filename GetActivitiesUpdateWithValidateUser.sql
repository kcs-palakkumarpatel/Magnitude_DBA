-- =============================================
-- Author:		<Mittal Patel,,GD>
-- Create date: <Create Date,,21 Apr 2021>
-- Description:	<Description,,>
-- Call SP:		GetActivitiesUpdateWithValidateUser 'fedics', '67cfE4x5Ra18G7LA1pRAXA==', 135, '1970-01-01', 0, 'ThemeMDPI','false', 76
-- =============================================
CREATE PROCEDURE dbo.GetActivitiesUpdateWithValidateUser
    @UserName NVARCHAR(50),
    @Password NVARCHAR(100),
    @AppUserId BIGINT,
    @LastServerDate DATETIME,
    @ThemeId BIGINT,
    @Resolution NVARCHAR(50),
    @ResetBadge NVARCHAR(50),
    @GroupId BIGINT
AS
BEGIN
    EXEC dbo.WSValidateAppUserLogin @UserName = @UserName, -- nvarchar(50)
                                    @Password = @Password; -- nvarchar(100)

    EXEC dbo.WSGetAppUserInfoById @AppUserId = @AppUserId,           -- bigint
                                  @LastServerDate = @LastServerDate; -- datetime

    EXEC dbo.WSGetAppUserModule @AppUserId = @AppUserId; -- bigint

    EXEC dbo.WSGetThemeImageByThemeId @ThemeId = @ThemeId,               -- bigint
                                      @Resolution = @Resolution,         -- nvarchar(50)
                                      @LastServerDate = @LastServerDate; -- datetime

    IF @ResetBadge = 'true'
    BEGIN
        EXEC dbo.UpdateReadAction @AppUserId = @AppUserId; -- bigint
    END;

    EXEC dbo.GetAppUserActivities @AppUserId = @AppUserId,           -- bigint
                                  @LastServerDate = @LastServerDate; -- datetime

    EXEC dbo.GetActivityCountByAppUserId @AppUserId = @AppUserId; -- bigint

    EXEC dbo.WSGetHeaderSetting @GroupId = @GroupId,               -- bigint
                                @LastServerDate = @LastServerDate,
								@AppUserId = @AppUserId; -- datetime

    EXEC dbo.GetBaseCount @AppUserId = @AppUserId; -- bigint

	EXEC dbo.GetUserNotifyMessage @AppUserId = @AppUserId; -- int
	
END;
