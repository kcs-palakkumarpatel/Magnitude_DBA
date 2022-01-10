CREATE PROCEDURE [dbo].[InsertOrUpdateEstablishmentStatus]
    @StatusIconTableType StatusIconTableType READONLY,
    @EstablishmentId BIGINT,
    @UserId BIGINT,
    @AdditionaEstablishmentCount INT = 0
AS
BEGIN
DECLARE @StatusIconTableTypeRunTime StatusIconTableType;
INSERT INTO @StatusIconTableTypeRunTime
SELECT *
FROM @StatusIconTableType;

    DECLARE @Id BIGINT;
     DECLARE @IconImage BIGINT;
     DECLARE @Name NVARCHAR(50);
    DECLARE @OpeningIcon BIT;
   DECLARE @ResolvedIcon BIT;
   DECLARE @IsActive BIT;
	  IF (@AdditionaEstablishmentCount = 0)
	  BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.Establishment
            WHERE Id = @EstablishmentId
                  AND StatusIconEstablishment = 1
        )
        BEGIN
            IF EXISTS (SELECT 1 FROM @StatusIconTableTypeRunTime WHERE Id = 0)
            BEGIN
                INSERT INTO dbo.EstablishmentStatus
                (
                    EstablishmentId,
                    StatusName,
                    StatusIconImageId,
                    DefaultStartStatus,
                    DefaultEndStatus,
                    CreatedOn,
                    CreatedBy,
                    IsDeleted
                )
                SELECT @EstablishmentId,
                       Name,
                       IconImage,
                       OpeningIcon,
                       ResolvedIcon,
                       GETUTCDATE(),
                       @UserId,
                       0
                FROM @StatusIconTableTypeRunTime
                WHERE Id = 0;
            END;
            IF EXISTS (SELECT 1
            FROM @StatusIconTableTypeRunTime
            WHERE Id > 0)
            BEGIN
			
                UPDATE dbo.EstablishmentStatus 
                SET 
					StatusName =  ST.Name,
                    StatusIconImageId = ST.IconImage,
                    DefaultStartStatus = ST.OpeningIcon,
                    DefaultEndStatus = ST.ResolvedIcon,
                    IsDeleted = ST.IsDelete,
                    UpdatedOn = GETUTCDATE(),
                    UpdatedBy = @UserId
                FROM EstablishmentStatus ES,
                    @StatusIconTableTypeRunTime as ST
                WHERE ES.Id = ST.Id
                      AND ST.Id > 0;
            END;

             END;
        ELSE
        BEGIN
            UPDATE dbo.EstablishmentStatus
            SET IsDeleted = 1
            WHERE EstablishmentId = @EstablishmentId;
        END;
		END
		ELSE
		BEGIN
		 INSERT INTO dbo.EstablishmentStatus
                (
                    EstablishmentId,
                    StatusName,
                    StatusIconImageId,
                    DefaultStartStatus,
                    DefaultEndStatus,
                    CreatedOn,
                    CreatedBy,
                    IsDeleted
                )
                SELECT @EstablishmentId,
                       Name,
                       IconImage,
                       OpeningIcon,
                       ResolvedIcon,
                       GETUTCDATE(),
                       @UserId,
                       0
                FROM @StatusIconTableTypeRunTime
               END
END;
