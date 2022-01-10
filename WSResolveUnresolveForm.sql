-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSResolveUnresolveForm
-- =============================================
CREATE PROCEDURE [dbo].[WSResolveUnresolveForm]
    @ReportId BIGINT,
    @IsResolved NVARCHAR(20),
    @AppUserId BIGINT,
    @IsOut BIT
AS
BEGIN
    DECLARE @ResolvedFromOut BIT;
    IF @IsOut = 00
    BEGIN
        SELECT @ResolvedFromOut = CASE
                                      WHEN ISNULL(SeenClientAnswerMasterId, 0) > 0 THEN
                                          1
                                      ELSE
                                          0
                                  END
        FROM dbo.AnswerMaster
        WHERE Id = @ReportId;
    END;
    ELSE
    BEGIN
        SET @ResolvedFromOut = 0;
    END;


    DECLARE @Attachment VARCHAR(MAX),
            @lgCustomerUserId BIGINT,
            @CustomerName NVARCHAR(MAX);
    IF @IsOut = 1
    BEGIN
        UPDATE dbo.SeenClientAnswerMaster
        SET IsResolved = @IsResolved,
            UpdatedBy = @AppUserId
        WHERE Id = @ReportId;
    END;
    ELSE
    BEGIN
        UPDATE dbo.AnswerMaster
        SET IsResolved = @IsResolved,
            UpdatedBy = @AppUserId
        WHERE Id = @ReportId;
    END;
	   
    DECLARE @Message VARCHAR(100) = '';
    SET @Message = @IsResolved + ' - Ref# ' + CONVERT(varchar(25), @ReportId);
    IF (@ResolvedFromOut = 0)
    BEGIN
        EXEC dbo.InsertCloseLoopAction @AppUserId = @AppUserId,  -- bigint
                                       @Conversation = @Message, -- nvarchar(2000)
                                       @ReportId = @ReportId,    -- bigint
                                       @IsOut = @IsOut,          -- bit
                                       @ReminderDate = '',
                                       @Attachment = '',
                                       @lgCustomerUserId = NULL,
                                       @CustomerName = NULL;
        RETURN 1;
    END;
 RETURN 1;
END;
