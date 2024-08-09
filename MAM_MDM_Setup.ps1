########################################

# Microsoft Graph SDK installation / update function
function Install-MicrosoftGraphModule {
    Param (
        [string]$ModuleName = "Microsoft.Graph",
        [version]$RequiredVersion = [version]"2.20.0"
    )

    # Check if the Microsoft.Graph module is installed
    Write-Host "Checking for Microsoft.Graph Module..."
    $module = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue

    if ($null -eq $module) {
        Write-Host "`n$moduleName module is not installed. Installing now..."
        Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber

        # Wait for the module to be installed
        while ($null -eq (Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue)) {
            Start-Sleep -Seconds 5
            Write-Host "Waiting for $moduleName module to install..."
        }
        Write-Host "`n$moduleName module has been installed. Proceeding with automation..."
        Import-Module Microsoft.Graph.Authentication
        Import-Module Microsoft.Graph.Applications
    } else {
        # If the module is already installed we need to verify what version they are on
        Write-Host "`n$moduleName module is already installed. Verifying version..."

        # Checking the version to see if it needs to be updated
        if ($module.Version -lt $RequiredVersion) {
            Write-Host "`n$moduleName module is out of date. Updating now..."
            Update-Module -Name Microsoft.Graph -Force

            # Wait for the module to be updated
            $updateModule = $null
            While ($null -eq $updateModule -or $updateModule.Version -lt $RequiredVersion) {
                Start-Sleep -Seconds 5
                Write-Host "`nWaiting for $moduleName module to update..."
                $updateModule = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue
            }
            Write-Host "$moduleName module has been updated."
            Write-Host "Proceeding with automation...`n"
        } else {
            Write-Host "`n$moduleName Module is Version 2.20.0 or above. Proceeding with automation...`n"
        }
    }
}
########################################

# Authentication Function
function Get-AccessToken {
    param (
        [string]$TenantId,
        [pscredential]$Credential
    )

    $oauthUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

    $tokenRequestBody = @{
        client_id     = $Credential.UserName
        client_secret = $Credential.GetNetworkCredential().Password
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }

    $tokenRequestResponse = Invoke-RestMethod -Uri $oauthUri -Method POST -ContentType "application/x-www-form-urlencoded" -Body $tokenRequestBody
    return $tokenRequestResponse.access_token
}
########################################

# Headers Function
function Get-Headers {
    param (
        [string]$AccessToken
    )

    return @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }
}
########################################
Function Test-JSON(){

<#
.SYNOPSIS
This function is used to test if the JSON passed to a REST Post request is valid
.DESCRIPTION
The function tests if the JSON passed to the REST Post is valid
.EXAMPLE
Test-JSON -JSON $JSON
Test if the JSON is valid before calling the Graph REST interface
.NOTES
NAME: Test-AuthHeader
#>

param (

$JSON

)

    try {

    $TestJSON = ConvertFrom-Json $JSON -ErrorAction Stop
    $validJson = $true

    }

    catch {

    $validJson = $false
    $_.Exception

    }

    if (!$validJson){

    Write-Host "Provided JSON isn't in valid JSON format" -f Red
    break

    }

}
########################################
Function Add-ManagedAppPolicy(){

<#
.SYNOPSIS
This function is used to add an Managed App policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a Managed App policy
.EXAMPLE
Add-ManagedAppPolicy -JSON $JSON
Adds a Managed App policy in Intune
.NOTES
NAME: Add-ManagedAppPolicy
#>

[cmdletbinding()]

param
(
    $JSON
)

$graphApiVersion = "Beta"
$Resource = "deviceAppManagement/managedAppPolicies"

    try {

        if($JSON -eq "" -or $JSON -eq $null){

        write-host "No JSON specified, please specify valid JSON for a Managed App Policy..." -f Red

        }

        else {

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $JSON -ContentType "application/json"

        }

    }

    catch {

    Write-Host
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break

    }

}
########################################
Function Add-DeviceCompliancePolicybaseline(){

<#
.SYNOPSIS
This function is used to add a device compliance policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a device compliance policy
.EXAMPLE
Add-DeviceCompliancePolicy -JSON $JSON
Adds an iOS device compliance policy in Intune
.NOTES
NAME: Add-DeviceCompliancePolicy
#>

[cmdletbinding()]

param
(
    $JSON
)

$graphApiVersion = "Beta"
$Resource = "deviceManagement/deviceCompliancePolicies"
    
    try {

        if($JSON -eq "" -or $JSON -eq $null){

        write-host "No JSON specified, please specify valid JSON for the iOS Policy..." -f Red

        }

        else {

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break

    }

}
########################################
Function Add-DeviceConfigurationPolicy(){

<#
.SYNOPSIS
This function is used to add an device configuration policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a device configuration policy
.EXAMPLE
Add-DeviceConfigurationPolicy -JSON $JSON
Adds a device configuration policy in Intune
.NOTES
NAME: Add-DeviceConfigurationPolicy
#>

[cmdletbinding()]

param
(
    $JSON
)

$graphApiVersion = "Beta"
$DCP_resource = "deviceManagement/deviceConfigurations"
Write-Verbose "Resource: $DCP_resource"

    try {

        if($JSON -eq "" -or $JSON -eq $null){

        write-host "No JSON specified, please specify valid JSON for the Android Policy..." -f Red

        }

        else {

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $JSON -ContentType "application/json"

        }

    }

    catch {

    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break

    }

}
########################################
Function Add-MDMApplication(){
<#
.SYNOPSIS
This function is used to add an MDM application using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds an MDM application from the itunes store
.EXAMPLE
Add-MDMApplication -JSON $JSON
Adds an application into Intune
.NOTES
NAME: Add-MDMApplication
#>

[cmdletbinding()]

param

(

    $JSON

)

$graphApiVersion = "Beta"
$App_resource = "deviceAppManagement/mobileApps"

    try {

        if(!$JSON){

        write-host "No JSON was passed to the function, provide a JSON variable" -f Red
        break

        }

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($App_resource)"
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JSON -Headers $headers
    }
    catch {

    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();

    Write-Host "Response content:`n$responseBody" -f Red

    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
    }
}
########################################
#JSON Components
########################################

$MAM_AndroidBase = @"

{
    "@odata.context":  "https://graph.microsoft.com/Beta/$metadata#deviceAppManagement/androidManagedAppProtections(apps())/$entity",
    "displayName":  "Android MAM Baseline with PIN",
    "description":  "Enforces data encryption with 4-digit app passcode",
    "periodOfflineBeforeAccessCheck":  "PT12H",
    "periodOnlineBeforeAccessCheck":  "PT0S",
    "allowedInboundDataTransferSources":  "allApps",
    "allowedOutboundDataTransferDestinations":  "allApps",
    "organizationalCredentialsRequired":  false,
    "allowedOutboundClipboardSharingLevel":  "allApps",
    "dataBackupBlocked":  false,
    "deviceComplianceRequired":  true,
    "managedBrowserToOpenLinksRequired":  false,
    "saveAsBlocked":  false,
    "periodOfflineBeforeWipeIsEnforced":  "P60D",
    "pinRequired":  true,
    "maximumPinRetries":  10,
    "simplePinBlocked":  false,
    "minimumPinLength":  4,
    "pinCharacterSet":  "numeric",
    "periodBeforePinReset":  "PT0S",
    "allowedDataStorageLocations":  [

                                    ],
    "contactSyncBlocked":  false,
    "printBlocked":  false,
    "fingerprintBlocked":  false,
    "disableAppPinIfDevicePinIsSet":  false,
    "minimumRequiredOsVersion":  null,
    "minimumWarningOsVersion":  null,
    "minimumRequiredAppVersion":  null,
    "minimumWarningAppVersion":  null,
    "minimumWipeOsVersion":  null,
    "minimumWipeAppVersion":  null,
    "appActionIfDeviceComplianceRequired":  "block",
    "appActionIfMaximumPinRetriesExceeded":  "block",
    "pinRequiredInsteadOfBiometricTimeout":  "PT30M",
    "allowedOutboundClipboardSharingExceptionLength":  0,
    "notificationRestriction":  "allow",
    "previousPinBlockCount":  0,
    "managedBrowser":  "notConfigured",
    "maximumAllowedDeviceThreatLevel":  "notConfigured",
    "mobileThreatDefenseRemediationAction":  "block",
    "blockDataIngestionIntoOrganizationDocuments":  false,
    "allowedDataIngestionLocations":  [
                                          "oneDriveForBusiness",
                                          "sharePoint",
                                          "camera"
                                      ],
    "appActionIfUnableToAuthenticateUser":  null,
    "isAssigned":  false,
    "targetedAppManagementLevels":  "unspecified",
    "screenCaptureBlocked":  false,
    "disableAppEncryptionIfDeviceEncryptionIsEnabled":  false,
    "encryptAppData":  true,
    "deployedAppCount":  19,
    "minimumRequiredPatchVersion":  "0000-00-00",
    "minimumWarningPatchVersion":  "0000-00-00",
    "minimumWipePatchVersion":  "0000-00-00",
    "allowedAndroidDeviceManufacturers":  null,
    "appActionIfAndroidDeviceManufacturerNotAllowed":  "block",
    "requiredAndroidSafetyNetDeviceAttestationType":  "none",
    "appActionIfAndroidSafetyNetDeviceAttestationFailed":  "block",
    "requiredAndroidSafetyNetAppsVerificationType":  "none",
    "appActionIfAndroidSafetyNetAppsVerificationFailed":  "block",
    "customBrowserPackageId":  "",
    "customBrowserDisplayName":  "",
    "minimumRequiredCompanyPortalVersion":  null,
    "minimumWarningCompanyPortalVersion":  null,
    "minimumWipeCompanyPortalVersion":  null,
    "keyboardsRestricted":  false,
    "allowedAndroidDeviceModels":  [

                                   ],
    "appActionIfAndroidDeviceModelNotAllowed":  "block",
    "exemptedAppPackages":  [

                            ],
    "approvedKeyboards":  [

                          ],
    "apps@odata.context":  "https://graph.microsoft.com/Beta/$metadata#deviceAppManagement/androidManagedAppProtections(\u0027T_e27af3a0-a273-4bd9-b51b-bd4953e80ad6\u0027)/apps",
    "apps":  [
                 {
                     "id":  "com.microsoft.emmx.android",
                     "version":  "-725393251",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.emmx"
                                             }
                 },
                 {
                     "id":  "com.microsoft.flow.android",
                     "version":  "-496779816",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.flow"
                                             }
                 },
                 {
                     "id":  "com.microsoft.msapps.android",
                     "version":  "986978680",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.msapps"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.excel.android",
                     "version":  "-1789826587",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.excel"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.officehub.android",
                     "version":  "-1091809935",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.officehub"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.officehubhl.android",
                     "version":  "-1175805259",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.officehubhl"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.officehubrow.android",
                     "version":  "-1861979965",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.officehubrow"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.onenote.android",
                     "version":  "186482170",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.onenote"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.outlook.android",
                     "version":  "1146701235",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.outlook"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.powerpoint.android",
                     "version":  "1411665537",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.powerpoint"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.word.android",
                     "version":  "2122351424",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.office.word"
                                             }
                 },
                 {
                     "id":  "com.microsoft.planner.android",
                     "version":  "-1658524342",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.planner"
                                             }
                 },
                 {
                     "id":  "com.microsoft.powerbim.android",
                     "version":  "1564653697",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.powerbim"
                                             }
                 },
                 {
                     "id":  "com.microsoft.sharepoint.android",
                     "version":  "84773357",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.sharepoint"
                                             }
                 },
                 {
                     "id":  "com.microsoft.skydrive.android",
                     "version":  "1887770705",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.skydrive"
                                             }
                 },
                 {
                     "id":  "com.microsoft.stream.android",
                     "version":  "648128536",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.stream"
                                             }
                 },
                 {
                     "id":  "com.microsoft.teams.android",
                     "version":  "1900143244",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.teams"
                                             }
                 },
                 {
                     "id":  "com.microsoft.todos.android",
                     "version":  "1697858135",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.microsoft.todos"
                                             }
                 },
                 {
                     "id":  "com.yammer.v1.android",
                     "version":  "-1248070370",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.androidMobileAppIdentifier",
                                                 "packageId":  "com.yammer.v1"
                                             }
                 }
             ],
    "@odata.type":  "#microsoft.graph.androidManagedAppProtection"

}


