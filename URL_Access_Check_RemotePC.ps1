$timeout = 10
$resultPath = .\result.csv
$servers = @(
#('<SERVER NAME>','<USER NAME>','<Password>'),
)

$urls = @(
'https://google.com',
'http://yahoo.com'
)

$Hash_array = [ordered]@{Urls = [System.Collections.ArrayList]$urls}

foreach ($server in $servers) {
    $pw = convertto-securestring -AsPlainText -Force -String $server[2]
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $server[1],$pw
    try{
        $session = new-pssession -computername $server[0] -credential $cred
    }catch{
        echo "VM connect error"
    }
    $url_arr = [System.Collections.ArrayList]@()
    foreach ($url in $urls){
        if($session){
            $status = 0
            try{
                $status = (Invoke-WebRequest -Uri $url -TimeoutSec $timeout).statuscode
            }catch{
            }
if($status -eq 200){
$url_arr.Add("Working")
            }
            else{
$url_arr.Add("Not Working("+$status+")")
            }
        }else{
            $url_arr.Add('VM connect error')
        }
    }
    if($session){
        Remove-PSSession $session
    }
    $Hash_array.Add($server[0] , $url_arr)
}
$op =@()
for($i=0; $i -le $urls.Count; $i++){
    $custObj = [pscustomobject]@{}
    foreach($item in $Hash_array.GetEnumerator() ){
          Add-Member -InputObject $custObj -MemberType NoteProperty -Name $item.Key -Value $item.Value[$i]
    }
    $op+=($custObj)
}
$op | Export-Csv -Path $resultPath -NoTypeInformation