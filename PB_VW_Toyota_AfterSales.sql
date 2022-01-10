CREATE VIEW dbo.PB_VW_Toyota_AfterSales AS

SELECT * FROM 
(SELECT p.Region,CapturedDate,ReferenceNo,IsResolved,UserName,p.Latitude,p.Longitude,p.CustomerName,p.CustomerMobile,p.CustomerEmail,p.CustomerCompany,
[Franchise],[Customer],[Address],[Indent],[Model],[Chassis],[Contract type],[Last Service Date],[Last MOT Date],[Full Name],[Mobile],[Email],[Make],[FU Model],[Serial number]
from (
select
RTRIM(LTRIM(SUBSTRING(E.EstablishmentName,CHARINDEX('-',E.EstablishmentName)+1,LEN(E.EstablishmentName)))) AS Region,CAST(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved ,A.Detail as Answer,u.name as UserName,AM.Latitude,AM.Longitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3075
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3074
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3073
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3071
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3072
) as CustomerName,
CASE WHEN q.Id=70453 THEN 'FU Model' ELSE Q.Questiontitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5437 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (70847,74098,44645,44925,44136,45554,44856,70808,44647,70804,44139,44140,44141,70452,70453,70454,74099)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Franchise],[Customer],[Address],[Indent],[Model],[Chassis],[Contract type],[Last Service Date],[Last MOT Date],[Full Name],[Mobile],[Email],[Make],[FU Model],[Serial number]
))p
)AA

LEFT JOIN 

