[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "AdminPassword")]

[CmdletBinding(DefaultParameterSetName = "no-arguments")]
Param (
    [Parameter(HelpMessage = "Enables initialization of values in the .env file, which may be placed in source control.",
        ParameterSetName = "env-init")]
    [switch]$InitEnv,

    [Parameter(Mandatory = $true,
        HelpMessage = "The path to a valid Sitecore license.xml file.",
        ParameterSetName = "env-init")]
    [string]$LicenseXmlPath,

    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local development environments.
    [Parameter(Mandatory = $true,
        HelpMessage = "Sets the sitecore\\admin password for this environment via environment variable.",
        ParameterSetName = "env-init")]
    [string]$AdminPassword
)

$ErrorActionPreference = "Stop";

if ($InitEnv) {
    if (-not $LicenseXmlPath.EndsWith("license.xml")) {
        Write-Error "Sitecore license file must be named 'license.xml'."
    }
    if (-not (Test-Path $LicenseXmlPath)) {
        Write-Error "Could not find Sitecore license file at path '$LicenseXmlPath'."
    }
    # We actually want the folder that it's in for mounting
    $LicenseXmlPath = (Get-Item $LicenseXmlPath).Directory.FullName
}

Write-Host "Preparing your Sitecore Containers environment!" -ForegroundColor Green

################################################
# Retrieve and import SitecoreDockerTools module
################################################

# Check for Sitecore Gallery
Import-Module PowerShellGet
$SitecoreGallery = Get-PSRepository | Where-Object { $_.Name -eq "SitecoreGallery" }
if (-not $SitecoreGallery) {
  Write-Host "Adding Sitecore PowerShell Gallery..." -ForegroundColor Green
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted -Verbose
  $SitecoreGallery = Get-PSRepository -Name SitecoreGallery
}
else
{
  Write-Host "Updating Sitecore PowerShell Gallery url..." -ForegroundColor Yellow
  Set-PSRepository -Name $SitecoreGallery.Name -Source "https://sitecore.myget.org/F/sc-powershell/api/v2"
}

#Install and Import SitecoreDockerTools
$dockerToolsVersion = "10.3.40"
Remove-Module SitecoreDockerTools -ErrorAction SilentlyContinue
if (-not (Get-InstalledModule -Name SitecoreDockerTools -RequiredVersion $dockerToolsVersion -ErrorAction SilentlyContinue)) {
    Write-Host "Installing SitecoreDockerTools..." -ForegroundColor Green
    Install-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion -Scope CurrentUser -Repository $SitecoreGallery.Name
}
Write-Host "Importing SitecoreDockerTools..." -ForegroundColor Green
Import-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion
Write-SitecoreDockerWelcome

##################
# Create .env file
##################
Write-Host "Creating .env file." -ForegroundColor Green
Copy-Item ".\.env.local" ".\.env" -Force

##################################
# Configure TLS/HTTPS certificates
##################################

Push-Location data\traefik\certs
try {
    $mkcert = ".\mkcert.exe"
    if ($null -ne (Get-Command mkcert.exe -ErrorAction SilentlyContinue)) {
        # mkcert installed in PATH
        $mkcert = "mkcert"
    } elseif (-not (Test-Path $mkcert)) {
        Write-Host "Downloading and installing mkcert certificate tool..." -ForegroundColor Green
        $preference = $ProgressPreference
        $ProgressPreference = "SilentlyContinue" # Makes the download exponentially faster
        Invoke-WebRequest "https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-windows-amd64.exe" -UseBasicParsing -OutFile mkcert.exe
        $ProgressPreference = $preference
        if ((Get-FileHash mkcert.exe).Hash -ne "1BE92F598145F61CA67DD9F5C687DFEC17953548D013715FF54067B34D7C3246") {
            Remove-Item mkcert.exe -Force
            throw "Invalid mkcert.exe file"
        }
    }
    Write-Host "Generating Traefik TLS certificate..." -ForegroundColor Green
    & $mkcert -install
    & $mkcert "*.lighthouse.localhost"
	& $mkcert "lighthouse.localhost"
	& $mkcert "cm.lighthouse.localhost"

	# stash CAROOT path for messaging at the end of the script
    $caRoot = "$(& $mkcert -CAROOT)\rootCA.pem"
}
catch {
    Write-Error "An error occurred while attempting to generate TLS certificate: $_"
}
finally {
    Pop-Location
}

################################
# Add Windows hosts file entries
################################
$envContent = Get-Content .env -Encoding UTF8
$ASPNET_HOST = $envContent | Where-Object { $_ -imatch "^ASPNET_RENDERING_HOST=.+" }
$ASPNET_HOST = $ASPNET_HOST.Split("=")[1]
$ASPNETCore_HOST = $envContent | Where-Object { $_ -imatch "^ASPNETCore_RENDERING_HOST=.+" }
$ASPNETCore_HOST = $ASPNETCore_HOST.Split("=")[1]
$NextJS_HOST = $envContent | Where-Object { $_ -imatch "^NextJS_RENDERING_HOST=.+" }
$NextJS_HOST = $NextJS_HOST.Split("=")[1]
$Angular_HOST = $envContent | Where-Object { $_ -imatch "^Angular_RENDERING_HOST=.+" }
$Angular_HOST = $Angular_HOST.Split("=")[1]
$React_HOST = $envContent | Where-Object { $_ -imatch "^React_RENDERING_HOST=.+" }
$React_HOST = $React_HOST.Split("=")[1]

