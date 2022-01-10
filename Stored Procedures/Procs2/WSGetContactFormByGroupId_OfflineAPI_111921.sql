
/*
=============================================
Author:			<Vasu Patel>
Create date:	<29 Dec 2015>
Description:	<Get ContactFrom by UserGroupId>


Exec WSGetContactFormByGroupId_OfflineAPI 10008,'2016-01-01 04:32:07.647'

drop procedure WSGetContactFormByGroupId_OfflineAPI
*/
CREATE PROCEDURE [dbo].[WSGetContactFormByGroupId_OfflineAPI_111921]
    @GroupId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(150);
    DECLARE @ContactId INT = 0;
    SELECT @ContactId = ContactId
    FROM dbo.ContactQuestions
    WHERE ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate;
    SELECT @Url = KeyValue + N'ContactQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT DISTINCT
           CQ.Id AS QuestionId,
           CQ.QuestionTypeId,
           QuestionTitle,
           ShortName,
           [Required],
           [MaxLength],
           ISNULL(Hint, '') AS Hint,
           ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           Position,
           IsGroupField,
           ISNULL(D.ContactOptionId, '') AS ContactOptionId,
           ISNULL(D.Detail, '') AS Detail,
           Margin,
           FontSize,
           ISNULL(@Url + CQ.ImagePath, '') AS ImagePath,
           CQ.IsDisplayInDetail AS DisplayInDetail,
           CQ.IsDisplayInSummary AS DisplayInList,
           CQ.IsCommentCompulsory AS IsCommentCompulsory,
           (CASE
                WHEN @LastServerDate = '1970-01-01 00:00:00.00' THEN
                    1
                WHEN ISNULL(CQ.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(CQ.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.EstablishmentGroup AS Eg
        OUTER APPLY dbo.Split(Eg.ContactQuestion, ',') AS AQ
        INNER JOIN dbo.[Group] AS G
            ON G.Id = Eg.GroupId
        INNER JOIN dbo.Contact AS C
            ON C.Id = G.ContactId
        INNER JOIN dbo.ContactQuestions AS CQ
            ON CQ.ContactId = C.Id
               AND CQ.IsDeleted = 0
               AND AQ.Data = CQ.Id
        LEFT OUTER JOIN dbo.ContactDetails D
            ON D.ContactQuestionId = CQ.Id
               AND ContactMasterId = 0
               AND D.IsDeleted = 0
    WHERE G.Id = @GroupId
          AND
          (
              ISNULL(CQ.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND
          (
              ISNULL(Eg.UpdatedOn, Eg.CreatedOn) >= @LastServerDate
              OR ISNULL(C.UpdatedOn, C.CreatedOn) >= @LastServerDate
              OR CQ.ContactId = CASE @ContactId
                                    WHEN 0 THEN
                                        0
                                    ELSE
                                        @ContactId
                                END
              OR @LastServerDate IS NULL
          )
          AND
          (
              ISNULL(CQ.UpdatedOn, CQ.CreatedOn) >= @LastServerDate
              OR ISNULL(CQ.DeletedOn, '') >= @LastServerDate
              OR @LastServerDate IS NULL
          );
END;
