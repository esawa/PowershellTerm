<#
    This script terminates a user account. The following details the current progress on the script:
    AD
    [x] Reads input for user to be termed. During testing, this is disabled as a test user is being used
    [x] Disables the user account
    [x] Resets password
    [x] Fills in AD description (currently replaces what already exists rather than appending)
    [] Clear Manager
    [] Clear Direct Reports (not sure if this is possible)

    Exchange
    [] Hide from address list
    [] Give full access to their manager
    [] Convert to shared mailbox
    [] Set away message

    AD (again)
    [] Remove them from all security and distribution lists (this may require a pause in the script)

    H-drive (not sure if this will be possible)
    [] Move into disabled user folder
    [] Grant manager access
    [] Create shortcut in manager's H-drive

#>
#Prompt for script user's initials
$Initials = Read-Host -Prompt 'Enter YOUR Initials'
#Prompt for termed user's username
#$TermedUser = Read-Host -Prompt 'Enter Termed Username'

#TEMPORARY: Use Tuser as a placeholder while testing
$TermedUser = 'tuser'

#create a variable 
$UserADAccount = Get-ADUser -Filter {SamAccountName -eq $TermedUser}

#check if user account is null. If so, break. Otherwise, display user account info
if ($UserADAccount -eq $null){
    Write-Host 'User account does not exist. Termination has been cancelled' -ForegroundColor Red
    break
}
else {
    $UserADAccount
}

#Prompt for confirmation before proceeding with term
$Confirm = Read-Host -Prompt 'The above user account will be terminated. Please confirm (y/n)' 

#check user input above. If y, begin term process. Otherwise, break
if ($Confirm -eq 'y'){
    Write-Host 'Termination process has begun. Please wait...' -ForegroundColor Green
}
else {
    Write-Host 'Termination has been cancelled' -ForegroundColor Red
    break
}

#TEMPORARY: Remove when script is usable
Write-Host 'This is a placeholder for remaining script. A test user is currently being used for remaining of code'

#Disables the user's account
Set-ADUser $TermedUser -Enabled 0

#Generates a random 9 character password
$Password = ([char[]](([char]33..[char]95) + ([char]97..[char]126)) | Sort-Object {Get-Random})[0..8] -join ''
#$Password

#Changes the user's password to the above randomly generated one
Set-ADAccountPassword $TermedUser.DistinguishedName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

#Gets today's date
$Date = Get-Date -UFormat "%m/%d/%Y"
#$Date

#Sets the description of the AD object
#Currently replaces all description text
Set-ADUser $TermedUser -Description "Disabled $Date by $Initials"