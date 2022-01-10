-- =============================================
-- Author:		Krishna Panchal
-- Create date: 25-Mar-2021
-- Description:	GetAppuserByReportId
-- Call: GetAppuserByReportId 977463,1
-- =============================================
CREATE PROCEDURE [dbo].[GetAppuserByReportId]
    @ReportId BIGINT,
    @isOut BIT = 0
AS
BEGIN
    DECLARE @EstablishmentID BIGINT;
    IF (@isOut = 0)
    BEGIN
        SET @EstablishmentID =
        (
            SELECT TOP 1
                   EstablishmentId
            FROM dbo.AnswerMaster
            WHERE Id = @ReportId
                  AND IsDeleted = 0
        );
    END;
    ELSE
        SET @EstablishmentID =
    (
        SELECT TOP 1
               EstablishmentId
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @ReportId
              AND IsDeleted = 0
    )   ;

    SELECT AE.AppUserId,
           AU.Name,
           CAST(0 AS BIGINT) AS IsDefaultValue
    FROM dbo.AppUserEstablishment AE
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AE.AppUserId
        LEFT OUTER JOIN dbo.ContactRoleDetails CRD
            ON CRD.AppUserId = AU.Id
        LEFT OUTER JOIN dbo.ContactRoleEstablishment CRE
            ON CRE.EstablishmentId = AE.EstablishmentId
               AND CRE.ContactRoleId = CRD.ContactRoleId
    WHERE AE.EstablishmentId = @EstablishmentID
          AND AU.IsDeleted = 0
          AND AU.IsActive = 1
          AND AE.IsDeleted = 0
    GROUP BY AE.AppUserId,
             AU.Name,
             CRD.Id;
END;
