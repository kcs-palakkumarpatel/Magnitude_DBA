
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	18-Apr-2017
-- Description:	Get Capture Form Questions List by Capture ID
-- Call:					WSGetSeenClientQuestionsBySeenClientId 2441, 430985, 0, ''
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSeenClientQuestionsBySeenClientId_111921]
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + N'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT Q.Id AS QuestionId,
           Q.QuestionTypeId,
           Q.QuestionTitle,
           Q.ShortName,
           Q.[Required],
           Q.[MaxLength],
           ISNULL(Hint, '') AS Hint,
           ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
           Q.IsTitleBold,
           Q.IsTitleItalic,
           Q.IsTitleUnderline,
           Q.TitleTextColor,
           Q.Position,
           Q.EscalationRegex,
           ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
           CASE
               WHEN @ContactMasterIdList = '' THEN
                   ISNULL(Cd.Detail, '')
               ELSE
                   CASE
                       WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
                           ISNULL(
                                     dbo.ConcateString3Param(
                                                                'ContactGroupDetail',
                                                                @ContactMasterId,
                                                                Q.ContactQuestionId,
                                                                @ContactMasterIdList
                                                            ),
                                     ''
                                 )
                       ELSE
                           ISNULL(Cd.Detail, '')
                   END
           END AS Detail,
           Q.Margin,
           Q.FontSize,
           ISNULL(@Url + ImagePath, '') AS ImagePath,
           Q.IsDisplayInDetail AS DisplayInDetail,
           Q.IsRepetitive AS IsRepetitive,
           ISNULL(Q.QuestionsGroupNo, 0) AS QuestionsGroupNo,
           ISNULL(Q.QuestionsGroupName, '') AS QuestionsGroupName,
           Q.IsDisplayInSummary AS DisplayInList,
           Q.IsCommentCompulsory AS IsCommentCompulsory,
           Q.IsDecimal AS IsDecimal,
           Q.IsSignature AS IsSignature,
           Q.ImageHeight AS Imageheight,
           Q.ImageWidth AS ImageWidth,
           Q.ImageAlign AS ImageAlign,
           Q.IsRoutingOnGroup AS isRoutingOnGroup,
           Q.ChildPosition AS ChildPosition,
           ISNULL(Q.IsValidateUsingQR, 0) AS isQRType,
           (CASE
                WHEN Q.TenderQuestionType = 1 THEN
                    'ReleasedDate'
                WHEN Q.TenderQuestionType = 2 THEN
                    'MobiExpiryDate'
                WHEN Q.TenderQuestionType = 3 THEN
                    'GrayOutDate'
                WHEN Q.TenderQuestionType = 4 THEN
                    'ReminderDate'
                ELSE
                    ''
            END
           ) AS TenderQuestionType,
           Q.MaxWeight,
           ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
           ISNULL(Q.AllowArithmeticOperation, 0) AS IsAllowArithmeticOperation,
           ISNULL(QC.Formula, '') AS ArithmeticFormula
    FROM dbo.SeenClientQuestions AS Q WITH (NOLOCK)
        LEFT OUTER JOIN dbo.ContactDetails Cd WITH (NOLOCK)
            ON Cd.ContactQuestionId = Q.ContactQuestionId
               AND Cd.ContactMasterId = CASE
                                            WHEN @IsContactGroup = 0 THEN
                                                @ContactMasterId
                                            ELSE
                                        (
                                            SELECT TOP 1
                                                ContactMasterId
                                            FROM dbo.ContactGroupRelation
                                            WHERE ContactGroupId = @ContactMasterId
                                        )
                                        END
        LEFT JOIN dbo.QuestionCalculationItem AS QC
            ON QC.QuestionId = Q.Id
               AND QC.IsCapture = 1
    WHERE Q.IsDeleted = 0
          AND Q.SeenClientId = @SeenClientId
          AND Q.IsActive = 1
    ORDER BY Q.Position,
             Q.ChildPosition ASC;
END;
