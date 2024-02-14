	### PowerShell template profile 
	### Version 1.03 - Tim Sneath <tim@sneath.org>
	### From https://gist.github.com/timsneath/19867b12eee7fd5af2ba
	###
	### This file should be stored in $PROFILE.CurrentUserAllHosts
	### If $PROFILE.CurrentUserAllHosts doesn't exist, you can make one with the following:
	###    PS> New-Item $PROFILE.CurrentUserAllHosts -ItemType File -Force
	### This will create the file and the containing subdirectory if it doesn't already 
	###
	### As a reminder, to enable unsigned script execution of local scripts on client Windows, 
	### you need to run this line (or similar) from an elevated PowerShell prompt:
	   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
	### This is the default policy on Windows Server 2012 R2 and above for server Windows. For 
	### more information about execution policies, run Get-Help about_Execution_Policies.

	#DEFINITIONS
	$branchUserHandle = "gek"
	
	#import own modules
	Import-Module "C:\devPrivate\StenoGit\PSModules\stenogit" -Scope Global

	# Find out if the current user identity is elevated (has admin rights)
	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object Security.Principal.WindowsPrincipal $identity
	$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

	# If so and the current host is a command line, then change to red color 
	# as warning to user that they are operating in an elevated context
	if (($host.Name -match "ConsoleHost") -and ($isAdmin))
	{
		 $host.UI.RawUI.BackgroundColor = "DarkRed"
		 $host.PrivateData.ErrorBackgroundColor = "White"
		 $host.PrivateData.ErrorForegroundColor = "DarkRed"
		 Clear-Host
	}

	Import-Module posh-git
	
	# Useful shortcuts for traversing directories
	function cd...  { cd ..\.. }
	function cd.... { cd ..\..\.. }
	function c { cd c:\ }
	function user { cd $HOME }
	function sbb {cd c:\devsbb\}
	function private {cd c:\devPrivate\}
	function cd~~ {cd $HOME\"OneDrive - SBB\Desktop\"}
	
	#some bashfeeling
	function touch{
		if ($args.Length -lt 1){
		Write-Output "Zu wenig Argumente"
		return
		}
		New-Item -Path $args[0] -ItemType "file" -Force
	}

	# Compute file hashes - useful for checking successful downloads 
	function md5    { Get-FileHash -Algorithm MD5 $args }
	function sha1   { Get-FileHash -Algorithm SHA1 $args }
	function sha256 { Get-FileHash -Algorithm SHA256 $args }

	function www {& start msedge $args}

	function search {
		$searchString = "https://www.google.com/search?q="
		$numOfArgs = $args.Length
		for ($i=0; $i -lt $numOfArgs; $i++)
		{
			$searchString+=$args[$i] +"+"
		}
	& start msedge $searchString
	}

	function confluence{
		$baseUrl = "https://confluence.sbb.ch/"
		
		if ($args.Length -eq 0){
			$subPage = "#recently-viewed"
		}else{
			$subPage = "dosearchsite.action?queryString="
		}
		for ($i=0; $i -lt $args.Length; $i++)
		{
			$subPage+=$args[$i] +"+"
		}

		$url = $baseUrl+$subPage
		& start msedge $url
	}

	
###############################################################GUIProgrammCallers##################################
	#reposwitch
	function rcs1() {
		cd C:\devsbb\repos\rcs
		git branch
	}	
	function rcs2() {
		cd C:\devsbb\repos2\rcs
		git branch
	}	
	function rcs3() {
		cd C:\devsbb\repos3\rcs
		git branch
	}	

function repo() {
		cd C:\devsbb\repos\
	}

	Set-Alias -name 'e1' -value "C:\devsbb\eclipse-paeckli\eclipse.exe"
	Set-Alias -name 'e2' -value "C:\devsbb\eclipse-paeckli 2\eclipse.exe"
	Set-Alias -name 'e3' -value "C:\devsbb\eclipse-paeckli 3\eclipse.exe"

#################################################################Program Shorthands####################################	
	Set-Alias -name 'npp' -value 'C:\Program Files\Notepad++\notepad++.exe'
	Set-Alias -name 'keypass' -value 'keepass'
	Set-Alias -name 'prusa' -value "C:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer.exe"
	Set-Alias -name 'fusion' -value "C:\Users\e554112\AppData\Local\Autodesk\webdeploy\production\6a0c9611291d45bb9226980209917c3d\FusionLauncher.exe"

##################################################################WebCallers#######################################

	function flow{
		$baseUrl = "https://flow.sbb.ch/"
		if ($args.Length -eq 0){	
			$feature = getJiraFeature		
			$subPage = "browse/" + $feature
		}else{
			if ($args.Length -gt 0){
				if ( $args[0] -eq "board"){
					$subPage = "secure/RapidBoard.jspa?rapidView=4131"
				}
				if ( $args[0] -eq "backlog"){
					$subPage = "secure/RapidBoard.jspa?rapidView=4131&view=planning.nodetail&issueLimit=-1"
				}					
			}
		}
		$url = $baseUrl+$subPage
		& start msedge $url
	}

	# RCS only
	function build{
		$rcsBaseUrl = "https://ci-rcs.sbb.ch/job/RCS-Build/job/rcs/job/"	
		$gitbranch = getGitBranch
		$gitbranch = $gitBranch.replace(" ", "%252F")
		$url = $baseUrl+$gitbranch+$compare
		& start msedge $url
	}

	#RCS only
	function deploy{
	$baseUrl = "https://ci-rcs.sbb.ch/job/"
	$subPage = "deploy-environment-express/job/master/build?delay=0sec"
	$gitBranch = getGitBranch
	Set-Clipboard -Value $gitBranch
	if ($args.Length -gt 0){
		if ($args[0] -match "ext.*"){ 
			$subPage = "deploy-environment-extended/job/master/build?delay=0sec"
		}
	}	
	$url = $baseUrl + $subPage
	& start msedge $url
	}

	function code{
		$currentFolder = $pwd.Path.substring($pwd.Path.LastIndexOf("\")+1);

		if ($currentfolder.equals("rcs")){
			$project = "RCS"
			$compare = "&targetBranch=master" 	
		}else{
			$project = "TMS_CAPAOPT"
			$compare = "&targetBranch=develop" 	
		}

		$baseUrl = "https://code.sbb.ch/projects/PT_"+$project+"/repos/"+$currentfolder+"/compare/diff?sourceBranch="

		$gitbranch = getgitBranch
		$url = $baseUrl+$gitbranch+$compare
		& start msedge $url
	}

	function eagle{
		param ([switch]$lts, [switch]$load)
		if ($args.Length -gt 0){
			Write-Output "To many Arguments!"
			return
		}
		if ($load -or $lts){
			if ($lts){
				$eagleDl = "copy_and_run_eagle_lts_64.bat"			
			}else{
				$eagleDl = "copy_and_run_eagle_64.bat"
			}
			$destination = "C:\devSBB\EagleLoader"
			$source = "\\Filer17L\IT170L\project\RCS.A03881\100 Programm\40 Plattform\Eagle"
			if (Test-Path $destination){
				Remove-Item -Recurse -Force $destination
			}			
			mkdir $destination
			Copy-Item -Path $source -Destination $destination  -Recurse 
			& $destination\Eagle\$eagleDl
		}else{
			& $HOME\AppData\Roaming\softbee_64\Eagle\eagle.exe
		}
	}

	function intellij{
		idea64 $pwd.path
	}

	function pr{
		param ([switch]$create)

		$currentFolder = $pwd.Path.substring($pwd.Path.LastIndexOf("\")+1);
		if ($currentfolder.equals("rcs")){
			$project = "RCS"
		}else{
			$project = "TMS_CAPAOPT"
		}

		if ($create || args[0].equals("create")){
			$branch = getGitBranch
			$branch=$branch.replace("/","%2F")	
			$baseUrl = "https://code.sbb.ch/projects/PT_"+$project+"/repos/"+$currentFolder+"/pull-requests?create&sourceBranch=refs%2Fheads%2F"
			$url = $baseUrl+$branch
			& start msedge $url
		}else{
			$baseUrl = "https://code.sbb.ch/"
			$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
			$user = $user.substring($user.IndexOf("\")+1);
			$subPage = "projects/PT_"+$project+"/repos/"+$currentFolder+"/pull-requests?state=OPEN&reviewer="+$user+"#inbox-pull-request-reviewer"
			$url = $baseUrl + $subPage
			& start msedge $url
		}
	}
	
##################################################################GitShortcuts#######################################


# git shortcuts
	#see commits
	function lol() {
		git log --oneline
	}
	
	#status
	function s() {
		git status
	}

	#clean
	function clg() {
		git clean -fd
	}
	
	#add all and show the added files
	function aa() {
		git add --all
		git status
	}

	function stash(){
		git stash $args
	}

	function apply(){
		git stash apply
	}
	
	# amend : amend without changing the commitmessage
	# amend -edit: change then commitmessage 
	function amend() {
		param([switch]$edit)
		if ($edit){
			git commit --verbose --amend --reedit-message=HEAD
		}else{
			git commit --verbose --amend --reuse-message=HEAD
		}
	}

	#push
	function pu() {
		git push
	}
	
	# Push and set upstream to current branch
	function puset() {
		$branch = getGitBranch
		WRITE-OUTPUT "Pushing to" $branch
		git push --set-upstream origin $branch
	}		

	# Force push
	function puf() {
		git push --force
	}

	#rebase on master
	function masterrebase() {
		git fetch origin
		git rebase origin/master
	}


	#rebase on master
	function developrebase() {
		git fetch origin
		git rebase origin/develop
	}

	#checkout
	function co() {
		if ($args.size>0){
			git checkout $args[0]
		}else{
			$branches = git branch
			$selectedBranch = Create-Menu "Select Branch" $branches
			Write-Output $branches[$selectedBranch]
			git checkout $branches[$selectedBranch].substring(2)
		}
	}	

	#checkout from remote
	function coa() {
		if ($args.size>0){
			git checkout $args[0]
		}else{
			$branches = git branch
			$selectedBranch = Create-Menu "Select Branch" $branches
			Write-Output $branches[$selectedBranch]
			git checkout $branches[$selectedBranch].substring(2)
		}
	}

	#checkout new branch
	function cob() {
		$branch = ""
		if ($args.Length -gt 0){
			if (isProgressiv){
				$branch = "feature/"+$branchUserHandle+"/"+$args[0]
			}
			else{
			$branch = "private/wombat/"+$branchUserHandle+"/"+$args[0] 
			}
		}
		git checkout -b $branch
	}	

	#rename branch
	function rename() {
		if ($args.Length -eq 1){
			$branch = "private/wombat/"+$branchUserHandle+"/"+ $args[0];
			git branch -m $branch; 
			}
	}	

	#checkout master and update it
	function master() {
		git checkout master
		git pull
	}	

	#checkout master and update it
	function develop() {
		git checkout develop
		git pull
	}

	#remove current branch and switch to master
	function rmbranch() {
		$branch = getGitBranch
		if ($branch -match "master"){
			Write-Output "Nope. I won't delete master"
		}else{
			if (isProgressiv){
				git checkout develop
			}else{
				git checkout master
			}
			git pull
			git branch -D $branch
		}
	}			

	#remove all changes
	function unstage() {
		git reset HEAD
	}
	
	# cherry-pick
	function pick() {
		git cherry-pick $args[0]
	}

	# show branches 
	function b() {
		git branch
	}

	# show remote branches
	function ba() {
		git branch -a --verbose
	}

	#workflows
#		function upAndAway() {
#			param ([switch]$amend)
#			git add -A
#			if ($args.length -gt 0){		
#				git commit -m $args
#			}
#		
#			if ($amend){
#				git commit --amend
#			}
#			else{
#				commit
#			}
#			if ($amend){
#				git push -f
#			}else{
#				git push
#			}
#			code
#		}
	
# extended git commit with prepared commit-message
		function commit() {
		#prepare the commit-message
			$template = "C:/devsbb/git/.gitmessageTemplate"
			$outfile = "C:/devsbb/git/.gitmessage"
			$currentReviewerFile ="C:/devsbb/git/reviewer"
			$reviewer = Get-Content -Raw $currentReviewerFile
			
			$jira = getJiraFeature
			$title = "$args"

			$message = Get-Content -Raw $template
			
			$message = $message -replace "@JIRA", $jira
			$reviewerLine = "@review: "+$reviewer;
			$message = $message -replace "@REVIEW", $reviewerLine	
			$message = $message -replace "@TITLE", $title

			$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
			[System.IO.File]::WriteAllLines($outfile, $message, $Utf8NoBomEncoding)
		#set out file as template 
			git config --global commit.template $outfile	
		#commit
			git commit
		
		#reads the last commit message and saves the last reviewer for the next message
			$writtenGitMessage = git log -1 --pretty=%B
			[regex]$regex="@review:.*@sbb\.ch"
			$reviewer = $regex.Matches($writtenGitMessage)

			if (-not(([string]::IsNullOrWhiteSpace($reviewer)))) {
				$reviewer = $reviewer.value.replace("@review: ","")
				$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
				[System.IO.File]::WriteAllLines($currentReviewerFile, $reviewer, $Utf8NoBomEncoding)
			}
		}

	function rv() {
		git remote -v
	}

	function pub()  {
		git publish
	}
	# git add
	function a() {
		git add
	}
	function au() {
		git add --update
	}

	function ai() {
		git add --interactive
	}
	function ap() {
		git add --patch
	}
#	function aaa() {
#		git add --all
#		git commit --verbose --amend --reuse-message=HEAD
#	}
#	function aua() {
#		git add --update
#		git commit --verbose --amend --reuse-message=HEAD
#	}
#
#	function cp() {
#		git checkout --patch
#	}
#	function rp() {
#		git reset --patch
#	}
	# git fetch
	function f() {
		git fetch
	}
	# git rebase
	function r() {
		$commitCount = args[0]
		git rebase --interactive HEAD ~$commitCount
	}
	function rc() {
		git rebase --continue
	}
	function ra() {
		git rebase --abort
	}
	# git diff
	function d() {
		git diff
	}
	function p()  {
		git diff --cached
	}
	function dc() {
		git diff --cached
	}
	function wd() {
		git diff --word-diff
	}
	function wdc() {
		git diff --cached --word-diff
	}
	function dt() {
		git difftool
	}
	function dtc() {
		git difftool --cached
	}
	function dtp() {
		git difftool --tool=p4
	}
	function dtcp() {
		git difftool --cached --tool=p4
	}
	function mt() {
		git mergetool
	}
	function mtp() {
		git mergetool --tool=p4
	}
	# git log
	function l1() {
		git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %b %Cgreen(%cd) %C(bold blue)<%an>%Creset" --abbrev-commit
	}
	function l2() {
		git log --pretty=oneline --abbrev-commit --max-count=15 --decorate
	}
	function ll() {
		git log --graph --date-order -C -M --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --date=short
	}
	function lx() {
		git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %Cgreen(%cd) %C(bold blue) %an [%ae]:%Creset %n %s %n %b %n" --abbrev-commit
	}
	function wdw() {
		git log --pretty="format:%an - %s"
	}
	function l() {
		git log --graph --date-order -C -M --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --all --date=short --max-count=15
	}
	function gf() {
		git log -m -S
	}
	function glb() {
		git log
	}
	function glbnm() {
		git log --no-merges
	}

	function mcp() {
		git multi-cherry-pick
	}

	function reword() {
		git commit --amend
	}
	function cleanf() {
		git clean -xdf
	}
	function review-files() {
		git log --name-only --max-count=1
	}
#####################################################################################################################
	# Shows navigable menu of all options when hitting Tab
	Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

	# Autocompletion for arrow keys
	Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
	Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

	# Quick shortcut to start notepad
	function n      { notepad $args }

	# Drive shortcuts
	function HKLM:  { Set-Location HKLM: }
	function HKCU:  { Set-Location HKCU: }
	function Env:   { Set-Location Env: }

	# Creates drive shortcut for Work Folders, if current user account is using it
	if (Test-Path "$env:USERPROFILE\Work Folders")
	{
		New-PSDrive -Name Work -PSProvider FileSystem -Root "$env:USERPROFILE\Work Folders" -Description "Work Folders"
		function Work: { Set-Location Work: }
	}

	# Creates drive shortcut for OneDrive, if current user account is using it
	if (Test-Path HKCU:\SOFTWARE\Microsoft\OneDrive)
	{
		$onedrive = Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\OneDrive
		if (Test-Path $onedrive.UserFolder)
		{
			New-PSDrive -Name OneDrive -PSProvider FileSystem -Root $onedrive.UserFolder -Description "OneDrive"
			function OneDrive: { Set-Location OneDrive: }
		}
		Remove-Variable onedrive
	}

	# Set up command prompt and window title. Use UNIX-style convention for identifying 
	# whether user is elevated (root) or not. Window title shows current version of PowerShell
	# and appends [ADMIN] if appropriate for easy taskbar identification
	function prompt 
	{ 
		if ($isAdmin) 
		{
			"[" + (Get-Location) + "] # " 
		}
		else 
		{
			"[" + (Get-Location) + "] $ "
		}
	}

	$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
	if ($isAdmin)
	{
		$Host.UI.RawUI.WindowTitle += " [ADMIN]"
	}

	# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
	function dirs
	{
		if ($args.Count -gt 0)
		{
			Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
		}
		else
		{
			Get-ChildItem -Recurse | Foreach-Object FullName
		}
	}

	# Simple function to start a new elevated process. If arguments are supplied then 
	# a single command is started with admin rights; if not then a new admin instance
	# of PowerShell is started.
	function sudo
	{
		if ($args.Count -gt 0)
		{   
		   $argList = "& '" + $args + "'"
		   Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
		}
		else
		{
		   Start-Process "$psHome\powershell.exe" -Verb runAs
		}
	}

	# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
	# with elevated rights. 
	Set-Alias -Name su -Value admin
	Set-Alias -Name sudo -Value admin


	# Make it easy to edit this profile once it's installed
	function settings
	{
		if ($host.Name -match "ise")
		{
			$psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
		}
		else
		{
			vscode -r $profile.CurrentUserAllHosts
		}
	}

	function db
	{
	sqldeveloper.exe
	}

	#VSCode normally uses "code" as its command-line call. We use this to access the sbb bitbucket, so we change it to vscode. 
	#Make shure to remove vscode from the path to avoid conflicts
	Set-Alias -name 'vscode' -value 'C:\Users\e554112\AppData\Local\Programs\Microsoft VS Code\Code.exe'
	
	# We don't need these any more; they were just temporary variables to get to $isAdmin. 
	# Delete them to prevent cluttering up the user profile. 
	Remove-Variable identity
	Remove-Variable principal

	oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\aliens.omp.json" | Invoke-Expression

	Set-Location C:\devsbb\repos\rcs

	#A script for doing Arc-Overhangs on already calculated Gcode
	function arcOverhangs{
	$fileList = Get-ChildItem -Path $pwd.path -Name -Include *.gcode
	$selected = Create-Menu "Please select file" $fileList
	python3 "C:\Program Files\Prusa3D\postprocess\arcOverhangs.py" $fileList[$selected] 
	}

	#A simple todo-List
	function todo{
			$path = 'C:\devPrivate\TodoList\todo\'

		if ($args -contains "add"){
			$title = Read-Host "Title"
			$bullets = @()
			$dateNow = Get-Date -Format "dd/MM/yy"
			
			$bullet =""
			while (-not($bullet  -eq "x"))			{
				$bullet = Read-Host "Task (x to end)"
				if (-not($bullet -eq "x")){
					$bullets+=$bullet
				}
			}
			$days = Read-Host "Days to do it"
			if (-not($days -match "\d*")){
				Write-Output "Days musst be positiv int. Setting days to 0..."
				days = 0
			}
			$futureDate = (Get-Date).AddDays($days) 
			$dateDue = Get-Date -Date $futureDate -Format "dd/MM/yy"
			$outString = "`r`n" + "## "+$title  + "`r`n"
			if ($bullets.length -gt 0){
				$outString += "|          |          |" + "`r`n"
				$outString += "|----------|----------|" + "`r`n"
				$outString += "|    ##########       |                            |  ##########    |" + "`r`n"
			}
			foreach ($b in $bullets){
				$outString += "|    **********____    |    [ ] " + $b +"    |    ____**********    |"  + "`r`n"
			}
			if ($bullets.length -gt 0){
				$outString += "|    ##########       |                            |  ##########    |" + "`r`n"
			}
			$outString += "### Faellig" + "`r`n"
			$outString += $dateDue + "`r`n"
			$outString += "### Erstellt" + "`r`n"
			$outString += $dateNow + "`r`n"
			$outString|Out-File -FilePath $path.replace("*","AA_todo.md") -Append -encoding ascii
		}else{
			 & vscode -r $path
		}
	}

	#function gitstatus {& git status $args}
	#Set-Alias -name 'status' -value 'gitstatus'

	#function gitcommit {& git commit $args}
	#Set-Alias -name 'commit' -value 'gitcommit'

	#function gitpush{& git push $args}
	#Set-Alias -name 'push' -value 'gitpush'

	#function gitrebase {& git rebase $args}
	#Set-Alias -name 'rebase' -value 'gitrebase'

	#function gitbranch {& git branch $args}
	#Set-Alias -name 'branch' -value 'gitbranch'

	#function gitcheckout {& git checkout $args}
	#Set-Alias -name 'checkout' -value 'gitcheckout'

	#function gitcheckout {& git checkout $args}
	#Set-Alias -name 'co' -value 'gitcheckout'

function doc
{
Write-Output "db              			... starts sqlDeveloper"
Write-Output "settings        			... edit the Powershell-Profile"
Write-Output "sudo [command]  			... starts the powershell or a selected comand with elevated rights"
Write-Output "dirs            			... shows all subdirs"
Write-Output "npp             			... starts notepad++"
Write-Output "eagle [(-lts) -(load)] 	... start eagle [-load: download the latest version of eagle before starting it | -lts: download the lts version of eagle before starting it]"
Write-Output "code 					 	... open bitbucket with the current branch"
Write-Output "flow [(board) (backlog)]	... open jira with the current story (defined by the current branch) calling board will open the current sprint, backlog opens the backlog"
Write-Output "deploy [(ext)] 			... opens jenkins (express or extended rcs-job) and copys the current branch to the clipboard"
Write-Output "pr 						... show my open pull requests"
}

	# Creates Menues that are selectable via the arrow-keys
	Function Create-Menu (){
	    Param(
    	    [Parameter(Mandatory=$True)][String]$MenuTitle,
        	[Parameter(Mandatory=$True)][array]$MenuOptions
    	)

	    $MaxValue = $MenuOptions.count-1
    	$Selection = 0
    	$EnterPressed = $False
    
	    Clear-Host

    	While($EnterPressed -eq $False){
     	   Write-Host "$MenuTitle"
        	For ($i=0; $i -le $MaxValue; $i++){
	            If ($i -eq $Selection){
    	            Write-Host -BackgroundColor Cyan -ForegroundColor Black "[ $($MenuOptions[$i]) ]"
        	    } Else {
            	    Write-Host "  $($MenuOptions[$i])  "
           	 }
	        }
	        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode	
	        Switch($KeyInput){
    	        13{
        	        $EnterPressed = $True
            	    Return $Selection
                	Clear-Host
                	break
            	}
	            38{
    	            If ($Selection -eq 0){
        	            $Selection = $MaxValue
            	    } Else {
                	    $Selection -= 1
                	}
                	Clear-Host
                	break
            	}
				40{
                	If ($Selection -eq $MaxValue){
                    	$Selection = 0
                	} Else {
                    	$Selection +=1
                	}
                	Clear-Host
                	break
            	}
            	Default{
                	Clear-Host
            	}
        	}
    	}
	}

function isProgressiv(){
	$branches = git branch
	return $branches -contains "  develop" -or $branches -contains "* develop"
}

function getGitBranch(){
	return  &git rev-parse --abbrev-ref HEAD 
}
function getJiraFeature(){
	$gitbranch = getGitBranch
	[regex]$regex="RCSPF-\d*"
	$jira = $regex.Matches($gitbranch)
	return $jira.value
}