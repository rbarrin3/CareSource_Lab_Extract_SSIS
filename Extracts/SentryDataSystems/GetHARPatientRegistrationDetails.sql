/******************************************************************************************************************************
**               AUTHOR    : Sid G
**        CREATION DATE    : 03/17/2022
**              VERSION    : 1.0
**          DATABASE(S)    : Clarity
**          WRITTEN FOR    : Sentry
**        SQL FILE NAME    : Sentry HAR Extract
**          TEMPLATE ID    : 
**             TICKET #    : 
**
**              PURPOSE    : Sentry HAR Extract
** BI DOCUMENT LOCATION    : Teams > Epic EMR Project - DTAS > General > Cogito > Extract Specifications > SentryDataSystems >
**                           Sentry Data Specification Data Map - Epic 20220110.xlsx
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		04/07/2022 XXXX	        Sid	        1.X			Modified Updated Missing Fields.
*******************************************************************************************************************************/
CREATE PROCEDURE dbo.GetHARPatientRegistrationDetails
AS

DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1')); 




select 
hsp.HSP_ACCOUNT_ID as "HAR Account Number1",
hsp.HSP_ACCOUNT_ID as "HAR Account Number2",
pat.PAT_MRN_ID	as "Medical Record Number",
ISNULL(pat.PAT_LAST_NAME,'') as "Patient Last Name",
ISNULL(pat.PAT_FIRST_NAME,'') as "Patient First Name",
CASE WHEN hsp.ACCT_BASECLS_HA_C = 1 THEN 'I'
     WHEN hsp.ACCT_BASECLS_HA_C = 2 THEN 'O'
	 END AS "Patient Class"	,
ISNULL(CONVERT(char(3), zac.NAME),'') as "Patient Type",
ISNULL(CONVERT(varchar(25), dep.DEPT_ABBREVIATION),'') as "Location of Service",
replace(convert(varchar(10), hsp.ADM_DATE_TIME, 101),'/','') AS "Admit Date/Service Date",
replace(convert(varchar(10), hsp.DISCH_DATE_TIME, 101),'/','') AS "Discharge Date/Service Date"	,
'' as "Facility Code"


from
HSP_ACCOUNT hsp
left outer join PATIENT pat ON hsp.PAT_ID = pat.PAT_ID
left outer join ZC_ACCT_CLASS_HA zac ON hsp.ACCT_CLASS_HA_C = zac.ACCT_CLASS_HA_C
left outer join CLARITY_LOC loc ON hsp.LOC_ID = loc.LOC_ID
left outer join CLARITY_DEP dep on hsp.ADM_DEPARMENT_ID = dep.DEPARTMENT_ID

where
hsp.ACCT_BASECLS_HA_C IN (1,2)
AND hsp.DISCH_DATE_TIME >= '02/01/2022' and hsp.DISCH_DATE_TIME < '02/03/2022'

