-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	27-Apr-2017
-- Description:	Get Copy Capture Form Details
--Call:	dbo.GetTaskQuestionListByTaskById 975980,2751
-- =============================================

CREATE PROCEDURE [dbo].[GetTaskQuestionListByTaskById]
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientId BIGINT,
    @ActivityId BIGINT = 0
AS
BEGIN
    DECLARE @Url NVARCHAR(150);

    SELECT @Url = KeyValue + N'SeenClient/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    DECLARE @ID INT = @SeenClientId;
    IF (@SeenClientId <= 0 AND @ActivityId > 0)
    BEGIN
        SELECT @ID = SeenClientId
        FROM dbo.EstablishmentGroup
        WHERE Id = @ActivityId;
    END;

    IF (@SeenClientAnswerMasterId <> 0)
    BEGIN

        SELECT Q.Id AS QuestionId,
               Q.QuestionTypeId,
               Q.QuestionTitle,
               (CASE
                    WHEN Q.QuestionTypeId = 17 THEN
               (CASE
                    WHEN SCA.Detail <> '' THEN
                    (
                        SELECT STUFF(
                               (
                                   SELECT ',' + EE.Detail
                                   FROM
                                   (
                                       SELECT (@Url + Data) AS Detail,
                                              Id
                                       FROM dbo.Split((SCA.Detail), ',')
                                   ) EE
                                   FOR XML PATH('')
                               ),
                               1,
                               1,
                               ''
                                    ) AS listStr
                    )
                    ELSE
                        ''
                END
               )
                    ELSE
                        SCA.Detail
                END
               ) Answer,
               Q.Position,
               Q.ChildPosition,
               @ID AS SeenClientID,
			   Q.Required AS IsRequired,
			  EG.AttachmentLimit
        FROM dbo.SeenClientAnswers SCA
            INNER JOIN dbo.SeenClientQuestions Q
                ON Q.Id = SCA.QuestionId
				INNER JOIN dbo.EstablishmentGroup EG ON
                EG.SeenClientId = Q.SeenClientId
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
        ORDER BY Q.Position,
                 Q.ChildPosition ASC;
    END;
    ELSE
    BEGIN
        SELECT DISTINCT
            QuestionId,
            QuestionTypeId,
            QuestionTitle,
            ISNULL(Answer, '') AS Answer,
            Position,
            ChildPosition,
            CD.SeenClientID,
		    CD.Required AS IsRequired
        FROM
        (
            SELECT Q.Id AS QuestionId,
                   Q.QuestionTypeId,
                   Q.QuestionTitle,
                   '' AS Answer,
                   Q.Position,
                   Q.ChildPosition,
                   @ID AS SeenClientID,
				   Q.Required,
				   EG.AttachmentLimit
            FROM dbo.SeenClientQuestions AS Q INNER JOIN dbo.EstablishmentGroup EG ON EG.SeenClientId = Q.SeenClientId
            WHERE Q.SeenClientId = @ID
                  AND Q.IsDeleted = 0
                  AND Q.IsActive = 1
                  AND ISNULL(Q.IsRepetitive, 0) = 0
        ) AS CD
        ORDER BY CD.Position,
                 CD.ChildPosition ASC;
    END;
END;
