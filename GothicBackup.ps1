# Gothic 1 Remake - Permadeath Backup Manager
# Path is stored in the scheduled task description
# Worker/VBS files are stored in LocalAppData (not TEMP)

$TaskName      = "Gothic_Permadeath_Backup"
$DefaultBackup = "$env:USERPROFILE\Documents\Gothic_Permadeath_Backups"
$Source        = "$env:LOCALAPPDATA\G1R\Saved\SaveGames"
$MaxBackups    = 30
$AppDataDir    = "$env:LOCALAPPDATA\GothicBackup"

function Pause-Script {
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Get-SavedBackupPath {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $task -and -not [string]::IsNullOrWhiteSpace($task.Description)) {
        if ($task.Description -match 'BackupPath=(.+)') {
            $path = $Matches[1].Trim()
            if (-not [string]::IsNullOrWhiteSpace($path)) {
                return $path
            }
        }
    }
    return $DefaultBackup
}

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Gothic 1 Remake - Backup Manager" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Start backups (every 5 minutes)"
    Write-Host "2. Stop backups"
    Write-Host "3. Restore a backup"
    Write-Host "4. Choose backup folder"
    Write-Host "5. Open game save folder"
    Write-Host "6. Check status"
    Write-Host "7. Exit"
    Write-Host ""
    Write-Host "Current backup folder:" -ForegroundColor DarkGray
    Write-Host $BackupPath -ForegroundColor Yellow
    Write-Host ""
}

function Test-GameRunning {
    $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -like "*Gothic*" -or
        $_.ProcessName -like "*G1R*"
    }
    return $null -ne $processes
}

function Start-Backup {
    param([string]$BackupPath)

    if (-not (Test-Path $BackupPath)) {
        try {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        }
        catch {
            Write-Host "Failed to create backup folder: $_" -ForegroundColor Red
            Pause-Script
            return
        }
    }

    $MilestonesPath = Join-Path $BackupPath "Milestones"
    if (-not (Test-Path $MilestonesPath)) {
        New-Item -ItemType Directory -Path $MilestonesPath -Force | Out-Null
    }

    if (-not (Test-Path $AppDataDir)) {
        try {
            New-Item -ItemType Directory -Path $AppDataDir -Force | Out-Null
        }
        catch {
            Write-Host "Failed to create folder $AppDataDir : $_" -ForegroundColor Red
            Pause-Script
            return
        }
    }

    $SafeSource     = $Source -replace "'", "''"
    $SafeBackupPath = $BackupPath -replace "'", "''"
    $SafeMilestones = $MilestonesPath -replace "'", "''"

    $WorkerPath = Join-Path $AppDataDir "GothicBackup_Worker.ps1"
    $VbsPath    = Join-Path $AppDataDir "GothicBackup_Launcher.vbs"

    $WorkerContent = @"
`$Source      = '$SafeSource'
`$BackupRoot  = '$SafeBackupPath'
`$Milestones  = '$SafeMilestones'
`$MaxBackups  = $MaxBackups
`$CounterFile = Join-Path `$BackupRoot 'backup_counter.txt'

`$running = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    `$_.ProcessName -like '*Gothic*' -or
    `$_.ProcessName -like '*G1R*'
}
if (-not `$running) { exit }

