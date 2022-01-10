
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSResolveUnresolveFormWithSatuts 114328,'Resolved',4486,1,'23.0301667','72.5707305'
-- =============================================
CREATE PROCEDURE [dbo].[WSResolveUnresolveFormWithSatuts_111921]
    @ReportId BIGINT,
    @IsResolved NVARCHAR(20),
    @AppUserId BIGINT,
    @IsOut BIT,
    @Latitude NVARCHAR(20) = '0.00',
    @Longitude NVARCHAR(20) = '0.00'
AS
BEGIN
    DECLARE @ResolvedFromOut BIT,
            @Offset INT,
            @LastStatusId INT,
            @CurrentStatusId INT,
            @LastStatusName VARCHAR(15),
            @ResolvedStatusName VARCHAR(15),
            @EstablishmentId INT,
            @Attachment VARCHAR(MAX),
            @lgCustomerUserId BIGINT,
            @CustomerName NVARCHAR(MAX),
            @UserName VARCHAR(50),
            @UnresolvedStatusName VARCHAR(50);
    IF @IsOut = 0
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

    SELECT @UserName = Name
    FROM dbo.AppUser
    WHERE Id = @AppUserId;


    DECLARE @EstablishmentStatusId BIGINT,
            @StatusDate DATETIME;
    SELECT @StatusDate = GETUTCDATE();
    IF (@IsResolved = 'Resolved')
    BEGIN
        (SELECT @EstablishmentStatusId = es.Id
         FROM dbo.EstablishmentStatus AS es
             INNER JOIN dbo.SeenClientAnswerMaster AS SA
                 ON es.EstablishmentId = SA.EstablishmentId
         WHERE SA.Id = @ReportId
               AND DefaultEndStatus = 1
               AND es.IsDeleted = 0);
    END;
    ELSE
    BEGIN
        (SELECT @EstablishmentStatusId = Es.Id
         FROM dbo.EstablishmentStatus AS es
             INNER JOIN dbo.SeenClientAnswerMaster AS SA
                 ON es.EstablishmentId = SA.EstablishmentId
         WHERE SA.Id = @ReportId
               AND es.DefaultStartStatus = 1
               AND es.isdeleted = 0);
    END;
    IF @IsOut = 1
    BEGIN
        UPDATE dbo.SeenClientAnswerMaster
        SET IsResolved = @IsResolved,
            UpdatedBy = @AppUserId
        --,statusHistoryId = @EstablishmentStatusId
        WHERE Id = @ReportId;

        IF EXISTS
        (
            SELECT *
            FROM dbo.AnswerMaster
            WHERE SeenClientAnswerMasterId = @ReportId
        )
        BEGIN
            UPDATE dbo.AnswerMaster
            SET IsResolved = @IsResolved,
                UpdatedBy = @AppUserId
            WHERE SeenClientAnswerMasterId = @ReportId;
        END;


        IF (@IsResolved = 'Resolved')
        BEGIN
            UPDATE PM
            SET PM.IsDeleted = 1,
                PM.DeletedBy = @AppUserId,
                PM.DeletedOn = GETUTCDATE()
            FROM dbo.PendingEmail PM
            WHERE PM.RefId = @ReportId
                  AND IsSent = 0;

            UPDATE PendingSMS
            SET IsDeleted = 1,
                DeletedBy = @AppUserId,
                DeletedOn = GETUTCDATE()
            WHERE RefId = @ReportId
                  AND IsSent = 0;
        END;
        ELSE
        BEGIN
            UPDATE PM
            SET PM.IsDeleted = 0,
                PM.DeletedBy = NULL,
                PM.DeletedOn = NULL
            FROM dbo.PendingEmail PM
            WHERE PM.RefId = @ReportId
                  AND PM.IsSent = 0;

            UPDATE PendingSMS
            SET IsDeleted = 0,
                DeletedBy = NULL,
                DeletedOn = NULL
            WHERE RefId = @ReportId
                  AND IsSent = 0;
        END;

    END;
    ELSE
    BEGIN

        UPDATE dbo.AnswerMaster
        SET IsResolved = @IsResolved,
            UpdatedBy = @AppUserId
        WHERE Id = @ReportId;

    END;
    SELECT @Offset = SA.TimeOffSet,
           @LastStatusId = SA.StatusHistoryId,
           @EstablishmentId = SA.EstablishmentId
    FROM dbo.SeenClientAnswerMaster AS SA
    WHERE SA.Id = @ReportId;
    IF (
       (
           SELECT StatusIconEstablishment
           FROM dbo.Establishment
           WHERE id = @EstablishmentId
                 AND IsDeleted = 0
       ) = 1
       )
    BEGIN
        PRINT '1';
        SELECT @LastStatusName = ES.StatusName
        FROM dbo.StatusHistory AS SH
            INNER JOIN dbo.EstablishmentStatus AS ES
                ON SH.EstablishmentStatusId = ES.Id
            INNER JOIN SeenClientAnswerMaster AS SA
                ON SH.Id = SA.StatusHistoryId
        WHERE SH.id = @LastStatusId;


        EXEC dbo.InsertStatusHistory @ReferenceNo = @ReportId,                        -- bigint
                                     @EstablishmentStatusId = @EstablishmentStatusId, -- bigint
                                     @UserId = @AppUserId,                            -- bigint
                                     @Latitude = @Latitude,                           -- nvarchar(50)
                                     @Longitude = @Longitude,                         -- nvarchar(50)
                                     @StatusDateTime = @StatusDate,                   -- datetime
                                     @isWeb = NULL;

        IF @IsOut = 1
        BEGIN
            UPDATE dbo.SeenClientAnswerMaster
            SET statusHistoryId =
                (
                    SELECT TOP 1
                        id
                    FROM dbo.StatusHistory
                    WHERE ReferenceNo = @ReportId
                    ORDER BY id DESC
                )
            WHERE Id = @ReportId;
        END;
        SELECT @ResolvedStatusName = StatusName
        FROM dbo.EstablishmentStatus
        WHERE EstablishmentId = @EstablishmentId
              AND DefaultEndStatus = 1
              AND IsDeleted = 0;
        SELECT @UnresolvedStatusName = StatusName
        FROM dbo.EstablishmentStatus
        WHERE EstablishmentId = @EstablishmentId
              AND DefaultStartStatus = 1
              AND IsDeleted = 0;

        DECLARE @Message VARCHAR(100) = '';
        IF (@IsResolved = 'Resolved')
        BEGIN

            SET @Message = 'Resolved - Ref# ' + CONVERT(varchar(25), @ReportId);
        END;
        ELSE
        BEGIN
            SET @Message = 'Unresolved - Ref# ' + CONVERT(varchar(25), @ReportId);
        END;

    END;
    ELSE
    BEGIN
        SET @Message = @IsResolved + ' - Ref# ' + CONVERT(varchar(25), @ReportId);


        DECLARE @TEMP TABLE
        (
            Id BIGINT,
            ReferenceNo BIGINT,
            StatusCounter VARCHAR(20),
            StatusId BIGINT,
            StatusImage VARCHAR(50),
            StatusName VARCHAR(50),
            StatusTime VARCHAR(50)
        );

        INSERT INTO @TEMP
        (
            Id,
            ReferenceNo,
            StatusCounter,
            StatusId,
            StatusImage,
            StatusName,
            StatusTime
        )
        VALUES
        (0, @ReportId, '', 0, '', '', '');
        SELECT *
        FROM @TEMP;


    END;

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
    END;

END;
