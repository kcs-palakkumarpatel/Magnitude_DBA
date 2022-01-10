-- =============================================
-- Author:			D3
-- Create date:	11 Dec 2017
-- Description:	
-- Call:dbo.InsertOrUpdateDefaultContact 331842,null,null,11601,362222,1246,0,1246,1,0
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateDefaultContact]
(
    @Id BIGINT,
    @GroupId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId BIGINT,
    @ContactId BIGINT,
    @AppUserId BIGINT,
    @IsGroup BIT,
    @CreatedBy BIGINT,
    @IsDeleted BIT,
    @IsSelectAll BIT
)
AS
SET NOCOUNT ON;
IF (@IsSelectAll = 0)
BEGIN
    PRINT '1';
    IF (@Id = 0)
    BEGIN
        PRINT '2';
        SELECT @Id = ISNULL(Id, 0)
        FROM dbo.DefaultContact
        WHERE (
                  ISNULL(GroupId, 0) = @GroupId
                  OR ISNULL(ActivityId, 0) = @ActivityId
                  OR ISNULL(EstablishmentId, 0) = @EstablishmentId
              )
              AND AppUserId = @AppUserId
              AND IsDeleted = 0;
    END;

    IF @Id = 0
    BEGIN
        PRINT '3';
        INSERT INTO DefaultContact
        (
            [GroupId],
            [ActivityId],
            [EstablishmentId],
            [ContactId],
            [AppUserId],
            [IsGroup],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted]
        )
        VALUES
        (@GroupId, @ActivityId, @EstablishmentId, @ContactId, @AppUserId, @IsGroup, GETDATE(), @CreatedBy, @IsDeleted);
        SELECT CONVERT(BIGINT, SCOPE_IDENTITY()) AS InsertedID;
    END;
    ELSE
    BEGIN
        PRINT '4';
        IF @IsDeleted = 1
        BEGIN
            PRINT '5';
            IF (ISNULL(@EstablishmentId, 0) != 0)
            BEGIN
			PRINT 'E'
                UPDATE dbo.DefaultContact
                SET IsDeleted = 1,
                    DeletedOn = GETUTCDATE(),
                    DeletedBy = @CreatedBy
                WHERE ContactId = @ContactId AND AppUserId = @AppUserId AND EstablishmentId = @EstablishmentId;
            END;

            IF (ISNULL(@ActivityId, 0) != 0)
            BEGIN
                UPDATE dbo.DefaultContact
                SET IsDeleted = 1,
                    DeletedOn = GETUTCDATE(),
                    DeletedBy = @CreatedBy
                WHERE ContactId = @ContactId AND AppUserId = @AppUserId  AND ActivityId = @ActivityId;
            END;

            IF (ISNULL(@GroupId, 0) != 0)
            BEGIN
                UPDATE dbo.DefaultContact
                SET IsDeleted = 1,
                    DeletedOn = GETUTCDATE(),
                    DeletedBy = @CreatedBy
                WHERE ContactId = @ContactId AND AppUserId = @AppUserId AND GroupId = @GroupId;
            END;
        END;
        ELSE
        BEGIN
            PRINT '6';
            UPDATE dbo.DefaultContact
            SET [GroupId] = @GroupId,
                [ActivityId] = @ActivityId,
                [EstablishmentId] = @EstablishmentId,
                [ContactId] = @ContactId,
                [AppUserId] = @AppUserId,
                [IsGroup] = @IsGroup,
                [UpdatedOn] = GETDATE(),
                [UpdatedBy] = @CreatedBy,
                IsDeleted = 0
            WHERE [Id] = @Id;
        END;

        SELECT ISNULL(@Id, 0) AS InsertedID;
    END;
