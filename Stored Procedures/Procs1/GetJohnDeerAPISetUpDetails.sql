-- =============================================
-- Author:		<Author,,Anant>
-- Create date: <Create Date,,19 Jun 2019>
-- Description:	<Description,,>
-- Call SP:		GetJohnDeerAPISetUpDetails
-- =============================================
CREATE PROCEDURE dbo.GetJohnDeerAPISetUpDetails
AS
BEGIN
    SELECT Id,
           FromEstablishnmentId,
           FromEstablishmentGroupId,
           fromGroupId,
           isFromSalesTypeActivity,
           ToEstablishnmentId,
           ToEstablishmentGroupId,
           ToGroupId,
           isToSalesTypeActivity
    FROM dbo.MapingWorkFlowMaster;

    SELECT Id,
           WorkFlowMasterId,
           FromQuestionId,
           ToQuestionId
    FROM dbo.MapingWorkFlowConfiguration;

    SELECT Id,
           WorkFlowMasterId,
           OptionId,
           EstablishmentID
    FROM dbo.JohnDeerEstablishmentSelection;
END;
