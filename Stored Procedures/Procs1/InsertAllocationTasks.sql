-- =============================================
-- Author:		Krishna Panchal
-- Create date: 21/Jan/2021
-- Description:	Insert Allocation Tasks bunch to user 
-- Call SP:		
-- =============================================
CREATE PROCEDURE dbo.InsertAllocationTasks @UserTaskAllocationTableType UserTaskAllocationTableType READONLY
AS
BEGIN
    BEGIN TRY

        DECLARE @RegisterSeenClientEmailSMS_Unallocatedtbl AS RegisterSeenClientEmailSMSTableType;
        INSERT INTO @RegisterSeenClientEmailSMS_Unallocatedtbl
        (
            lgAnswerMasterId,
            SeenClientAnswerChildId,
            lgSeenClientId,
            lgEstablishmentId,
            lgAppUserId,
            EncryptedId,
            lstReoccurring,
            Resend
        )
        SELECT UTA.SeenClientAnswerMasterId AS lgAnswerMasterId,
               '' AS SeenClientAnswerChildId,
               SCA.SeenClientId AS lgSeenClientId,
               SCA.EstablishmentId AS lgEstablishmentId,
               UTA.AppUserId AS lgAppUserId,
               UTA.EncryptedId AS EncryptedId,
               '' AS lstReoccurring,
               'false' AS Resend
        FROM dbo.SeenClientAnswerMaster SCA
            INNER JOIN @UserTaskAllocationTableType UTA
                ON SCA.Id = UTA.SeenClientAnswerMasterId
        WHERE SCA.IsDeleted = 0
              AND UTA.AllocationType = 0
        ORDER BY Id DESC;
        EXEC dbo.RegisterSeenClientUnallocatedNotification @RegisterSeenClientEmailSMS = @RegisterSeenClientEmailSMS_Unallocatedtbl; -- RegisterSeenClientEmailSMSTableType

        UPDATE SCA
        SET SCA.IsUnAllocated = 0,
            SCA.AppUserId = UTA.AppUserId,
            SCA.ContactMasterId = UTA.ContactMasterId
        FROM dbo.SeenClientAnswerMaster SCA
            INNER JOIN @UserTaskAllocationTableType UTA
                ON SCA.Id = UTA.SeenClientAnswerMasterId
        WHERE SCA.IsDeleted = 0
              AND UTA.AllocationType = 1;

        UPDATE SCA
        SET SCA.IsUnAllocated = 1,
            SCA.AppUserId = UTA.AppUserId,
            SCA.ContactMasterId = UTA.ContactMasterId
        FROM dbo.SeenClientAnswerMaster SCA
            INNER JOIN @UserTaskAllocationTableType UTA
                ON SCA.Id = UTA.SeenClientAnswerMasterId
        WHERE SCA.IsDeleted = 0
              AND UTA.AllocationType = 0;

        UPDATE RS
        SET RS.DeletedOn = GETUTCDATE(),
            RS.IsDeleted = 1
        FROM dbo.RecurringSetting RS
            INNER JOIN @UserTaskAllocationTableType UTA
                ON RS.SeenClientAnswerMasterId = UTA.SeenClientAnswerMasterId
        WHERE ISNULL(RS.IsDeleted, 0) = 0
              AND UTA.AllocationType = 0;

        DECLARE @Counter INT,
                @TotalCount INT,
                @SeenClientId BIGINT,
                @SeenClientAnswerIdForEmail BIGINT,
                @SeenClientAnswerIdForName BIGINT,
                @ContactMasterID BIGINT,
                @Email VARCHAR(200),
                @Name VARCHAR(500);
        DECLARE @Temptbl AS TABLE
        (
            Id INT PRIMARY KEY IDENTITY(1, 1),
            SeenClientID BIGINT,
            ContactMasterID BIGINT
        );
        INSERT INTO @Temptbl
        (
            SeenClientID,
            ContactMasterID
        )
        SELECT SeenClientAnswerMasterId,
               ContactMasterId
        FROM @UserTaskAllocationTableType
        WHERE AllocationType = 1;

        SET @Counter = 1;
        SET @TotalCount =
        (
            SELECT COUNT(1)
            FROM @UserTaskAllocationTableType
            WHERE AllocationType = 1
        );
        WHILE (@Counter <= @TotalCount)
        BEGIN
            SELECT @SeenClientId = SeenClientID,
                   @ContactMasterID = ContactMasterID
            FROM @Temptbl
            WHERE Id = @Counter;

            SELECT DISTINCT TOP 1
                @SeenClientAnswerIdForEmail = SCA.Id
            FROM dbo.SeenClientAnswers SCA
                INNER JOIN dbo.SeenClientQuestions SCQ
                    ON SCQ.Id = SCA.QuestionId
                INNER JOIN dbo.ContactDetails CD
                    ON CD.ContactQuestionId = SCQ.ContactQuestionId
            WHERE SCA.SeenClientAnswerMasterId = @SeenClientId
                  AND SCA.QuestionTypeId = 10
            ORDER BY SCA.Id ASC;

            SELECT DISTINCT TOP 1
                @SeenClientAnswerIdForName = SCA.Id
            FROM dbo.SeenClientAnswers SCA
                INNER JOIN dbo.SeenClientQuestions SCQ
                    ON SCQ.Id = SCA.QuestionId
                INNER JOIN dbo.ContactDetails CD
                    ON CD.ContactQuestionId = SCQ.ContactQuestionId
            WHERE SCA.SeenClientAnswerMasterId = @SeenClientId
                  AND SCA.QuestionTypeId = 4
            ORDER BY SCA.Id ASC;

            UPDATE dbo.SeenClientAnswers
            SET Detail =
                (
                    SELECT TOP 1
                        Detail
                    FROM dbo.ContactDetails CD
                        INNER JOIN dbo.SeenClientQuestions SCQ
                            ON SCQ.ContactQuestionId = CD.ContactQuestionId
                    WHERE CD.ContactMasterId = @ContactMasterID
                          AND CD.QuestionTypeId = 10
                          AND ISNULL(CD.IsDeleted, 0) = 0
                )
            WHERE Id = @SeenClientAnswerIdForEmail;

            UPDATE dbo.SeenClientAnswers
            SET Detail =
                (
                    SELECT TOP 1
                        Detail
                    FROM dbo.ContactDetails CD
                        INNER JOIN dbo.SeenClientQuestions SCQ
                            ON SCQ.ContactQuestionId = CD.ContactQuestionId
                    WHERE CD.ContactMasterId = @ContactMasterID
                          AND CD.QuestionTypeId = 4
                          AND ISNULL(CD.IsDeleted, 0) = 0
                )
            WHERE Id = @SeenClientAnswerIdForName;
            SET @Counter = @Counter + 1;
            CONTINUE;
        END;

        DECLARE @RegisterSeenClientEmailSMS_tbl AS RegisterSeenClientEmailSMSTableType;
        INSERT INTO @RegisterSeenClientEmailSMS_tbl
        (
            lgAnswerMasterId,
            SeenClientAnswerChildId,
            lgSeenClientId,
            lgEstablishmentId,
            lgAppUserId,
            EncryptedId,
            lstReoccurring,
            Resend
        )
        SELECT UTA.SeenClientAnswerMasterId AS lgAnswerMasterId,
               '' AS SeenClientAnswerChildId,
               SCA.SeenClientId AS lgSeenClientId,
               SCA.EstablishmentId AS lgEstablishmentId,
               UTA.AppUserId AS lgAppUserId,
               UTA.EncryptedId AS EncryptedId,
               '' AS lstReoccurring,
               'false' AS Resend
        FROM dbo.SeenClientAnswerMaster SCA
            INNER JOIN @UserTaskAllocationTableType UTA
                ON SCA.Id = UTA.SeenClientAnswerMasterId
        WHERE SCA.IsDeleted = 0
              AND UTA.AllocationType = 1
        ORDER BY Id DESC;
        EXEC dbo.RegisterSeenClientEmailSMS_New @RegisterSeenClientEmailSMS = @RegisterSeenClientEmailSMS_tbl; -- RegisterSeenClientEmailSMSTableType

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
         'dbo.InsertAllocationTasks',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'',
         GETUTCDATE(),
         0
        );
    END CATCH;
END;
