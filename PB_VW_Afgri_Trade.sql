CREATE VIEW dbo.PB_VW_Afgri_Trade AS

SELECT 'TREKKER' AS Type,AA.*,
	   BB.ResponseDate,
	   BB.ResponseNo,
	   BB.Approved,
	   BB.Reason,
	   BB.[Verkoop Prys]
	   FROM 
(select EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.PI,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,CustomerCompany,
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],NULL AS [Drom Ure],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],[SH Enjin No],NULL AS [SH Drom Ure],[Inruil bedrag (Rands)],[Overtrade af (Rands)],[Agfacts prys (Rands) excl. BTW],[Herstel Kostes +- (Rands) excl. BTW],[Bakwerk],[Raamwerk],[Gewigte],[Instrumente],[Sitplek],[Algemeen Kommentaar],
--[Algemeen Foto],
[Battery],[Alternator],[Ligte],[Bedrading],[Aansitter],[Elektries Kommentaar],
--[Elektries Foto],
[kilowatts],NULL AS [klas],[Toestand],[Verkoeler],[Koppelaar],[Enjin Kommentaar],
--[Enjin Foto],
[Ratkas],[Ratkas Kommentaar],[Hyser],[Koppelstukke],[Remme],[Hidroulies Kommentaar],
--[Hidroulies Foto],
[Vierwiel dryf],[Vierwiel Kommentaar],
--[Vierwiel Foto],
[Ewenaar],[Stuur meganisme],[Ewenaar Kommentaar],
--[Ewenaar Foto],
[P.T.O],[PTO Kommentaar],
--[PTO Foto],
[Oile lekke],[Algemene Ster Waarde],[Voor],[Agter],[Uurmeter lesing],[Top Link],[4 Wheel Dryf],[Pre Sold],[Registrasie Dokument],[Ander]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,AM.PI,
CASE 
WHEN q.Id=5524 THEN 'SH Reeks No'
WHEN q.Id=5525 THEN 'SH Enjin No' 
WHEN q.id=5538 THEN 'Algemeen Kommentaar'
WHEN q.id=5539 THEN 'Algemeen Foto'
WHEN q.id=5546 THEN 'Elektries Kommentaar'
WHEN q.id=5547 THEN 'Elektries Foto'
WHEN q.id=5552 THEN 'Enjin Kommentaar'
WHEN q.id=5553 THEN 'Enjin Foto'
WHEN q.id=5555 THEN 'Ratkas Kommentaar'
WHEN q.id=5561 THEN 'Hidroulies Kommentaar'
WHEN q.id=5562 THEN 'Hidroulies Foto'
WHEN q.id=5564 THEN 'Vierwiel Kommentaar'
WHEN q.id=5565 THEN 'Vierwiel Foto'
WHEN q.id=5568 THEN 'Ewenaar Kommentaar'
WHEN q.id=5569 THEN 'Ewenaar Foto'
WHEN q.id=5571 THEN 'PTO Kommentaar'
WHEN q.id=5572 THEN 'PTO Foto' ELSE q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=269
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=268
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=267
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=265
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=266
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=971
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (14052,10564,10565,70840,7992,5514,5515,5516,5517,7987,5519,5521,5522,5523,5524,5525,7997,7996,7995,7994,5533,5534,5535,5536,5537,5538,5539,5541,5542,5543,5544,5545,5546,5547,70838,5549,5550,5551,5552,5553,5554,5555,5558,5559,5560,5561,5562,5563,5564,5565,5566,5567,5568,5569,5570,5571,5572,5573,5574,5576,5577,5578,7989,7990,7991,5580,5581,73003,73004)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],[SH Enjin No],[Inruil bedrag (Rands)],[Overtrade af (Rands)],[Agfacts prys (Rands) excl. BTW],[Herstel Kostes +- (Rands) excl. BTW],[Bakwerk],[Raamwerk],[Gewigte],[Instrumente],[Sitplek],[Algemeen Kommentaar],[Algemeen Foto],[Battery],[Alternator],[Ligte],[Bedrading],[Aansitter],[Elektries Kommentaar],[Elektries Foto],[kilowatts],[Toestand],[Verkoeler],[Koppelaar],[Enjin Kommentaar],[Enjin Foto],[Ratkas],[Ratkas Kommentaar],[Hyser],[Koppelstukke],[Remme],[Hidroulies Kommentaar],[Hidroulies Foto],[Vierwiel dryf],[Vierwiel Kommentaar],[Vierwiel Foto],[Ewenaar],[Stuur meganisme],[Ewenaar Kommentaar],[Ewenaar Foto],[P.T.O],[PTO Kommentaar],[PTO Foto],[Oile lekke],[Algemene Ster Waarde],[Voor],[Agter],[Uurmeter lesing],[Top Link],[4 Wheel Dryf],[Pre Sold],[Registrasie Dokument],[Ander]
))P
)AA

