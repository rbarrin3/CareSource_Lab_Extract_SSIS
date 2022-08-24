/*******************************************************************************************************************************
**              VERSION : 1.0
**          DATABASE(S) : Caboodle
**          WRITTEN FOR : Sentry Data Systems
**        SQL FILE NAME : Sentry_340_Location_Matrix.txt
**  SQL OUTPUT FILE NAME: 20220519_location_map.xlsx 
**    OUTPUT FILE FORMAT: excel file
**          TEMPLATE ID : 
**             TICKET # : 
**
**              PURPOSE : To pull information for 340B eligibile departments for creation of delimited file.
** BI DOCUMENT LOCATION : Teams > Epic EMR Project - DTAS > General > Cogito > Extract Specifications > SentryDataSystems >
**                        Sentry Data Specification Data Map - Epic 20220110.xlsx
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		MM/DD/YYYY XXXX	        Developer	        1.X			one time transfer
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[GetLocationMatrixDetails]
AS
SELECT D.DepartmentEpicId 'Location of Service',
       D.LocationAbbreviation 'Facility Code',
       CASE D.InpatientDeptYN_X WHEN 'Y' THEN 'I'
                                WHEN 'N' THEN 'O'
       ELSE D.InpatientDeptYN_X END AS 'Location Field Patient Class',
       D.DepartmentName 'Location Friendly Name',
       D.Address 'Street Address of Location',
       CASE WHEN (PD.EligibilityDate IS NULL  OR PD.DepartmentID IN ('10101147','10101147','10101259','10101151'))  THEN 'N'--USE THIS TO ELIMINTE THE ONES INELIGIBLE ON ELIGIBLE SPREADSHEET MARKED RED BY hOLIDAY C
       ELSE 'Y' END '340B Eligible',
       ISNULL(PD.ThreeFortyBID,'') 'HRSA Identifier',
       REPLACE(FORMAT(PD.EligibilityDate,'d','us'),'/','')  'Start Date of Eligibility'
FROM DepartmentDim D
LEFT OUTER JOIN CustomRaw.PharmacyDepartments340BInformation PD
    ON D.DepartmentEpicId=PD.DepartmentID
WHERE D.DepartmentKey > 0
AND D.IsDepartment = 1
AND D._IsDeleted = 0