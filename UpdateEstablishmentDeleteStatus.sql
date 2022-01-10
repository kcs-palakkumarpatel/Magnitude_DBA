CREATE PROCEDURE [dbo].[UpdateEstablishmentDeleteStatus]
    @EstablishmentStatusId BIGINT,
    @Status BIT OUTPUT
AS
BEGIN
    UPDATE dbo.EstablishmentStatus
    SET IsDeleted = 1
    WHERE Id = @EstablishmentStatusId;
    SET @Status = 0;

--   IF NOT EXISTS
--   (
--       SELECT Id
--       FROM dbo.StatusHistory
--       WHERE EstablishmentStatusId = @EstablishmentStatusId
--   )
--   BEGIN
--       UPDATE dbo.EstablishmentStatus
--       SET IsDeleted = 1
--       WHERE Id = @EstablishmentStatusId;
--		SET @Status = 0;
--   END;
--ELSE
--   BEGIN
--   	SET @Status = 1;
--END
END;