"@
########################################

$MAM_iOSBase = @"

{

    "@odata.context":  "https://graph.microsoft.com/Beta/$metadata#deviceAppManagement/iosManagedAppProtections(apps())/$entity",
    "displayName":  "iOS MAM Baseline with PIN",
    "description":  "Enforces data encryption with 4-digit app passcode",
    "periodOfflineBeforeAccessCheck":  "PT12H",
    "periodOnlineBeforeAccessCheck":  "PT0S",
    "allowedInboundDataTransferSources":  "allApps",
    "allowedOutboundDataTransferDestinations":  "allApps",
    "organizationalCredentialsRequired":  false,
    "allowedOutboundClipboardSharingLevel":  "allApps",
    "dataBackupBlocked":  false,
    "deviceComplianceRequired":  true,
    "managedBrowserToOpenLinksRequired":  false,
    "saveAsBlocked":  false,
    "periodOfflineBeforeWipeIsEnforced":  "P60D",
    "pinRequired":  true,
    "maximumPinRetries":  10,
    "simplePinBlocked":  false,
    "minimumPinLength":  4,
    "pinCharacterSet":  "numeric",
    "periodBeforePinReset":  "PT0S",
    "allowedDataStorageLocations":  [

                                    ],
    "contactSyncBlocked":  false,
    "printBlocked":  false,
    "fingerprintBlocked":  false,
    "disableAppPinIfDevicePinIsSet":  false,
    "minimumRequiredOsVersion":  null,
    "minimumWarningOsVersion":  null,
    "minimumRequiredAppVersion":  null,
    "minimumWarningAppVersion":  null,
    "minimumWipeOsVersion":  null,
    "minimumWipeAppVersion":  null,
    "appActionIfDeviceComplianceRequired":  "block",
    "appActionIfMaximumPinRetriesExceeded":  "block",
    "pinRequiredInsteadOfBiometricTimeout":  "PT30M",
    "allowedOutboundClipboardSharingExceptionLength":  0,
    "notificationRestriction":  "allow",
    "previousPinBlockCount":  0,
    "managedBrowser":  "notConfigured",
    "maximumAllowedDeviceThreatLevel":  "notConfigured",
    "mobileThreatDefenseRemediationAction":  "block",
    "blockDataIngestionIntoOrganizationDocuments":  false,
    "allowedDataIngestionLocations":  [
                                          "oneDriveForBusiness",
                                          "sharePoint",
                                          "camera"
                                      ],
    "appActionIfUnableToAuthenticateUser":  null,
    "isAssigned":  false,
    "targetedAppManagementLevels":  "unspecified",
    "appDataEncryptionType":  "whenDeviceLocked",
    "minimumRequiredSdkVersion":  null,
    "deployedAppCount":  17,
    "faceIdBlocked":  false,
    "minimumWipeSdkVersion":  null,
    "allowedIosDeviceModels":  null,
    "appActionIfIosDeviceModelNotAllowed":  "block",
    "thirdPartyKeyboardsBlocked":  false,
    "filterOpenInToOnlyManagedApps":  false,
    "disableProtectionOfManagedOutboundOpenInData":  false,
    "protectInboundDataFromUnknownSources":  false,
    "customBrowserProtocol":  "",
    "exemptedAppProtocols":  [
                                 {
                                     "name":  "Default",
                                     "value":  "tel;telprompt;skype;app-settings;calshow;itms;itmss;itms-apps;itms-appss;itms-services;"
                                 }
                             ],
    "apps@odata.context":  "https://graph.microsoft.com/Beta/$metadata#deviceAppManagement/iosManagedAppProtections(\u0027T_c6a62df0-9e88-4c86-8103-6a70cad6eaef\u0027)/apps",
    "apps":  [
                 {
                     "id":  "com.microsoft.msapps.ios",
                     "version":  "408162834",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.msapps"
                                             }
                 },
                 {
                     "id":  "com.microsoft.msedge.ios",
                     "version":  "-2135752869",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.msedge"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.excel.ios",
                     "version":  "-1255026913",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.office.excel"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.outlook.ios",
                     "version":  "-518090279",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.office.outlook"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.powerpoint.ios",
                     "version":  "-740777841",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.office.powerpoint"
                                             }
                 },
                 {
                     "id":  "com.microsoft.office.word.ios",
                     "version":  "922692278",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.office.word"
                                             }
                 },
                 {
                     "id":  "com.microsoft.officemobile.ios",
                     "version":  "-803819540",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.officemobile"
                                             }
                 },
                 {
                     "id":  "com.microsoft.onenote.ios",
                     "version":  "107156768",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.onenote"
                                             }
                 },
                 {
                     "id":  "com.microsoft.plannermobile.ios",
                     "version":  "-175532278",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.plannermobile"
                                             }
                 },
                 {
                     "id":  "com.microsoft.powerbimobile.ios",
                     "version":  "-91595494",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.powerbimobile"
                                             }
                 },
                 {
                     "id":  "com.microsoft.procsimo.ios",
                     "version":  "-1388599138",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.procsimo"
                                             }
                 },
                 {
                     "id":  "com.microsoft.sharepoint.ios",
                     "version":  "-585639021",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.sharepoint"
                                             }
                 },
                 {
                     "id":  "com.microsoft.skydrive.ios",
                     "version":  "-108719121",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.skydrive"
                                             }
                 },
                 {
                     "id":  "com.microsoft.skype.teams.ios",
                     "version":  "-1040529574",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.skype.teams"
                                             }
                 },
                 {
                     "id":  "com.microsoft.stream.ios",
                     "version":  "126860698",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.stream"
                                             }
                 },
                 {
                     "id":  "com.microsoft.to-do.ios",
                     "version":  "-292160221",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "com.microsoft.to-do"
                                             }
                 },
                 {
                     "id":  "wefwef.ios",
                     "version":  "207428455",
                     "mobileAppIdentifier":  {
                                                 "@odata.type":  "#microsoft.graph.iosMobileAppIdentifier",
                                                 "bundleId":  "wefwef"
                                             }
                 }
             ],
    "@odata.type":  "#microsoft.graph.iosManagedAppProtection"


}


"@
########################################

$BaselineAndroidOwner = @"

{
    "@odata.type":  "#microsoft.graph.androidDeviceOwnerCompliancePolicy",
    "description":  "PIN, encryption, integrity",
    "displayName":  "Android Device Owner Baseline",
    "deviceThreatProtectionEnabled":  false,
    "deviceThreatProtectionRequiredSecurityLevel":  "unavailable",
    "advancedThreatProtectionRequiredSecurityLevel":  null,
    "securityRequireSafetyNetAttestationBasicIntegrity":  true,
    "securityRequireSafetyNetAttestationCertifiedDevice":  false,
    "osMinimumVersion":  null,
    "osMaximumVersion":  null,
    "minAndroidSecurityPatchLevel":  null,
    "passwordRequired":  true,
    "passwordMinimumLength":  4,
    "passwordMinimumLetterCharacters":  null,
    "passwordMinimumLowerCaseCharacters":  null,
    "passwordMinimumNonLetterCharacters":  null,
    "passwordMinimumNumericCharacters":  null,
    "passwordMinimumSymbolCharacters":  null,
    "passwordMinimumUpperCaseCharacters":  null,
    "passwordRequiredType":  "numeric",
    "passwordMinutesOfInactivityBeforeLock":  5,
    "passwordExpirationDays":  null,
    "passwordPreviousPasswordCountToBlock":  null,
    "storageRequireEncryption":  true,
    "scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":72,"notificationTemplateId":"","notificationMessageCCList":[]}]}]

}

"@
########################################

$BaselineAndroidWork = @"