Write-Host "Adding Windows hosts file entries..." -ForegroundColor Green

Add-HostsEntry "cm.lighthouse.localhost"
Add-HostsEntry "cd.lighthouse.localhost"
Add-HostsEntry "id.lighthouse.localhost"
Add-HostsEntry "sh.lighthouse.localhost"
Add-HostsEntry "ts.lighthouse.localhost"
Add-HostsEntry "www.lighthouse.localhost"

Add-HostsEntry "$ASPNET_HOST"
Add-HostsEntry "$ASPNETCore_HOST"
Add-HostsEntry "$NextJS_HOST"
Add-HostsEntry "$Angular_HOST"
Add-HostsEntry "$React_HOST"
##########################
# Show Certificate Details
##########################
Push-Location data\traefik\certs
try
{
    Write-Host
    Write-Host ("#"*75) -ForegroundColor Cyan
    Write-Host "To avoid HTTPS errors, set the NODE_EXTRA_CA_CERTS environment variable" -ForegroundColor Cyan
    Write-Host "using the following commmand:" -ForegroundColor Cyan
    Write-Host "setx NODE_EXTRA_CA_CERTS $caRoot"
    Write-Host
    Write-Host "You will need to restart your terminal or VS Code for it to take effect." -ForegroundColor Cyan
    Write-Host ("#"*75) -ForegroundColor Cyan
}
catch {
    Write-Error "An error occurred while attempting to generate TLS certificate: $_"
}
finally {
    Pop-Location
}

################################
# Generate JSS_EDITING_SECRET
################################
$jssEditingSecret = Get-SitecoreRandomString 64 -DisallowSpecial
Set-EnvFileVariable "JSS_EDITING_SECRET" -Value $jssEditingSecret

###############################
# Populate the environment file
###############################

if ($InitEnv) {
    Write-Host "Populating required .env file values..." -ForegroundColor Green

    # HOST_LICENSE_FOLDER
    Set-DockerComposeEnvFileVariable "HOST_LICENSE_FOLDER" -Value $LicenseXmlPath

	# CD_HOST
	Set-DockerComposeEnvFileVariable "CD_HOST" -Value "cd.lighthouse.localhost"

    # CM_HOST
    Set-DockerComposeEnvFileVariable "CM_HOST" -Value "cm.lighthouse.localhost"

    # ID_HOST
    Set-DockerComposeEnvFileVariable "ID_HOST" -Value "id.lighthouse.localhost"

    # TS_HOST
    Set-DockerComposeEnvFileVariable "TS_HOST" -Value "ts.lighthouse.localhost"

    # RENDERING_HOST
    Set-DockerComposeEnvFileVariable "RENDERING_HOST" -Value "www.lighthouse.localhost"

    # REPORTING_API_KEY = random 64-128 chars
    Set-DockerComposeEnvFileVariable "REPORTING_API_KEY" -Value (Get-SitecoreRandomString 128 -DisallowSpecial)

    # TELERIK_ENCRYPTION_KEY = random 64-128 chars
    # DEMO TEAM CUSTOMIZATION - Add -DisallowSpecial
    Set-DockerComposeEnvFileVariable "TELERIK_ENCRYPTION_KEY" -Value (Get-SitecoreRandomString 128 -DisallowSpecial)

    # SITECORE_IDSECRET = random 64 chars
    Set-DockerComposeEnvFileVariable "SITECORE_IDSECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)

    # SITECORE_ID_CERTIFICATE
    $idCertPassword = Get-SitecoreRandomString 8 -DisallowSpecial
    Set-DockerComposeEnvFileVariable "SITECORE_ID_CERTIFICATE" -Value (Get-SitecoreCertificateAsBase64String -DnsName "localhost" -Password (ConvertTo-SecureString -String $idCertPassword -Force -AsPlainText))

    # SITECORE_ID_CERTIFICATE_PASSWORD
    Set-DockerComposeEnvFileVariable "SITECORE_ID_CERTIFICATE_PASSWORD" -Value $idCertPassword

    # SQL_SA_PASSWORD
    # Need to ensure it meets SQL complexity requirements
    Set-DockerComposeEnvFileVariable "SQL_SA_PASSWORD" -Value (Get-SitecoreRandomString 19 -DisallowSpecial -EnforceComplexity)

    # SITECORE_ADMIN_PASSWORD
    Set-DockerComposeEnvFileVariable "SITECORE_ADMIN_PASSWORD" -Value $AdminPassword

    # SITECORE_SERVICES_TOKEN_SECURITYKEY = random 32 chars
    Set-DockerComposeEnvFileVariable "SITECORE_SERVICES_TOKEN_SECURITYKEY" -Value (Get-SitecoreRandomString 32 -DisallowSpecial)

    # MEDIA_REQUEST_PROTECTION_SHARED_SECRET = random 64 chars
    Set-DockerComposeEnvFileVariable "MEDIA_REQUEST_PROTECTION_SHARED_SECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)

    # SITECORE_CLIENT_SECRET = random 64 chars
    Set-DockerComposeEnvFileVariable "SITECORE_CLIENT_SECRET" -Value (Get-SitecoreRandomString 64 -DisallowSpecial)

    # DEMO TEAM CUSTOMIZATION - Non-interactive CLI login
    $clientSecret = Get-SitecoreRandomString 64 -DisallowSpecial
    Set-EnvFileVariable "ID_SERVER_DEMO_CLIENT_SECRET" -Value $clientSecret
}

Write-Host "Done!" -ForegroundColor Green