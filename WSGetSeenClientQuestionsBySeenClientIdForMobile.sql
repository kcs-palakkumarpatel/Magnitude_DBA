-- =============================================
-- Author:		Krishna Panchal
-- Create date: 13-11-2020
-- Description:	Get Capture Form Questions List by Capture ID For Mobile
-- Call:		WSGetSeenClientQuestionsBySeenClientIdForMobile 2705, 0, 0, '','2020-01-01 00:00:00.00'
-- =============================================

CREATE PROCEDURE [dbo].[WSGetSeenClientQuestionsBySeenClientIdForMobile]
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(MAX),
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
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
           TitleTextColor,
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
           Margin,
           FontSize,
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
                WHEN ISNULL(Q.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(Q.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.SeenClientQuestions AS Q
        LEFT OUTER JOIN dbo.ContactDetails Cd
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
    WHERE (
              ISNULL(Q.IsDeleted,0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.SeenClientId = @SeenClientId
          AND Q.IsActive = 1
          AND
          (
              ISNULL(Q.UpdatedOn, Q.CreatedOn) >= @LastServerDate
              OR ISNULL(Q.DeletedOn, '') >= @LastServerDate
          )
    ORDER BY Q.Position,
             Q.ChildPosition ASC;
END;
