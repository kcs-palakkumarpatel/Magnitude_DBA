
-- =============================================
-- Author:		<Author,,Anant>
-- Create date: <Create Date,,19 Jun 2019>
-- Description:	<Description,,>
-- Call SP:		GetPendingCaptureFormForJohnDeer
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingCaptureFormForJohnDeer_111721]
AS
BEGIN
    SELECT Id,
           WorkflowMasterID,
           ISNULL(fromReferenceNumber,0) AS fromReferenceNumber,
           ISNULL(ToEstablishnmentId,0) AS ToEstablishnmentId,
           isActioned
    FROM dbo.MapingWorkFlowData
    WHERE isActioned = 0
          AND IsDeleted = 0;
END;
