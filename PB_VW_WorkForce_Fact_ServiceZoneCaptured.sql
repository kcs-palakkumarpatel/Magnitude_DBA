Create view PB_VW_WorkForce_Fact_ServiceZoneCaptured as
WITH cte AS(
Select Establishment,
CapturedDate,
ReferenceNo,
IsPositive,
FormStatus,
UserName,
[User],
Longitude,
Latitude,
RepeatCount,
[Name],
[Surname],
[Mobile],
[Email],
[Company],
[Industry],
[Designation],
[Date],
[Time],
[Name of Client],
[Name of Site],
[Current Head count],
[Contact Person],
[Attendees],
[Apologies],
[Reason for meeting],
[Minutes],
[Action Point],
[Responsible Person],
[Deadline],
[Compliments],
[Pain Points],
[Other Opportunity],
[Rate Meeting]

 from(

 


select E.EstablishmentName as Establishment,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as FormStatus,
A.Detail as Answer,Q.ShortName as Question , u.name as UserName,u.username AS[User],
AM.Longitude,AM.Latitude,A.RepeatCount

 

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and E.isdeleted=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
inner join dbo.[Appuser] u on u.id=AM.CreatedBy

 

where G.id=494
and EG.id=6515 and Q.id in
(56562,56563,56564,56565,56566,56567,56568,56572,56573,56574,56575,56576,56577,56578,72248,
56579,56580,72249,72250,72251,56581,56582,56583,56584)
and (AM.isdeleted is null or AM.isdeleted=0)

 

)S 
PIVOT(Max(Answer)
for Question in
([Name],
[Surname],
[Mobile],
[Email],
[Company],
[Industry],
[Designation],
[Date],
[Time],
[Name of Client],
[Name of Site],
[Current Head count],
[Contact Person],
[Attendees],
[Apologies],
[Reason for meeting],
[Minutes],
[Action Point],
[Responsible Person],
[Deadline],
[Compliments],
[Pain Points],
[Other Opportunity],
[Rate Meeting]

))P
 )

 
 SELECT 
B.Establishment,
B.CapturedDate,
B.ReferenceNo,
B.IsPositive,
B.FormStatus,
B.UserName,
B.[User],
B.Longitude,
B.Latitude,
A.RepeatCount,
B.[Name],
B.[Surname],
B.[Mobile],
B.[Email],
B.[Company],
B.[Industry],
B.[Designation],
B.[Date],
B.[Time],
B.[Name of Client],
B.[Name of Site],
B.[Current Head count],
B.[Contact Person],
B.[Attendees],
B.[Apologies],
B.[Reason for meeting],
B.[Minutes],
A.[Action Point],
A.[Responsible Person],
A.[Deadline],
B.[Compliments],
B.[Pain Points],
B.[Other Opportunity],
B.[Rate Meeting]

 FROM
 (SELECT * FROM cte WHERE cte.RepeatCount<>0)A 
 RIGHT OUTER JOIN
  ( SELECT * FROM cte WHERE cte.RepeatCount=0)B ON A.ReferenceNo=B.ReferenceNo


