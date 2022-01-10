-- =============================================
-- Author:				Sunil Vaghasiya
-- Create date:		21-June-2017
-- Description:		Get feedback IN by AnswerMasterId
-- Call SP:				dbo.WSGetFeedBackReportDataById 536254,7600
-- =============================================
CREATE PROCEDURE [dbo].[WSGetFeedBackReportDataById]
    @AnswerMasterId BIGINT,
	@AppUserId BIGINT
AS
    BEGIN

        DECLARE @PIDispaly VARCHAR(5) = '0';
        IF ( ( SELECT   COUNT(1)
               FROM     dbo.Questions
               WHERE    QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                        AND QuestionnaireId = ( SELECT  QuestionnaireId
                                                FROM    dbo.AnswerMaster
                                                WHERE   Id = @AnswerMasterId
                                              )
                        --AND [Required] = 1
                        AND IsDeleted = 0
             ) > 0 )
            BEGIN
                SET @PIDispaly = '1';
            END;

        SELECT  Am.Id AS ReportId ,
                Am.EstablishmentId ,
                EstablishmentName ,
                Am.Latitude ,
                Am.Longitude ,
                --CONVERT(DECIMAL(18,0), Am.PI) AS EI ,
                IIF(@PIDispaly = 1,CONVERT(DECIMAL(18,0), Am.[PI]), IIF(Am.[PI] >= 0.00, CONVERT(DECIMAL(18,0), Am.[PI]), -1)) AS EI ,
                Am.IsPositive AS SmileType ,
                dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet,
                                             Am.CreatedOn),
                                     'dd/MMM/yy HH:mm') AS CaptureDate ,
                Eg.EstablishmentGroupName AS ActivityName ,
                Eg.Id AS ActivityId ,
                Am.AppUserId ,
                ISNULL(U.Name, '') AS AppUserName ,
                ISNULL(Am.SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId ,
                Am.IsTransferred ,
                Am.IsResolved AS AnswerStatus ,
                IIF(ISNULL(SAM.ContactMasterId, 0) = 0, ISNULL(SCA.ContactMasterId,
                                                              0), ISNULL(SAM.ContactMasterId,
                                                              0)) AS ContactMasterId ,
                ( SELECT TOP 1
                            ISNULL(cd.Detail, '')
                  FROM      dbo.ContactDetails cd
				  INNER JOIN ContactQuestions cq ON cq.Id = cd.ContactQuestionId
                  WHERE     cd.ContactMasterId = IIF(ISNULL(SAM.ContactMasterId,
                                                         0) = 0, ISNULL(SCA.ContactMasterId,
                                                              0), ISNULL(SAM.ContactMasterId,
                                                              0))
                            AND cd.QuestionTypeId = 4 ORDER BY cq.Position
                ) AS ContactDetails ,
                Am.IsOutStanding ,
                Am.IsActioned ,
                ISNULL(U.Name, '') AS TransferToUser ,
                ISNULL(TransferFromUser.Name, '') AS TransferFromUser ,
                Am.IsDisabled ,
                ISNULL(F.IsFlag, 0) AS [IsFlag]
        FROM    dbo.AnswerMaster AS Am
                INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM ON Am.SeenClientAnswerMasterId = SAM.Id
                LEFT OUTER JOIN dbo.SeenClientAnswerChild AS SCA ON SCA.Id = Am.SeenClientAnswerChildId
                LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.AnswerMasterId
                LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
				LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.Type = 1
        WHERE   Am.Id = @AnswerMasterId
		ORDER BY Am.Id ASC;
    END;
