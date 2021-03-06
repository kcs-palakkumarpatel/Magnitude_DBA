
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		dbo.WSGetAppUserInfoById 4567,null
--  WSGetAppUserInfoById_101120 4567,nul
-- =============================================
/*
drop procedure WSGetAppUserInfoById_101120
*/
CREATE PROCEDURE [dbo].[WSGetAppUserInfoById]
    @AppUserId BIGINT,
    @LastServerDate DATETIME
AS
BEGIN
SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + 'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
	SELECT DISTINCT
        U.Id,
        Name,
        Email,
        Mobile,
        IsAreaManager,
        ISNULL(@Url + ImageName, '') AS ImageUrl
    FROM dbo.AppUser U
        LEFT JOIN dbo.DefaultContact DC
            ON DC.AppUserId = @AppUserId
               AND U.Id = DC.AppUserId
    WHERE U.Id = @AppUserId
          AND (ISNULL(U.UpdatedOn, U.CreatedOn) >= ISNULL(@LastServerDate, '1970-01-01')
              --OR @LastServerDate IS NULL
              )
          OR (ISNULL(DC.UpdatedOn, DC.CreatedOn) >= ISNULL(@LastServerDate, '1970-01-01'));
    --SELECT DISTINCT
    --    U.Id,
    --    Name,
    --    Email,
    --    Mobile,
    --    IsAreaManager,
    --    ISNULL(@Url + ImageName, '') AS ImageUrl
    --FROM dbo.AppUser U
    --    LEFT JOIN dbo.DefaultContact DC
    --        ON U.Id = DC.AppUserId
    --WHERE U.Id = @AppUserId
    --      AND DC.AppUserId = @AppUserId
    --      AND (ISNULL(U.UpdatedOn, U.CreatedOn) >= ISNULL(@LastServerDate, '1970-01-01'))
    --      OR (ISNULL(DC.UpdatedOn, DC.CreatedOn) >= ISNULL(@LastServerDate, '1970-01-01'));
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetAppUserInfoById',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