LEFT JOIN 

(select CAST(ResponseDate AS DATE) AS ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Approved],[Reason],[Verkoop Prys]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=971
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (6772,6773,4953)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Approved],[Reason],[Verkoop Prys]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 'IMPLEMENTE' AS Type,AA.*,
	   BB.ResponseDate,
	   BB.ResponseNo,
	   BB.Approved,
	   BB.Reason,
	   NULL AS [Verkoop Prys]
	   FROM 
(select EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.PI,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,CustomerCompany,
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],NULL AS [Drom Ure],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],NULL AS [SH Enjin No],NULL AS [SH Drom Ure],[Inruil bedrag (Rands)],[Overtrade af (Rands)],NULL AS [Agfacts prys (Rands) excl. BTW],[Herstel Kostes +- (Rands) excl. BTW],NULL AS [Bakwerk],[Raamwerk],NULL AS [Gewigte],NULL AS [Instrumente],NULL AS [Sitplek],[Algemeen Kommentaar],
--[Algemeen Foto],
NULL AS [Battery],NULL AS [Alternator],NULL AS [Ligte],[Bedrading],NULL AS [Aansitter],[Elektries Kommentaar],
--[Elektries Foto],
NULL AS [kilowatts],NULL AS [klas],NULL AS [Toestand],NULL AS [Verkoeler],NULL AS [Koppelaar],NULL AS [Enjin Kommentaar],NULL AS [Ratkas],NULL AS [Ratkas Kommentaar],NULL AS [Hyser],[Koppelstukke],NULL AS [Remme],NULL AS [Hidroulies Kommentaar],NULL AS [Vierwiel dryf],NULL AS [Vierwiel Kommentaar],NULL AS [Ewenaar],NULL AS [Stuur meganisme],NULL AS [Ewenaar Kommentaar],NULL AS [P.T.O],NULL AS [PTO Kommentaar],NULL AS [Oile lekke],[Algemene Ster Waarde],NULL AS [Voor],NULL AS [Agter],NULL AS [Uurmeter lesing],[Top Link],NULL AS [4 Wheel Dryf],[Pre Sold],NULL AS [Registrasie Dokument],[Ander]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,AM.PI,
CASE 
WHEN q.Id=8780 THEN 'SH Reeks No'
WHEN q.id=8788 THEN 'Algemeen Kommentaar'
WHEN q.id=8789 THEN 'Algemeen Foto'
WHEN q.id=8792 THEN 'Elektries Kommentaar'
WHEN q.id=8793 THEN 'Elektries Foto' ELSE q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=269
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=268
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=267
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=265
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=266
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=1539
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (14053,10561,10562,70841,8768,8770,8771,8772,8773,8774,8775,8777,8778,8779,8780,8781,8782,8783,8787,8788,8789,8791,8792,8793,8795,8796,8797,8798,8799,73000,73001,73002)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],[Inruil bedrag (Rands)],[Overtrade af (Rands)],[Herstel Kostes +- (Rands) excl. BTW],[Raamwerk],[Algemeen Kommentaar],[Algemeen Foto],[Bedrading],[Elektries Kommentaar],[Elektries Foto],[Koppelstukke],[Algemene Ster Waarde],[Top Link],[Pre Sold],[Ander]
))P
)AA

LEFT JOIN 

(select CAST(ResponseDate AS DATE) AS ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Approved],[Reason]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=1539
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (7187,7188)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Approved],[Reason]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 'STROPERS' AS Type,AA.*,
	   BB.ResponseDate,
	   BB.ResponseNo,
	   BB.Approved,
	   BB.Reason,
	   NULL AS [Verkoop Prys] 
	   FROM 
