
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Dec 2015>
-- Description:	<Get Establishment Activity Name by Common SMS Key Word>
-- Call: GetActivitybyCommonSMSKeyWord 2397
-- =============================================
CREATE PROCEDURE [dbo].[GetActivitybyCommonSMSKeyWord] @EstablishmentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @CommonSMSKeyword NVARCHAR(100);
    SELECT @CommonSMSKeyword = CommonSMSKeyword
    FROM dbo.Establishment WITH (NOLOCK)
    WHERE Id = @EstablishmentId;
    SELECT Establishment.Id AS Id,
           EstablishmentGroupName AS EstablishmentName,
           '' AS ActivityLink,
           ConfigureImagePath AS ImagePath,
           ConfigureImageName AS ImageName,
           BorderColor AS BorderColor,
           BackgroundColor AS BackgroundColor,
           IsConfugureManualImage AS ISConfugureManualImage,
           ISNULL(ConfigureImageSequence, 0) AS [Sequence]
    FROM dbo.Establishment WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentGroup WITH (NOLOCK)
            ON EstablishmentGroup.Id = Establishment.EstablishmentGroupId
    WHERE CommonSMSKeyword = @CommonSMSKeyword
          AND Establishment.IsDeleted = 0
          AND EstablishmentGroup.IsDeleted = 0
          AND dbo.EstablishmentGroup.EstablishmentGroupType = 'Customer'
    ORDER BY ISNULL(ConfigureImageSequence, 0) ASC;
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
         'dbo.GetActivitybyCommonSMSKeyWord',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @EstablishmentId,
         GETUTCDATE(),
         N''
        );
END CATCH

    SET NOCOUNT OFF;
END;
