
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	18-Apr-2017
-- Description:	Get Capture Form Questions List by Capture ID
-- =============================================
/*
drop procedure WSGetSeenClientQuestionsBySeenClientId_OfflineAPI

Exec WSGetSeenClientQuestionsBySeenClientId_OfflineAPI 655, 1109, 0, ''
*/
CREATE PROCEDURE [dbo].[WSGetSeenClientQuestionsBySeenClientId_OfflineAPI]
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(MAX),
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
                WHEN @LastServerDate = '1970-01-01 00:00:00.00' THEN
                    1
                WHEN ISNULL(Q.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(Q.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action],
           ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
           ISNULL(Q.AllowArithmeticOperation, 0) AS IsAllowArithmeticOperation,
           ISNULL(QC.Formula, '') AS ArithmeticFormula
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
        LEFT JOIN dbo.QuestionCalculationItem AS QC
            ON QC.QuestionId = Q.Id
               AND QC.IsCapture = 1
    WHERE (
              ISNULL(Q.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.SeenClientId = @SeenClientId
          AND Q.IsActive = 1
          AND (
                  ISNULL(Q.UpdatedOn, Q.CreatedOn) >= @LastServerDate
                  OR ISNULL(Q.DeletedOn, '') >= @LastServerDate
              )
    ORDER BY Q.Position,
             Q.ChildPosition ASC;
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
         'dbo.WSGetSeenClientQuestionsBySeenClientId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ContactMasterId,0),
         @SeenClientId+','+@ContactMasterId+','+@IsContactGroup+','+@ContactMasterIdList+','+@LastServerDate,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
