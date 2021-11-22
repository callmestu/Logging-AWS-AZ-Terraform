#Requires -Version 7.0
#region Get
function Get-GraphSynchronizationJobId() {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$AccessToken,
 
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$ServicePrincipalId
    )
 
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $params = @{
            Method  = "GET"
            Uri     = ("https://graph.microsoft.com/beta/servicePrincipals/" + $servicePrincipalId + "/synchronization/jobs")
            Headers = @{
                "Authorization" = ("Bearer " + $accessToken)
                "Accept"        = "application/json"
            }
            Body    = @{ }
        }
    }
 
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        try {
            $response = Invoke-RestMethod @params
            $response = $response.value[0].id
        }
        catch {
            Write-Error -ErrorRecord $_ -ErrorAction Stop
        }
    }
 
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
        return $response
    }
 
}
function Get-GraphServicePrincipal() {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$AccessToken,
 
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$DisplayName
    )
 
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $params = @{
            Method  = "GET"
            Headers = @{
                "Authorization" = ("Bearer " + $accessToken)
                "Accept"        = "application/json"
            }
        }
    }
 
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        try {
            $response = Invoke-RestMethod @params -Uri "https://graph.microsoft.com/beta/servicePrincipals"
            $response.value | ForEach-Object {
                if ($_.displayName -like $displayName) {
                    $objectId = $_.id
                }
            }
            if ($response.'@odata.nextLink') {
                Write-Verbose -Message "NextLink Section"
                $nextLink = $response.'@odata.nextLink'
                while ($nextLink -ne $null) {
                    $output = Invoke-RestMethod @params -Uri $nextLink
                    $output.value | ForEach-Object {
                        if ($_.displayName -like $displayName) {
                            $objectId = $_.id
                        }
                    }
                    $nextLink = $output.'@odata.nextLink'
 
                }
            }
        }
        catch {
            Write-Error -ErrorRecord $_ -ErrorAction Stop
        }
    }
 
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
        return $objectId
    }
 
}
#endregion

#region New

function New-GraphAccessToken() { 
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantId,
 
        [Parameter(Mandatory = $true)]
        [string]$ApplicationId,
 
        [Parameter(Mandatory = $true)]
        [string]$ClientSecret
    )
 
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $params = @{
            Method  = "POST"
            Uri     = ("https://login.microsoftonline.com/" + $tenantId + "/oauth2/token")
            Headers = @{
                "Content-Type" = "application/x-www-form-urlencoded"
                "Accept"       = "application/json"
            }
            Body    = @{
                "resource"      = "https://graph.microsoft.com"
                "grant_type"    = "client_credentials"
                "client_id"     = "$applicationId"
                "client_secret" = "$clientSecret"
            }
        }
    }
 
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        try {
            $response = Invoke-RestMethod @params
            $accessToken = "$($response.access_token)"
        }
        catch {
            Write-Error -ErrorRecord $_ -ErrorAction Stop
        }
    }
 
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
        return $accessToken
    }
 
}
#endregion

#region Start
function Start-GraphSynchronizationJob() {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$AccessToken,
 
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$ServicePrincipalId,
 
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$JobId
    )
 
    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        $params = @{
            Method  = "POST"
            Uri     = ("https://graph.microsoft.com/beta/servicePrincipals/" + $servicePrincipalId + "/synchronization/jobs/" + $JobId + "/start")
            Headers = @{
                "Authorization" = ("Bearer " + $accessToken)
            }
        }
    }
 
    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            Write-Error -ErrorRecord $_ -ErrorAction Stop
        }
    }
 
    end {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
        return $response
    }
 
}
#endregion

#region Initialization
function Initialization {

    [CmdletBinding()]
    param ()

    begin {
        $TenantId = Get-AutomationVariable -Name 'TenantID'
        $displayName = Get-AutomationVariable -Name 'DisplayName'
        $applicationId = Get-AutomationVariable -Name 'ClientID'
        $cscredential = Get-AutomationPSCredential -Name 'ClientSecret'
        $clientSecret = $cscredential.GetNetworkCredential().password        
    }

    process {
        #$accessToken = New-GraphAccessToken -TenantId $tenantId -ApplicationId $applicationId -ClientSecret $clientSecret -Username $username -Password $password
        $accessToken = New-GraphAccessToken -TenantId $tenantId -ApplicationId $applicationId -ClientSecret $clientSecret
        $servicePrincipalId = Get-GraphServicePrincipal -AccessToken $accessToken -DisplayName $displayName
        $jobId = Get-GraphSynchronizationJobId -AccessToken $accessToken -ServicePrincipalId $servicePrincipalId
        Start-GraphSynchronizationJob -AccessToken $accessToken -ServicePrincipalId $servicePrincipalId -JobId $jobId
    }

    end {
        Write-Host "AWS Single Sign-On Integration - Sync Completed" -ForegroundColor Green
    }

}
#endregion

Initialization