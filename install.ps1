Remove-Item  $env:APPDATA\wsltty -Force -Recurse -ErrorAction Ignore
New-Item -Path $env:APPDATA\wsltty  -ItemType Junction -Value .\wsltty

Remove-Item  $HOME\.ssh\config -ErrorAction Ignore
New-Item -Path $HOME\.ssh\config  -ItemType HardLink -Value .\ssh\config

Remove-Item  $HOME\.ssh\authorized_keys -ErrorAction Ignore
New-Item -Path $HOME\.ssh\authorized_keys  -ItemType HardLink -Value .\ssh\authorized_keys

Remove-Item  $HOME\.config\wezterm -ErrorAction Ignore -recurse
New-Item -Path $HOME\.config\wezterm  -ItemType Junction -Value .\config\wezterm