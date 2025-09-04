function Get-LocalMonitors {
    [CmdletBinding()]
    param ()

    $ManufacturerHash = @{
        "AAC" = "AcerView";
        "ACR" = "Acer";
        "AOC" = "AOC";
        "AIC" = "AG Neovo";
        "APP" = "Apple Computer";
        "AST" = "AST Research";
        "AUO" = "Asus";
        "BNQ" = "BenQ";
        "CMO" = "Acer";
        "CPL" = "Compal";
        "CPQ" = "Compaq";
        "CPT" = "Chunghwa Pciture Tubes, Ltd.";
        "CTX" = "CTX";
        "DEC" = "DEC";
        "DEL" = "Dell";
        "DPC" = "Delta";
        "DWE" = "Daewoo";
        "EIZ" = "EIZO";
        "ELS" = "ELSA";
        "ENC" = "EIZO";
        "EPI" = "Envision";
        "FCM" = "Funai";
        "FUJ" = "Fujitsu";
        "FUS" = "Fujitsu-Siemens";
        "GSM" = "LG Electronics";
        "GWY" = "Gateway 2000";
        "HEI" = "Hyundai";
        "HIT" = "Hitachi/Nissei";
        "HSL" = "Hansol";
        "HTC" = "Hitachi/Nissei";
        "HWP" = "HP";
        "IBM" = "IBM";
        "ICL" = "Fujitsu ICL";
        "IVM" = "Iiyama";
        "KDS" = "Korea Data Systems";
        "LEN" = "Lenovo";
        "LGD" = "Asus";
        "LPL" = "Fujitsu";
        "MAX" = "Belinea";
        "MEI" = "Panasonic";
        "MEL" = "Mitsubishi Electronics";
        "MS_" = "Panasonic";
        "NAN" = "Nanao";
        "NEC" = "NEC";
        "NTT" = "NTT Data";
        "OQO" = "OQO Mobile";
        "PLX" = "Plaxx";
        "PNY" = "PNY Technology";
        "POS" = "Positivo";
        "PPG" = "Philips Display";
        "PRI" = "Proview International";
        "QUA" = "Quanta Computer";
        "RCA" = "RadioShack";
        "SAG" = "Samsung Electronics";
        "SAV" = "Sharp Corporation";
        "SEC" = "Seiko Epson";
        "SHU" = "Shunyei Optoelectronics";
        "SIG" = "Signavio AG";
        "SMI" = "Silicon Motion";
        "SPT" = "Sony Picture Technology";
        "SRG" = "Sharp Corporation";
        "SYN" = "Synnex";
        "TCL" = "TCL Communication Inc.";
        "TER" = "TerraMaster";
        "THX" = "THX Inc.";
        "TPC" = "Taishin Precision Components";
        "TRI" = "Tripp Lite";
        "UCD" = "Ucdei Electronics";
        "VIA" = "Via Technologies";
        "VID" = "VisionTek";
        "WCH" = "WinChip Group";
        "XIN" = "Xinjiang Aisin Electronic Co., Ltd.";
        "YAO" = "Yaochuang Electronics Technology";
        "ZEN" = "Zenith Display"
    }

    try {
        $Monitors = Get-WmiObject -Namespace "root\WMI" -Class "WMIMonitorID" -ComputerName $env:COMPUTERNAME -ErrorAction Stop
    } catch {
        Write-Warning "Failed to query WMI on localhost: $_"
        return
    }

    $Monitor_Array = @()

    foreach ($Monitor in $Monitors) {
        if ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName) -ne $null) {
            $Mon_Model = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
        } else {
            $Mon_Model = $null
        }

        $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)","")
        $Mon_Attached_Computer = ($Monitor.PSComputerName).Replace("$([char]0x0000)","")
        $Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")

        if ($Mon_Model -like "*800 AIO*" -or $Mon_Model -like "*8300 AiO*") { continue }

        $Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer
        if ($Mon_Manufacturer_Friendly -eq $null) {
            $Mon_Manufacturer_Friendly = $Mon_Manufacturer
        }

        $Monitor_Obj = [PSCustomObject]@{
            Manufacturer     = $Mon_Manufacturer_Friendly
            Model            = $Mon_Model
            SerialNumber     = $Mon_Serial_Number
            AttachedComputer = $Mon_Attached_Computer
        }

        $Monitor_Array += $Monitor_Obj
    }

    return $Monitor_Array
}

$monitors = Get-LocalMonitors
Write-Output $monitors