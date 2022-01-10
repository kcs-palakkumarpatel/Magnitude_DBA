-- =============================================
-- Author:		Krishna Panchal
-- Create date:	11-Feb-2021
-- Description:	Get Task Type Priority
-- Call SP    : dbo.GetTaskTypePriority
-- =============================================
CREATE PROCEDURE [dbo].[GetTaskTypePriority]
AS
BEGIN
    SELECT Id,
           PriorityName
    FROM dbo.TaskTypePriority;
END;
