-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 29-Dec-2020
-- Description: Insert Task by Export   
-- SP call:InsertSeenClientAnswerMasterWithJohnDeer 702930,32135,1
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerMasterByExport_backup]
(
    @ImportTaskTypeTableType ImportTaskTypeTableType READONLY,
    @ActivityID BIGINT,
    @EstablishmentID BIGINT,
    @AppUserID BIGINT,
    @NoOfRows INT,
    @ImportFileName VARCHAR(200) = ''
)
AS
BEGIN
    BEGIN TRY
        DECLARE @SeenClientID INT,
                @ContactUserID INT,
                @TimeOffSet BIGINT = 0,
                @SeenClientAnswerMasterID BIGINT = 0;
        SELECT TOP 1
            @ContactUserID = CM.Id
        FROM dbo.ContactDetails CD
            INNER JOIN dbo.AppUser AU
                ON AU.Id = @AppUserID
                   AND CD.QuestionTypeId = 10
                   AND CD.Detail = AU.Email
                   AND ISNULL(CD.IsDeleted, 0) = 0
            INNER JOIN dbo.ContactMaster CM
                ON CM.Id = CD.ContactMasterId
                   AND CM.GroupId = AU.GroupId;

        SELECT @SeenClientID = SeenClientId
        FROM dbo.EstablishmentGroup
        WHERE Id = @ActivityID;

        SELECT @TimeOffSet = TimeOffSet
        FROM dbo.Establishment
        WHERE Id = @EstablishmentID;

        SELECT @TimeOffSet = TimeOffSet
        FROM dbo.Establishment
        WHERE Id = @EstablishmentID;
        DECLARE @StatusHistory BIGINT = 0;
        DECLARE @Counter INT,
                @TotalCount INT,
                @InternalCounter INT,
                @InternalCounterCount INT,
                @ImportFileId INT;
        SET @Counter = 1;
        SET @TotalCount = @NoOfRows;

        INSERT INTO dbo.UnAllocatedTaskImportFileLog
        (
            FileName,
            EstablishmentGroupId,
            EstablishmentId,
            CreatedBy,
            CreatedOn
        )
        VALUES
        (   @ImportFileName,  -- FileName - varchar(200)
            @ActivityID,      -- EstablishmentGroupId - bigint
            @EstablishmentID, -- EstablishmentId - bigint
            @AppUserID,       -- CreatedBy - bigint
            GETUTCDATE()      -- CreatedOn - datetime
        );
        SET @ImportFileId = SCOPE_IDENTITY();

        WHILE (@Counter <= @TotalCount)
        BEGIN
            INSERT INTO dbo.SeenClientAnswerMaster
            (
                EstablishmentId,
                SeenClientId,
                AppUserId,
                IsOutStanding,
                Latitude,
                Longitude,
                TimeOffSet,
                IsPositive,
                EI,
                IsResolved,
                IsTransferred,
                IsActioned,
                ContactMasterId,
                IsSubmittedForGroup,
                ContactGroupId,
                PI,
                CreatedOn,
                CreatedBy,
                IsDeleted,
                IsRecursion,
                DraftEntry,
                Platform,
                DraftSave,
                IsFlag,
                IsUnAllocated,
                ImportFileId
            )
            VALUES
            (   @EstablishmentID, -- EstablishmentId - bigint
                @SeenClientID,    -- SeenClientId - bigint
                @AppUserID,       -- AppUserId - bigint
                1,                -- IsOutStanding - bit
                N'0.00',          -- Latitude - nvarchar(50)
                N'0.00',          -- Longitude - nvarchar(50)
                @TimeOffSet,      -- TimeOffSet - int
                N'Neutral',       -- IsPositive - nvarchar(10)
                0.00,             -- EI - decimal(18, 2)
                N'Unresolved',    -- IsResolved - nvarchar(10)
                0,                -- IsTransferred - bit
                0,                -- IsActioned - bit
                @ContactUserID,   -- ContactMasterId - bigint
                0,                -- IsSubmittedForGroup - bit
                NULL,             -- ContactGroupId - bigint
                -1.00,            -- PI - decimal(18, 2)
                GETUTCDATE(),     -- CreatedOn - datetime
                @AppUserID,       -- CreatedBy - bigint
                0,                -- IsDeleted - bit
                0,                -- IsRecursion - bit
                0,                -- DraftEntry - bit
                N'Web',           -- Platform - nvarchar(50)
                0,                -- DraftSave - int
                0,                -- IsFlag - bit
                1,                -- IsUnAllocated - bit
                @ImportFileId
            );

            SET @SeenClientAnswerMasterID = SCOPE_IDENTITY();

            IF EXISTS
            (
                SELECT StatusIconEstablishment
                FROM dbo.Establishment
                WHERE Id = @EstablishmentID
            )
            BEGIN
                INSERT INTO dbo.StatusHistory
                (
                    ReferenceNo,
                    EstablishmentStatusId,
                    UserId,
                    StatusDateTime,
                    Latitude,
                    IsOut,
                    Longitude,
                    CreatedOn,
                    CreatedBy,
                    UpdatedOn,
                    UpdatedBy,
                    DeletedOn,
                    DeletedBy,
                    IsDeleted
                )
                VALUES
                (   @SeenClientAnswerMasterID,                  -- ReferenceNo - bigint
                    (
                        SELECT Id
                        FROM dbo.EstablishmentStatus
                        WHERE EstablishmentId = @EstablishmentID
                              AND DefaultStartStatus = 1
                              AND IsDeleted = 0
                    ),                                          -- EstablishmentStautId - bigint
                    @AppUserID,                                 -- UserId - bigint
                    DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), --StatusDateTime   
                    0.0,                                        -- Latitude - nvarchar(50)
                    1,                                          -- IsOut - bit
                    0.0,                                        -- Longitude - nvarchar(50)
                    GETUTCDATE(),                               -- CreatedOn - datetime
                    @AppUserID,                                 -- CreatedBy - bigint
                    NULL,                                       -- UpdatedOn - datetime
                    0,                                          -- UpdatedBy - bigint
                    NULL,                                       -- DeletedOn - datetime
                    0,                                          -- DeletedBy - bigint
                    0                                           -- IsDeleted - bit		
                );

                SET @StatusHistory = SCOPE_IDENTITY();
                UPDATE dbo.SeenClientAnswerMaster
                SET StatusHistoryId = @StatusHistory
                WHERE Id = @SeenClientAnswerMasterID;

            END;

            SET @InternalCounter = 1;
            SELECT @InternalCounterCount = COUNT(*)
            FROM @ImportTaskTypeTableType
            WHERE GroupID = @Counter;

            DECLARE @MainTable AS TABLE
            (
                Id INT,
                Value NVARCHAR(MAX),
                QuestionID INT,
                QuestionTypeId INT
            );

            DELETE FROM @MainTable;

            INSERT INTO @MainTable
            (
                Id,
                Value,
                QuestionID,
                QuestionTypeId
            )
            SELECT ROW_NUMBER() OVER (ORDER BY QuestionID),
                   Value,
                   QuestionID,
                   QuestionTypeId
            FROM @ImportTaskTypeTableType
            WHERE GroupID = @Counter;

            WHILE (@InternalCounter <= @InternalCounterCount)
            BEGIN
                DECLARE @OptionToInsertId NVARCHAR(MAX) = '';
                SELECT @OptionToInsertId = COALESCE(@OptionToInsertId + ',', '') + CONVERT(NVARCHAR(50), SCO.Id)
                FROM dbo.SeenClientOptions SCO
                    INNER JOIN @MainTable MT
                        ON MT.QuestionID = SCO.QuestionId
                WHERE SCO.Name IN (
                                      SELECT DISTINCT Data FROM dbo.Split(MT.Value, ',')
                                  )
                      AND MT.Id = @InternalCounter
                ORDER BY Position;


                DECLARE @OptionId NVARCHAR(MAX);
                INSERT INTO dbo.SeenClientAnswers
                (
                    SeenClientAnswerMasterId,
                    SeenClientAnswerChildId,
                    QuestionId,
                    OptionId,
                    QuestionTypeId,
                    Detail,
                    Weight,
                    QPI,
                    CreatedOn,
                    CreatedBy,
                    IsDeleted,
                    IsDisabled,
                    RepetitiveGroupId,
                    RepetitiveGroupName,
                    RepeatCount,
                    IsNA
                )
                SELECT @SeenClientAnswerMasterID,
                       0,
                       MT.QuestionID,
                       ISNULL(
                       (
                           SELECT STUFF(
                                           (
                                               SELECT ', ' + CAST(Id AS VARCHAR(10)) [text()]
                                               FROM dbo.SeenClientOptions
                                               WHERE QuestionId = MT.QuestionID
                                                     AND Name IN (
                                                                     SELECT DISTINCT Data FROM dbo.Split(MT.Value, ',')
                                                                 )
                                               FOR XML PATH(''), TYPE
                                           ).value('.', 'NVARCHAR(MAX)'),
                                           1,
                                           2,
                                           ' '
                                       ) List_Output
                           FROM dbo.SeenClientOptions t
                           WHERE t.QuestionId = MT.QuestionID
                                 AND t.Name IN (
                                                   SELECT DISTINCT Data FROM dbo.Split(MT.Value, ',')
                                               )
                           GROUP BY t.QuestionId
                       ),
                       0
                             ),
                       MT.QuestionTypeId,
                       MT.Value,
                       0.00,
                       0.00,
                       GETUTCDATE(),
                       @AppUserID,
                       0,
                       0,
                       SCQ.QuestionsGroupNo,
                       SCQ.QuestionsGroupName,
                       1,
                       0
                FROM @MainTable MT
				INNER JOIN dbo.SeenClientQuestions AS SCQ ON SCQ.Id = MT.QuestionID
                WHERE MT.Id = @InternalCounter;

                DECLARE @QuestionTypeId INT,
                        @Detail VARCHAR(1000),
                        @QuestionId BIGINT;
                SELECT @QuestionTypeId = QuestionTypeId,
                       @Detail = Value,
                       @QuestionId = QuestionID
                FROM @MainTable
                WHERE Id = @InternalCounter;


                IF (@QuestionTypeId = 26 AND @Detail <> '')
                BEGIN
                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM dbo.SeenClientOptions
                        WHERE QuestionId = @QuestionId
                              AND IsDeleted = 0
                              AND Name = @Detail
                    )
                    BEGIN
                        INSERT INTO dbo.SeenClientOptions
                        (
                            QuestionId,
                            Position,
                            Name,
                            Value,
                            DefaultValue,
                            [Weight],
                            Point,
                            QAEnd,
                            CreatedOn,
                            CreatedBy,
                            IsDeleted
                        )
                        SELECT @QuestionId,           -- QuestionId - bigint
                               0,                     -- Position - int
                               RTRIM(LTRIM(@Detail)), -- Name - nvarchar(255)
                               RTRIM(LTRIM(@Detail)), -- Value - nvarchar(max)
                               0,                     -- DefaultValue - bit
                               0,                     -- Weight - decimal
                               0,                     -- Point - decimal
                               0,                     -- QAEnd - bit
                               GETUTCDATE(),          -- CreatedOn - datetime
                               @AppUserID,            -- CreatedBy - bigint
                               0;                     -- IsDeleted - bit
                    END;
                END;
                SET @InternalCounter = @InternalCounter + 1;
                CONTINUE;
            END;
            SET @Counter = @Counter + 1;
            CONTINUE;
        END;

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
         'dbo.InsertOrUpdateSeenClientQuestions',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @AppUserID,
         N'',
         GETUTCDATE(),
         @AppUserID
        );
    END CATCH;
END;
