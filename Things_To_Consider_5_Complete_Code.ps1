#Find out the conditions we need and what table we will be merging on
Write-Verbose "We will be merging on $MergeTable, so we will run a switch statement to find out what conditions to apply"
switch ($MergeTable) {
    "AD_Group_Membership" {
        $MergeCondition = "AND Target.GroupName = '$Group' AND Target.Domain = '$Domain'"
        $UpdateCondition = $null
    }
    "AD_Groups" {
        $MergeCondition = "AND Target.Domain = '$Domain'"
        $UpdateCondition = "Target.whenchanged = Source.whenchanged"
    }
    "Domain_Members" {
        $MergeCondition = "AND Target.Domain = '$Domain'"
        $UpdateCondition = "Target.email = Source.email, Target.employeeid = Source.employeeid, Target.employeenumber = Source.employeenumber"
    }
    "Domain_Members_Attributes" {
        $MergeCondition = "AND Target.AttributeName = '$($AttributeSyncJob)_$Attribute'"
        $UpdateCondition = "Target.AttributeValue = Source.AttributeValue"
        $UpdateConditionWhenMatched = "and Target.AttributeValue != Source.AttributeValue"
    }
}

#I am so sorry about this block of code, it is highly dynamic and well it works. It avoided me duplicating it multiple times
#Do not align this text, as it will cause it to break!
$SQLQuery = @"
MERGE INTO $($Target) WITH (READPAST) AS Target
USING $($Target)_$($UniqueIdentifier)_TEMP AS Source
ON Target.[$($PrimaryKey)] = Source.[$($PrimaryKey)]
WHEN NOT MATCHED THEN
INSERT ($InsertColumns) VALUES ($InsertValues)
$(#If condition to see if we actually need a Update Condition
if ($UpdateCondition -notlike $null) {
"WHEN MATCHED $(if ($UpdateConditionWhenMatched) {$UpdateConditionWhenMatched})
THEN UPDATE SET $UpdateCondition"})
WHEN NOT MATCHED BY Source $MergeCondition THEN
DELETE;
"@

#########################################################################################################################################################
#Merge Outputs
#########################################################################################################################################################
#Native Merge Query
<#
MERGE INTO  WITH (READPAST) AS Target
USING __TEMP AS Source
ON Target.[] = Source.[]
WHEN NOT MATCHED THEN
INSERT () VALUES ()

WHEN NOT MATCHED BY Source  THEN
DELETE;
#>

#No Switch Statement
<#
MERGE INTO dbo.Domain_Members WITH (READPAST) AS Target
USING dbo.Domain_Members_DOMAIN_Test_TEMP AS Source
ON Target.[domsam] = Source.[domsam]
WHEN NOT MATCHED THEN
INSERT ([domsam],[samaccountname],[Domain],[Email],[employeenumber],[OktaID],[employeeid]) VALUES (Source.[domsam],Source.[samaccountname],Source.[Domain],Source.[Email],Source.[employeenumber],Source.[OktaID],Source.[employeeid])

WHEN NOT MATCHED BY Source  THEN
DELETE;
#>

#Domain_Members_Loaded
<#
MERGE INTO dbo.Domain_Members WITH (READPAST) AS Target
USING dbo.Domain_Members_DOMAIN_Test_TEMP AS Source
ON Target.[domsam] = Source.[domsam]
WHEN NOT MATCHED THEN
INSERT ([domsam],[samaccountname],[Domain],[Email],[employeenumber],[OktaID],[employeeid]) VALUES (Source.[domsam],Source.[samaccountname],Source.[Domain],Source.[Email],Source.[employeenumber],Source.[OktaID],Source.[employeeid])
WHEN MATCHED 
THEN UPDATE SET Target.email = Source.email, Target.employeeid = Source.employeeid, Target.employeenumber = Source.employeenumber
WHEN NOT MATCHED BY Source AND Target.Domain = 'LAN' THEN
DELETE;
#>