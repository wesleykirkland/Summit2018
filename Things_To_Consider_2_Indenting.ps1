########################################################################################################################
#Proper input indentation and bad output indentation
########################################################################################################################
Write-Verbose 'Generating the real function code'
[System.Collections.ArrayList]$FunctionCode = @() #Use an arraylist for efficiency/performance of the code generation

Write-Verbose 'Generate the base function code and make it an advanced function'
[void]$FunctionCode.Add("
    function Invoke-SomethingBinary {
    #Heres a comment
")

#Generate the code for the process block
$String = '
    [System.Collections.ArrayList]$Arguments = @()
    #To Do, loop through all the optional parameters and maybe even make them dynamic for an unlimited number
    if ($OptionalParameter1) {
        $Arguments.Add("$($OptionalParameter1)") | Out-Null
    }

    if ($OptionalParameter2) {
        $Arguments.Add("$($OptionalParameter2)") | Out-Null
    }
}
'
    
Write-Verbose 'Generate the process block'
[void]$FunctionCode.Add($String)

$FunctionCode | clip

########################################################################################################################
#Proper Indentation
########################################################################################################################
Write-Verbose 'Generating the real function code'
[System.Collections.ArrayList]$FunctionCode = @() #Use an arraylist for efficiency/performance of the code generation

Write-Verbose 'Generate the base function code and make it an advanced function'
[void]$FunctionCode.Add("function Invoke-SomethingBinary {
#Heres a comment
")

#Generate the code for the process block
$String = '    [System.Collections.ArrayList]$Arguments = @()

    #To Do, loop through all the optional parameters and maybe even make them dynamic for an unlimited number
    if ($OptionalParameter1) {
        $Arguments.Add("$($OptionalParameter1)") | Out-Null
    }

    if ($OptionalParameter2) {
        $Arguments.Add("$($OptionalParameter2)") | Out-Null
    }
'
    
Write-Verbose 'Generate the process block'
[void]$FunctionCode.Add($String)

$FunctionCode | clip

########################################################################################################################
#Source Code Indention
$Target = 'TEMP_Table'
$UniqueIdentifier = Get-Random -Maximum 10
$PrimaryKey = 'PK1'
$InsertColumns = 'Col1,Col2'
$InsertValues = 'Val1,Val2'
$MergeCondition = "AND Target.AttributeName = 'Attrib1'"
$UpdateCondition = "Target.AttributeValue = Source.AttributeValue"
$UpdateConditionWhenMatched = "and Target.AttributeValue != Source.AttributeValue"

#Fully expanded code
$SQLQuery = @"
MERGE INTO $($Target) WITH (READPAST) AS Target
USING $($Target)_$($UniqueIdentifier)_TEMP AS Source
ON Target.[$($PrimaryKey)] = Source.[$($PrimaryKey)]
WHEN NOT MATCHED THEN
    INSERT ($InsertColumns) VALUES ($InsertValues)
$(#If condition to see if we actually need a Update Condition
    if ($UpdateCondition -notlike $null) {
        "WHEN MATCHED $(
            if ($UpdateConditionWhenMatched) {
                $UpdateConditionWhenMatched
            }
        )
            THEN UPDATE SET $UpdateCondition"
    }
)
WHEN NOT MATCHED BY Source $MergeCondition THEN
    DELETE;
"@

$SQLQuery | clip

#Output Code Indention, Non expanded code
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
$SQLQuery | clip