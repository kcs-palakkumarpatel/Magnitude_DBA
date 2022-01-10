-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 13 03 2021>
-- Description:	<Description,,InsertOrUpdateQuestionnaireWithoutput]>
-- Call SP    :	[InsertOrUpdateQuestionnaireWithoutput]
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateQuestionnaireWithoutput]
    @Id BIGINT,
    @QuestionnaireTitle NVARCHAR(MAX),
    @QuestionnaireType NVARCHAR(10),
    @Description NVARCHAR(MAX),
    @QuestionnaireFormType NVARCHAR(50),
    @DeletedContactQuestion NVARCHAR(50),
    @UserId BIGINT,
    @PageId BIGINT,
    @CompareType BIGINT,
    @FixedBenchmark DECIMAL(18, 2),
    @TestTime NVARCHAR(10),
    @LastTestDate DATE,
    @EscalationValue BIGINT,
    @IsMultipleRouting BIT,
    @ControlStyleId BIGINT =1,
	@lgQuestionnaireId BIGINT OUTPUT
AS
BEGIN
IF (@ControlStyleId = 0)
	BEGIN
		SET @ControlStyleId = 1
	END
    IF (@Id = 0)
    BEGIN
	    DECLARE @RealPageID BIGINT; -- This will fall away if code gets fixed
        SELECT TOP 1
            @RealPageID = Id
        FROM dbo.Page
        WHERE PageName = 'Questionnaire';

        INSERT INTO dbo.[Questionnaire]
        (
            [QuestionnaireTitle],
            [QuestionnaireType],
            [Description],
            [QuestionnaireFormType],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [CompareType],
            [FixedBenchMark],
            [TestTime],
            [LastTestDate],
            [EscalationValue],
            [IsMultipleRouting],
            [ControlStyleId]
        )
        VALUES
        (@QuestionnaireTitle,
         @QuestionnaireType,
         @Description,
         @QuestionnaireFormType,
         GETUTCDATE(),
         @UserId,
         0  ,
         @CompareType,
         @FixedBenchmark,
         @TestTime,
         @LastTestDate,
         @EscalationValue,
         @IsMultipleRouting,
         @ControlStyleId
        );
        SELECT @Id = SCOPE_IDENTITY();
		SET @lgQuestionnaireId = @Id
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
        (@UserId, @PageId, 'Insert record in table Questionnaire', 'Questionnaire', @Id, GETUTCDATE(), @UserId, 0);

        INSERT INTO dbo.[UserRolePermissions]
        (
            [PageID],
            [ActualID],
            [UserID],
            [CreatedOn],
            [CreatedBy],
            [UpdatedOn],
            [UpdatedBy],
            [DeletedOn],
            [DeletedBy],
            [IsDeleted]
        )
        VALUES
        (@RealPageID, @Id, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);
    END;
    ELSE
    BEGIN
	PRINT 1
	PRINT @ControlStyleId
        ----IF @DeletedContactQuestion = ''
        ----    OR @DeletedContactQuestion IS NULL
        ----    BEGIN
        ----        UPDATE  A
        ----        SET     A.IsDeleted = 1 ,
        ----                A.DeletedOn = GETUTCDATE() ,
        ----                A.DeletedBy = @UserId
        ----        FROM    dbo.AnswerMaster AS Am
        ----                INNER JOIN dbo.Answers AS A ON A.AnswerMasterId = Am.Id
        ----        WHERE   Am.QuestionnaireId = @Id
        ----                AND A.IsDeleted = 0;

        ----        UPDATE  Am
        ----        SET     Am.IsDeleted = 1 ,
        ----                Am.DeletedOn = GETUTCDATE() ,
        ----                Am.DeletedBy = @UserId
        ----        FROM    dbo.AnswerMaster AS Am
        ----        WHERE   Am.QuestionnaireId = @Id
        ----                AND Am.IsDeleted = 0;
        ----    END;
        UPDATE dbo.[Questionnaire]
        SET [QuestionnaireTitle] = @QuestionnaireTitle,
            --[QuestionnaireType] = @QuestionnaireType ,
            --[QuestionnaireFormType] = @QuestionnaireFormType ,
            [Description] = @Description,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            [CompareType] = @CompareType,
            [FixedBenchMark] = @FixedBenchmark,
            [TestTime] = @TestTime,
            [LastTestDate] = @LastTestDate,
            [EscalationValue] = @EscalationValue,
            [IsMultipleRouting] = @IsMultipleRouting,
            [ControlStyleId] = @ControlStyleId
        WHERE [Id] = @Id;
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
        (@UserId, @PageId, 'Update record in table Questionnaire', 'Questionnaire', @Id, GETUTCDATE(), @UserId, 0);
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;

	SET @lgQuestionnaireId = @Id
END;

