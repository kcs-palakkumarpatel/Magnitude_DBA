--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
-- exec dbo.DeleteOTISdataOlder365
CREATE PROCEDURE DeleteOTISdataOlder365
AS
BEGIN

    DECLARE @AnswerMasterid TABLE (id INT);
    INSERT INTO @AnswerMasterid
    (
        id
    )
    SELECT Id
    FROM dbo.SeenClientAnswerMaster
    WHERE EstablishmentId = 23267
          AND CreatedOn < (GETUTCDATE() - 365);

    DELETE FROM dbo.SeenClientAnswers WHERE SeenClientAnswerMasterId IN (SELECT id FROM @AnswerMasterid);
    DELETE FROM dbo.SeenClientAnswerMaster WHERE Id IN (SELECT id FROM @AnswerMasterid);

END;