(select EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.PI,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,CustomerCompany,
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],[Drom Ure],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],[SH Enjin No],[SH Drom Ure],[Inruil bedrag (Rands)],[Overtrade af (Rands)],NULL AS [Agfacts prys (Rands) excl. BTW],[Herstel Kostes +- (Rands) excl. BTW],[Bakwerk],[Raamwerk],NULL AS [Gewigte],[Instrumente],[Sitplek],[Algemeen Kommentaar],
--[Algemeen Foto],
[Battery],[Alternator],[Ligte],[Bedrading],[Aansitter],[Elektries Kommentaar],
--[Elektries Foto],
NULL AS [kilowatts],[klas],[Toestand],[Verkoeler],[Koppelaar],[Enjin Kommentaar],
--[Enjin Foto],
[Ratkas],[Ratkas Kommentaar],NULL AS [Hyser],[Koppelstukke],[Remme],[Hidroulies Kommentaar],
--[Hidroulies Foto],
NULL AS [Vierwiel dryf],NULL AS [Vierwiel Kommentaar],NULL AS [Ewenaar],[Stuur meganisme],[Ewenaar Kommentaar],
--[Ewenaar Foto],
NULL AS [P.T.O],NULL AS [PTO Kommentaar],[Oile lekke],[Algemene Ster Waarde],[Voor],[Agter],[Uurmeter lesing],NULL AS [Top Link],NULL AS [4 Wheel Dryf],[Pre Sold],[Registrasie Dokument],[Ander]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,AM.PI,
CASE 
WHEN q.Id=8848 THEN 'SH Reeks No'
WHEN q.Id=8849 THEN 'SH Enjin No'
WHEN q.Id=9775 THEN 'SH Drom Ure'
WHEN q.id=8860 THEN 'Algemeen Kommentaar'
WHEN q.id=8861 THEN 'Algemeen Foto'
WHEN q.id=8868 THEN 'Elektries Kommentaar'
WHEN q.id=8869 THEN 'Elektries Foto'
WHEN q.id=8874 THEN 'Enjin Kommentaar'
WHEN q.id=8875 THEN 'Enjin Foto'
WHEN q.id=8877 THEN 'Ratkas Kommentaar'
WHEN q.id=8881 THEN 'Hidroulies Kommentaar'
WHEN q.id=8882 THEN 'Hidroulies Foto'
WHEN q.id=8884 THEN 'Ewenaar Kommentaar'
WHEN q.id=8885 THEN 'Ewenaar Foto' ELSE q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=269
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=268
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=267
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=265
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=266
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=1541
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (14051,10557,10558,70842,8836,8838,8839,8840,8841,9774,8842,8843,8845,8846,8847,8848,8849,9775,8850,8851,8852,8856,8857,8858,8859,8860,8861,8863,8864,8865,8866,8867,8868,8869,70839,8871,8872,8873,8874,8875,8876,8877,8879,8880,8881,8882,8883,8884,8885,8886,8887,8889,8890,8891,8892,8893,8894,73005,73006,73007,73008)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Tak],[Gee asseblief 'n kommentaar om die versoek prys te motiveer.],[Hoeveel voorneme eenhede is die kliënt van plan om te koop?],[Sal die kliënt gebruik maak van John Deere finansiering?],[Select - Geld Deponeer],[Klient],[Inruil op],[Reeks No],[Enjin No],[Drom Ure],[Prys (Rands)],[Bystand af],[Fabrikaat],[Model],[Jaar Model],[SH Reeks No],[SH Enjin No],[SH Drom Ure],[Inruil bedrag (Rands)],[Overtrade af (Rands)],[Herstel Kostes +- (Rands) excl. BTW],[Bakwerk],[Raamwerk],[Instrumente],[Sitplek],[Algemeen Kommentaar],[Algemeen Foto],[Battery],[Alternator],[Ligte],[Bedrading],[Aansitter],[Elektries Kommentaar],[Elektries Foto],[klas],[Toestand],[Verkoeler],[Koppelaar],[Enjin Kommentaar],[Enjin Foto],[Ratkas],[Ratkas Kommentaar],[Koppelstukke],[Remme],[Hidroulies Kommentaar],[Hidroulies Foto],[Stuur meganisme],[Ewenaar Kommentaar],[Ewenaar Foto],[Oile lekke],[Algemene Ster Waarde],[Voor],[Agter],[Uurmeter lesing],[Pre Sold],[Registrasie Dokument],[Ander]
))P
)AA

LEFT JOIN 

(select CAST(ResponseDate AS DATE) AS ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Approved],[Reason]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=1541
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (7191,7192)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Approved],[Reason]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

