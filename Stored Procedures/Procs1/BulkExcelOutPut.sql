/*
 =============================================
 Author:		<Vasu Patel>
 Create date: <14 Sep 2016>
 Description:	<Excel Out Put> 
 Updated Date: Updated by Disha - 22-OCT-2016 - Addititon of 6 newly added columns for Escalation
 =============================================
*/
CREATE PROCEDURE [dbo].[BulkExcelOutPut]
	
AS
BEGIN
	   SELECT  Establishment ,
				MainEstablishment,
				UniqSMSKeyWord,
				InEscalationEmails,
				InEscalationMobiles,
				InEscalationEmailSubject,
				OutEscalationEmails,
				OutEscalationMobiles,
				OutEscalationEmailSubject,
                CASE [Status]
                  WHEN 1 THEN 'Success'
                  WHEN 2
                  THEN 'Establishment already Exists OR Main Establishment is Not Exists'
                  WHEN 3 THEN 'Uniq Keyword Exists'
				  WHEN 4 THEN 'Uniq Keyword Required'
                  ELSE 'Problem In Upload'
                END AS [Import Status]
        FROM    dbo.EstablishmentImport
        UNION ALL
        SELECT TOP 100
                '' AS Establishment ,
				'' AS MainEstablishment,
				'' AS UniqSMSKeyWord,
				'' AS InEscalationEmails,
				'' AS InEscalationMobiles,
				'' AS InEscalationEmailSubject,
				'' AS OutEscalationEmails,
				'' AS OutEscalationMobiles,
				'' AS OutEscalationEmailSubject,
                '' AS [Import Status]
        FROM    dbo.AnswerMaster;
END