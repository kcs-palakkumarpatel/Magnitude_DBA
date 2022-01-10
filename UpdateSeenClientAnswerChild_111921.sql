
-- =============================================
-- Author:		Sunil Vaghasiya
-- Create date: 06-Jan-2017
-- Description:	Update group users in child table "[SeenClientAnswerChild]"
-- Call SP    :		dbo.UpdateSeenClientAnswerChild 256122,399
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSeenClientAnswerChild_111921]
    @SeenClientAnswerMasterId BIGINT,
    @ContactMasterId BIGINT
AS
BEGIN
    DECLARE @Id BIGINT = 0;
    SELECT @Id = Id
    FROM dbo.SeenClientAnswerChild WITH
        (NOLOCK)
    WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ContactMasterId = @ContactMasterId;
    IF NOT EXISTS
    (
        SELECT Id
        FROM dbo.SeenClientAnswerChild WITH
            (NOLOCK)
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND ContactMasterId = @ContactMasterId
    )
    BEGIN
        PRINT 1;
        INSERT INTO dbo.SeenClientAnswerChild
        (
            SeenClientAnswerMasterId,
            ContactMasterId
        )
        VALUES
        (@SeenClientAnswerMasterId, @ContactMasterId);
        SELECT @Id = Id
        FROM dbo.SeenClientAnswerChild WITH
            (NOLOCK)
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND ContactMasterId = @ContactMasterId;
    END;
    ELSE
    BEGIN
        UPDATE dbo.SeenClientAnswerChild
        SET SeenClientAnswerMasterId = @SeenClientAnswerMasterId,
            ContactMasterId = @ContactMasterId
        WHERE Id = @Id;
    END;
    SELECT ISNULL(@Id, 0) AS UpdateId;
END;