{
    "@odata.type":  "#microsoft.graph.androidWorkProfileCompliancePolicy",
    "description":  "PIN, encryption, integrity",
    "displayName":  "Android Work Profile Baseline",
    "passwordRequired":  true,
    "passwordMinimumLength":  4,
    "passwordRequiredType":  "numeric",
    "passwordMinutesOfInactivityBeforeLock":  5,
    "passwordExpirationDays":  null,
    "passwordPreviousPasswordBlockCount":  null,
    "passwordSignInFailureCountBeforeFactoryReset":  null,
    "securityPreventInstallAppsFromUnknownSources":  true,
    "securityDisableUsbDebugging":  false,
    "securityRequireVerifyApps":  false,
    "deviceThreatProtectionEnabled":  false,
    "deviceThreatProtectionRequiredSecurityLevel":  "unavailable",
    "advancedThreatProtectionRequiredSecurityLevel":  "unavailable",
    "securityBlockJailbrokenDevices":  true,
    "osMinimumVersion":  null,
    "osMaximumVersion":  null,
    "minAndroidSecurityPatchLevel":  null,
    "storageRequireEncryption":  true,
    "securityRequireSafetyNetAttestationBasicIntegrity":  true,
    "securityRequireSafetyNetAttestationCertifiedDevice":  false,
    "securityRequireGooglePlayServices":  true,
    "securityRequireUpToDateSecurityProviders":  false,
    "securityRequireCompanyPortalAppIntegrity":  true,
    "scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":72,"notificationTemplateId":"","notificationMessageCCList":[]}]}]

}

"@
########################################

$BaselineiOS = @"

{
    "@odata.type":  "#microsoft.graph.iosCompliancePolicy",
    "description":  "Block jailbroken devices, require PIN",
    "displayName":  "iOS Baseline",
    "passcodeBlockSimple":  true,
    "passcodeExpirationDays":  null,
    "passcodeMinimumLength":  4,
    "passcodeMinutesOfInactivityBeforeLock":  0,
    "passcodeMinutesOfInactivityBeforeScreenTimeout":  5,
    "passcodePreviousPasscodeBlockCount":  null,
    "passcodeMinimumCharacterSetCount":  null,
    "passcodeRequiredType":  "numeric",
    "passcodeRequired":  true,
    "osMinimumVersion":  null,
    "osMaximumVersion":  null,
    "osMinimumBuildVersion":  null,
    "osMaximumBuildVersion":  null,
    "securityBlockJailbrokenDevices":  true,
    "deviceThreatProtectionEnabled":  false,
    "deviceThreatProtectionRequiredSecurityLevel":  "unavailable",
    "managedEmailProfileRequired":  false,
    "restrictedApps":  [

                       ],
"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":72,"notificationTemplateId":"","notificationMessageCCList":[]}]}]
}


"@
########################################

$BaselineWin10 = @"

{
    "@odata.type":  "#microsoft.graph.windows10CompliancePolicy",
    "description":  "Minimum OS: 20H2",
    "displayName":  "Windows 10 Baseline",
    "passwordRequired":  false,
    "passwordBlockSimple":  false,
    "passwordRequiredToUnlockFromIdle":  false,
    "passwordMinutesOfInactivityBeforeLock":  null,
    "passwordExpirationDays":  null,
    "passwordMinimumLength":  null,
    "passwordMinimumCharacterSetCount":  null,
    "passwordRequiredType":  "deviceDefault",
    "passwordPreviousPasswordBlockCount":  null,
    "requireHealthyDeviceReport":  false,
    "osMinimumVersion":  "10.0.19042",
    "osMaximumVersion":  null,
    "mobileOsMinimumVersion":  null,
    "mobileOsMaximumVersion":  null,
    "earlyLaunchAntiMalwareDriverEnabled":  false,
    "bitLockerEnabled":  false,
    "secureBootEnabled":  false,
    "codeIntegrityEnabled":  false,
    "storageRequireEncryption":  false,
    "activeFirewallRequired":  false,
    "defenderEnabled":  false,
    "defenderVersion":  null,
    "signatureOutOfDate":  false,
    "rtpEnabled":  false,
    "antivirusRequired":  false,
    "antiSpywareRequired":  false,
    "deviceThreatProtectionEnabled":  false,
    "deviceThreatProtectionRequiredSecurityLevel":  "unavailable",
    "configurationManagerComplianceRequired":  false,
    "tpmRequired":  false,
    "validOperatingSystemBuildRanges":  [

                                        ],
"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":72,"notificationTemplateId":"","notificationMessageCCList":[]}]}]
}


"@
########################################

$BaselineMacOS = @"

{
    "@odata.type":  "#microsoft.graph.macOSCompliancePolicy",
    "description":  "Firewall, encryption and Gatekeeper",
    "displayName":  "MacOS Baseline",
    "passwordRequired":  false,
    "passwordBlockSimple":  false,
    "passwordExpirationDays":  null,
    "passwordMinimumLength":  null,
    "passwordMinutesOfInactivityBeforeLock":  null,
    "passwordPreviousPasswordBlockCount":  null,
    "passwordMinimumCharacterSetCount":  null,
    "passwordRequiredType":  "deviceDefault",
    "osMinimumVersion":  null,
    "osMaximumVersion":  null,
    "osMinimumBuildVersion":  null,
    "osMaximumBuildVersion":  null,
    "systemIntegrityProtectionEnabled":  true,
    "deviceThreatProtectionEnabled":  false,
    "deviceThreatProtectionRequiredSecurityLevel":  "unavailable",
    "storageRequireEncryption":  true,
    "gatekeeperAllowedAppSource":  "macAppStoreAndIdentifiedDevelopers",
    "firewallEnabled":  true,
    "firewallBlockAllIncoming":  false,
    "firewallEnableStealthMode":  false,
    "scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":72,"notificationTemplateId":"","notificationMessageCCList":[]}]}]

}


"@
########################################

$Win10BASICDR = @"

