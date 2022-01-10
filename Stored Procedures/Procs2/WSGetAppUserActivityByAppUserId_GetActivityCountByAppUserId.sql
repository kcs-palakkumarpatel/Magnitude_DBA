CREATE PROC WSGetAppUserActivityByAppUserId_GetActivityCountByAppUserId @AppUserId BIGINT
AS
BEGIN
    EXEC dbo.WSGetAppUserActivityByAppUserId @AppUserId;

    EXEC GetActivityCountByAppUserId @AppUserId;

END;