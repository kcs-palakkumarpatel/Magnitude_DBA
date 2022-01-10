
-- WSGetEstablishmentStatusByReportId 58122, 0
CREATE PROCEDURE [dbo].[WSGetEstablishmentStatusByReportId]
	@ReportId bigint,
	@isOut bit
AS
SET NOCOUNT ON
SET DEADLOCK_PRIORITY NORMAL;
	
BEGIN TRY
IF (@isOut = 1)
BEGIN
PRINT @isOut
SELECT
	ES.Id AS StatusId, 
	ES.EstablishmentId, 
	[StatusName],
	SSI.IconPath AS StatusImage,
	[DefaultStartStatus], 
	[DefaultEndStatus], 
	[IsActive]
FROM EstablishmentStatus ES
INNER JOIN SeenClientAnswerMaster SCAM ON ES.EstablishmentId =  SCAM.EstablishmentId
INNER JOIN dbo.StatusIconImage AS SSI ON SSI.Id = ES.StatusIconImageId
WHERE SCAM.Id = @ReportId
 AND SCAM.IsDeleted = 0
AND ES.IsDeleted = 0
 END
 ELSE
 BEGIN
 SELECT
	ES.Id AS StatusId, 
	ES.EstablishmentId, 
	[StatusName],
	SSI.IconPath AS StatusImage,
	[DefaultStartStatus], 
	[DefaultEndStatus], 
	[IsActive]
FROM EstablishmentStatus ES
INNER JOIN SeenClientAnswerMaster SCAM ON ES.EstablishmentId =  SCAM.EstablishmentId
INNER JOIN dbo.StatusIconImage AS SSI ON SSI.Id = ES.StatusIconImageId
WHERE SCAM.Id = (Select SeenClientAnswerMasterId from AnswerMaster where Id = @ReportId)
AND SCAM.IsDeleted = 0
AND ES.IsDeleted = 0
 END
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
         'dbo.WSGetEstablishmentStatusByReportId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ReportId,0),
         @ReportId+','+@isOut,
         GETUTCDATE(),
         N''
        );
END CATCH
SET NOCOUNT OFF