{
    "@odata.type":  "#microsoft.graph.windows10GeneralConfiguration",
    "deviceManagementApplicabilityRuleOsEdition":  null,
    "deviceManagementApplicabilityRuleOsVersion":  null,
    "deviceManagementApplicabilityRuleDeviceMode":  null,
    "description":  "Basic security profile for Windows 10 that is also BYOD friendly.",
    "displayName":  "SCC - Windows 10 - Standard Device Security",
    "taskManagerBlockEndTask":  false,
    "energySaverOnBatteryThresholdPercentage":  0,
    "energySaverPluggedInThresholdPercentage":  0,
    "powerLidCloseActionOnBattery":  "notConfigured",
    "powerLidCloseActionPluggedIn":  "notConfigured",
    "powerButtonActionOnBattery":  "notConfigured",
    "powerButtonActionPluggedIn":  "notConfigured",
    "powerSleepButtonActionOnBattery":  "notConfigured",
    "powerSleepButtonActionPluggedIn":  "notConfigured",
    "powerHybridSleepOnBattery":  "enabled",
    "powerHybridSleepPluggedIn":  "enabled",
    "windows10AppsForceUpdateSchedule":  null,
    "enableAutomaticRedeployment":  false,
    "microsoftAccountSignInAssistantSettings":  "notConfigured",
    "authenticationAllowSecondaryDevice":  true,
    "authenticationWebSignIn":  "notConfigured",
    "authenticationPreferredAzureADTenantDomainName":  null,
    "cryptographyAllowFipsAlgorithmPolicy":  false,
    "displayAppListWithGdiDPIScalingTurnedOn":  [

                                                ],
    "displayAppListWithGdiDPIScalingTurnedOff":  [

                                                 ],
    "enterpriseCloudPrintDiscoveryEndPoint":  null,
    "enterpriseCloudPrintOAuthAuthority":  null,
    "enterpriseCloudPrintOAuthClientIdentifier":  null,
    "enterpriseCloudPrintResourceIdentifier":  null,
    "enterpriseCloudPrintDiscoveryMaxLimit":  null,
    "enterpriseCloudPrintMopriaDiscoveryResourceIdentifier":  null,
    "experienceDoNotSyncBrowserSettings":  "notConfigured",
    "messagingBlockSync":  false,
    "messagingBlockMMS":  false,
    "messagingBlockRichCommunicationServices":  false,
    "printerNames":  [

                     ],
    "printerDefaultName":  null,
    "printerBlockAddition":  false,
    "searchBlockDiacritics":  false,
    "searchDisableAutoLanguageDetection":  false,
    "searchDisableIndexingEncryptedItems":  false,
    "searchEnableRemoteQueries":  false,
    "searchDisableUseLocation":  false,
    "searchDisableLocation":  false,
    "searchDisableIndexerBackoff":  false,
    "searchDisableIndexingRemovableDrive":  false,
    "searchEnableAutomaticIndexSizeManangement":  false,
    "searchBlockWebResults":  false,
    "securityBlockAzureADJoinedDevicesAutoEncryption":  false,
    "diagnosticsDataSubmissionMode":  "none",
    "oneDriveDisableFileSync":  false,
    "systemTelemetryProxyServer":  null,
    "edgeTelemetryForMicrosoft365Analytics":  "notConfigured",
    "inkWorkspaceAccess":  "notConfigured",
    "inkWorkspaceAccessState":  "notConfigured",
    "inkWorkspaceBlockSuggestedApps":  false,
    "smartScreenEnableAppInstallControl":  false,
    "smartScreenAppInstallControl":  "notConfigured",
    "personalizationDesktopImageUrl":  null,
    "personalizationLockScreenImageUrl":  null,
    "bluetoothAllowedServices":  [

                                 ],
    "bluetoothBlockAdvertising":  false,
    "bluetoothBlockPromptedProximalConnections":  false,
    "bluetoothBlockDiscoverableMode":  false,
    "bluetoothBlockPrePairing":  false,
    "edgeBlockAutofill":  false,
    "edgeBlocked":  false,
    "edgeCookiePolicy":  "userDefined",
    "edgeBlockDeveloperTools":  false,
    "edgeBlockSendingDoNotTrackHeader":  false,
    "edgeBlockExtensions":  false,
    "edgeBlockInPrivateBrowsing":  false,
    "edgeBlockJavaScript":  false,
    "edgeBlockPasswordManager":  false,
    "edgeBlockAddressBarDropdown":  false,
    "edgeBlockCompatibilityList":  false,
    "edgeClearBrowsingDataOnExit":  false,
    "edgeAllowStartPagesModification":  false,
    "edgeDisableFirstRunPage":  false,
    "edgeBlockLiveTileDataCollection":  false,
    "edgeSyncFavoritesWithInternetExplorer":  false,
    "edgeFavoritesListLocation":  null,
    "edgeBlockEditFavorites":  false,
    "edgeNewTabPageURL":  null,
    "edgeHomeButtonConfiguration":  null,
    "edgeHomeButtonConfigurationEnabled":  false,
    "edgeOpensWith":  "notConfigured",
    "edgeBlockSideloadingExtensions":  false,
    "edgeRequiredExtensionPackageFamilyNames":  [

                                                ],
    "edgeBlockPrinting":  false,
    "edgeFavoritesBarVisibility":  "notConfigured",
    "edgeBlockSavingHistory":  false,
    "edgeBlockFullScreenMode":  false,
    "edgeBlockWebContentOnNewTabPage":  false,
    "edgeBlockTabPreloading":  false,
    "edgeBlockPrelaunch":  false,
    "edgeShowMessageWhenOpeningInternetExplorerSites":  "notConfigured",
    "edgePreventCertificateErrorOverride":  false,
    "edgeKioskModeRestriction":  "notConfigured",
    "edgeKioskResetAfterIdleTimeInMinutes":  null,
    "cellularBlockDataWhenRoaming":  false,
    "cellularBlockVpn":  false,
    "cellularBlockVpnWhenRoaming":  false,
    "cellularData":  "allowed",
    "defenderBlockEndUserAccess":  false,
    "defenderDaysBeforeDeletingQuarantinedMalware":  5,
    "defenderSystemScanSchedule":  "userDefined",
    "defenderFilesAndFoldersToExclude":  [

                                         ],
    "defenderFileExtensionsToExclude":  [

                                        ],
    "defenderScanMaxCpu":  50,
    "defenderMonitorFileActivity":  "monitorIncomingFilesOnly",
    "defenderPotentiallyUnwantedAppAction":  "audit",
    "defenderPotentiallyUnwantedAppActionSetting":  "auditMode",
    "defenderProcessesToExclude":  [

                                   ],
    "defenderPromptForSampleSubmission":  "promptBeforeSendingPersonalData",
    "defenderRequireBehaviorMonitoring":  true,
    "defenderRequireCloudProtection":  true,
    "defenderRequireNetworkInspectionSystem":  true,
    "defenderRequireRealTimeMonitoring":  true,
    "defenderScanArchiveFiles":  true,
    "defenderScanDownloads":  true,
    "defenderScheduleScanEnableLowCpuPriority":  false,
    "defenderDisableCatchupQuickScan":  false,
    "defenderDisableCatchupFullScan":  false,
    "defenderScanNetworkFiles":  true,
    "defenderScanIncomingMail":  true,
    "defenderScanMappedNetworkDrivesDuringFullScan":  false,
    "defenderScanRemovableDrivesDuringFullScan":  true,
    "defenderScanScriptsLoadedInInternetExplorer":  true,
    "defenderSignatureUpdateIntervalInHours":  2,
    "defenderScanType":  "userDefined",
    "defenderScheduledScanTime":  null,
    "defenderScheduledQuickScanTime":  null,
    "defenderCloudBlockLevel":  "notConfigured",
    "defenderCloudExtendedTimeout":  null,
    "defenderCloudExtendedTimeoutInSeconds":  null,
    "defenderBlockOnAccessProtection":  false,
    "defenderSubmitSamplesConsentType":  "sendSafeSamplesAutomatically",
    "lockScreenAllowTimeoutConfiguration":  false,
    "lockScreenBlockActionCenterNotifications":  false,
    "lockScreenBlockCortana":  false,
    "lockScreenBlockToastNotifications":  false,
    "lockScreenTimeoutInSeconds":  null,
    "lockScreenActivateAppsWithVoice":  "notConfigured",
    "passwordBlockSimple":  true,
    "passwordExpirationDays":  null,
    "passwordMinimumLength":  8,
    "passwordMinutesOfInactivityBeforeScreenTimeout":  15,
    "passwordMinimumCharacterSetCount":  3,
    "passwordPreviousPasswordBlockCount":  null,
    "passwordRequired":  true,
    "passwordRequireWhenResumeFromIdleState":  false,
    "passwordRequiredType":  "alphanumeric",
    "passwordSignInFailureCountBeforeFactoryReset":  10,
    "passwordMinimumAgeInDays":  null,
    "privacyAdvertisingId":  "notConfigured",
    "privacyAutoAcceptPairingAndConsentPrompts":  false,
    "privacyDisableLaunchExperience":  false,
    "privacyBlockInputPersonalization":  false,
    "privacyBlockPublishUserActivities":  false,
    "privacyBlockActivityFeed":  false,
    "startBlockUnpinningAppsFromTaskbar":  false,
    "startMenuAppListVisibility":  "userDefined",
    "startMenuHideChangeAccountSettings":  false,
    "startMenuHideFrequentlyUsedApps":  false,
    "startMenuHideHibernate":  false,
    "startMenuHideLock":  false,
    "startMenuHidePowerButton":  false,
    "startMenuHideRecentJumpLists":  false,
    "startMenuHideRecentlyAddedApps":  false,
    "startMenuHideRestartOptions":  false,
    "startMenuHideShutDown":  false,
    "startMenuHideSignOut":  false,
    "startMenuHideSleep":  false,
    "startMenuHideSwitchAccount":  false,
    "startMenuHideUserTile":  false,
    "startMenuLayoutEdgeAssetsXml":  null,
    "startMenuLayoutXml":  null,
    "startMenuMode":  "userDefined",
    "startMenuPinnedFolderDocuments":  "notConfigured",
    "startMenuPinnedFolderDownloads":  "notConfigured",
    "startMenuPinnedFolderFileExplorer":  "notConfigured",
    "startMenuPinnedFolderHomeGroup":  "notConfigured",
    "startMenuPinnedFolderMusic":  "notConfigured",
    "startMenuPinnedFolderNetwork":  "notConfigured",
    "startMenuPinnedFolderPersonalFolder":  "notConfigured",
    "startMenuPinnedFolderPictures":  "notConfigured",
    "startMenuPinnedFolderSettings":  "notConfigured",
    "startMenuPinnedFolderVideos":  "notConfigured",
    "settingsBlockSettingsApp":  false,
    "settingsBlockSystemPage":  false,
    "settingsBlockDevicesPage":  false,
    "settingsBlockNetworkInternetPage":  false,
    "settingsBlockPersonalizationPage":  false,
    "settingsBlockAccountsPage":  false,
    "settingsBlockTimeLanguagePage":  false,
    "settingsBlockEaseOfAccessPage":  false,
    "settingsBlockPrivacyPage":  false,
    "settingsBlockUpdateSecurityPage":  false,
    "settingsBlockAppsPage":  false,
    "settingsBlockGamingPage":  false,
    "windowsSpotlightBlockConsumerSpecificFeatures":  false,
    "windowsSpotlightBlocked":  false,
    "windowsSpotlightBlockOnActionCenter":  false,
    "windowsSpotlightBlockTailoredExperiences":  false,
    "windowsSpotlightBlockThirdPartyNotifications":  false,
    "windowsSpotlightBlockWelcomeExperience":  false,
    "windowsSpotlightBlockWindowsTips":  false,
    "windowsSpotlightConfigureOnLockScreen":  "notConfigured",
    "networkProxyApplySettingsDeviceWide":  false,
    "networkProxyDisableAutoDetect":  false,
    "networkProxyAutomaticConfigurationUrl":  null,
    "networkProxyServer":  null,
    "accountsBlockAddingNonMicrosoftAccountEmail":  false,
    "antiTheftModeBlocked":  false,
    "bluetoothBlocked":  false,
    "cameraBlocked":  false,
    "connectedDevicesServiceBlocked":  false,
    "certificatesBlockManualRootCertificateInstallation":  false,
    "copyPasteBlocked":  false,
    "cortanaBlocked":  false,
    "deviceManagementBlockFactoryResetOnMobile":  false,
    "deviceManagementBlockManualUnenroll":  false,
    "safeSearchFilter":  "userDefined",
    "edgeBlockPopups":  false,
    "edgeBlockSearchSuggestions":  false,
    "edgeBlockSearchEngineCustomization":  false,
    "edgeBlockSendingIntranetTrafficToInternetExplorer":  false,
    "edgeSendIntranetTrafficToInternetExplorer":  false,
    "edgeRequireSmartScreen":  true,
    "edgeEnterpriseModeSiteListLocation":  null,
    "edgeFirstRunUrl":  null,
    "edgeSearchEngine":  null,
    "edgeHomepageUrls":  [

                         ],
    "edgeBlockAccessToAboutFlags":  false,
    "smartScreenBlockPromptOverride":  false,
    "smartScreenBlockPromptOverrideForFiles":  false,
    "webRtcBlockLocalhostIpAddress":  false,
    "internetSharingBlocked":  false,
    "settingsBlockAddProvisioningPackage":  false,
    "settingsBlockRemoveProvisioningPackage":  false,
    "settingsBlockChangeSystemTime":  false,
    "settingsBlockEditDeviceName":  false,
    "settingsBlockChangeRegion":  false,
    "settingsBlockChangeLanguage":  false,
    "settingsBlockChangePowerSleep":  false,
    "locationServicesBlocked":  false,
    "microsoftAccountBlocked":  false,
    "microsoftAccountBlockSettingsSync":  false,
    "nfcBlocked":  false,
    "resetProtectionModeBlocked":  false,
    "screenCaptureBlocked":  false,
    "storageBlockRemovableStorage":  false,
    "storageRequireMobileDeviceEncryption":  false,
    "usbBlocked":  false,
    "voiceRecordingBlocked":  false,
    "wiFiBlockAutomaticConnectHotspots":  false,
    "wiFiBlocked":  false,
    "wiFiBlockManualConfiguration":  false,
    "wiFiScanInterval":  null,
    "wirelessDisplayBlockProjectionToThisDevice":  false,
    "wirelessDisplayBlockUserInputFromReceiver":  false,
    "wirelessDisplayRequirePinForPairing":  false,
    "windowsStoreBlocked":  false,
    "appsAllowTrustedAppsSideloading":  "notConfigured",
    "windowsStoreBlockAutoUpdate":  false,
    "developerUnlockSetting":  "notConfigured",
    "sharedUserAppDataAllowed":  false,
    "appsBlockWindowsStoreOriginatedApps":  false,
    "windowsStoreEnablePrivateStoreOnly":  false,
    "storageRestrictAppDataToSystemVolume":  false,
    "storageRestrictAppInstallToSystemVolume":  false,
    "gameDvrBlocked":  false,
    "experienceBlockDeviceDiscovery":  false,
    "experienceBlockErrorDialogWhenNoSIM":  false,
    "experienceBlockTaskSwitcher":  false,
    "logonBlockFastUserSwitching":  false,
    "tenantLockdownRequireNetworkDuringOutOfBoxExperience":  false,
    "appManagementMSIAllowUserControlOverInstall":  false,
    "appManagementMSIAlwaysInstallWithElevatedPrivileges":  false,
    "dataProtectionBlockDirectMemoryAccess":  false,
    "appManagementPackageFamilyNamesToLaunchAfterLogOn":  [

                                                          ],
    "uninstallBuiltInApps":  false,
    "defenderDetectedMalwareActions":  {
                                           "lowSeverity":  "clean",
                                           "moderateSeverity":  "quarantine",
                                           "highSeverity":  "remove",
                                           "severeSeverity":  "block"
                                       }
}


