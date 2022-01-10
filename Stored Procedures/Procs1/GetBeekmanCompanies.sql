-- =============================================
-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,19 Jun 2019>
-- Description:	<Description,,>
-- Call SP:		GetBeekmanCompanies
-- =============================================
CREATE PROCEDURE dbo.GetBeekmanCompanies
AS
BEGIN
    SELECT Id,
           ApiId,
           EstablishmentId,
           ContactMasterId,
           AppUserId,
           SeenClientId,
           ContactGroupId
    FROM dbo.BeekmanCompanies
    WHERE EstablishmentId <> 0
	          --AND (
          --        ContactMasterId <> 0
          --        OR ContactMasterId <> 0
          --    )
          AND AppUserId <> 0;
END;
