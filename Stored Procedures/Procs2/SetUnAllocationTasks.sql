-- =============================================
-- Author:		Krishna Panchal
-- Create date: 21/Jan/2021
-- Description:	UnAllocation Tasks bunch
-- Call SP:		
-- =============================================
CREATE PROCEDURE [dbo].[SetUnAllocationTasks]
	@ReportIds VARCHAR(MAX)
AS
BEGIN
    UPDATE SeenClientAnswerMaster
    SET IsUnAllocated = 1
	WHERE ID IN ( SELECT Data FROM dbo.Split(@ReportIds, ','))
    AND IsDeleted = 0;
END;
