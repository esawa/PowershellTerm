<#
    This script terminates a user account. The following details the current progress on the script:
    AD
    [x] Reads input for user to be termed. During testing, this is disabled as a test user is being used
    [x] Disables the user account
    [x] Resets password
    [x] Fills in AD description
    [x] Clear Manager
    [x] Clear Direct Reports

    Exchange
    [] Hide from address list (on prem)
    [] Give full access to their manager
    [] Set away message
    [] Convert to shared mailbox

    AD (again. Both of these steps need to be completed after the mailbox has finished converting to a shared mailbox. Probably need to put a pause in)
    [] Remove them from all security and distribution lists
    [] Move into termed 60 days OU

    H-drive (not sure if this will be possible)
    [] Move into disabled user folder
    [] Grant manager access
    [] Create shortcut in manager's H-drive

#>

<#

    This section involves reading in put from the user and storing that data in a variable. 
    It also creates an AD user object and does some checks before moving on with the script.

#>
#Prompt for script user's initials
$Initials = Read-Host -Prompt 'Enter YOUR Initials'
#Prompt for termed user's username
#$TermedUser = Read-Host -Prompt 'Enter Termed Username'
#Prompt for termed user's manager's username
$Manager = Read-Host -Prompt 'Enter Manager Username'

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

<#

    This section does most of the AD term tasks

#>

#TEMPORARY: Remove when script is usable
Write-Host 'This is a placeholder for remaining script. A test user is currently being used for remaining of code'

#Disables the user's account
Set-ADUser $TermedUser -Enabled 0

#Generates a random 9 character password
$Password = ([char[]](([char]33..[char]95) + ([char]97..[char]126)) | Sort-Object {Get-Random})[0..8] -join ''
#$Password

#Changes the user's password to the above randomly generated one
Set-ADAccountPassword $UserADAccount.DistinguishedName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

#Gets today's date
$Date = Get-Date -UFormat "%m/%d/%Y"
#$Date

#Sets the description of the AD object
Set-ADUser $TermedUser -Description "Disabled $Date by $Initials" 

#Clears user's manager field
Set-ADUser $TermedUser -Manager $null

#Clears user's direct reports
$DirectReports = Get-ADUser -Filter {SamAccountName -eq $TermedUser} -Properties directreports | Select-Object -ExpandProperty DirectReports

#iterates through all the termed user's direct reports and clears their manager
foreach ($user in $DirectReports) {
    Set-ADUser $user -Manager $null 
}

<#

    This section does the exchange term tasks

#>

#Making Changes in Exchange requires you to created a PSSession
#Prompts the user to enter credentials
$UserCredential = Get-Credential
#Creates the session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Imports all commands
Import-PSSession $Session -DisableNameChecking

Add-MailboxPermission -Identity $TermedUser -User $Manager -AccessRights FullAccess -InheritanceType All

#Ends the above PSSession
Remove-PSSession $Session