(
select CAST(ResponseDate AS DATE) AS ResponseDate,SeenClientAnswerMasterId,Responseno,
[Activity Type:],[WIP number],[Call Type],[Select a status],[Type of contract],[Market intelligence & opportunity areas],[Company name],[Contract status],[Reason for lost deal],[Identify areas of improvement],[Activity:],[Did you visit the customer?],[comments],[Elements Required],[Environment],[Floor Surface],[Yard],[2. Hour meter Reading],[3.Tyre size],[4. Monthly Operational Hours],[FrontTyres TYPE],[FrontTyres SIZE],[FrontTyres PROFILE],[FrontTyres Qty],[FrontTyres Comments],[RearTyres Type],[RearTyres size],[RearTyres PROFILE],[RearTyres Qty],[RearTyres Comments],[Parts Qty],[Parts descriptions],[Part1 Qty],[Part1 descriptions],[Part2 Qty],[Part2 descriptions],[Part3 Qty],[Part3 descriptions],[Part4 Qty],[Part4 descriptions],[Part5 Qty],[Part5 descriptions],[Part6 Qty],[Part6 descriptions],[Part7 Qty],[Part7 descriptions],[Part8 Qty],[Part8 descriptions],[Part9 Qty],[Part9 descriptions],[Is the unit New Equipment?],[Did the New Equipment Sales rep sell a FMA?],[Did you complete a Site inspection?],[FMA Details],[Does the customer require a LMI?],[LMI Quantity],[LMI Details],[Does the customer require Training?],[Does the customer require  Driver / Operator Training?],[Does the customer require Apprenticeship / Learnership Related Training?],[Does the customer require Technical Skills Related Training?],[Does the customer require OEM Product Specific Training?],[Does the customer require Soft-Skill Development Training?],[Does the customer require e-Learning Content Access?],[Does the customer require Facility / Venue Hire (Meetings / Workshops)JHB only?],[Number of people trained],[Training Details],[Does the customer require Engineering?],[Engineering Details],[Does the customer require a Spraybooth work?],[Spraybooth Details],[Does the customer require Electronic Repairs?],[ElectronicRepairs Details],[Does the customer require a Short Term Rental Unit?],[Have you completed a site inspection?],[Model request],
[Elements Sold:],[FrontTyres QuantitySold],[FrontTyres Reason for lost sale],[FrontTyres Who is the competitor?],[FrontTyres Reason for lost sales],
--[Tyres Quoted],[Tyres Forecasted],[Tyres Converted],CAST(REPLACE(P.[Tyres Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Tyres Converted],',','') AS DECIMAL) AS [Tyres Lose],
[RearTyres Quantity Sold],[RearTyres Reason for lost sale],[RearTyres Who is the competitor?],[RearTyres Reason for lost sales],
--[Parts Quoted],[Parts Forecasted],[Parts Converted],CAST(REPLACE(P.[Parts Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Parts Converted],',','') AS DECIMAL) AS [Parts Lose],
[Parts Description],[Parts Quantity Sold],[Parts Reason for lost sale],[Parts Who is the competitor?],[Parts Reason for lost sales],
[Parts1 Description],
[Parts1 Quantity Sold],
[Parts1 Reason for lost sale],
[Parts1 Who is the competitor?],
[Parts1 Reason for lost sales],
[Parts2 Description],
[Parts2 Quantity Sold],
[Parts2 Reason for lost sale],
[Parts2 Who is the competitor?],
[Parts2 Reason for lost sales],
[Parts3 Description],
[Parts3 Quantity Sold],
[Parts3 Reason for lost sale],
[Parts3 Who is the competitor?],
[Parts3 Reason for lost sales],
[Parts4 Description],
[Parts4 Quantity Sold],
[Parts4 Reason for lost sale],
[Parts4 Who is the competitor?],
[Parts4 Reason for lost sales],
[Parts5 Description],
[Parts5 Quantity Sold],
[Parts5 Reason for lost sale],
[Parts5 Who is the competitor?],
[Parts5 Reason for lost sales],
[Parts6 Description],
[Parts6 Quantity Sold],
[Parts6 Reason for lost sale],
[Parts6 Who is the competitor?],
[Parts6 Reason for lost sales],
[Parts7 Description],
[Parts7 Quantity Sold],
[Parts7 Reason for lost sale],
[Parts7 Who is the competitor?],
[Parts7 Reason for lost sales],
[Parts8 Description],
[Parts8 Quantity Sold],
[Parts8 Reason for lost sale],
[Parts8 Who is the competitor?],
[Parts8 Reason for lost sales],
[Parts9 Description],
[Parts9 Quantity Sold],
[Parts9 Reason for lost sale],
[Parts9 Who is the competitor?],
[Parts9 Reason for lost sales],
--[PMA Quoted],[PMA Forecasted],[PMA Converted],CAST(REPLACE(P.[PMA Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[PMA Converted],',','') AS DECIMAL) AS [PMA Lose],
--[FMA Quoted],[FMA Forecasted],[FMA Converted],CAST(REPLACE(P.[FMA Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[FMA Converted],',','') AS DECIMAL) AS [FMA Lose],
[FMA Quantity Sold],[FMA Reason for lost sale],[FMA Who is the competitor?],[FMA Reason for lost sales],
--[LMI Quoted],[LMI Forecasted],[LMI Converted],CAST(REPLACE(P.[LMI Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[LMI Converted],',','') AS DECIMAL) AS [LMI Lose],
[LMI Quantity Sold],[LMI Reason for lost sale],[LMI Who is the competitor?],[LMI Reason for lost sales],
--[Training Quoted],[Training Forecasted],[Training Converted],CAST(REPLACE(P.[Training Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Training Converted],',','') AS DECIMAL) AS [Training Lose],
[Types of training provided],[Driver Number of people trained],[Driver Reason for lost sale],[Driver Who is the competitor?],[Driver Reason for lost sales],
[Apprenticeship Number of people trained],
[Apprenticeship Reason for lost sale],
[Apprenticeship Who is the competitor?],
[Apprenticeship Reason for lost sales],
[Technical Number of people trained],
[Technical Reason for lost sale],
[Technical Who is the competitor?],
[Technical Reason for lost sales],
[OEM Number of people trained],
[OEM Reason for lost sale],
[OEM Who is the competitor?],
[OEM Reason for lost sales],
[Soft-Skill Number of people trained],
[Soft-Skill Reason for lost sale],
[Soft-Skill Who is the competitor?],
[Soft-Skill Reason for lost sales],
[e-Learning Number of people trained],
[e-Learning Reason for lost sale],
[e-Learning Who is the competitor?],
[e-Learning Reason for lost sales],
[Facility Number of people trained],
[Facility Reason for lost sale],
[Facility Who is the competitor?],
[Facility Reason for lost sales],
--[Engineering Quoted],[Engineering Forecasted],[Engineering Converted],CAST(REPLACE(P.[Engineering Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Engineering Converted],',','') AS DECIMAL) AS [Engineering Lose],
[Engineering Was this a successful deal?],[Engineering Reason for lost sale],[Engineering Who is the competitor?],[Engineering Reason for lost sales],
--[Spraybooth Quoted],[Spraybooth Forecasted],[Spraybooth Converted],CAST(REPLACE(P.[Spraybooth Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Spraybooth Converted],',','') AS DECIMAL) AS [Spraybooth Lose],
[Spraybooth Was this a successful deal?],[Spraybooth Reason for lost sale],[Spraybooth Who is the competitor?],[Spraybooth Reason for lost sales],
--[ElectronicRepairs Quoted],[ElectronicRepairs Forecasted],[ElectronicRepairs Converted],CAST(REPLACE(P.[ElectronicRepairs Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[ElectronicRepairs Converted],',','') AS DECIMAL) AS [ElectronicRepairs Lose],
[ElectronicRepairs Was this a successful deal?],[ElectronicRepairs Reason for lost sale],[ElectronicRepairs Who is the competitor?],[ElectronicRepairs Reason for lost sales],[What type of service does customer require?],[Reason for client not signing contract?],[Does the customer require a repair?],[Repair details],
[STR Quantity Rented],
[STR Reason for lost sale],
[STR Who is the competitor?],
[STR Reason for lost sales],
[Service Sold],
[Service Reason for lost sale],
[Service Who is the competitor?],
[Service Reason for lost sales],
--[Repairs Quoted],[Repairs Forecasted],[Repairs Converted],CAST(REPLACE(P.[Repairs Quoted],',','') AS DECIMAL)-CAST(REPLACE(P.[Repairs Converted],',','') AS DECIMAL) AS [Repairs Lose],
[Repairs Was this a successful deal?],[Repairs Reason for lost sale],[Repairs Who is the competitor?],[Repairs Reason for lost sales]
from (select 
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,cam.Id as SeenClientAnswerMasterId,am.Id AS Responseno
,CAST(a.Detail AS VARCHAR(8000))  as Answer,
CASE
WHEN q.id=58623 THEN 'Select a status'
WHEN q.Id=56637 THEN '3.Tyre size'
WHEN Q.Id=53660	THEN 'FrontTyres Type'
WHEN Q.Id=61006	THEN 'FrontTyres Type'
WHEN Q.Id=53662	THEN 'FrontTyres size'
WHEN Q.Id=53663	THEN 'FrontTyres profile'
WHEN Q.Id=53665	THEN 'FrontTyres profile'
WHEN Q.Id=53685	THEN 'FrontTyres size'
WHEN Q.Id=53686	THEN 'FrontTyres profile'
WHEN Q.Id=53687	THEN 'FrontTyres profile'
WHEN Q.Id=53691	THEN 'FrontTyres size'
WHEN Q.Id=53692	THEN 'FrontTyres profile'
WHEN Q.Id=53693	THEN 'FrontTyres profile'
WHEN Q.Id=53697	THEN 'FrontTyres size'
WHEN Q.Id=53698	THEN 'FrontTyres profile'
WHEN Q.Id=53701	THEN 'FrontTyres profile'
WHEN Q.Id=53702	THEN 'FrontTyres profile'
WHEN Q.Id=53783	THEN 'FrontTyres profile'
WHEN Q.Id=53784	THEN 'FrontTyres profile'
WHEN Q.Id=53677	THEN 'FrontTyres Size'
WHEN Q.Id=53683	THEN 'FrontTyres Profile'
WHEN Q.Id=53302	THEN 'FrontTyres Qty'
WHEN Q.Id=53304	THEN 'FrontTyres Comments'
WHEN Q.Id=53661	THEN 'RearTyres Type'
WHEN Q.Id=61007	THEN 'RearTyres Type'
WHEN Q.Id=53666	THEN 'RearTyres size'
WHEN Q.Id=53667	THEN 'RearTyres profile'
WHEN Q.Id=53668	THEN 'RearTyres profile'
WHEN Q.Id=53688	THEN 'RearTyres size'
WHEN Q.Id=53689	THEN 'RearTyres profile'
WHEN Q.Id=53690	THEN 'RearTyres profile'
WHEN Q.Id=53694	THEN 'RearTyres size'
WHEN Q.Id=53695	THEN 'RearTyres profile'
WHEN Q.Id=53696	THEN 'RearTyres profile'
WHEN Q.Id=53699	THEN 'RearTyres size'
WHEN Q.Id=53700	THEN 'RearTyres profile'
WHEN Q.Id=53703	THEN 'RearTyres profile'
WHEN Q.Id=53704	THEN 'RearTyres profile'
WHEN Q.Id=53785	THEN 'RearTyres profile'
WHEN Q.Id=53786	THEN 'RearTyres profile'
WHEN Q.Id=53678	THEN 'RearTyres size'
WHEN Q.Id=53684	THEN 'RearTyres Profile'
WHEN Q.Id=53306	THEN 'RearTyres Qty'
WHEN Q.Id=53308	THEN 'RearTyres Comments'
WHEN Q.Id=53310	THEN 'Parts Qty'
WHEN Q.Id=53311	THEN 'Parts descriptions'
WHEN Q.Id=53314	THEN 'Part1 Qty'
WHEN Q.Id=53315	THEN 'Part1 descriptions'
WHEN Q.Id=53317	THEN 'Part2 Qty'
WHEN Q.Id=53318	THEN 'Part2 descriptions'
WHEN Q.Id=53322	THEN 'Part3 Qty'
WHEN Q.Id=53323	THEN 'Part3 descriptions'
WHEN Q.Id=53326	THEN 'Part4 Qty'
WHEN Q.Id=53327	THEN 'Part4 descriptions'
WHEN Q.Id=53330	THEN 'Part5 Qty'
WHEN Q.Id=53331	THEN 'Part5 descriptions'
WHEN Q.Id=53334	THEN 'Part6 Qty'
WHEN Q.Id=53335	THEN 'Part6 descriptions'
WHEN Q.Id=53338	THEN 'Part7 Qty'
WHEN Q.Id=53339	THEN 'Part7 descriptions'
WHEN Q.Id=53342	THEN 'Part8 Qty'
WHEN Q.Id=53343	THEN 'Part8 descriptions'
WHEN Q.Id=53346	THEN 'Part9 Qty'
WHEN Q.Id=53347	THEN 'Part9 descriptions'
WHEN Q.Id=53349	THEN 'FMA Details'
WHEN Q.Id=60501 THEN 'LMI Quantity'
WHEN Q.Id=53351	THEN 'LMI Details'
WHEN Q.Id=53353	THEN 'Training Details'
WHEN Q.Id=53364	THEN 'Engineering Details'
WHEN Q.Id=53367	THEN 'Spraybooth Details'
WHEN Q.Id=53370	THEN 'ElectronicRepairs Details'
WHEN Q.Id=69405	THEN 'FrontTyres QuantitySold'
WHEN Q.Id=69655 THEN 'FrontTyres Reason for lost sale'
WHEN Q.Id=69656 THEN 'FrontTyres Who is the competitor?'
WHEN Q.Id=69665 THEN 'FrontTyres Reason for lost sales'
WHEN Q.Id=53378	THEN 'Tyres Quoted'
WHEN Q.Id=56640	THEN 'Tyres Forecasted'
WHEN Q.Id=53379	THEN 'Tyres Converted'
WHEN Q.Id=69407 THEN 'RearTyres Quantity Sold'
WHEN Q.Id=53651	THEN 'RearTyres Reason for lost sale'
WHEN Q.Id=53381	THEN 'RearTyres Who is the competitor?'
WHEN Q.Id=53382	THEN 'RearTyres Reason for lost sales'
WHEN Q.Id=53384	THEN 'Parts Quoted'
WHEN Q.Id=56641	THEN 'Parts Forecasted'
WHEN Q.Id=53385	THEN 'Parts Converted'
WHEN Q.Id=69413 THEN 'Parts Description'
WHEN Q.Id=69414 THEN 'Parts Quantity Sold'
WHEN Q.Id=53652	THEN 'Parts Reason for lost sale'
WHEN Q.Id=53387	THEN 'Parts Who is the competitor?'
WHEN Q.Id=53388	THEN 'Parts Reason for lost sales'
WHEN Q.Id=69417 THEN 'Parts1 Description'
WHEN Q.Id=69418 THEN 'Parts1 Quantity Sold'
WHEN Q.Id=69531 THEN 'Parts1 Reason for lost sale'
WHEN Q.Id=69560 THEN 'Parts1 Who is the competitor?'
WHEN Q.Id=69570 THEN 'Parts1 Reason for lost sales'
WHEN Q.Id=69419 THEN 'Parts2 Description'
WHEN Q.Id=69420 THEN 'Parts2 Quantity Sold'
WHEN Q.Id=69635 THEN 'Parts2 Reason for lost sale'
WHEN Q.Id=69561 THEN 'Parts2 Who is the competitor?'
WHEN Q.Id=69571 THEN 'Parts2 Reason for lost sales'
WHEN Q.Id=69421 THEN 'Parts3 Description'
WHEN Q.Id=69422 THEN 'Parts3 Quantity Sold'
WHEN Q.Id=69636 THEN 'Parts3 Reason for lost sale'
WHEN Q.Id=69562 THEN 'Parts3 Who is the competitor?'
WHEN Q.Id=69572 THEN 'Parts3 Reason for lost sales'
WHEN Q.Id=69423 THEN 'Parts4 Description'
WHEN Q.Id=69424 THEN 'Parts4 Quantity Sold'
WHEN Q.Id=69638 THEN 'Parts4 Reason for lost sale'
WHEN Q.Id=69634 THEN 'Parts4 Who is the competitor?'
WHEN Q.Id=69573 THEN 'Parts4 Reason for lost sales'
WHEN Q.Id=69425 THEN 'Parts5 Description'
WHEN Q.Id=69426 THEN 'Parts5 Quantity Sold'
WHEN Q.Id=69639 THEN 'Parts5 Reason for lost sale'
WHEN Q.Id=69657 THEN 'Parts5 Who is the competitor?'
WHEN Q.Id=69661 THEN 'Parts5 Reason for lost sales'
WHEN Q.Id=69427 THEN 'Parts6 Description'
WHEN Q.Id=69428 THEN 'Parts6 Quantity Sold'
WHEN Q.Id=69640 THEN 'Parts6 Reason for lost sale'
WHEN Q.Id=69658 THEN 'Parts6 Who is the competitor?'
WHEN Q.Id=69662 THEN 'Parts6 Reason for lost sales'
WHEN Q.Id=69429 THEN 'Parts7 Description'
WHEN Q.Id=69430 THEN 'Parts7 Quantity Sold'
WHEN Q.Id=69641 THEN 'Parts7 Reason for lost sale'
WHEN Q.Id=69659 THEN 'Parts7 Who is the competitor?'
WHEN Q.Id=69663 THEN 'Parts7 Reason for lost sales'
WHEN Q.Id=69431 THEN 'Parts8 Description'
WHEN Q.Id=69432 THEN 'Parts8 Quantity Sold'
WHEN Q.Id=69637 THEN 'Parts8 Reason for lost sale'
WHEN Q.Id=69660 THEN 'Parts8 Who is the competitor?'
WHEN Q.Id=69664 THEN 'Parts8 Reason for lost sales'
WHEN Q.Id=69505 THEN 'Parts9 Description'
WHEN Q.Id=69506 THEN 'Parts9 Quantity Sold'
WHEN Q.Id=53653	THEN 'Parts9 Reason for lost sale'
WHEN Q.Id=53393	THEN 'Parts9 Who is the competitor?'
WHEN Q.Id=53394	THEN 'Parts9 Reason for lost sales'
WHEN Q.Id=53390	THEN 'PMA Quoted'
WHEN Q.Id=56642	THEN 'PMA Forecasted'
WHEN Q.Id=53391	THEN 'PMA Converted'
WHEN Q.Id=53439	THEN 'FMA Quoted'
WHEN Q.Id=56643	THEN 'FMA Forecasted'
WHEN Q.Id=53440	THEN 'FMA Converted'
WHEN Q.Id=69507 THEN 'FMA Quantity Sold'
WHEN Q.Id=53654	THEN 'FMA Reason for lost sale'
WHEN Q.Id=53442	THEN 'FMA Who is the competitor?'
WHEN Q.Id=53443	THEN 'FMA Reason for lost sales'
WHEN Q.Id=53445	THEN 'LMI Quoted'
WHEN Q.Id=56644	THEN 'LMI Forecasted'
WHEN Q.Id=53446	THEN 'LMI Converted'
WHEN Q.Id=69508 THEN 'LMI Quantity Sold'
WHEN Q.Id=53655	THEN 'LMI Reason for lost sale'
WHEN Q.Id=53448	THEN 'LMI Who is the competitor?'
WHEN Q.Id=53449	THEN 'LMI Reason for lost sales'
WHEN Q.Id=53451	THEN 'Training Quoted'
WHEN Q.Id=56645	THEN 'Training Forecasted'
WHEN Q.Id=53452	THEN 'Training Converted'
WHEN Q.Id=69521 THEN 'Types of training provided'
WHEN Q.Id=69524 THEN 'Driver Number of people trained'
WHEN Q.Id=53656	THEN 'Driver Reason for lost sale'
WHEN Q.Id=53454	THEN 'Driver Who is the competitor?'
WHEN Q.Id=53455	THEN 'Driver Reason for lost sales'
WHEN Q.Id=69525 THEN 'Apprenticeship Number of people trained'
WHEN Q.Id=69532 THEN 'Apprenticeship Reason for lost sale'
WHEN Q.Id=69559 THEN 'Apprenticeship Who is the competitor?'
WHEN Q.Id=69568 THEN 'Apprenticeship Reason for lost sales'
WHEN Q.Id=69526 THEN 'Technical Number of people trained'
WHEN Q.Id=69537 THEN 'Technical Reason for lost sale'
WHEN Q.Id=69563 THEN 'Technical Who is the competitor?'
WHEN Q.Id=69569 THEN 'Technical Reason for lost sales'
WHEN Q.Id=69527 THEN 'OEM Number of people trained'
WHEN Q.Id=69536 THEN 'OEM Reason for lost sale'
WHEN Q.Id=69558 THEN 'OEM Who is the competitor?'
WHEN Q.Id=69567 THEN 'OEM Reason for lost sales'
WHEN Q.Id=69528 THEN 'Soft-Skill Number of people trained'
WHEN Q.Id=69533 THEN 'Soft-Skill Reason for lost sale'
WHEN Q.Id=69557 THEN 'Soft-Skill Who is the competitor?'
WHEN Q.Id=69566 THEN 'Soft-Skill Reason for lost sales'
WHEN Q.Id=69529 THEN 'e-Learning Number of people trained'
WHEN Q.Id=69534 THEN 'e-Learning Reason for lost sale'
WHEN Q.Id=69556 THEN 'e-Learning Who is the competitor?'
WHEN Q.Id=69565 THEN 'e-Learning Reason for lost sales'
WHEN Q.Id=69530 THEN 'Facility Number of people trained'
WHEN Q.Id=69535 THEN 'Facility Reason for lost sale'
WHEN Q.Id=69555 THEN 'Facility Who is the competitor?'
WHEN Q.Id=69564 THEN 'Facility Reason for lost sales'
WHEN Q.Id=53457	THEN 'Engineering Quoted'
WHEN Q.Id=56646	THEN 'Engineering Forecasted'
WHEN Q.Id=53458	THEN 'Engineering Converted'
WHEN Q.Id=69710 THEN 'Engineering Was this a successful deal?'
WHEN Q.Id=53657	THEN 'Engineering Reason for lost sale'
WHEN Q.Id=53460	THEN 'Engineering Who is the competitor?'
WHEN Q.Id=53461	THEN 'Engineering Reason for lost sales'
WHEN Q.Id=53463	THEN 'Spraybooth Quoted'
WHEN Q.Id=56647	THEN 'Spraybooth Forecasted'
WHEN Q.Id=53464	THEN 'Spraybooth Converted'
WHEN Q.Id=69711 THEN 'Spraybooth Was this a successful deal?'
WHEN Q.Id=53658	THEN 'Spraybooth Reason for lost sale'
WHEN Q.Id=53466	THEN 'Spraybooth Who is the competitor?'
WHEN Q.Id=53467	THEN 'Spraybooth Reason for lost sales'
WHEN Q.Id=53469	THEN 'ElectronicRepairs Quoted'
WHEN Q.Id=56648	THEN 'ElectronicRepairs Forecasted'
WHEN Q.Id=53470	THEN 'ElectronicRepairs Converted'
WHEN Q.Id=69712 THEN 'ElectronicRepairs Was this a successful deal?'
WHEN Q.Id=53659	THEN 'ElectronicRepairs Reason for lost sale'
WHEN Q.Id=53472	THEN 'ElectronicRepairs Who is the competitor?'
WHEN Q.Id=53473	THEN 'ElectronicRepairs Reason for lost sales'
WHEN Q.Id=60504	THEN 'Repairs Quoted'
WHEN Q.Id=60505	THEN 'Repairs Forecasted'
WHEN Q.Id=60506	THEN 'Repairs Converted'
WHEN Q.Id=69754 THEN 'STR Quantity Rented'
WHEN Q.Id=60507	THEN 'STR Reason for lost sale'
WHEN Q.Id=60508	THEN 'STR Who is the competitor?'
WHEN Q.Id=60509	THEN 'STR Reason for lost sales' 
WHEN Q.Id=69755 THEN 'Service Sold'
WHEN Q.Id=69756 THEN 'Service Reason for lost sale'
WHEN Q.Id=69757 THEN 'Service Who is the competitor?'
WHEN Q.Id=69758 THEN 'Service Reason for lost sales'
WHEN Q.Id=69718 THEN 'Repairs Was this a successful deal?'
WHEN Q.Id=66795 THEN 'Repairs Reason for lost sale'
WHEN Q.Id=66796 THEN 'Repairs Who is the competitor?'
WHEN Q.Id=66797 THEN 'Repairs Reason for lost sales' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5437
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (53483,53299,29604,58623,53807,29249,29280,29605,29281,53475,53476,53477,53478,53479,53480,53660,53662,53663,53665,53685,53686,53687,53691,53692,53693,53697,53698,53701,53702,53783,53784,53677,53683,53302,53304,53661,53666,53667,53668,53688,53689,53690,53694,53695,53696,53699,53700,53703,53704,53785,53786,53678,53684,53306,53308,53310,53311,53314,53315,53317,53318,53322,53323,53326,53327,53330,53331,53334,53335,53338,53339,53342,53343,53346,53347,53348,53355,53356,53349,53350,53351,53352,53617,53618,53619,53620,53621,53622,53623,53353,53363,53364,53366,53367,53369,53370,53372,53373,53374,53378,53379,53651,53381,53382,53384,53385,53652,53387,53388,53390,53391,53653,53393,53394,53439,53440,53654,53442,53443,53445,53446,53655,53448,53449,53451,53452,53656,53454,53455,53457,53458,53657,53460,53461,53463,53464,53658,53466,53467,53469,53470,53659,53472,53473,56636,56640,56641,56642,56643,56644,56645,56646,56647,56648,56638,56639,57316,57317,58624,58625,58626,56637,60510,60511,60501,60502,60504,60505,60506,60507,60508,60509,60513,61006,61007,69402,58724,
69403,69405,69655,69656,69665,69407,69413,69414,69417,69418,69531,69560,69570,69419,69420,69635,69561,69571,69421,69422,69636,69562,69572,69423,69424,69638,69634,69573,69425,69426,69639,69657,69661,69427,69428,69640,69658,69662,69429,69430,69641,69659,69663,69431,69432,69637,69660,69664,69505,69506,69507,69508,69521,69524,69525,69532,69559,69568,69526,69537,69563,69569,69527,69536,69558,69567,69528,69533,69557,69566,69529,69534,69556,69565,69530,69535,69555,69564,69710,69711,69712,69754,69755,69756,69757,69758,69718,66795,66796,66797)
LEFT JOIN dbo.[Appuser] u on u.id=am.CreatedBy
LEFT JOIN SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Activity Type:],[WIP number],[Call Type],[Select a status],[Type of contract],[Market intelligence & opportunity areas],[Company name],[Contract status],[Reason for lost deal],[Identify areas of improvement],[Activity:],[Did you visit the customer?],[comments],[Elements Required],[Environment],[Floor Surface],[Yard],[2. Hour meter Reading],[3.Tyre size],[4. Monthly Operational Hours],[FrontTyres TYPE],[FrontTyres SIZE],[FrontTyres PROFILE],[FrontTyres Qty],[FrontTyres Comments],[RearTyres Type],[RearTyres size],[RearTyres PROFILE],[RearTyres Qty],[RearTyres Comments],[Parts Qty],[Parts descriptions],[Part1 Qty],[Part1 descriptions],[Part2 Qty],[Part2 descriptions],[Part3 Qty],[Part3 descriptions],[Part4 Qty],[Part4 descriptions],[Part5 Qty],[Part5 descriptions],[Part6 Qty],[Part6 descriptions],[Part7 Qty],[Part7 descriptions],[Part8 Qty],[Part8 descriptions],[Part9 Qty],[Part9 descriptions],[Is the unit New Equipment?],[Did the New Equipment Sales rep sell a FMA?],[Did you complete a Site inspection?],[FMA Details],[Does the customer require a LMI?],[LMI Quantity],[LMI Details],[Does the customer require Training?],[Does the customer require  Driver / Operator Training?],[Does the customer require Apprenticeship / Learnership Related Training?],[Does the customer require Technical Skills Related Training?],[Does the customer require OEM Product Specific Training?],[Does the customer require Soft-Skill Development Training?],[Does the customer require e-Learning Content Access?],[Does the customer require Facility / Venue Hire (Meetings / Workshops)JHB only?],[Number of people trained],[Training Details],[Does the customer require Engineering?],[Engineering Details],[Does the customer require a Spraybooth work?],[Spraybooth Details],[Does the customer require Electronic Repairs?],[ElectronicRepairs Details],[Does the customer require a Short Term Rental Unit?],[Have you completed a site inspection?],[Model request],[Tyres Quoted],[Tyres Forecasted],[Tyres Converted],[Tyres Reason for lost sale],[Tyres Who is the competitor?],[Tyres Reason for lost sales],[Parts Quoted],[Parts Forecasted],[Parts Converted],[Parts Reason for lost sale],[Parts Who is the competitor?],[Parts Reason for lost sales],[PMA Quoted],[PMA Forecasted],[PMA Converted],[PMA Reason for lost sale],[PMA Who is the competitor?],[PMA Reason for lost sales],[FMA Quoted],[FMA Forecasted],[FMA Converted],[FMA Reason for lost sale],[FMA Who is the competitor?],[FMA Reason for lost sales],[LMI Quoted],[LMI Forecasted],[LMI Converted],[LMI Reason for lost sale],[LMI Who is the competitor?],[LMI Reason for lost sales],[Training Quoted],[Training Forecasted],[Training Converted],[Training Reason for lost sale],[Training Who is the competitor?],[Training Reason for lost sales],[Engineering Quoted],[Engineering Forecasted],[Engineering Converted],[Engineering Reason for lost sale],[Engineering Who is the competitor?],[Engineering Reason for lost sales],[Spraybooth Quoted],[Spraybooth Forecasted],[Spraybooth Converted],[Spraybooth Reason for lost sale],[Spraybooth Who is the competitor?],[Spraybooth Reason for lost sales],[ElectronicRepairs Quoted],[ElectronicRepairs Forecasted],[ElectronicRepairs Converted],[ElectronicRepairs Reason for lost sale],[ElectronicRepairs Who is the competitor?],[ElectronicRepairs Reason for lost sales],[What type of service does customer require?],[Reason for client not signing contract?],[Does the customer require a repair?],[Repair details],[Repairs Quoted],[Repairs Forecasted],[Repairs Converted],[Repairs Reason for lost sale],[Repairs Who is the competitor?],[Repairs Reason for lost sales],
[Elements Sold:],[FrontTyres QuantitySold],
[FrontTyres Reason for lost sale],
[FrontTyres Who is the competitor?],
[FrontTyres Reason for lost sales],
[RearTyres Quantity Sold],
[Parts Description],
[Parts Quantity Sold],
[Parts1 Description],
[Parts1 Quantity Sold],
[Parts1 Reason for lost sale],
[Parts1 Who is the competitor?],
[Parts1 Reason for lost sales],
[Parts2 Description],
[Parts2 Quantity Sold],
[Parts2 Reason for lost sale],
[Parts2 Who is the competitor?],
[Parts2 Reason for lost sales],
[Parts3 Description],
[Parts3 Quantity Sold],
[Parts3 Reason for lost sale],
[Parts3 Who is the competitor?],
[Parts3 Reason for lost sales],
[Parts4 Description],
[Parts4 Quantity Sold],
[Parts4 Reason for lost sale],
[Parts4 Who is the competitor?],
[Parts4 Reason for lost sales],
[Parts5 Description],
[Parts5 Quantity Sold],
[Parts5 Reason for lost sale],
[Parts5 Who is the competitor?],
[Parts5 Reason for lost sales],
[Parts6 Description],
[Parts6 Quantity Sold],
[Parts6 Reason for lost sale],
[Parts6 Who is the competitor?],
[Parts6 Reason for lost sales],
[Parts7 Description],
[Parts7 Quantity Sold],
[Parts7 Reason for lost sale],
[Parts7 Who is the competitor?],
[Parts7 Reason for lost sales],
[Parts8 Description],
[Parts8 Quantity Sold],
[Parts8 Reason for lost sale],
[Parts8 Who is the competitor?],
[Parts8 Reason for lost sales],
[Parts9 Description],
[Parts9 Quantity Sold],
[Parts9 Reason for lost sale],
[Parts9 Who is the competitor?],
[Parts9 Reason for lost sales],
[FMA Quantity Sold],
[LMI Quantity Sold],
[Types of training provided],
[Driver Number of people trained],
[Apprenticeship Number of people trained],
[Apprenticeship Reason for lost sale],
[Apprenticeship Who is the competitor?],
[Apprenticeship Reason for lost sales],
[Technical Number of people trained],
[Technical Reason for lost sale],
[Technical Who is the competitor?],
[Technical Reason for lost sales],
[OEM Number of people trained],
[OEM Reason for lost sale],
[OEM Who is the competitor?],
[OEM Reason for lost sales],
[Soft-Skill Number of people trained],
[Soft-Skill Reason for lost sale],
[Soft-Skill Who is the competitor?],
[Soft-Skill Reason for lost sales],
[e-Learning Number of people trained],
[e-Learning Reason for lost sale],
[e-Learning Who is the competitor?],
[e-Learning Reason for lost sales],
[Facility Number of people trained],
[Facility Reason for lost sale],
[Facility Who is the competitor?],
[Facility Reason for lost sales],
[Engineering Was this a successful deal?],
[Spraybooth Was this a successful deal?],
[ElectronicRepairs Was this a successful deal?],
[STR Quantity Rented],
[STR Reason for lost sale],
[STR Who is the competitor?],
[STR Reason for lost sales],
[Service Sold],
[Service Reason for lost sale],
[Service Who is the competitor?],
[Service Reason for lost sales],
[Repairs Was this a successful deal?],
[Driver Reason for lost sale],[Driver Who is the competitor?],[Driver Reason for lost sales],
[RearTyres Reason for lost sale],[RearTyres Who is the competitor?],[RearTyres Reason for lost sales]
))P
)BB ON	AA.ReferenceNo=BB.SeenClientAnswerMasterId
WHERE AA.UserName NOT IN ('Salisha Naidoo','Toyota Forklift Admin')

