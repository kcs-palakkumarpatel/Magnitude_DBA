-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 06-May-2021
-- Description: Get Import data file
-- SP call : GetUnAllocatedTaskAndImportFileLog 8743,'',1,5
-- =============================================
CREATE PROCEDURE dbo.GetUnAllocatedTaskAndImportFileLog
    @ActivityId BIGINT,
    @SearchText VARCHAR(1000) = '',
    @Page INT = 1,
    @Rows INT = 50
AS
BEGIN
    BEGIN TRY

        DECLARE @Temp AS TABLE
        (
            Id BIGINT,
            FileName VARCHAR(1000),
            EstablishmentGroupId BIGINT,
            EstablishmentId BIGINT,
            TotalCount BIGINT,
            CreatedBy VARCHAR(200),
            CreatedOn VARCHAR(100)
        );
        INSERT INTO @Temp
        (
            Id,
            FileName,
            EstablishmentGroupId,
            EstablishmentId,
            TotalCount,
            CreatedBy,
            CreatedOn
        )
        SELECT UAT.Id,
               UAT.[FileName],
               UAT.EstablishmentGroupId,
               UAT.EstablishmentId,
               ISNULL(
               (
                   SELECT COUNT(Id)
                   FROM dbo.SeenClientAnswerMaster
                   WHERE ImportFileId = UAT.Id
                         --AND ISNULL(IsUnAllocated, 0) = 1
                         AND ISNULL(IsDeleted, 0) = 0
               ),
               0
                     ) AS TotalCount,
               ISNULL(AP.Name, '') AS CreatedBy,
               FORMAT(UAT.CreatedOn, 'dd/MMM/yy HH:mm') AS CreatedOn
        FROM dbo.UnAllocatedTaskImportFileLog UAT
            INNER JOIN dbo.AppUser AP
                ON AP.Id = UAT.CreatedBy
				AND AP.IsDeleted = 0
        WHERE ISNULL(UAT.IsDeleted, 0) = 0
              AND UAT.EstablishmentGroupId = @ActivityId;

        SELECT Id,
               FileName,
               EstablishmentGroupId,
               EstablishmentId,
               TotalCount,
               CreatedBy,
               CreatedOn
        FROM @Temp
        WHERE (
                  @SearchText = ''
                  OR
                  (
                      FileName LIKE '%' + @SearchText + '%'
                      OR CreatedBy LIKE '%' + @SearchText + '%'
                      OR TotalCount LIKE '%' + @SearchText + '%'
                  )
              ) AND TotalCount > 0
        ORDER BY Id DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
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
        (ERROR_LINE(), 'dbo.InsertOrUpdateSeenClientQuestions', N'Database', ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(), 0, N'', GETUTCDATE(), 0);
    END CATCH;
END;