if (-not (Test-Path `$Source)) { exit }

`$Timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
`$Dest = Join-Path `$BackupRoot ("Backup_" + `$Timestamp)

try {
    New-Item -ItemType Directory -Path `$Dest -Force | Out-Null
    Copy-Item -Path (`$Source + '\*') -Destination `$Dest -Recurse -Force -ErrorAction Stop
}
catch {
    exit
}

`$counter = 0
if (Test-Path `$CounterFile) {
    `$raw = Get-Content `$CounterFile -ErrorAction SilentlyContinue
    if (`$raw -match '^\d+$') { `$counter = [int]`$raw }
}
`$counter++
`$counter | Out-File -FilePath `$CounterFile -Encoding utf8 -Force

if (`$counter % `$MaxBackups -eq 0) {
    `$milestoneName = "Milestone_" + `$Timestamp + "_#" + `$counter
    `$milestoneDest = Join-Path `$Milestones `$milestoneName
    try {
        New-Item -ItemType Directory -Path `$milestoneDest -Force | Out-Null
        Copy-Item -Path (`$Dest + '\*') -Destination `$milestoneDest -Recurse -Force -ErrorAction Stop
    }
    catch { }
}

`$allBackups = Get-ChildItem -Path `$BackupRoot -Directory -ErrorAction SilentlyContinue |
               Where-Object { `$_.Name -like 'Backup_*' } |
               Sort-Object LastWriteTime -Descending

if (`$allBackups.Count -gt `$MaxBackups) {
    `$toDelete = `$allBackups | Select-Object -Skip `$MaxBackups
    foreach (`$old in `$toDelete) {
        Remove-Item -Path `$old.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}
"@

    try {
        $WorkerContent | Out-File -FilePath $WorkerPath -Encoding utf8 -Force
    }
    catch {
        Write-Host "Failed to create worker script: $_" -ForegroundColor Red
        Pause-Script
        return
    }

    $VbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$WorkerPath""", 0, False
"@

    try {
        $VbsContent | Out-File -FilePath $VbsPath -Encoding ascii -Force
    }
    catch {
        Write-Host "Failed to create VBS launcher: $_" -ForegroundColor Red
        Pause-Script
        return
    }

    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

    try {
        $Action = New-ScheduledTaskAction -Execute "wscript.exe" `
            -Argument "//B //Nologo `"$VbsPath`""

        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
            -RepetitionInterval (New-TimeSpan -Minutes 5) `
            -RepetitionDuration (New-TimeSpan -Days 9999)

        $Settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -Hidden `
            -ExecutionTimeLimit (New-TimeSpan -Minutes 2)

        $Description = "BackupPath=$BackupPath"

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger `
            -Settings $Settings -Description $Description -Force | Out-Null

        if (-not $?) {
            throw "Failed to register scheduled task"
        }

        Write-Host ""
        Write-Host "Backups started successfully!" -ForegroundColor Green
        Write-Host "Folder: $BackupPath" -ForegroundColor Yellow
        Write-Host "Interval: every 5 minutes" -ForegroundColor Yellow
        Write-Host "Keeps the last $MaxBackups regular backups." -ForegroundColor Yellow
        Write-Host "Every 30th backup is also saved to the Milestones folder." -ForegroundColor Yellow
        Write-Host "Backups are created only while the game is running." -ForegroundColor Yellow
        Write-Host "Runs fully hidden (no window flicker)." -ForegroundColor Green
        Write-Host ""
        Write-Host "Helper files: $AppDataDir" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Note: antivirus may warn about the hidden scheduled task. This is normal." -ForegroundColor DarkYellow
    }
    catch {
        Write-Host ""
        Write-Host "Error creating scheduled task:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible causes: limited account permissions or antivirus blocking." -ForegroundColor Yellow
    }

    Pause-Script
}

function Stop-Backup {
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Host ""
        Write-Host "Backups stopped." -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "Task not found or already stopped." -ForegroundColor Yellow
    }
    Pause-Script
}

function Restore-Backup {
    param([string]$BackupPath)

    if (Test-GameRunning) {
        Write-Host ""
        Write-Host "Close the game first!" -ForegroundColor Red
        Write-Host "Restoring while the game is running can corrupt saves." -ForegroundColor Yellow
        Pause-Script
        return
    }

    if (-not (Test-Path $BackupPath)) {
        Write-Host "Backup folder not found:" -ForegroundColor Red
        Write-Host $BackupPath -ForegroundColor Yellow
        Pause-Script
        return
    }

    $regular = Get-ChildItem -Path $BackupPath -Directory -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -like 'Backup_*' } |
               Sort-Object LastWriteTime -Descending

    $milestonesPath = Join-Path $BackupPath "Milestones"
    $milestones = @()
    if (Test-Path $milestonesPath) {
        $milestones = Get-ChildItem -Path $milestonesPath -Directory -ErrorAction SilentlyContinue |
                      Where-Object { $_.Name -like 'Milestone_*' } |
                      Sort-Object LastWriteTime -Descending
    }

    $all = @()
    if ($regular)    { $all += $regular }
    if ($milestones) { $all += $milestones }

    if ($all.Count -eq 0) {
        Write-Host "No backups found in:" -ForegroundColor Yellow
        Write-Host $BackupPath -ForegroundColor Yellow
        Pause-Script
        return
    }

    $all = $all | Sort-Object LastWriteTime -Descending

    Clear-Host
    Write-Host "Backup list (newest first):" -ForegroundColor Cyan
    Write-Host "(Backup_... = regular, Milestone_... = every 30th backup)" -ForegroundColor DarkGray
    Write-Host ""

    for ($i = 0; $i -lt $all.Count; $i++) {
        $item = $all[$i]
        $prefix = if ($item.Name -like 'Milestone_*') { "[M] " } else { "    " }
        Write-Host ("{0,3}. {1}{2}   [{3}]" -f ($i + 1), $prefix, $item.Name, $item.LastWriteTime)
    }

    Write-Host ""
    Write-Host "  0. Cancel"
    Write-Host ""

    $choice = Read-Host "Select backup number"

    if ($choice -eq "0" -or [string]::IsNullOrWhiteSpace($choice)) {
        return
    }

    $index = 0
    if (-not [int]::TryParse($choice, [ref]$index)) {
        Write-Host "Invalid input." -ForegroundColor Red
        Pause-Script
        return
    }

    $index = $index - 1
    if ($index -lt 0 -or $index -ge $all.Count) {
        Write-Host "Invalid number." -ForegroundColor Red
        Pause-Script
        return
    }

    $selected = $all[$index].FullName

    Write-Host ""
    Write-Host "WARNING! Current game saves will be replaced." -ForegroundColor Red
    Write-Host "Current save folder will be renamed to SaveGames_old_... as a safety copy." -ForegroundColor Yellow

    $confirm = Read-Host "Continue? (yes / no)"
    if ($confirm -notin @("yes", "Yes", "YES", "y", "Y")) {
        Write-Host "Cancelled."
        Pause-Script
        return
    }

    if (Test-GameRunning) {
        Write-Host ""
        Write-Host "The game was started during confirmation!" -ForegroundColor Red
        Write-Host "Restore cancelled. Close the game and try again." -ForegroundColor Yellow
        Pause-Script
        return
    }

    try {
        $oldName = "SaveGames_old_" + (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')

        if (Test-Path $Source) {
            Rename-Item -Path $Source -NewName $oldName -ErrorAction Stop
        }

        New-Item -ItemType Directory -Path $Source -Force | Out-Null
        Copy-Item -Path (Join-Path $selected "*") -Destination $Source -Recurse -Force -ErrorAction Stop

        Write-Host ""
        Write-Host "Backup restored successfully!" -ForegroundColor Green
        Write-Host "Old saves kept as: $oldName" -ForegroundColor DarkGray
        Write-Host "Now start the game and load the latest save." -ForegroundColor Yellow
    }
    catch {
        Write-Host ""
        Write-Host "Restore failed:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }

    Pause-Script
}

function Open-SaveFolder {
    if (-not (Test-Path $Source)) {
        Write-Host ""
        Write-Host "Save folder does not exist yet:" -ForegroundColor Yellow
        Write-Host $Source -ForegroundColor Yellow
        Write-Host ""
        Write-Host "It will appear after the first save in the game." -ForegroundColor DarkYellow
        Pause-Script
        return
    }

    try {
        Start-Process "explorer.exe" -ArgumentList $Source
        Write-Host ""
        Write-Host "Save folder opened." -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "Failed to open folder: $_" -ForegroundColor Red
    }

    Pause-Script
}

function Check-Status {
    param([string]$BackupPath)

    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    Write-Host ""
    if ($null -eq $task) {
        Write-Host "Status: backups are NOT running" -ForegroundColor Yellow
    }
    else {
        $info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
        Write-Host "Status: backups are RUNNING" -ForegroundColor Green
        Write-Host "Task state: $($task.State)" -ForegroundColor Cyan
        if ($info) {
            Write-Host "Last run: $($info.LastRunTime)" -ForegroundColor DarkGray
            Write-Host "Next run: $($info.NextRunTime)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "Backup folder: $BackupPath" -ForegroundColor DarkCyan

    if (Test-Path $BackupPath) {
        $count = (Get-ChildItem -Path $BackupPath -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -like 'Backup_*' }).Count
        Write-Host "Regular backups: $count / $MaxBackups" -ForegroundColor DarkCyan

        $milestonesPath = Join-Path $BackupPath "Milestones"
        if (Test-Path $milestonesPath) {
            $mCount = (Get-ChildItem -Path $milestonesPath -Directory -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -like 'Milestone_*' }).Count
            Write-Host "Milestones (every 30th): $mCount" -ForegroundColor DarkCyan
        }

        $counterFile = Join-Path $BackupPath "backup_counter.txt"
        if (Test-Path $counterFile) {
            $c = Get-Content $counterFile -ErrorAction SilentlyContinue
            Write-Host "Total successful backups (counter): $c" -ForegroundColor DarkCyan
        }
    }
    else {
        Write-Host "Folder does not exist yet." -ForegroundColor Yellow
    }

    Pause-Script
}

# ====================== Main loop ======================
$BackupPath = Get-SavedBackupPath

while ($true) {
    Show-Menu
    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" { Start-Backup -BackupPath $BackupPath }
        "2" { Stop-Backup }
        "3" { Restore-Backup -BackupPath $BackupPath }
        "4" {
            Write-Host ""
            Write-Host "Current folder: $BackupPath" -ForegroundColor Yellow
            $newPath = Read-Host "Enter new path (Enter = keep current)"
            if (-not [string]::IsNullOrWhiteSpace($newPath)) {
                $BackupPath = $newPath.Trim()
                Write-Host "Folder changed to: $BackupPath" -ForegroundColor Green
                Write-Host ""
                Write-Host "Important: to start writing backups to the new folder," -ForegroundColor Yellow
                Write-Host "run option 1 again." -ForegroundColor Yellow
            }
            Pause-Script
        }
        "5" { Open-SaveFolder }
        "6" { Check-Status -BackupPath $BackupPath }
        "7" { exit }
        default {
            Write-Host "Invalid choice" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
