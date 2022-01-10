-- =============================================
-- Author:			Sunil Patel
-- Create date:	03 Jan 2017
-- Description:	For Get Drafted Capture Forms Data
-- Call SP    :		DeleteDraftEntryById 92842
-- =============================================
CREATE PROCEDURE [dbo].[DeleteDraftEntryById]
    (
      @SeenClientAnswerMasterId BIGINT = 0 
	 )
AS
    BEGIN
        SET NOCOUNT ON;

        UPDATE  dbo.SeenClientAnswerMaster
        SET     DraftEntry = 0 ,
                IsDeleted = 1
        WHERE   Id = @SeenClientAnswerMasterId;
        UPDATE  dbo.SeenClientAnswers
        SET     IsDeleted = 1
        WHERE   SeenClientAnswerMasterId = @SeenClientAnswerMasterId;

    END;