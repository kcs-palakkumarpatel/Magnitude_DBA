CREATE VIEW [dbo].[Vw_Establishment]
WITH SCHEMABINDING
AS
SELECT Id,
       EstablishmentName,
       EstablishmentGroupId,
       TimeOffSet,
       IsDeleted,
	   GroupId,
	   DynamicSaveButtonText,
	   StatusIconEstablishment,
	   FeedbackOnce
FROM dbo.Establishment;


