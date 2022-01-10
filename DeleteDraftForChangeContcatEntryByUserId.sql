-- =============================================
-- Author:			Sunil Patel
-- Create date:	03 Jan 2017
-- Description:	For Get Drafted Capture Forms Data
-- Call SP    :		DeleteDraftForChangeContcatEntryByUserId 1243
-- =============================================
CREATE PROCEDURE [dbo].[DeleteDraftForChangeContcatEntryByUserId] ( @UserID BIGINT )
AS
    BEGIN
        DECLARE @TempTable TABLE ( Id BIGINT );
        DECLARE @Id NVARCHAR(MAX);
        INSERT  INTO @TempTable
                ( Id
                )
                SELECT  Id
                FROM    SeenClientAnswerMaster
                WHERE   AppUserId = @UserID
                        AND DraftSave = 1; 

        DELETE  dbo.SeenClientAnswers
        WHERE   SeenClientAnswerMasterId IN ( SELECT    Id
                                              FROM      @TempTable );
        DELETE  dbo.SeenClientAnswerMaster
        WHERE   Id IN ( SELECT  Id
                        FROM    @TempTable );
     
	     SELECT 1 AS insertedId;

    END;
