-- =============================================
-- Author:				Vasu Patel
-- Create date:		23 Jan 2018
-- Description:		application user update with auto save
-- =============================================
CREATE PROCEDURE [dbo].[SetFormAutoSaveStatus]
    @AppUserId BIGINT ,
    @AutoSave BIT
AS
    BEGIN
        UPDATE  dbo.AppUser
        SET     AutoSave = @AutoSave, UpdatedOn = GETUTCDATE(), UpdatedBy = @AppUserId
        WHERE   Id = @AppUserId;
	
        SELECT  ISNULL(AutoSave, 0) AS AutoSave
        FROM    dbo.AppUser
        WHERE   Id = @AppUserId;
    END;
