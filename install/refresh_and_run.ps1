# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')

# Pause for another 5 seconds
Start-Sleep -Seconds 1

# Run windows-install.bat
Start-Process -FilePath 'cmd.exe' -ArgumentList '/k windows-install.bat' -WorkingDirectory $PWD