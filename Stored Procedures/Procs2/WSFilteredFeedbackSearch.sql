-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Apr-2017
-- Description:	<Description,,GetAppUserById>
-- Call SP    :	WSFilteredFeedbackSearch
-- =============================================
CREATE PROCEDURE [dbo].[WSFilteredFeedbackSearch] 
@SearchOption INT,
@SeenClientId BIGINT,
@SearchText NVARCHAR(MAX)
AS 
    BEGIN
   
IF (@SearchOption = 1)
BEGIN
Select DISTINCT ReferenceNo FROM
(
Select id as ReferenceNo, 1 as IsCapture from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = @SeenClientId)) and Detail LIKE '%' + @SearchText + '%')
UNION 
Select SeenClientAnswerMasterID as ReferenceNo , 0 as IsCapture from AnswerMaster where SeenClientAnswerMasterId IN (Select id from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = @SeenClientId)) and Detail LIKE '%' + @SearchText + '%'))
) as A
END
ELSE IF (@SearchOption = 2)
--Is Reference Number
BEGIN
IF(ISNUMERIC(@SearchText) = 1)
BEGIN
Select DISTINCT ReferenceNo, IsCapture FROM
(
Select id as ReferenceNo, 1 as IsCapture from SeenClientAnswerMaster where ID = @SearchText --ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = 1908)) and Detail LIKE '%' + @SearchText + '%')
UNION
Select id as ReferenceNo , 0 as IsCapture from AnswerMaster where SeenClientAnswerMasterId = @SearchText --IN (Select id from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = 1908)) and Detail LIKE '%' + @SearchText + '%'))
) as A
END
ELSE
	SELECT 'NOT A INTEGER'
END
ELSE
BEGIN
Select DISTINCT ReferenceNo FROM
(
Select id as ReferenceNo, 1 as IsCapture from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = @SeenClientId)) and Detail LIKE '%' + @SearchText + '%')
UNION
Select SeenClientAnswerMasterID as ReferenceNo , 0 as IsCapture from AnswerMaster where SeenClientAnswerMasterId IN (Select id from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = @SeenClientId)) and Detail LIKE '%' + @SearchText + '%'))
) as A

IF(ISNUMERIC(@SearchText) = 1)
BEGIN
Select DISTINCT ReferenceNo, IsCapture FROM
(
Select id as ReferenceNo, 1 as IsCapture from SeenClientAnswerMaster where ID = @SearchText --ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = 1908)) and Detail LIKE '%' + @SearchText + '%')
UNION
Select id as ReferenceNo , 0 as IsCapture from AnswerMaster where SeenClientAnswerMasterId = @SearchText --IN (Select id from SeenClientAnswerMaster where ContactMasterId = (Select top 1 ContactMasterId from ContactDetails where ContactMasterId IN (Select ContactMasterId from SeenClientAnswerMaster where EstablishmentId IN (Select id from Establishment where SeenClientId = 1908)) and Detail LIKE '%' + @SearchText + '%'))
) as A
END

Select Ref as "Capture Form Reference ", "IsOut", ISNULL(EstablishmentGroupName,'') As "Activity Name" , ISNULL("Conversation",'') as "Chat Message", (CASE WHEN EstablishmentGroupType = 'Sales' then 'Capture' Else 'Feedback' END) As "Activity Type" FROM
(
Select Ref,Isout from  
(
SELECT Distinct SeenClientAnswerMasterId as Ref, 1 as Isout from SeenClientAnswers WHERE (SeenClientAnswerMasterId = (CASE WHEN ISNUMERIC(@SearchText) = 1 then @SearchText else '' end) 
OR Detail LIKE @SearchText) AND SeenClientAnswerMasterId IN (Select id from SeenClientAnswerMaster where SeenClientId IN (@SeenClientId) and IsDeleted = 0)
UNION
SELECT SeenClientAnswerMasterId as Ref, 0 as IsOut from AnswerMaster WHERE (SeenClientAnswerMasterId IN (Select id from SeenClientAnswerMaster where SeenClientId IN (@SeenClientId) and IsDeleted = 0) AND id IN (Select AnswerMasterId from Answers where (AnswerMasterId = CASE WHEN ISNUMERIC(@SearchText) = 1 then @SearchText else '' end) OR  Detail LIKE @SearchText))
) AS Ref )
As Reference
LEFT JOIN SeenClientAnswerMaster SCAM ON SCAM.id =  Ref 
LEFT JOIN EstablishmentGroup EG ON EG.SeenClientId = SCAM.SeenClientId
LEFT JOIN ChatDetails CD ON CD.SeenClientAnswerMasterId = SCAM.id AND Cd.Conversation LIKE '%' + @SearchText + '%'
WHERE SCAM.IsDeleted = 0
AND EG.IsDeleted = 0
AND EG.id IN (Select EstablishmentGroupId from Establishment where id =  SCAM.EstablishmentId)
ORDER BY SCAM.CreatedOn DESC
END


    END
