-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 08-Aug-2021
-- Description: Get Recurring Setting
-- SP call: GetRecurringSetting 5819
-- =============================================
CREATE PROCEDURE [dbo].[DeleteRecurringSetting] @SeenClientAnswerMasterIds VARCHAR(MAX)
AS
BEGIN
    UPDATE dbo.RecurringSetting
    SET IsDeleted = 1,
        DeletedOn = GETUTCDATE()
    WHERE SeenClientAnswerMasterId IN (
                                          SELECT Data FROM dbo.Split(@SeenClientAnswerMasterIds, ',')
                                      );
END;