"@
########################################

$Win10BASICEP = @"

{
    "@odata.type":  "#microsoft.graph.windows10EndpointProtectionConfiguration",
    "deviceManagementApplicabilityRuleOsEdition":  null,
    "deviceManagementApplicabilityRuleOsVersion":  null,
    "deviceManagementApplicabilityRuleDeviceMode":  null,
    "description":  "Basic security profile for Windows 10 that is also BYOD friendly.",
    "displayName":  "SCC - Windows 10 - Standard Endpoint Protection",
    "dmaGuardDeviceEnumerationPolicy":  "deviceDefault",
    "xboxServicesEnableXboxGameSaveTask":  false,
    "xboxServicesAccessoryManagementServiceStartupMode":  "manual",
    "xboxServicesLiveAuthManagerServiceStartupMode":  "manual",
    "xboxServicesLiveGameSaveServiceStartupMode":  "manual",
    "xboxServicesLiveNetworkingServiceStartupMode":  "manual",
    "localSecurityOptionsBlockMicrosoftAccounts":  false,
    "localSecurityOptionsBlockRemoteLogonWithBlankPassword":  false,
    "localSecurityOptionsDisableAdministratorAccount":  false,
    "localSecurityOptionsAdministratorAccountName":  null,
    "localSecurityOptionsDisableGuestAccount":  false,
    "localSecurityOptionsGuestAccountName":  null,
    "localSecurityOptionsAllowUndockWithoutHavingToLogon":  false,
    "localSecurityOptionsBlockUsersInstallingPrinterDrivers":  false,
    "localSecurityOptionsBlockRemoteOpticalDriveAccess":  false,
    "localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser":  "notConfigured",
    "localSecurityOptionsMachineInactivityLimit":  15,
    "localSecurityOptionsMachineInactivityLimitInMinutes":  15,
    "localSecurityOptionsDoNotRequireCtrlAltDel":  false,
    "localSecurityOptionsHideLastSignedInUser":  false,
    "localSecurityOptionsHideUsernameAtSignIn":  false,
    "localSecurityOptionsLogOnMessageTitle":  null,
    "localSecurityOptionsLogOnMessageText":  null,
    "localSecurityOptionsAllowPKU2UAuthenticationRequests":  false,
    "localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool":  false,
    "localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager":  null,
    "localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients":  "none",
    "localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers":  "none",
    "lanManagerAuthenticationLevel":  "lmAndNltm",
    "lanManagerWorkstationDisableInsecureGuestLogons":  false,
    "localSecurityOptionsClearVirtualMemoryPageFile":  false,
    "localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn":  false,
    "localSecurityOptionsAllowUIAccessApplicationElevation":  false,
    "localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations":  false,
    "localSecurityOptionsOnlyElevateSignedExecutables":  false,
    "localSecurityOptionsAdministratorElevationPromptBehavior":  "promptForConsentOnTheSecureDesktop",
    "localSecurityOptionsStandardUserElevationPromptBehavior":  "promptForCredentialsOnTheSecureDesktop",
    "localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation":  false,
    "localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation":  true,
    "localSecurityOptionsAllowUIAccessApplicationsForSecureLocations":  false,
    "localSecurityOptionsUseAdminApprovalMode":  true,
    "localSecurityOptionsUseAdminApprovalModeForAdministrators":  true,
    "localSecurityOptionsInformationShownOnLockScreen":  "notConfigured",
    "localSecurityOptionsInformationDisplayedOnLockScreen":  "notConfigured",
    "localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees":  false,
    "localSecurityOptionsClientDigitallySignCommunicationsAlways":  false,
    "localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers":  false,
    "localSecurityOptionsDisableServerDigitallySignCommunicationsAlways":  false,
    "localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees":  false,
    "localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares":  false,
    "localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts":  false,
    "localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares":  false,
    "localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange":  false,
    "localSecurityOptionsSmartCardRemovalBehavior":  "lockWorkstation",
    "defenderSecurityCenterDisableAppBrowserUI":  false,
    "defenderSecurityCenterDisableFamilyUI":  false,
    "defenderSecurityCenterDisableHealthUI":  false,
    "defenderSecurityCenterDisableNetworkUI":  false,
    "defenderSecurityCenterDisableVirusUI":  false,
    "defenderSecurityCenterDisableAccountUI":  false,
    "defenderSecurityCenterDisableClearTpmUI":  false,
    "defenderSecurityCenterDisableHardwareUI":  false,
    "defenderSecurityCenterDisableNotificationAreaUI":  false,
    "defenderSecurityCenterDisableRansomwareUI":  false,
    "defenderSecurityCenterDisableSecureBootUI":  false,
    "defenderSecurityCenterDisableTroubleshootingUI":  false,
    "defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI":  false,
    "defenderSecurityCenterOrganizationDisplayName":  null,
    "defenderSecurityCenterHelpEmail":  null,
    "defenderSecurityCenterHelpPhone":  null,
    "defenderSecurityCenterHelpURL":  null,
    "defenderSecurityCenterNotificationsFromApp":  "notConfigured",
    "defenderSecurityCenterITContactDisplay":  "notConfigured",
    "windowsDefenderTamperProtection":  "notConfigured",
    "firewallBlockStatefulFTP":  false,
    "firewallIdleTimeoutForSecurityAssociationInSeconds":  null,
    "firewallPreSharedKeyEncodingMethod":  "deviceDefault",
    "firewallIPSecExemptionsAllowNeighborDiscovery":  false,
    "firewallIPSecExemptionsAllowICMP":  false,
    "firewallIPSecExemptionsAllowRouterDiscovery":  false,
    "firewallIPSecExemptionsAllowDHCP":  false,
    "firewallCertificateRevocationListCheckMethod":  "deviceDefault",
    "firewallMergeKeyingModuleSettings":  false,
    "firewallPacketQueueingMethod":  "deviceDefault",
    "defenderAdobeReaderLaunchChildProcess":  "auditMode",
    "defenderAttackSurfaceReductionExcludedPaths":  [

                                                    ],
    "defenderOfficeAppsOtherProcessInjectionType":  "auditMode",
    "defenderOfficeAppsOtherProcessInjection":  "auditMode",
    "defenderOfficeCommunicationAppsLaunchChildProcess":  "auditMode",
    "defenderOfficeAppsExecutableContentCreationOrLaunchType":  "auditMode",
    "defenderOfficeAppsExecutableContentCreationOrLaunch":  "auditMode",
    "defenderOfficeAppsLaunchChildProcessType":  "auditMode",
    "defenderOfficeAppsLaunchChildProcess":  "auditMode",
    "defenderOfficeMacroCodeAllowWin32ImportsType":  "auditMode",
    "defenderOfficeMacroCodeAllowWin32Imports":  "auditMode",
    "defenderScriptObfuscatedMacroCodeType":  "auditMode",
    "defenderScriptObfuscatedMacroCode":  "auditMode",
    "defenderScriptDownloadedPayloadExecutionType":  "auditMode",
    "defenderScriptDownloadedPayloadExecution":  "auditMode",
    "defenderPreventCredentialStealingType":  "auditMode",
    "defenderProcessCreationType":  "auditMode",
    "defenderProcessCreation":  "auditMode",
    "defenderUntrustedUSBProcessType":  "auditMode",
    "defenderUntrustedUSBProcess":  "auditMode",
    "defenderUntrustedExecutableType":  "auditMode",
    "defenderUntrustedExecutable":  "auditMode",
    "defenderEmailContentExecutionType":  "auditMode",
    "defenderEmailContentExecution":  "auditMode",
    "defenderAdvancedRansomewareProtectionType":  "auditMode",
    "defenderGuardMyFoldersType":  "auditMode",
    "defenderGuardedFoldersAllowedAppPaths":  [

                                              ],
    "defenderAdditionalGuardedFolders":  [

                                         ],
    "defenderNetworkProtectionType":  "enable",
    "defenderExploitProtectionXml":  null,
    "defenderExploitProtectionXmlFileName":  null,
    "defenderSecurityCenterBlockExploitProtectionOverride":  false,
    "appLockerApplicationControl":  "notConfigured",
    "deviceGuardLocalSystemAuthorityCredentialGuardSettings":  "notConfigured",
    "deviceGuardEnableVirtualizationBasedSecurity":  false,
    "deviceGuardEnableSecureBootWithDMA":  false,
    "deviceGuardSecureBootWithDMA":  "notConfigured",
    "deviceGuardLaunchSystemGuard":  "notConfigured",
    "smartScreenEnableInShell":  true,
    "smartScreenBlockOverrideForFiles":  false,
    "applicationGuardEnabled":  false,
    "applicationGuardEnabledOptions":  "notConfigured",
    "applicationGuardBlockFileTransfer":  "notConfigured",
    "applicationGuardBlockNonEnterpriseContent":  false,
    "applicationGuardAllowPersistence":  false,
    "applicationGuardForceAuditing":  false,
    "applicationGuardBlockClipboardSharing":  "notConfigured",
    "applicationGuardAllowPrintToPDF":  false,
    "applicationGuardAllowPrintToXPS":  false,
    "applicationGuardAllowPrintToLocalPrinters":  false,
    "applicationGuardAllowPrintToNetworkPrinters":  false,
    "applicationGuardAllowVirtualGPU":  false,
    "applicationGuardAllowFileSaveOnHost":  false,
    "bitLockerAllowStandardUserEncryption":  true,
    "bitLockerDisableWarningForOtherDiskEncryption":  true,
    "bitLockerEnableStorageCardEncryptionOnMobile":  false,
    "bitLockerEncryptDevice":  true,
    "bitLockerRecoveryPasswordRotation":  "notConfigured",
    "defenderDisableScanArchiveFiles":  false,
    "defenderDisableBehaviorMonitoring":  false,
    "defenderDisableCloudProtection":  false,
    "defenderEnableScanIncomingMail":  false,
    "defenderEnableScanMappedNetworkDrivesDuringFullScan":  false,
    "defenderDisableScanRemovableDrivesDuringFullScan":  false,
    "defenderDisableScanDownloads":  false,
    "defenderDisableIntrusionPreventionSystem":  false,
    "defenderDisableOnAccessProtection":  false,
    "defenderDisableRealTimeMonitoring":  false,
    "defenderDisableScanNetworkFiles":  false,
    "defenderDisableScanScriptsLoadedInInternetExplorer":  false,
    "defenderBlockEndUserAccess":  false,
    "defenderScanMaxCpuPercentage":  null,
    "defenderCheckForSignaturesBeforeRunningScan":  false,
    "defenderCloudBlockLevel":  "notConfigured",
    "defenderCloudExtendedTimeoutInSeconds":  null,
    "defenderDaysBeforeDeletingQuarantinedMalware":  null,
    "defenderDisableCatchupFullScan":  false,
    "defenderDisableCatchupQuickScan":  false,
    "defenderEnableLowCpuPriority":  false,
    "defenderFileExtensionsToExclude":  [

                                        ],
    "defenderFilesAndFoldersToExclude":  [

                                         ],
    "defenderProcessesToExclude":  [

                                   ],
    "defenderPotentiallyUnwantedAppAction":  "userDefined",
    "defenderScanDirection":  "monitorAllFiles",
    "defenderScanType":  "userDefined",
    "defenderScheduledQuickScanTime":  null,
    "defenderScheduledScanDay":  "userDefined",
    "defenderScheduledScanTime":  null,
    "defenderSubmitSamplesConsentType":  "sendSafeSamplesAutomatically",
    "defenderDetectedMalwareActions":  null,
    "firewallRules":  [

                      ],
    "userRightsAccessCredentialManagerAsTrustedCaller":  {
                                                             "state":  "notConfigured",
                                                             "localUsersOrGroups":  [

                                                                                    ]
                                                         },
    "userRightsAllowAccessFromNetwork":  {
                                             "state":  "notConfigured",
                                             "localUsersOrGroups":  [

                                                                    ]
                                         },
    "userRightsBlockAccessFromNetwork":  {
                                             "state":  "notConfigured",
                                             "localUsersOrGroups":  [

                                                                    ]
                                         },
    "userRightsActAsPartOfTheOperatingSystem":  {
                                                    "state":  "notConfigured",
                                                    "localUsersOrGroups":  [

                                                                           ]
                                                },
    "userRightsLocalLogOn":  {
                                 "state":  "notConfigured",
                                 "localUsersOrGroups":  [

                                                        ]
                             },
    "userRightsDenyLocalLogOn":  {
                                     "state":  "notConfigured",
                                     "localUsersOrGroups":  [

                                                            ]
                                 },
    "userRightsBackupData":  {
                                 "state":  "notConfigured",
                                 "localUsersOrGroups":  [

                                                        ]
                             },
    "userRightsChangeSystemTime":  {
                                       "state":  "notConfigured",
                                       "localUsersOrGroups":  [

                                                              ]
                                   },
    "userRightsCreateGlobalObjects":  {
                                          "state":  "notConfigured",
                                          "localUsersOrGroups":  [

                                                                 ]
                                      },
    "userRightsCreatePageFile":  {
                                     "state":  "notConfigured",
                                     "localUsersOrGroups":  [

                                                            ]
                                 },
    "userRightsCreatePermanentSharedObjects":  {
                                                   "state":  "notConfigured",
                                                   "localUsersOrGroups":  [

                                                                          ]
                                               },
    "userRightsCreateSymbolicLinks":  {
                                          "state":  "notConfigured",
                                          "localUsersOrGroups":  [

                                                                 ]
                                      },
    "userRightsCreateToken":  {
                                  "state":  "notConfigured",
                                  "localUsersOrGroups":  [

                                                         ]
                              },
    "userRightsDebugPrograms":  {
                                    "state":  "notConfigured",
                                    "localUsersOrGroups":  [

                                                           ]
                                },
    "userRightsRemoteDesktopServicesLogOn":  {
                                                 "state":  "notConfigured",
                                                 "localUsersOrGroups":  [

                                                                        ]
                                             },
    "userRightsDelegation":  {
                                 "state":  "notConfigured",
                                 "localUsersOrGroups":  [

                                                        ]
                             },
    "userRightsGenerateSecurityAudits":  {
                                             "state":  "notConfigured",
                                             "localUsersOrGroups":  [

                                                                    ]
                                         },
    "userRightsImpersonateClient":  {
                                        "state":  "notConfigured",
                                        "localUsersOrGroups":  [

                                                               ]
                                    },
    "userRightsIncreaseSchedulingPriority":  {
                                                 "state":  "notConfigured",
                                                 "localUsersOrGroups":  [

                                                                        ]
                                             },
    "userRightsLoadUnloadDrivers":  {
                                        "state":  "notConfigured",
                                        "localUsersOrGroups":  [

                                                               ]
                                    },
    "userRightsLockMemory":  {
                                 "state":  "notConfigured",
                                 "localUsersOrGroups":  [

                                                        ]
                             },
    "userRightsManageAuditingAndSecurityLogs":  {
                                                    "state":  "notConfigured",
                                                    "localUsersOrGroups":  [

                                                                           ]
                                                },
    "userRightsManageVolumes":  {
                                    "state":  "notConfigured",
                                    "localUsersOrGroups":  [

                                                           ]
                                },
    "userRightsModifyFirmwareEnvironment":  {
                                                "state":  "notConfigured",
                                                "localUsersOrGroups":  [

                                                                       ]
                                            },
    "userRightsModifyObjectLabels":  {
                                         "state":  "notConfigured",
                                         "localUsersOrGroups":  [

                                                                ]
                                     },
    "userRightsProfileSingleProcess":  {
                                           "state":  "notConfigured",
                                           "localUsersOrGroups":  [

                                                                  ]
                                       },
    "userRightsRemoteShutdown":  {
                                     "state":  "notConfigured",
                                     "localUsersOrGroups":  [

                                                            ]
                                 },
    "userRightsRestoreData":  {
                                  "state":  "notConfigured",
                                  "localUsersOrGroups":  [

                                                         ]
                              },
    "userRightsTakeOwnership":  {
                                    "state":  "notConfigured",
                                    "localUsersOrGroups":  [

                                                           ]
                                },
    "firewallProfileDomain":  {
                                  "firewallEnabled":  "allowed",
                                  "stealthModeRequired":  false,
                                  "stealthModeBlocked":  false,
                                  "incomingTrafficRequired":  false,
                                  "incomingTrafficBlocked":  false,
                                  "unicastResponsesToMulticastBroadcastsRequired":  false,
                                  "unicastResponsesToMulticastBroadcastsBlocked":  false,
                                  "inboundNotificationsRequired":  false,
                                  "inboundNotificationsBlocked":  false,
                                  "authorizedApplicationRulesFromGroupPolicyMerged":  false,
                                  "authorizedApplicationRulesFromGroupPolicyNotMerged":  false,
                                  "globalPortRulesFromGroupPolicyMerged":  false,
                                  "globalPortRulesFromGroupPolicyNotMerged":  false,
                                  "connectionSecurityRulesFromGroupPolicyMerged":  false,
                                  "connectionSecurityRulesFromGroupPolicyNotMerged":  false,
                                  "outboundConnectionsRequired":  false,
                                  "outboundConnectionsBlocked":  false,
                                  "inboundConnectionsRequired":  false,
                                  "inboundConnectionsBlocked":  true,
                                  "securedPacketExemptionAllowed":  false,
                                  "securedPacketExemptionBlocked":  false,
                                  "policyRulesFromGroupPolicyMerged":  false,
                                  "policyRulesFromGroupPolicyNotMerged":  false
                              },
    "firewallProfilePublic":  {
                                  "firewallEnabled":  "allowed",
                                  "stealthModeRequired":  false,
                                  "stealthModeBlocked":  false,
                                  "incomingTrafficRequired":  false,
                                  "incomingTrafficBlocked":  false,
                                  "unicastResponsesToMulticastBroadcastsRequired":  false,
                                  "unicastResponsesToMulticastBroadcastsBlocked":  false,
                                  "inboundNotificationsRequired":  false,
                                  "inboundNotificationsBlocked":  false,
                                  "authorizedApplicationRulesFromGroupPolicyMerged":  false,
                                  "authorizedApplicationRulesFromGroupPolicyNotMerged":  false,
                                  "globalPortRulesFromGroupPolicyMerged":  false,
                                  "globalPortRulesFromGroupPolicyNotMerged":  false,
                                  "connectionSecurityRulesFromGroupPolicyMerged":  false,
                                  "connectionSecurityRulesFromGroupPolicyNotMerged":  false,
                                  "outboundConnectionsRequired":  false,
                                  "outboundConnectionsBlocked":  false,
                                  "inboundConnectionsRequired":  false,
                                  "inboundConnectionsBlocked":  true,
                                  "securedPacketExemptionAllowed":  false,
                                  "securedPacketExemptionBlocked":  false,
                                  "policyRulesFromGroupPolicyMerged":  false,
                                  "policyRulesFromGroupPolicyNotMerged":  false
                              },
    "firewallProfilePrivate":  {
                                   "firewallEnabled":  "allowed",
                                   "stealthModeRequired":  false,
                                   "stealthModeBlocked":  false,
                                   "incomingTrafficRequired":  false,
                                   "incomingTrafficBlocked":  false,
                                   "unicastResponsesToMulticastBroadcastsRequired":  false,
                                   "unicastResponsesToMulticastBroadcastsBlocked":  false,
                                   "inboundNotificationsRequired":  false,
                                   "inboundNotificationsBlocked":  false,
                                   "authorizedApplicationRulesFromGroupPolicyMerged":  false,
                                   "authorizedApplicationRulesFromGroupPolicyNotMerged":  false,
                                   "globalPortRulesFromGroupPolicyMerged":  false,
                                   "globalPortRulesFromGroupPolicyNotMerged":  false,
                                   "connectionSecurityRulesFromGroupPolicyMerged":  false,
                                   "connectionSecurityRulesFromGroupPolicyNotMerged":  false,
                                   "outboundConnectionsRequired":  false,
                                   "outboundConnectionsBlocked":  false,
                                   "inboundConnectionsRequired":  false,
                                   "inboundConnectionsBlocked":  true,
                                   "securedPacketExemptionAllowed":  false,
                                   "securedPacketExemptionBlocked":  false,
                                   "policyRulesFromGroupPolicyMerged":  false,
                                   "policyRulesFromGroupPolicyNotMerged":  false
                               },
    "bitLockerSystemDrivePolicy":  {
                                       "encryptionMethod":  null,
                                       "startupAuthenticationRequired":  true,
                                       "startupAuthenticationBlockWithoutTpmChip":  false,
                                       "startupAuthenticationTpmUsage":  "allowed",
                                       "startupAuthenticationTpmPinUsage":  "allowed",
                                       "startupAuthenticationTpmKeyUsage":  "allowed",
                                       "startupAuthenticationTpmPinAndKeyUsage":  "allowed",
                                       "minimumPinLength":  null,
                                       "prebootRecoveryEnableMessageAndUrl":  false,
                                       "prebootRecoveryMessage":  null,
                                       "prebootRecoveryUrl":  null,
                                       "recoveryOptions":  {
                                                               "blockDataRecoveryAgent":  false,
                                                               "recoveryPasswordUsage":  "allowed",
                                                               "recoveryKeyUsage":  "allowed",
                                                               "hideRecoveryOptions":  true,
                                                               "enableRecoveryInformationSaveToStore":  true,
                                                               "recoveryInformationToStore":  "passwordAndKey",
                                                               "enableBitLockerAfterRecoveryInformationToStore":  true
                                                           }
                                   },
    "bitLockerFixedDrivePolicy":  {
                                      "encryptionMethod":  null,
                                      "requireEncryptionForWriteAccess":  false,
                                      "recoveryOptions":  {
                                                              "blockDataRecoveryAgent":  false,
                                                              "recoveryPasswordUsage":  "allowed",
                                                              "recoveryKeyUsage":  "allowed",
                                                              "hideRecoveryOptions":  true,
                                                              "enableRecoveryInformationSaveToStore":  true,
                                                              "recoveryInformationToStore":  "passwordAndKey",
                                                              "enableBitLockerAfterRecoveryInformationToStore":  true
                                                          }
                                  },
    "bitLockerRemovableDrivePolicy":  {
                                          "encryptionMethod":  null,
                                          "requireEncryptionForWriteAccess":  false,
                                          "blockCrossOrganizationWriteAccess":  false
                                      }
}


