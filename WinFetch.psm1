function WinFetch {
    
    param(
        [Parameter()]
        [ValidateSet('11','11ClassicColor','XP')]
        [string]$ArtStyle
    )

    $Win32Info = Get-CimInstance Win32_OperatingSystem

#    . .\$PSScriptRoot\Ascii.ps1

    #region Format data

    $Uptime = (([DateTime]$Win32Info.LocalDateTime) - ([datetime]$Win32Info.LastBootUpTime));
    $UptimeFormat = $Uptime.Days.ToString() + ' Days ' + $Uptime.Hours.ToString() + ' Hours ' + $Uptime.Minutes.ToString() + ' Minutes ' + $Uptime.Seconds.ToString() + ' Seconds '

    $Mobo = Get-CimInstance Win32_BaseBoard
    $MoboFormat = $Mobo.Manufacturer + " " + $Mobo.Product

    if ($PSVersionTable.PSVersion -gt '5.1') {
        $Shell = "Microsoft PowerShell $($PSVersionTable.PSVersion.ToString())"
    } elseif ($PSVersionTable.PSVersion -le '5.1') {
        $Shell = "Microsoft Windows PowerShell $($PSVersionTable.PSVersion.ToString())"
    }

    $VideoController = Get-CimInstance Win32_VideoController
    $Resolution = $VideoController.CurrentHorizontalResolution.ToString() + " x " + $VideoController.CurrentVerticalResolution.ToString() + " (" + $VideoController.CurrentRefreshRate.ToString() + "Hz)"

    $AvailableRAM = ([math]::Truncate($Win32Info.FreePhysicalMemory/ 1KB))
    $TotalRAM = ([math]::Truncate((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB))
    $UsedRAM = $TotalRAM -$AvailableRAM
    $AvailableRAMPercent = ($AvailableRAM / $TotalRAM) * 100
    $AvailableRAMPercent = "{0:N0}" -f $AvailableRAMPercent
    $UsedRamPercent = ($UsedRam / $TotalRAM) * 100
    $UsedRamPercent = "{0:N0}" -f $UsedRamPercent

    $RAM = $UsedRAM.ToString() + "MB / " + $TotalRAM.ToString() + " MB " + "(" + $UsedRamPercent.ToString() + "%" + ")"

    $LogicalDisk = Get-CimInstance Win32_LogicalDisk
    $FormattedDisks = New-Object System.Collections.Generic.List[System.Object];

    $NumDisks = $LogicalDisk.Count;

    if ($NumDisks) {
        for ($i=0; $i -lt ($NumDisks); $i++) {
            $DiskID = $LogicalDisk[$i].DeviceId;

            $DiskSize = $LogicalDisk[$i].Size;

            if ($DiskSize -gt 0) {
                $FreeDiskSize = $LogicalDisk[$i].FreeSpace
                $FreeDiskSizeGB = $FreeDiskSize / 1073741824;
                $FreeDiskSizeGB = "{0:N0}" -f $FreeDiskSizeGB;

                $DiskSizeGB = $DiskSize / 1073741824;
                $DiskSizeGB = "{0:N0}" -f $DiskSizeGB;

                if ($DiskSizeGB -gt 0 -And $FreeDiskSizeGB -gt 0) {
                    $FreeDiskPercent = ($FreeDiskSizeGB / $DiskSizeGB) * 100;
                    $FreeDiskPercent = "{0:N0}" -f $FreeDiskPercent;

                    $UsedDiskSizeGB = $DiskSizeGB - $FreeDiskSizeGB;
                    $UsedDiskPercent = ($UsedDiskSizeGB / $DiskSizeGB) * 100;
                    $UsedDiskPercent = "{0:N0}" -f $UsedDiskPercent;
                }
                else {
                    $FreeDiskPercent = 0;
                    $UsedDiskSizeGB = 0;
                    $UsedDiskPercent = 0;
                }
            }
            else {
                $DiskSizeGB = 0;
                $FreeDiskSizeGB = 0;
                $FreeDiskPercent = 0;
                $UsedDiskSizeGB = 0;
                $UsedDiskPercent = 100;
            }

            $FormattedDisk = "Disk " + $DiskID.ToString() + " " + 
                $UsedDiskSizeGB.ToString() + "GB" + " / " + $DiskSizeGB.ToString() + "GB " + 
                "(" + $UsedDiskPercent.ToString() + "%" + ")";
            $FormattedDisks.Add($FormattedDisk);
        }
    }
    else {
        $DiskID = $LogicalDisk.DeviceId;

        $FreeDiskSize = $LogicalDisk.FreeSpace
        $FreeDiskSizeGB = $FreeDiskSize / 1073741824;
        $FreeDiskSizeGB = "{0:N0}" -f $FreeDiskSizeGB;

        $DiskSize = $LogicalDisk.Size;
        $DiskSizeGB = $DiskSize / 1073741824;
        $DiskSizeGB = "{0:N0}" -f $DiskSizeGB;

        if ($DiskSize -gt 0 -And $FreeDiskSize -gt 0 ) {
            $FreeDiskPercent = ($FreeDiskSizeGB / $DiskSizeGB) * 100;
            $FreeDiskPercent = "{0:N0}" -f $FreeDiskPercent;

            $UsedDiskSizeGB = $DiskSizeGB - $FreeDiskSizeGB;
            $UsedDiskPercent = ($UsedDiskSizeGB / $DiskSizeGB) * 100;
            $UsedDiskPercent = "{0:N0}" -f $UsedDiskPercent;

            $FormattedDisk = "Disk " + $DiskID.ToString() + " " +
                $UsedDiskSizeGB.ToString() + "GB" + " / " + $DiskSizeGB.ToString() + "GB " +
                "(" + $UsedDiskPercent.ToString() + "%" + ")";
            $FormattedDisks.Add($FormattedDisk);
        } 
        else {
            $FormattedDisk = "Disk " + $DiskID.ToString() + " Empty";
            $FormattedDisks.Add($FormattedDisk);
        }
    }


    $Battery = Get-CimInstance Win32_Battery
    $BattryLife = $Battery.EstimatedChargeRemaining.ToString() + "% Remaining"




    $UserInfo = $Env:USERNAME + [System.Net.Dns]::GetHostName()
    $OSInfo = $Win32Info.Caption + " " + $Win32Info.OSArchitecture
    $KernelInfo = $Win32Info.Version
    $UptimeInfo = $UptimeFormat
    $MotherboardInfo = $MoboFormat
    $ShellInfo = $Shell
    $ResolutionInfo = $Resolution 
    $CPUInfo = (Get-CimInstance CIM_Processor -Property Name).Name
    $GPUInfo = (Get-CimInstance Win32_DisplayConfiguration).DeviceName
    $RAMInfo = $RAM
    $DiskInfo = $FormattedDisks
    $BatteryInfo = $BattryLife

    $LBlu = "`e[38;5;86m"
    $IRed = "`e[38;5;197m"
    $Red = "`e[38;5;9m"
    $Grn = "`e[38;5;42m"
    $Blu = "`e[38;5;39m"
    $Yel = "`e[38;5;227m"
    $Res = "`e[0m"
 
 
    [string[]] $ArtArray =
    "$Red████████████████████$Grn  ████████████████████$Res",
    "$Red████████████████████$Grn  ████████████████████$Res",
    "$Red████████████████████$Grn  ████████████████████$Res",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`User:$Res $UserInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`OS:$Res $OSInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`Kernel:$Res $KernelInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`System Uptime:$Res $UptimeInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`Motherboard:$Res $MotherboardInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`Shell:$Res $ShellInfo",
    "$Red████████████████████$Grn  ████████████████████$Res  $IRed`Resolution:$Res $ResolutionInfo",
    "                                                      ",
    "$Blu████████████████████$Yel  ████████████████████$Res  $IRed`CPU:$Res $CPUInfo",
    "$Blu████████████████████$Yel  ████████████████████$Res  $IRed`GPU:$Res $GPUInfo",
    "$Blu████████████████████$Yel  ████████████████████$Res  $IRed`RAM:$Res $RAMInfo",
    "$Blu████████████████████$Yel  ████████████████████$Res  $IRed`Drive:$Res $DiskInfo",
    "$Blu████████████████████$Yel  ████████████████████$Res",
    "$Blu████████████████████$Yel  ████████████████████$Res",
    "$Blu████████████████████$Yel  ████████████████████$Res  $IRed`Battery:$Res $BatteryInfo",
    "$Blu████████████████████$Yel  ████████████████████$Res",
    "$Blu████████████████████$Yel  ████████████████████$Res",
    "$Blu████████████████████$Yel  ████████████████████$Res  ";


    Clear-Host
    Write-Output "$LBlu`[WinFetch | Version 0.45.0]$Res"
    Write-Output " "
    Write-Output " "
    Return $ArtArray
}