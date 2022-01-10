CREATE VIEW dbo.[PB_VW_NW_Particulars] AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserId,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.[Company name],
       AA.[Product interested in],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Are you],
       BB.[Trading name of business],
       BB.[Registered name of business],
       BB.[Previous trading/registered names],
       BB.[Incorporated form of business],
       BB.[VAT registration number],
       BB.[Registered name of holding company],
       BB.[Names of subsidiary and associate companies],
       BB.[Business activities],
       BB.[Physical address],
       BB.[Are deliveries to be made to this address? If not, then where?],
       BB.[Postal address + code],
       BB.[Are invoices to be sent to this postal address? If not, then where?],
       BB.[Registered address],
       BB.[Telephone number],
       BB.[Fax area & no],
       BB.Premises,
       BB.Email,
       BB.[Name of landlord],
       BB.[Postal address of landlord],
       BB.[Details of],
       BB.[Full name],
       BB.[ID No.],
       BB.[Residential address],
       BB.[% shareholding / interest],
       BB.[Registration number of incorporation],
       BB.[Postal address for invoice],
       BB.[Delivery address if different to physical address],
       BB.[Accounts contact person],
       BB.[Accounts department telephone number],
       BB.[Accounts department fax number],
       BB.[Orders placed by],
       BB.[Order numbers used?],
       BB.[Project / division requesting invoice],
       BB.[Credit limit request] FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Company name],[Product interested in]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3024
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3023
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3021
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3022
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5067 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (39679,39680)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Product interested in]
))p
)AA
LEFT JOIN 
(
select EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,IsResolved AS Status,UserId,UserName,
[Are you],[Trading name of business],[Registered name of business],[Previous trading/registered names],[Incorporated form of business],[VAT registration number],[Registered name of holding company],[Names of subsidiary and associate companies],[Business activities],[Physical address],[Are deliveries to be made to this address? If not, then where?],[Postal address + code],[Are invoices to be sent to this postal address? If not, then where?],[Registered address],[Telephone number],[Fax area & no],[Premises],[Email],[Name of landlord],[Postal address of landlord],[Details of],[Full name],[ID No.],[Residential address],[% shareholding / interest],[Registration number of incorporation],[Postal address for invoice],[Delivery address if different to physical address],[Accounts contact person],[Accounts department telephone number],[Accounts department fax number],[Orders placed by],[Order numbers used?],[Project / division requesting invoice],[Credit limit request]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.Id as ReferenceNo,cam.Id AS SeenClientAnswerMasterId,
am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5067 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (26240,26242,26243,26244,26246,26247,26248,26249,26250,26251,26252,26253,26254,26255,26256,26257,26258,26259,26260,26261,26262,26263,26264,26265,26270,26271,26273,26274,26275,26276,26277,26278,26279,26280,26281,26282,26283,26284,26285,26286,26287,26763)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Are you],[Trading name of business],[Registered name of business],[Previous trading/registered names],[Incorporated form of business],[VAT registration number],[Registered name of holding company],[Names of subsidiary and associate companies],[Business activities],[Physical address],[Are deliveries to be made to this address? If not, then where?],[Postal address + code],[Are invoices to be sent to this postal address? If not, then where?],[Registered address],[Telephone number],[Fax area & no],[Premises],[Email],[Name of landlord],[Postal address of landlord],[Details of],[Full name],[ID No.],[Residential address],[% shareholding / interest],[Registration number of incorporation],[Postal address for invoice],[Delivery address if different to physical address],[Accounts contact person],[Accounts department telephone number],[Accounts department fax number],[Orders placed by],[Order numbers used?],[Project / division requesting invoice],[Credit limit request]
))P
)BB ON AA.ReferenceNo=bb.SeenClientAnswerMasterId

