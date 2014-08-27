##############################################################################
##
## New-CommandWrapper
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

<#

.SYNOPSIS

Adds parameters and functionality to existing cmdlets and functions.

.EXAMPLE

New-CommandWrapper Get-Process `
      -AddParameter @{
          SortBy = {
              $newPipeline = {
                  __ORIGINAL_COMMAND__ | Sort-Object -Property $SortBy
              }
          }
      }

This example adds a 'SortBy' parameter to Get-Process. It accomplishes
this by adding a Sort-Object command to the pipeline.

.EXAMPLE

$parameterAttributes = @'
          [Parameter(Mandatory = $true)]
          [ValidateRange(50,75)]
          [Int]
'@

New-CommandWrapper Clear-Host `
      -AddParameter @{
          @{
              Name = 'MyMandatoryInt';
              Attributes = $parameterAttributes
          } = {
              Write-Host $MyMandatoryInt
              Read-Host "Press ENTER"
         }
      }

This example adds a new mandatory 'MyMandatoryInt' parameter to
Clear-Host. This parameter is also validated to fall within the range
of 50 to 75. It doesn't alter the pipeline, but does display some
information on the screen before processing the original pipeline.

#>
function New-CommandWrapper {
    param(
        ## The name of the command to extend
        [Parameter(Mandatory = $true)]
        $Name,

        ## Script to invoke before the command begins
        [ScriptBlock] $Begin,

        ## Script to invoke for each input element
        [ScriptBlock] $Process,

        ## Script to invoke at the end of the command
        [ScriptBlock] $End,

        ## Parameters to add, and their functionality.
        ##
        ## The Key of the hashtable can be either a simple parameter name,
        ## or a more advanced parameter description.
        ##
        ## If you want to add additional parameter validation (such as a
        ## parameter type,) then the key can itself be a hashtable with the keys
        ## 'Name' and 'Attributes'. 'Attributes' is the text you would use when
        ## defining this parameter as part of a function.
        ##
        ## The Value of each hashtable entry is a scriptblock to invoke
        ## when this parameter is selected. To customize the pipeline,
        ## assign a new scriptblock to the $newPipeline variable. Use the
        ## special text, __ORIGINAL_COMMAND__, to represent the original
        ## command. The $targetParameters variable represents a hashtable
        ## containing the parameters that will be passed to the original
        ## command.
        [HashTable] $AddParameter
    )

    Set-StrictMode -Version Latest

    ## Store the target command we are wrapping, and its command type
    $target = $Name
    $commandType = "Cmdlet"

    ## If a function already exists with this name (perhaps it's already been
    ## wrapped,) rename the other function and chain to its new name.
    if(Test-Path function:\$Name)
    {
        $target = "$Name" + "-" + [Guid]::NewGuid().ToString().Replace("-","")
        Rename-Item function:\GLOBAL:$Name GLOBAL:$target
        $commandType = "Function"
    }

    ## The template we use for generating a command proxy
    $proxy = @'
        __CMDLET_BINDING_ATTRIBUTE__
        param(
        __PARAMETERS__
        )
        begin
        {
            try {
                __CUSTOM_BEGIN__

                ## Access the REAL Foreach-Object command, so that command
                ## wrappers do not interfere with this script
                $foreachObject = $executionContext.InvokeCommand.GetCmdlet(
                    "Microsoft.PowerShell.Core\Foreach-Object")

                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                    '__COMMAND_NAME__',
                    [System.Management.Automation.CommandTypes]::__COMMAND_TYPE__)

                ## TargetParameters represents the hashtable of parameters that
                ## we will pass along to the wrapped command
                $targetParameters = @{}
                $PSBoundParameters.GetEnumerator() |
                    & $foreachObject {
                        if($command.Parameters.ContainsKey($_.Key))
                        {
                            $targetParameters.Add($_.Key, $_.Value)
                        }
                    }

                ## finalPipeline represents the pipeline we wil ultimately run
                $newPipeline = { & $wrappedCmd @targetParameters }
                $finalPipeline = $newPipeline.ToString()

                __CUSTOM_PARAMETER_PROCESSING__

                $steppablePipeline = [ScriptBlock]::Create(
                    $finalPipeline).GetSteppablePipeline()
                $steppablePipeline.Begin($PSCmdlet)
            } catch {
                throw
            }
        }

        process
        {
            try {
                __CUSTOM_PROCESS__
                $steppablePipeline.Process($_)
            } catch {
                throw
            }
        }

        end
        {
            try {
                __CUSTOM_END__
                $steppablePipeline.End()
            } catch {
                throw
            }
        }

        dynamicparam
        {
            ## Access the REAL Get-Command, Foreach-Object, and Where-Object
            ## commands, so that command wrappers do not interfere with this script
            $getCommand = $executionContext.InvokeCommand.GetCmdlet(
                "Microsoft.PowerShell.Core\Get-Command")
            $foreachObject = $executionContext.InvokeCommand.GetCmdlet(
                "Microsoft.PowerShell.Core\Foreach-Object")
            $whereObject = $executionContext.InvokeCommand.GetCmdlet(
                "Microsoft.PowerShell.Core\Where-Object")

            ## Find the parameters of the original command, and remove everything
            ## else from the bound parameter list so we hide parameters the wrapped
            ## command does not recognize.
            $command = & $getCommand __COMMAND_NAME__ -Type __COMMAND_TYPE__
            $targetParameters = @{}
            $PSBoundParameters.GetEnumerator() |
                & $foreachObject {
                    if($command.Parameters.ContainsKey($_.Key))
                    {
                        $targetParameters.Add($_.Key, $_.Value)
                    }
                }

            ## Get the argumment list as it would be passed to the target command
            $argList = @($targetParameters.GetEnumerator() |
                Foreach-Object { "-$($_.Key)"; $_.Value })

            ## Get the dynamic parameters of the wrapped command, based on the
            ## arguments to this command
            $command = $null
            try
            {
                $command = & $getCommand __COMMAND_NAME__ -Type __COMMAND_TYPE__ `
                    -ArgumentList $argList
            }
            catch
            {

            }

            $dynamicParams = @($command.Parameters.GetEnumerator() |
                & $whereObject { $_.Value.IsDynamic })

            ## For each of the dynamic parameters, add them to the dynamic
            ## parameters that we return.
            if ($dynamicParams.Length -gt 0)
            {
                $paramDictionary = `
                    New-Object Management.Automation.RuntimeDefinedParameterDictionary
                foreach ($param in $dynamicParams)
                {
                    $param = $param.Value
                    $arguments = $param.Name, $param.ParameterType, $param.Attributes
                    $newParameter = `
                        New-Object Management.Automation.RuntimeDefinedParameter `
                        $arguments
                    $paramDictionary.Add($param.Name, $newParameter)
                }
                return $paramDictionary
            }
        }

        <#

        .ForwardHelpTargetName __COMMAND_NAME__
        .ForwardHelpCategory __COMMAND_TYPE__

        #>
