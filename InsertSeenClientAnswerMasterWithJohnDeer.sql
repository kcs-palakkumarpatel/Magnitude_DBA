-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- SP call:InsertSeenClientAnswerMasterWithJohnDeer 911724,33283,1
-- =============================================
CREATE PROCEDURE dbo.InsertSeenClientAnswerMasterWithJohnDeer
(
    @lgAnswerMasterId BIGINT, --AnsweMasterId
    @lgToEstablishmentId BIGINT,
    @workflowMasterID BIGINT
)
AS
BEGIN
    DECLARE @Id BIGINT;
    DECLARE @SeenClientId BIGINT;
    DECLARE @AppUserId BIGINT = 6361;
    DECLARE @TimeOffSet INT;
    DECLARE @ContactMasterId BIGINT;
    DECLARE @IsSubmittedForGroup INT;
    DECLARE @ContactGroupId BIGINT = NULL;
    DECLARE @Platform NVARCHAR(200);

    SELECT @SeenClientId = ESG.SeenClientId,
           @TimeOffSet = ES.TimeOffSet
    FROM dbo.Establishment AS ES
        INNER JOIN dbo.EstablishmentGroup AS ESG
            ON ESG.Id = ES.EstablishmentGroupId
    WHERE ES.Id = @lgToEstablishmentId;

    SET @Platform = 'API Call';

    SELECT @ContactMasterId = ContactId,
           @IsSubmittedForGroup = IsGroup
    FROM DefaultContact
    WHERE AppUserId = @AppUserId
          AND EstablishmentId = @lgToEstablishmentId
          AND IsDeleted = 0;

    PRINT @ContactMasterId;
    PRINT @IsSubmittedForGroup;

    IF (@IsSubmittedForGroup > 0)
    BEGIN
        SET @ContactMasterId = NULL;
        SELECT @ContactGroupId = ContactId
        FROM DefaultContact
        WHERE AppUserId = @AppUserId
              AND EstablishmentId = @lgToEstablishmentId
              AND IsDeleted = 0;
    END;

    IF @IsSubmittedForGroup IS NOT NULL
    BEGIN
        PRINT '1';
        INSERT INTO dbo.[SeenClientAnswerMaster]
        (
            [EstablishmentId],
            [SeenClientId],
            [AppUserId],
            [Latitude],
            [Longitude],
            [TimeOffSet],
            [ContactMasterId],
            [IsSubmittedForGroup],
            [ContactGroupId],
            [CreatedBy],
            [EI],
            [IsPositive],
            [IsResolved],
            [MobileDate],
            [CopyReferenceID],
            [DraftEntry],
            [IsDeleted],
            [CreatedOn],
            [Platform],
            [DraftSave]
        )
        SELECT @lgToEstablishmentId,
               @SeenClientId,
               @AppUserId,
               Latitude,
               Longitude,
               @TimeOffSet,
               @ContactMasterId,
               @IsSubmittedForGroup,
               @ContactGroupId,
               @AppUserId,
               EI,
               'Neutral',
               IsResolved,
               NULL,
               NULL,
               0,
               IsDeleted,
               CreatedOn,
               @Platform,
               0
        FROM dbo.AnswerMaster
        WHERE Id = @lgAnswerMasterId
              AND IsDeleted = 0;

        SET @Id = SCOPE_IDENTITY();

        EXEC dbo.InsertSeenClientAnswerJohnDeer @Id,
                                                @lgToEstablishmentId,
                                                @workflowMasterID,
                                                @AppUserId,
                                                @lgAnswerMasterId;

        EXEC CalculatePerformanceIndex @Id, 1;

        EXEC SeenclientandFeedbackIspositiveUpdate @Id, 1;
    END;
    PRINT @Id;
    IF (@Id > 0)
    BEGIN
        UPDATE dbo.MapingWorkFlowData
        SET isActioned = 1
        WHERE fromReferenceNumber = @lgAnswerMasterId;
    END;
    SELECT SAM.Id AS lgAnswerMasterId,
           SAM.SeenClientId AS lgSeenClientId,
           0 AS SeenClientAnswerChildId,
           SAM.EstablishmentId AS lgEstablishmentId,
           SAM.AppUserId AS lgAppUserId
    FROM dbo.SeenClientAnswerMaster AS SAM
    WHERE SAM.Id = @Id
    UNION
    SELECT SAM.Id AS lgAnswerMasterId,
           SAM.SeenClientId AS lgSeenClientId,
           SC.Id AS SeenClientAnswerChildId,
           SAM.EstablishmentId AS lgEstablishmentId,
           SAM.AppUserId AS lgAppUserId
    FROM dbo.SeenClientAnswerChild AS SC
        INNER JOIN dbo.SeenClientAnswerMaster AS SAM
            ON SAM.Id = SC.SeenClientAnswerMasterId
    WHERE SAM.Id = @Id;
END;
