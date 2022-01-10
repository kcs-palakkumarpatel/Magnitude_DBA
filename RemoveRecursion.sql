-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <16 May 2016>
-- Description:	<Remove Recursion Email>
-- =============================================
CREATE PROCEDURE dbo.RemoveRecursion @RefId BIGINT
AS
BEGIN
    --DECLARE @EmailId NVARCHAR(100);
    --IF EXISTS ( SELECT  Detail
    --            FROM    dbo.SeenClientAnswers
    --            WHERE   SeenClientAnswerMasterId = @RefId
    --                    AND QuestionTypeId = 10 )
    --    BEGIN
    --        SELECT  @EmailId = Detail
    --        FROM    dbo.SeenClientAnswers
    --        WHERE   SeenClientAnswerMasterId = @RefId
    --                AND QuestionTypeId = 10;
    --        UPDATE  dbo.PendingEmail
    --        SET     IsDeleted = 1
    --        WHERE   RefId = @RefId
    --                AND EmailId = @EmailId
    --                AND EmailSubject = 'Seenclient Form - Recursion' AND IsSent = 0;
    --    END;


    --DECLARE @Mobile NVARCHAR(100);
    --IF EXISTS ( SELECT  Detail
    --            FROM    dbo.SeenClientAnswers
    --            WHERE   SeenClientAnswerMasterId = @RefId
    --                    AND QuestionTypeId = 11 )
    --    BEGIN
    --        SELECT  @Mobile = Detail
    --        FROM    dbo.SeenClientAnswers
    --        WHERE   SeenClientAnswerMasterId = @RefId
    --                AND QuestionTypeId = 11;
    --        UPDATE  dbo.PendingEmail
    --        SET     IsDeleted = 1
    --        WHERE   RefId = @RefId
    --                AND EmailId = @EmailId AND IsSent = 0; --AND EmailSubject = 'Seenclient Form - Recursion'
    --    END;

    --    UPDATE  dbo.SeenClientAnswerMaster
    --    SET     IsRecursion = 0
    --    WHERE   Id = @RefId;

    UPDATE dbo.PendingEmail
    SET IsDeleted = 1,
        DeletedBy = 1,
        DeletedOn = GETUTCDATE()
    WHERE RefId = @RefId
          AND EmailSubject = 'Seenclient Form - Recursion'
          AND IsSent = 0;

    UPDATE dbo.PendingEmail
    SET IsDeleted = 1,
        DeletedBy = 1,
        DeletedOn = GETUTCDATE()
    WHERE RefId = @RefId
          AND IsRecursion = 1;

    UPDATE dbo.PendingSMS
    SET IsDeleted = 1,
        DeletedBy = 1,
        DeletedOn = GETUTCDATE()
    WHERE RefId = @RefId
          AND IsRecursion = 1;

    UPDATE dbo.SeenClientAnswerMaster
    SET IsRecursion = 0
    WHERE Id = @RefId;
END;