"@
########################################
# Apps
########################################

# $Office32 = @"



# {

#   "@odata.type": "#microsoft.graph.officeSuiteApp",

#   "autoAcceptEula": true,

#   "description": "Microsoft 365 Desktop apps - 32 bit",

#   "developer": "Microsoft",

#   "displayName": "Microsoft 365 Desktop apps - 32 bit",

#   "excludedApps": {

#     "groove": true,

#     "infoPath": true,

#     "sharePointDesigner": true,

#     "lync":  true

#   },

#   "informationUrl": "",

#   "isFeatured": false,

#   "largeIcon": {

#     "type": "image/png",

#     "value": "iVBORw0KGgoAAAANSUhEUgAAAF0AAAAeCAMAAAEOZNKlAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJhUExURf////7z7/i9qfF1S/KCW/i+qv3q5P/9/PrQwfOMae1RG+s8AOxGDfBtQPWhhPvUx/759/zg1vWgg+9fLu5WIvKFX/rSxP728/nCr/FyR+tBBvOMaO1UH+1RHOs+AvSScP3u6f/+/v3s5vzg1+xFDO9kNPOOa/i7pvzj2/vWyes9Af76+Pzh2PrTxf/6+f7y7vOGYexHDv3t5+1SHfi8qPOIZPvb0O1NFuxDCe9hMPSVdPnFs/3q4/vaz/STcu5VIe5YJPWcfv718v/9/e1MFfF4T/F4TvF2TP3o4exECvF0SexIEPONavzn3/vZze1QGvF3Te5dK+5cKvrPwPrQwvKAWe1OGPexmexKEveulfezm/BxRfamiuxLE/apj/zf1e5YJfSXd/OHYv3r5feznPakiPze1P7x7f739f3w6+xJEfnEsvWdf/Wfge1LFPe1nu9iMvnDsfBqPOs/BPOIY/WZevJ/V/zl3fnIt/vTxuxHD+xEC+9mN+5ZJv749vBpO/KBWvBwRP/8+/SUc/etlPjArP/7+vOLZ/F7UvWae/708e1OF/aihvSWdvi8p+tABfSZefvVyPWihfSVde9lNvami+9jM/zi2fKEXvBuQvOKZvalifF5UPJ/WPSPbe9eLfrKuvvd0uxBB/7w7Pzj2vrRw/rOv+1PGfi/q/eymu5bKf3n4PnJuPBrPf3t6PWfgvWegOxCCO9nOO9oOfaskvSYePi5pPi2oPnGtO5eLPevlvKDXfrNvv739Pzd0/708O9gL+9lNfJ9VfrLu/OPbPnDsPBrPus+A/nArfarkQAAAGr5HKgAAADLdFJOU/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AvuakogAAAAlwSFlzAAAOwwAADsMBx2+oZAAAAz5JREFUOE+tVTtu4zAQHQjppmWzwIJbEVCzpTpjbxD3grQHSOXKRXgCAT6EC7UBVAmp3KwBnmvfzNCyZTmxgeTZJsXx43B+HBHRE34ZkXgkerXFTheeiCkRrbB4UXmp4wSWz5raaQEMTM5TZwuiXoaKgV+6FsmkZQcSy0kA71yMTMGHanX+AzMMGLAQCxU1F/ZwjULPugazl82GM0NEKm/U8EqFwEkO3/EAT4grgl0nucwlk9pcpTTJ4VPA4g/Rb3yIRhhp507e9nTQmZ1OS5RO4sS7nIRPEeHXCHdkw9ZEW2yVE5oIS7peD58Avs7CN+PVCmHh21oOqBdjDzIs+FldPJ74TFESUSJEfVzy9U/dhu+AuOT6eBp6gGKyXEx8euO450ZE4CMfstMFT44broWw/itkYErWXRx+fFArt9Ca9os78TFed0LVIUsmIHrwbwaw3BEOnOk94qVpQ6Ka2HjxewJnfyd6jUtGDQLdWlzmYNYLeKbbGOucJsNabCq1Yub0o92rtR+i30V2dapxYVEePXcOjeCKPnYyit7BtKeNlZqHbr+gt7i+AChWA9RsRs03pxTQc67ouWpxyESvjK5Vs3DVSy3IpkxPm5X+wZoBi+MFHWW69/w8FRhc7VBe6HAhMB2b8Q0XqDzTNZtXUMnKMjwKVaCrB/CSUL7WSx/HsdJC86lFGXwnioTeOMPjV+szlFvrZLA5VMVK4y+41l4e1xfx7Z88o4hkilRUH/qKqwNVlgDgpvYCpH3XwAy5eMCRnezIUxffVXoDql2rTHFDO+pjWnTWzAfrYXn6BFECblUpWGrvPZvBipETjS5ydM7tdXpH41ZCEbBNy/+wFZu71QO2t9pgT+iZEf657Q1vpN94PQNDxUHeKR103LV9nPVOtDikcNKO+2naCw7yKBhOe9Hm79pe8C4/CfC2wDjXnqC94kEeBU3WwN7dt/2UScXas7zDl5GpkY+M8WKv2J7fd4Ib2rGTk+jsC2cleEM7jI9veF7B0MBJrsZqfKd/81q9pR2NZfwJK2JzsmIT1Ns8jUH0UusQBpU8d2JzsHiXg1zXGLqxfitUNTDT/nUUeqDBp2HZVr+Ocqi/Ty3Rf4Jn82xxfSNtAAAAAElFTkSuQmCC"

