
-- WSGetEstablishmentStatusByReportId 58122, 0
CREATE PROCEDURE [dbo].[WSGetEstablishmentStatusByReportId_111921]
	@ReportId bigint,
	@isOut bit
AS
SET NOCOUNT ON
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
SET NOCOUNT OFF
