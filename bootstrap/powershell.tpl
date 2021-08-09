<powershell>
if ("${name}" -Match "_") {
    $nn="${name}".replace("_","-")
} else {
    $nn="${name}"
}
Rename-Computer -NewName $nn -Force
"
grains:
  owner: CTUIR
  roles:
    - infantry
" | Out-File -FilePath c:\minion_conf -Encoding ASCII

$src = 'http://repo.saltstack.com/windows/Salt-Minion-3002.6-Py3-AMD64-Setup.exe'
$dst = 'c:\salt_install.exe'
Invoke-WebRequest -Uri $src -OutFile $dst

do {
    sleep 5
} until(Test-NetConnection ${addr} -Port 4506 | ? { $_.TcpTestSucceeded })

Start-Process -FilePath "c:\salt_install.exe" -ArgumentList "/S /master=${addr} /minion-name=${name} /custom-config=c:\minion_conf"
</powershell>
