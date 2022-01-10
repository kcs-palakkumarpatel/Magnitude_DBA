-- =============================================
-- Author:		Disha Patel
-- Create date: 25-OCT-2016
-- Description:	Delete Feedbacks. If OUT Feedback is deleted, delete all its referenced IN Feedbacks
-- Call SP    :		dbo.DeleteFeedback 1277938, 1, 0, 1, 1
-- =============================================
CREATE PROCEDURE dbo.DeleteFeedback
    @ReportId BIGINT,
    @IsOut BIT,
    @SeenClientAnswerMasterId BIGINT,
    @DeletedBy BIGINT,
    @PageId BIGINT
AS
BEGIN
    IF @IsOut = 0 /* IN */
    BEGIN
        UPDATE dbo.AnswerMaster
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE [Id] = @ReportId;

        UPDATE dbo.Answers
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE AnswerMasterId = @ReportId;

        UPDATE dbo.CloseLoopAction
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE AnswerMasterId = @ReportId;

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@DeletedBy,
         @PageId,
         'Delete Feedback in table AnswerMaster,Answers and CloseLoopAction',
         'AnswerMaster,Answers and CloseLoopAction',
         @ReportId,
         GETUTCDATE(),
         @DeletedBy,
         0
        );
    END;
    ELSE IF @IsOut = 1 /* OUT */
    BEGIN
        UPDATE dbo.SeenClientAnswerMaster
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DraftEntry = 0,
            DeletedOn = GETUTCDATE()
        WHERE [Id] = @ReportId;

        UPDATE dbo.SeenClientAnswers
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE SeenClientAnswerMasterId = @ReportId;

        UPDATE dbo.SeenClientAnswerChild
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE SeenClientAnswerMasterId = @ReportId;

        UPDATE dbo.CloseLoopAction
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE SeenClientAnswerMasterId = @ReportId;

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@DeletedBy,
         @PageId,
         'Delete Capture Feedback in table SeenClientAnswerMaster,SeenClientAnswerChild,SeenClientAnswers and CloseLoopAction',
         'SeenClientAnswerMaster,SeenClientAnswers',
         @ReportId,
         GETUTCDATE(),
         @DeletedBy,
         0
        );

        IF EXISTS
        (
            SELECT 1
            FROM dbo.AnswerMaster
            WHERE SeenClientAnswerMasterId = @ReportId
        )
        BEGIN
            UPDATE dbo.AnswerMaster
            SET IsDeleted = 1,
                DeletedBy = @DeletedBy,
                DeletedOn = GETUTCDATE()
            WHERE SeenClientAnswerMasterId = @ReportId;

            UPDATE A
            SET A.IsDeleted = 1,
                A.DeletedBy = @DeletedBy,
                A.DeletedOn = GETUTCDATE()
            FROM dbo.Answers A
                INNER JOIN dbo.AnswerMaster AM
                    ON A.AnswerMasterId = AM.Id
                       AND AM.SeenClientAnswerMasterId = @ReportId;

            UPDATE A
            SET A.IsDeleted = 1,
                A.DeletedBy = @DeletedBy,
                A.DeletedOn = GETUTCDATE()
            FROM dbo.CloseLoopAction A
                INNER JOIN dbo.AnswerMaster AM
                    ON A.AnswerMasterId = AM.Id
                       AND AM.SeenClientAnswerMasterId = @ReportId;

            INSERT INTO dbo.ActivityLog
            (
                UserId,
                PageId,
                AuditComments,
                TableName,
                RecordId,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (@DeletedBy,
             @PageId,
             'Delete SeenClient Referenced Feedbacks in table AnswerMaster and Answers',
             'AnswerMaster,Answers',
             @ReportId,
             GETUTCDATE(),
             @DeletedBy,
             0
            );
        END;

        UPDATE PM
        SET PM.IsDeleted = 1,
            PM.DeletedBy = @DeletedBy,
            PM.DeletedOn = GETUTCDATE()
        FROM dbo.PendingEmail PM
        WHERE PM.RefId = @ReportId;

        UPDATE PendingSMS
        SET IsDeleted = 1,
            DeletedBy = @DeletedBy,
            DeletedOn = GETUTCDATE()
        WHERE RefId = @ReportId;

    END;
END;
