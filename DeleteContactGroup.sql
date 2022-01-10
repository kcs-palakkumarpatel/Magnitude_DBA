-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-May-2017
-- Description:	Delete Contacts Group.
-- Call SP:			dbo.DeleteContactGroup
-- =============================================
CREATE PROCEDURE dbo.DeleteContactGroup
    @IdList NVARCHAR(MAX),
    @DeletedBy BIGINT,
    @PageId BIGINT
AS
BEGIN
    DECLARE @Start INT = 1,
            @Total INT,
            @IsUsed BIT,
            @Id BIGINT,
            @Result NVARCHAR(MAX) = '',
            @Count INT = 0;
    DECLARE @Tbl TABLE
    (
        Id INT,
        Data INT
    );
    INSERT INTO @Tbl
    (
        Id,
        Data
    )
    SELECT Id,
           Data
    FROM dbo.Split(@IdList, ',');

    SELECT @Total = COUNT(1)
    FROM @Tbl;
    WHILE @Start <= @Total
    BEGIN
        SELECT @Id = Data
        FROM @Tbl
        WHERE Id = @Start;
        EXEC dbo.IsReferenceExists N'ContactGroup', @Id, @IsUsed OUTPUT;

		/*below code is commented as it is preventing to delete 
		contact group if one of the contact of that group is used 
		to submit capture individually (Abhishek 24-12-2021) (#210524)*/
        --IF
        --(
        --    SELECT COUNT(1)
        --    FROM dbo.SeenClientAnswerMaster
        --    WHERE ContactMasterId IN (
        --                                 SELECT ContactMasterId
        --                                 FROM dbo.ContactGroupRelation
        --                                 WHERE ContactGroupId = @Id AND IsDeleted = 0
        --                             )
        --          AND IsDeleted = 0
        --) > 0
        ----            OR ( SELECT COUNT(1)
        ----                 FROM   dbo.AnswerMaster
        ----                 WHERE  SeenClientAnswerMasterId IN (
        ----                        SELECT  ContactMasterId
        ----                        FROM    dbo.ContactGroupRelation
        ----                        WHERE   ContactGroupId = @Id )
        ----AND IsDeleted = 0
        ----               ) > 0
        --BEGIN
        --    SET @IsUsed = 1;
        --END;
        IF
        (
            SELECT COUNT(1)
            FROM dbo.SeenClientAnswerMaster
            WHERE ContactGroupId IN ( @Id )
                  AND IsDeleted = 0
        ) > 0
        BEGIN
            SET @IsUsed = 1;
        END;

        IF @IsUsed = 0
        BEGIN
            UPDATE dbo.[ContactGroup]
            SET IsDeleted = 1,
                DeletedBy = @DeletedBy,
                DeletedOn = GETUTCDATE()
            WHERE [Id] = @Id;
            UPDATE dbo.[ContactGroupRelation]
            SET IsDeleted = 1,
                DeletedBy = @DeletedBy,
                DeletedOn = GETUTCDATE()
            WHERE [ContactGroupId] = @Id
                  AND IsDeleted = 0;

			----Never delete contacts when delete contact group.--#210524(Added by Abhishek)
            ----## delete all contacts in this group ##
            --UPDATE dbo.[ContactDetails]
            --SET IsDeleted = 1,
            --    DeletedBy = @DeletedBy,
            --    DeletedOn = GETUTCDATE()
            --WHERE [ContactMasterId] IN (
            --                               SELECT ContactMasterId
            --                               FROM dbo.ContactGroupRelation
            --                               WHERE [ContactGroupId] = @Id
            --                                     AND IsDeleted = 1
            --                           );

            --UPDATE dbo.[ContactMaster]
            --SET IsDeleted = 1,
            --    DeletedBy = @DeletedBy,
            --    DeletedOn = GETUTCDATE(),
            --    Remarks = 'Deleted Using Contact Group.'
            --WHERE [Id] IN (
            --                  SELECT ContactMasterId
            --                  FROM dbo.ContactGroupRelation
            --                  WHERE [ContactGroupId] = @Id
            --                        AND IsDeleted = 1
            --              );

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
             'Delete record in table ContactGroup',
             'ContactGroup',
             @Id,
             GETUTCDATE(),
             @DeletedBy,
             0
            );
        END;
        ELSE
        BEGIN
            SET @Count += 1;
        END;
        SET @Start += 1;
    END;
    SELECT ISNULL(@Count, 0) AS TotalReference,
           SUBSTRING(@Result, 2, LEN(@Result)) AS Name;
END;