END;
ELSE
BEGIN
    IF (@Id = 0)
    BEGIN
        PRINT '6';
        SELECT @Id = ISNULL(Id, 0)
        FROM dbo.DefaultContact
        WHERE (
                  ISNULL(GroupId, 0) = @GroupId
                  OR ISNULL(ActivityId, 0) = @ActivityId
                  OR ISNULL(EstablishmentId, 0) = @EstablishmentId
              )
              AND AppUserId = @AppUserId
              AND IsDeleted = 0;
    END;
    IF @Id = 0
    BEGIN
        PRINT '7';
        IF (ISNULL(@EstablishmentId, 0) != 0)
        BEGIN
            PRINT '8';
            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId = @EstablishmentId
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales'
				  AND AppUserId NOT IN (
											SELECT  AppUserId FROM    dbo.DefaultContact WHERE  EstablishmentId= @EstablishmentId AND IsDeleted=0 
									   )
				  ;
        END;
        ELSE IF (ISNULL(@ActivityId, 0) != 0)
        BEGIN
            PRINT '9';
            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId IN (
                                         SELECT Id FROM Establishment WHERE EstablishmentGroupId = @ActivityId
                                     )
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales'
            GROUP BY AppUserId;
        END;
        ELSE IF (ISNULL(@GroupId, 0) != 0)
        BEGIN
            PRINT '10';
            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId IN (
                                         SELECT Id FROM Establishment WHERE GroupId = @GroupId
                                     )
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales';
        END;

        SELECT CONVERT(BIGINT, SCOPE_IDENTITY()) AS InsertedID;
    END;
    ELSE
    BEGIN
        IF @IsDeleted = 1
        BEGIN
            PRINT '11';
            UPDATE dbo.DefaultContact
            SET IsDeleted = 1,
                DeletedOn = GETUTCDATE(),
                DeletedBy = @CreatedBy
            WHERE ContactId = @ContactId;
        END;
        ELSE
        BEGIN
            PRINT '12';
            UPDATE dbo.DefaultContact
            SET [GroupId] = @GroupId,
                [ActivityId] = @ActivityId,
                [EstablishmentId] = @EstablishmentId,
                [ContactId] = @ContactId,
                [AppUserId] = @AppUserId,
                [IsGroup] = @IsGroup,
                [UpdatedOn] = GETDATE(),
                [UpdatedBy] = @CreatedBy,
                IsDeleted = 0
            WHERE [Id] = @Id;
        END;

        SELECT ISNULL(@Id, 0) AS InsertedID;

        IF (ISNULL(@EstablishmentId, 0) != 0)
        BEGIN
            PRINT '13';
            DELETE FROM dbo.DefaultContact
            WHERE AppUserId IN (
                                   SELECT AppUserId
                                   FROM dbo.AppUserEstablishment
                                   WHERE EstablishmentId = @EstablishmentId
                                         AND IsDeleted = 0
                                         AND EstablishmentType = 'Sales'
                               )
                  AND DefaultContact.EstablishmentId = @EstablishmentId;

            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId = @EstablishmentId
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales';
        END;
        ELSE IF (ISNULL(@ActivityId, 0) != 0)
        BEGIN
            PRINT '14';
            DELETE FROM dbo.DefaultContact
            WHERE AppUserId IN (
                                   SELECT AppUserId
                                   FROM dbo.AppUserEstablishment
                                   WHERE EstablishmentId IN (
                                                                SELECT Id FROM Establishment WHERE EstablishmentGroupId = @ActivityId
                                                            )
                                         AND ActivityId = @ActivityId
                                         AND IsDeleted = 0
                                         AND EstablishmentType = 'Sales'
                               );

            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId IN (
                                         SELECT Id FROM Establishment WHERE EstablishmentGroupId = @ActivityId
                                     )
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales';
        END;
        ELSE IF (ISNULL(@GroupId, 0) != 0)
        BEGIN
            PRINT '15';
            DELETE FROM dbo.DefaultContact
            WHERE AppUserId IN (
                                   SELECT AppUserId
                                   FROM dbo.AppUserEstablishment
                                   WHERE EstablishmentId IN (
                                                                SELECT Id FROM Establishment WHERE GroupId = @GroupId
                                                            )
                                         AND IsDeleted = 0
                                         AND EstablishmentType = 'Sales'
                               );
            INSERT INTO DefaultContact
            (
                [GroupId],
                [ActivityId],
                [EstablishmentId],
                [ContactId],
                [AppUserId],
                [IsGroup],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted]
            )
            SELECT DISTINCT
                @GroupId,
                @ActivityId,
                @EstablishmentId,
                @ContactId,
                AppUserId,
                @IsGroup,
                GETDATE(),
                @CreatedBy,
                @IsDeleted
            FROM dbo.AppUserEstablishment
            WHERE EstablishmentId IN (
                                         SELECT Id FROM Establishment WHERE GroupId = @GroupId
                                     )
                  AND IsDeleted = 0
                  AND EstablishmentType = 'Sales';
        END;

        SELECT ISNULL(@Id, 0) AS InsertedID;

    END;
END;

SET NOCOUNT OFF;