#   },

#   "localesToInstall": [

#     "en-us"

#   ],

#   "notes": "",

#   "officePlatformArchitecture": "x86",

#   "owner": "Microsoft",

#   "privacyInformationUrl": "",

#   "productIds": [

#     "o365ProPlusRetail"

#   ],

#   "publisher": "Microsoft",

#   "updateChannel": "current",

#   "useSharedComputerActivation": true

# }



# "@
# ########################################

# $Office64 = @"



# {

#   "@odata.type": "#microsoft.graph.officeSuiteApp",

#   "autoAcceptEula": true,

#   "description": "Microsoft 365 Desktop apps - 64 bit",

#   "developer": "Microsoft",

#   "displayName": "Microsoft 365 Desktop apps - 64 bit",

#   "excludedApps": {

#     "groove": true,

#     "infoPath": true,

#     "lync":  true,

#     "sharePointDesigner": true

#   },

#   "informationUrl": "",

#   "isFeatured": false,

#   "largeIcon": {

#     "type": "image/png",

#     "value": "iVBORw0KGgoAAAANSUhEUgAAAF0AAAAeCAMAAAEOZNKlAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJhUExURf////7z7/i9qfF1S/KCW/i+qv3q5P/9/PrQwfOMae1RG+s8AOxGDfBtQPWhhPvUx/759/zg1vWgg+9fLu5WIvKFX/rSxP728/nCr/FyR+tBBvOMaO1UH+1RHOs+AvSScP3u6f/+/v3s5vzg1+xFDO9kNPOOa/i7pvzj2/vWyes9Af76+Pzh2PrTxf/6+f7y7vOGYexHDv3t5+1SHfi8qPOIZPvb0O1NFuxDCe9hMPSVdPnFs/3q4/vaz/STcu5VIe5YJPWcfv718v/9/e1MFfF4T/F4TvF2TP3o4exECvF0SexIEPONavzn3/vZze1QGvF3Te5dK+5cKvrPwPrQwvKAWe1OGPexmexKEveulfezm/BxRfamiuxLE/apj/zf1e5YJfSXd/OHYv3r5feznPakiPze1P7x7f739f3w6+xJEfnEsvWdf/Wfge1LFPe1nu9iMvnDsfBqPOs/BPOIY/WZevJ/V/zl3fnIt/vTxuxHD+xEC+9mN+5ZJv749vBpO/KBWvBwRP/8+/SUc/etlPjArP/7+vOLZ/F7UvWae/708e1OF/aihvSWdvi8p+tABfSZefvVyPWihfSVde9lNvami+9jM/zi2fKEXvBuQvOKZvalifF5UPJ/WPSPbe9eLfrKuvvd0uxBB/7w7Pzj2vrRw/rOv+1PGfi/q/eymu5bKf3n4PnJuPBrPf3t6PWfgvWegOxCCO9nOO9oOfaskvSYePi5pPi2oPnGtO5eLPevlvKDXfrNvv739Pzd0/708O9gL+9lNfJ9VfrLu/OPbPnDsPBrPus+A/nArfarkQAAAGr5HKgAAADLdFJOU/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AvuakogAAAAlwSFlzAAAOwwAADsMBx2+oZAAAAz5JREFUOE+tVTtu4zAQHQjppmWzwIJbEVCzpTpjbxD3grQHSOXKRXgCAT6EC7UBVAmp3KwBnmvfzNCyZTmxgeTZJsXx43B+HBHRE34ZkXgkerXFTheeiCkRrbB4UXmp4wSWz5raaQEMTM5TZwuiXoaKgV+6FsmkZQcSy0kA71yMTMGHanX+AzMMGLAQCxU1F/ZwjULPugazl82GM0NEKm/U8EqFwEkO3/EAT4grgl0nucwlk9pcpTTJ4VPA4g/Rb3yIRhhp507e9nTQmZ1OS5RO4sS7nIRPEeHXCHdkw9ZEW2yVE5oIS7peD58Avs7CN+PVCmHh21oOqBdjDzIs+FldPJ74TFESUSJEfVzy9U/dhu+AuOT6eBp6gGKyXEx8euO450ZE4CMfstMFT44broWw/itkYErWXRx+fFArt9Ca9os78TFed0LVIUsmIHrwbwaw3BEOnOk94qVpQ6Ka2HjxewJnfyd6jUtGDQLdWlzmYNYLeKbbGOucJsNabCq1Yub0o92rtR+i30V2dapxYVEePXcOjeCKPnYyit7BtKeNlZqHbr+gt7i+AChWA9RsRs03pxTQc67ouWpxyESvjK5Vs3DVSy3IpkxPm5X+wZoBi+MFHWW69/w8FRhc7VBe6HAhMB2b8Q0XqDzTNZtXUMnKMjwKVaCrB/CSUL7WSx/HsdJC86lFGXwnioTeOMPjV+szlFvrZLA5VMVK4y+41l4e1xfx7Z88o4hkilRUH/qKqwNVlgDgpvYCpH3XwAy5eMCRnezIUxffVXoDql2rTHFDO+pjWnTWzAfrYXn6BFECblUpWGrvPZvBipETjS5ydM7tdXpH41ZCEbBNy/+wFZu71QO2t9pgT+iZEf657Q1vpN94PQNDxUHeKR103LV9nPVOtDikcNKO+2naCw7yKBhOe9Hm79pe8C4/CfC2wDjXnqC94kEeBU3WwN7dt/2UScXas7zDl5GpkY+M8WKv2J7fd4Ib2rGTk+jsC2cleEM7jI9veF7B0MBJrsZqfKd/81q9pR2NZfwJK2JzsmIT1Ns8jUH0UusQBpU8d2JzsHiXg1zXGLqxfitUNTDT/nUUeqDBp2HZVr+Ocqi/Ty3Rf4Jn82xxfSNtAAAAAElFTkSuQmCC"

