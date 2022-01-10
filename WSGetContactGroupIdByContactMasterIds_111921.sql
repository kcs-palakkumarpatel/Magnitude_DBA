﻿
-- =============================================
-- Author:		Matthew Grinaker
-- Updated Date:	
-- Created Date: 2020-05-09
-- Description:	Get Contact Group ID by list of contactMasterIds
-- Call:        dbo.WSGetContactGroupIdByContactMasterIds '31775,37712,37713,37714,37319'
-- =============================================

CREATE PROCEDURE [dbo].[WSGetContactGroupIdByContactMasterIds_111921] (@strContactMasterID NVARCHAR(MAX))
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ContactGroupId BIGINT;
    DECLARE @GroupCount INT;
    SET @GroupCount =
    (
        SELECT COUNT(Data) FROM dbo.Split(@strContactMasterID, ',')
    );
    SET @ContactGroupId =
    (
        SELECT TOP 1
               ContactGroupId
        FROM
        (
            SELECT ContactGroupId,
                   COUNT(ContactGroupId) AS AA
            FROM dbo.ContactGroupRelation WITH
                (NOLOCK)
            WHERE IsDeleted = 0
                  AND ContactGroupId IN
                      (
                          SELECT DISTINCT
                                 ContactGroupId AS CustGroupID
                          FROM
                          (
                              SELECT DISTINCT
                                     ContactGroupId,
                                     COUNT(ContactGroupId) AS GroupUserCount
                              FROM dbo.ContactGroupRelation WITH
                                  (NOLOCK)
                              WHERE IsDeleted = 0
                              GROUP BY ContactGroupId
                          ) AS A
                          WHERE GroupUserCount = @GroupCount
                                AND IsDeleted = 0
                          GROUP BY ContactGroupId
                      )
                  AND ContactMasterId IN
                      (
                          SELECT Data FROM dbo.Split(@strContactMasterID, ',')
                      )
            GROUP BY ContactGroupId
        ) AS b
        WHERE AA = @GroupCount
        ORDER BY ContactGroupId DESC
    );
    SELECT ISNULL(@ContactGroupId, 0) AS ContactGroupId;
END;
