Import-Module ActiveDirectory

$InactiveThresholdDays = 90
$ThresholdDate = (Get-Date).AddDays(-$InactiveThresholdDays)

Write-Host "Checking users inactive for more than $InactiveThresholdDays days..." -ForegroundColor Cyan
Write-Host "Threshold Date: $ThresholdDate"
Write-Host ""

$Users = Get-ADUser -Filter * -Properties LastLogonDate, Enabled | Where-Object {
    $_.Enabled -eq $true
}

$Results = foreach ($User in $Users) {

    $LastLogon = $User.LastLogonDate

    if ($null -eq $LastLogon) {
        $Status = "Never Logged In"
    }
    elseif ($LastLogon -lt $ThresholdDate) {
        $Status = "INACTIVE (90+ days)"
    }
    else {
        $Status = "ACTIVE"
    }

    [PSCustomObject]@{
        UserName      = $User.SamAccountName
        LastLogon     = $LastLogon
        Status        = $Status
        InactiveDays  = if ($LastLogon) {(New-TimeSpan -Start $LastLogon -End (Get-Date)).Days} else {"N/A"}
    }
}

$Results | Sort-Object LastLogon | Format-Table -AutoSize