'@

    ## Get the information about the original command
    $originalCommand = Get-Command $target
    $metaData = New-Object System.Management.Automation.CommandMetaData `
        $originalCommand
    $proxyCommandType = [System.Management.Automation.ProxyCommand]

    ## Generate the cmdlet binding attribute, and replace information
    ## about the target
    $proxy = $proxy.Replace("__CMDLET_BINDING_ATTRIBUTE__",
        $proxyCommandType::GetCmdletBindingAttribute($metaData))
    $proxy = $proxy.Replace("__COMMAND_NAME__", $target)
    $proxy = $proxy.Replace("__COMMAND_TYPE__", $commandType)

    ## Stores new text we'll be putting in the param() block
    $newParamBlockCode = ""

    ## Stores new text we'll be putting in the begin block
    ## (mostly due to parameter processing)
    $beginAdditions = ""

    ## If the user wants to add a parameter
    $currentParameter = $originalCommand.Parameters.Count
    if($AddParameter)
    {
        foreach($parameter in $AddParameter.Keys)
        {
            ## Get the code associated with this parameter
            $parameterCode = $AddParameter[$parameter]

            ## If it's an advanced parameter declaration, the hashtable
            ## holds the validation and / or type restrictions
            if($parameter -is [Hashtable])
            {
                ## Add their attributes and other information to
                ## the variable holding the parameter block additions
                if($currentParameter -gt 0)
                {
                    $newParamBlockCode += ","
                }

                $newParamBlockCode += "`n`n    " +
                    $parameter.Attributes + "`n" +
                    '    $' + $parameter.Name

                $parameter = $parameter.Name
            }
            else
            {
                ## If this is a simple parameter name, add it to the list of
                ## parameters. The proxy generation APIs will take care of
                ## adding it to the param() block.
                $newParameter =
                    New-Object System.Management.Automation.ParameterMetadata `
                        $parameter
                $metaData.Parameters.Add($parameter, $newParameter)
            }

            $parameterCode = $parameterCode.ToString()

            ## Create the template code that invokes their parameter code if
            ## the parameter is selected.
            $templateCode = @"

            if(`$PSBoundParameters['$parameter'])
            {
                $parameterCode

                ## Replace the __ORIGINAL_COMMAND__ tag with the code
                ## that represents the original command
                `$alteredPipeline = `$newPipeline.ToString()
                `$finalPipeline = `$alteredPipeline.Replace(
                    '__ORIGINAL_COMMAND__', `$finalPipeline)
            }
"@

            ## Add the template code to the list of changes we're making
            ## to the begin() section.
            $beginAdditions += $templateCode
            $currentParameter++
        }
    }

    ## Generate the param() block
    $parameters = $proxyCommandType::GetParamBlock($metaData)
    if($newParamBlockCode) { $parameters += $newParamBlockCode }
    $proxy = $proxy.Replace('__PARAMETERS__', $parameters)

    ## Update the begin, process, and end sections
    $proxy = $proxy.Replace('__CUSTOM_BEGIN__', $Begin)
    $proxy = $proxy.Replace('__CUSTOM_PARAMETER_PROCESSING__', $beginAdditions)
    $proxy = $proxy.Replace('__CUSTOM_PROCESS__', $Process)
    $proxy = $proxy.Replace('__CUSTOM_END__', $End)

    ## Save the function wrapper
    Write-Verbose $proxy
    Set-Content function:\GLOBAL:$NAME $proxy

    ## If we were wrapping a cmdlet, hide it so that it doesn't conflict with
    ## Get-Help and Get-Command
    if($commandType -eq "Cmdlet")
    {
        $originalCommand.Visibility = "Private"
    }
}