#   },

#   "localesToInstall": [

#     "en-us"

#   ],

#   "notes": "",

#   "officePlatformArchitecture": "x64",

#   "owner": "Microsoft",

#   "privacyInformationUrl": "",

#   "productIds": [

#     "o365ProPlusRetail"

#   ],

#   "publisher": "Microsoft",

#   "updateChannel": "current",

#   "useSharedComputerActivation": true

# }



# "@
########################################

# Main Script

# Install / Verify Microsoft Graph SDK
Install-MicrosoftGraphModule 

# Utilizing Microsoft Graph SDK to create an app registration
Write-Host "Login to M365 tenant..."
Connect-MgGraph -Scopes Directory.Read.All,AppRoleAssignment.ReadWrite.All,Application.ReadWrite.All -NoWelcome

# List app permissions
$requiredResourceAccess = @{
    "resourceAccess" = (
        @{ # DeviceManagementApps.ReadWrite.All
            "id" = "78145de6-330d-4800-a6ce-494ff2d33d07"
            "type" = "Role"
        },
        @{ # DeviceManagementConfiguration.ReadWrite.All
            "id" = "9241abd9-d0e6-425a-bd4f-47ba86e767a4"
            "type" = "Role"
        },
        @{ # DeviceManagementServiceConfig.ReadWrite.All
            "id" = "5ac13192-7ace-4fcf-b828-1a26f28068ee"
            "type" = "Role"
        },
        @{ # Directory.ReadWrite.All
            "id" = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
            "type" = "Role"
        },
        @{ # Group.ReadWrite.All
            "id"= "62a82d76-70ea-41e2-9197-370581804d09"
            "type" = "Role"
        },
        @{ # GroupMember.ReadWrite.All
            "id" = "dbaae8cf-10b5-4b86-a4a1-f871c94c6695"
            "type" = "Role"
        },
        @{ # DeviceManagementManagedDevices.ReadWrite.All
            "id" = "243333ab-4d21-40cb-a475-36241daa0842"
            "type" = "Role"
        },
        @{ # DeviceManagementRBAC.ReadWrite.All
            "id" = "e330c4f0-4170-414e-a55a-2f022ec2b57b"
            "type" = "Role"
        },
        @{ # DeviceManagementManagedDevices.PrivilegedOperations.All
            "id" = "5b07b0dd-2377-4e44-a38d-703f09a0dc3c"
            "type" = "Role"
        }
    )
    "resourceAppId" = "00000003-0000-0000-c000-000000000000"
}

# Retrieve the current logged in account
$account = (Get-MgContext).Account
$tenantName = (Get-MgOrganization).DisplayName

# Display the account information
Write-Host "`nYou are currently logged in with the following tenant and account:"
Write-Host "Tenant:  " -NoNewline
Write-Host "$($tenantName)" -ForegroundColor Blue
Write-Host "Account:  " -NoNewline
Write-Host "$($account)" -ForegroundColor Blue

# Ask the user if they want to continue
$accountResponse = Read-Host -Prompt "`nDo you want to continue with this account? (Y/N)"
# Normalize the response to upper case
$accountResponse = $accountResponse.ToUpper()

# Check for users response and take appropriate action
if ($accountResponse -eq 'Y') {

    # Create the app registration
    Write-Host "`nCreating Entra ID app registration..."
    $appName = "Test MAM MDM Automation"
    $app = New-MgApplication -DisplayName $appName -RequiredResourceAccess $requiredResourceAccess

    # Grant admin consent
    Write-Host "`nAssigning permissions to app registration..."
    $graphSpId = $(Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'").Id
    $sp = New-MgServicePrincipal -AppId $app.AppId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "78145de6-330d-4800-a6ce-494ff2d33d07" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "9241abd9-d0e6-425a-bd4f-47ba86e767a4" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "5ac13192-7ace-4fcf-b828-1a26f28068ee" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "19dbc75e-c2e2-444c-a770-ec69d8559fc7" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "62a82d76-70ea-41e2-9197-370581804d09" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "dbaae8cf-10b5-4b86-a4a1-f871c94c6695" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "243333ab-4d21-40cb-a475-36241daa0842" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "e330c4f0-4170-414e-a55a-2f022ec2b57b" -ResourceId $graphSpId
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId "5b07b0dd-2377-4e44-a38d-703f09a0dc3c" -ResourceId $graphSpId

    # Create the client secret
    Write-Host "`nCreating app secret..."
    $cred = Add-MgApplicationPassword -ApplicationId $app.Id

    $clientId = $app.AppId
    $secretKey = $cred.SecretText
    $tenantId = (Get-MgContext).TenantId

    # Creating necessary variables for authentication to the Microsoft Graph API
    $secureSecretKey = $secretKey | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $clientId, $secureSecretKey
    $sleepTimer = 30
    Write-Host "`nApplying app registration permissions, please wait $sleepTimer seconds..." 
    Start-Sleep -Seconds $sleepTimer
    $accessToken = Get-AccessToken -TenantId $tenantId -Credential $credential
    $headers = Get-Headers -AccessToken $accessToken

    # Create MAM policies for mobile devices
    Write-Host "Adding MAM policies for mobile devices..." -ForegroundColor Yellow
    Add-ManagedAppPolicy -JSON $MAM_AndroidBase #OK
    Add-ManagedAppPolicy -JSON $MAM_iOSBase #OK
    Write-Host

    # Create MDM compliance policies for mobile devices
    Write-Host "Adding MDM Compliance policies for mobile devices..." -ForegroundColor Yellow
    Add-DeviceCompliancePolicybaseline -JSON $BaselineAndroidOwner #OK
    Add-DeviceCompliancePolicybaseline -JSON $BaselineAndroidWork #OK
    Add-DeviceCompliancePolicybaseline -JSON $BaselineiOS #OK
    Write-Host
    
    # Create compliance polices for Windows and MacOS
    Write-Host "Adding Compliance policies for Windows and MacOS..." -ForegroundColor Yellow
    Add-DeviceCompliancePolicybaseline -Json $BaselineWin10 #OK
    Add-DeviceCompliancePolicybaseline -Json $BaselineMacOS #OK
    Write-Host 

    # Create basic device configuration profiles
    Write-Host "Adding Device configuration profiles..." -ForegroundColor Yellow
    Add-DeviceConfigurationPolicy -Json $Win10BASICDR
    Add-DeviceConfigurationPolicy -Json $Win10BASICEP
    Write-Host

    # Create Office apps
    # write-host "Publishing" ($Office32 | ConvertFrom-Json).displayName -ForegroundColor Yellow
    # Add-MDMApplication -JSON $Office32
    # Write-Host 
    # write-host "Publishing" ($Office64 | ConvertFrom-Json).displayName -ForegroundColor Yellow
    # Add-MDMApplication -JSON $Office64
    # Write-Host

    # Removing the app registration after everything is built
    Remove-MgApplication -ApplicationId $app.Id

    # Disconnect from the Microsoft Graph connection
    Disconnect-MgGraph
    Read-Host -Prompt "`nPress Enter to close this window"

} else {
    Write-Host "`nDisconnecting from Microsoft.Graph and existing script. Please run script again with correct account login." -ForegroundColor Red
    Disconnect-MgGraph
    Read-Host -Prompt "`nPress Enter to close this window"
    exit
}