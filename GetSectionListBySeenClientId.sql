-- =============================================
-- Author:		Krishna Panchal
-- Create date:	12-Dec-2021
-- Description:	GetSectionListBySeenClientId
-- Call SP    :	GetSectionListBySeenClientId 1898
-- =============================================
CREATE PROCEDURE dbo.GetSectionListBySeenClientId @SeenClientId BIGINT
AS
BEGIN
    SELECT SectionNo,
           SectionName
    FROM dbo.SeenClientQuestions
    WHERE SeenClientId = @SeenClientId
          AND ISNULL(IsSection, 0) = 1
          AND ISNULL(IsDeleted, 0) = 0
    GROUP BY SectionNo,
             SectionName;
END;
