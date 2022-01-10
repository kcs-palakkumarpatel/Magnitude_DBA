-- =============================================
-- Author:			Sunil Patel
-- Create date:	13 June 2017
-- Description:	For Get Drafted Capture Forms Data
-- Call SP    :		SearchDraftedFormsDataWeb 1243,1941
-- =============================================
CREATE PROCEDURE [dbo].[SearchDraftedFormsDataWebDraftSave]
    (
      @AppuserId BIGINT = 0 ,
      @EstablishmentId BIGINT = 0 ,
      @Search VARCHAR(50) = '' ,
      @FromDate DATETIME = NULL ,
      @ToDate DATETIME = NULL
    )
AS
    BEGIN

        SELECT  ISNULL(SAM.Id, 0) AS Id ,
                ISNULL(ES.EstablishmentGroupId, 0) AS ActivityId ,
                ISNULL(SAM.EstablishmentId, 0) AS EstablishmentId ,
                ISNULL(ES.EstablishmentName, 0) AS EstablishmentName ,
                ISNULL(SAM.SeenClientId, 0) AS SeenClientId ,
                ISNULL(SAM.AppUserId, 0) AS AppUserId ,
                AU.Name AS UserName ,
                ISNULL(SAM.ReadBy, 0) AS ReadBy ,
                ISNULL(SAM.IsActioned, 0) AS IsActioned ,
                SAM.SenderCellNo ,
                ISNULL(SAM.ContactMasterId, 0) AS ContactMasterId ,
                ISNULL(SAM.IsSubmittedForGroup, 0) AS IsSubmittedForGroup ,
                ISNULL(SAM.ContactGroupId, 0) AS ContactGroupId ,
                ISNULL(CG.ContactGropName, '') AS ContactGropName ,
                dbo.ChangeDateFormat(DATEADD(MINUTE, ES.TimeOffSet,
                                             SAM.CreatedOn),
                                     'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                ISNULL(SAM.CreatedBy, 0) AS CreatedBy ,
                SAM.MobileDate ,
                SAM.EscalationSendDate ,
                ISNULL(SAM.IsRecursion, 0) AS IsRecursion ,
                SAM.Narration ,
                ISNULL(SAM.DraftEntry, 0) AS DraftEntry ,
                dbo.AnswerDetails('SeenClientAnswers', SAM.Id) AS DisplayText
        FROM    dbo.SeenClientAnswerMaster AS SAM
                INNER JOIN dbo.Establishment AS ES ON ES.Id = SAM.EstablishmentId
                LEFT JOIN dbo.ContactGroup AS CG ON CG.Id = SAM.ContactGroupId
                INNER JOIN dbo.AppUser AS AU ON AU.Id = SAM.AppUserId
        WHERE   SAM.IsDeleted = 1
                AND SAM.DraftEntry = 1
                AND SAM.AppUserId = @AppuserId
                AND ES.EstablishmentGroupId = @EstablishmentId
                AND SAM.DraftSave = 1
                AND ( ES.EstablishmentName LIKE '%' + @Search + '%'
                      OR AU.Name LIKE '%' + @Search + '%'
                      OR dbo.ChangeDateFormat(DATEADD(MINUTE, ES.TimeOffSet,
                                                      SAM.CreatedOn),
                                              'dd/MMM/yyyy hh:mm AM/PM') LIKE '%'
                      + @Search + '%'
                      OR REPLACE(dbo.AnswerDetails('SeenClientAnswers', SAM.Id),
                                 '\n', '') LIKE '%' + @Search + '%'
                    )
        ORDER BY SAM.CreatedOn DESC;
    END;
