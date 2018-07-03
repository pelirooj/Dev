CREATE PROCEDURE [dbo].[usp_OSHENS_GetEmployees]
	
AS

BEGIN

	SET NOCOUNT ON;	--prevent extra result sets from interfering with SELECT statements.

select DISTINCT
employeeid AS 'Employee No.',
CASE
WHEN (RequestedName = '' OR RequestedName IS NULL)
THEN GivenName
ELSE RequestedName
END AS 'Firstname',
FamilyName AS 'Surname',

ISNULL (
CASE WHEN dbo.ufnIsEmpInUnit(employeeid, 'L1000') = 1
THEN o3.Description
ELSE od.Description
END 
,od.Description)
AS 'Org Level 1',

ISNULL (
CASE WHEN dbo.ufnIsEmpInUnit(employeeid, 'L1000') = 1
THEN o4.Description
ELSE ''  
END 
,'')
AS 'Org Level 2',

ISNULL (
CASE WHEN dbo.ufnIsEmpInUnit(employeeid, 'L1000') = 1
THEN o5.Description
ELSE ''
END 
,'')
AS 'Org Level 3',

--o3.Description as 'Org Level 1',
--o4.Description as 'Org Level 2',
--o5.Description as 'Org Level 3',
--m.EMPLOYEE_ID,
e.Email,
e.EmployeeID as 'LoginID',
--m.OD,
--m.CSM,
--m.TL,
--m.PS,
--m.MAN,
ISNULL (
CASE
WHEN m.OD = 1 THEN 1
WHEN m.CSM = 1 THEN 2
WHEN (m.TL = 1 OR m.PS = 1) THEN 3
WHEN m.MAN = 1 THEN 4
ELSE 0
END 
,0) AS 'Grade',
--1 as 'Grade1',
l.PhoneNo as 'Work Tel',
l.LocationDescription as 'Address1',
l.AddressLine1 as 'Address2',
l.AddressLine2 as 'Address3',
l.AddressLine3 as 'Town',
l.AddressLine4 as 'County',
l.PostCode as 'Postcode'
--p.*
from employee e
inner join personlink pl on pl.roleid = e.employeeid
inner join person pe on pe.personid = pl.personid
inner join career c on c.ParentIdentifier = employeeid
inner join post p on p.UniqueIdentifier = c.PostIdentifier
inner join organisation o on o.code = p.OrganisationCode
left join organisation o5 on o5.code = p.Level5OrgRef
left join organisation o4 on o4.code = p.Level4OrgRef
left join organisation o3 on o3.code = p.Level3OrgRef
left join location l on o.LocationReference = l.locationreference
left join Organisation od on od.Code = p.DirectorateRef
left join Elsi_T3.dbo.vw_ManagersForOSHENS m on m.EMPLOYEE_ID collate Latin1_General_CI_AS = e.EmployeeID

where PrimaryPostYN = 'y'
and e.startdate <= getdate()
and (terminationdate is null or terminationdate > getdate() or terminationdate ='')
--and pl.Role <> 'volunteer'
and (Email IS NOT NULL and e.UserName IS NOT NULL)
order by [Org Level 1], [Org Level 2],  [Org Level 3], Firstname, Surname desc

END

GO
--notes--------------------------------------------
--no volunteers
--inc if no username and/or email?
--do we want addresses for people? will be post address
--post title?
--as this is primary post, could be linked to TL in a differnt Service from Elsi. Requested changes make
--me think that the employee update should not update 'Grade' once the user has been created.
--ODs and CSMs are picked from Elsi using L3 and L4 'CS_UNIT' from unit table
--TL is TL from Elsi project Members table

--select * from Organisation where Code = 'L5031'
--select * from Organisation where Code = 'L1003'
--select * from Organisation order by Level
