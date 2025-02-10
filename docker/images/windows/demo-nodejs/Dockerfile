# escape=`

#
# Basic Windows node.js image for use as a parent image in the solution.
#

ARG PARENT_IMAGE
FROM $PARENT_IMAGE

ARG NODEJS_VERSION

USER ContainerAdministrator

# Download and extract Node.js
RUN powershell -Command `
    Invoke-WebRequest -Uri https://nodejs.org/dist/v%NODEJS_VERSION%/node-v%NODEJS_VERSION%-win-x64.zip -OutFile node.zip ; `
    Expand-Archive node.zip -DestinationPath "C:\\nodejs" ; `
    Remove-Item node.zip -Force

# Set environment variables
# Modify PATH dynamically in PowerShell
RUN powershell -Command [System.Environment]::SetEnvironmentVariable('PATH', $('C:\nodejs\node-v' + $env:NODEJS_VERSION + '-win-x64;C:\nodejs\node-v' + $env:NODEJS_VERSION + '-win-x64\bin;' + $env:PATH), [System.EnvironmentVariableTarget]::Machine)

RUN icacls.exe C:\nodejs\ /grant "Authenticated Users":(F) /t
USER ContainerUser