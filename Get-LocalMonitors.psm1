function Get-LocalMonitors {
  <#
  .SYNOPSIS
      This powershell function gets information about the monitors attached to any computer. It uses EDID information provided by WMI. If this value is not specified it pulls the monitors of the computer that the script is being run on.

  .DESCRIPTION
      The function begins by looping through each computer specified. For each computer it gets a litst of monitors.
      It then gets all of the necessary data from each monitor object and converts and cleans the data and places it in a custom PSObject. It then adds
      the data to an array. At the end the array is displayed.

      This is forked from github users MaxAnderson95.

  .PARAMETER None
      This cmdlet does not take any parameters.

  .EXAMPLE
      Get-LocalMonitors
      -------------------------
      Retrieves detailed information about all connected monitors on the local computer.

  .NOTES
      Name        : Get-LocalMonitors.ps1
      Version     : 1.0
      Author      : Michael Free
      DateCreated : 2025-09-04

  .LINK
      https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
  #>
  [CmdletBinding()]
  param ()
  #List of Manufacture Codes that could be pulled from WMI and their respective full names. Used for translating later down.
  $ManufacturerHash = @{
    'AAC' = 'AcerView';
    'ACI' = 'Asus (ASUSTeK Computer Inc.)';
    'ACR' = 'Acer';
    'ACT' = 'Targa';
    'ADI' = 'ADI Corporation';
    'AIC' = 'AG Neovo';
    'AMW' = 'AMW';
    'AOC' = 'AOC';
    'API' = 'Acer America Corp.';
    'APP' = 'Apple Computer';
    'ART' = 'ArtMedia';
    'AST' = 'AST Research';
    'AUO' = 'Asus';
    'BMM' = 'BMM';
    'BNQ' = 'BenQ';
    'BOE' = 'BOE Display Technology';
    'CMO' = 'Acer';
    'CPL' = 'Compal';
    'CPQ' = 'Compaq';
    'CPT' = 'Chunghwa Pciture Tubes, Ltd.';
    'CTX' = 'CTX';
    'DEC' = 'DEC';
    'DEL' = 'Dell';
    'DPC' = 'Delta';
    'DWE' = 'Daewoo';
    'ECS' = 'ELITEGROUP Computer Systems';
    'EIZ' = 'EIZO';
    'ELS' = 'ELSA';
    'ENC' = 'EIZO';
    'EPI' = 'Envision';
    'FCM' = 'Funai';
    'FUJ' = 'Fujitsu';
    'FUS' = 'Fujitsu-Siemens';
    'GSM' = 'LG Electronics';
    'GWY' = 'Gateway 2000';
    'HEI' = 'Hyundai';
    'HIQ' = 'Hyundai ImageQuest';
    'HIT' = 'HitachiNissei';
    'HSD' = 'Hannspree Inc';
    'HSL' = 'Hansol';
    'HTC' = 'Hitachi/Nissei';
    'HPN' = 'Hewlett Packard (HP)';
    'HWP' = 'HP';
    'IBM' = 'IBM';
    'ICL' = 'Fujitsu ICL';
    'IFS' = 'InFocus';
    'IQT' = 'Hyundai';
    'IVM' = 'Iiyama';
    'KDS' = 'Korea Data Systems';
    'KFC' = 'KFC Computek';
    'LEN' = 'Lenovo';
    'LGD' = 'Asus';
    'LKM' = 'ADLAS / AZALEA';
    'LNK' = 'LINK Technologies, Inc.';
    'LPL' = 'Fujitsu';
    'LTN' = 'Lite-On';
    'MAG' = 'MAG InnoVision';
    'MAX' = 'Belinea';
    'MEI' = 'Panasonic';
    'MEL' = 'Mitsubishi Electronics';
    'MIR' = 'Miro Computer Products AG';
    'MS_' = 'Panasonic';
    'MTC' = 'MITAC';
    'NAN' = 'Nanao';
    'NEC' = 'NEC';
    'NOK' = 'Nokia';
    'NTT' = 'NTT Data';
    'NVD' = 'Nvidia';
    'OPT' = 'Optoma';
    'OQO' = 'OQO Mobile';
    'OQI' = 'OPTIQUEST';
    'PBN' = 'Packard Bell';
    'PCK' = 'Daewoo';
    'PLN' = 'Planar Systems';
    'PLX' = 'Plaxx';
    'PNY' = 'PNY Technology';
    'POS' = 'Positivo';
    'PDC' = 'Polaroid';
    'PGS' = 'Princeton Graphic Systems';
    'PHL' = 'Philips Consumer Electronics Co.';
    'PPG' = 'Philips Display';
    'PRI' = 'Proview International';
    'PRT' = 'Princeton';
    'QUA' = 'Quanta Computer';
    'RCA' = 'RadioShack';
    'REL' = 'Relisys';
    'SAM' = 'Samsung';
    'SAN' = 'Samsung';
    'SAG' = 'Samsung Electronics';
    'SAV' = 'Sharp Corporation';
    'SBI' = 'Smarttech';
    'SEC' = 'Seiko Epson';
    'SGI' = 'SGI';
    'SHU' = 'Shunyei Optoelectronics';
    'SIG' = 'Signavio AG';
    'SMC' = 'Samtron';
    'SMI' = 'Silicon Motion';
    'SNI' = 'Siemens Nixdorf';
    'SNY' = 'Sony Corporation';
    'SPT' = 'Sony Picture Technology';
    'SRC' = 'Shamrock Technology';
    'SRG' = 'Sharp Corporation';
    'STN' = 'Samtron';
    'STP' = 'Sceptre';
    'SUN' = 'Sun Microsystems';
    'SYN' = 'Synnex';
    'TAT' = 'Tatung Co. of America, Inc.';
    'TCL' = 'TCL Communication Inc.';
    'TER' = 'TerraMaster';
    'THX' = 'THX Inc.';
    'TOS' = 'Toshiba';
    'TPC' = 'Taishin Precision Components';
    'TRL' = 'Royal Information Company';
    'TRI' = 'Tripp Lite';
    'TSB' = 'Toshiba, Inc.';
    'UCD' = 'Ucdei Electronics';
    'UNK' = 'Unknown';
    'UNM' = 'Unisys Corporation';
    'VIA' = 'Via Technologies';
    'VID' = 'VisionTek';
    'VSC' = 'ViewSonic Corporation';
    'WCH' = 'WinChip Group';
    'WTC' = 'Wen Technology';
    'XIN' = 'Xinjiang Aisin Electronic Co., Ltd.';
    'YAO' = 'Yaochuang Electronics Technology';
    'ZEN' = 'Zenith Display';
    'ZCM' = 'Zenith Data Systems';
    '_YV' = 'Fujitsu'
  }
  try {
    $Monitors = Get-WmiObject -Namespace 'root\WMI' -Class 'WMIMonitorID' -ErrorAction Stop
  }
  catch {
    Write-Warning "Failed to query WMI on localhost: $_"
    return
  }

  $Monitor_Array = @()

  foreach ($Monitor in $Monitors) {
    if ($null -eq $Monitor.UserFriendlyName) {
      $Mon_Model = 'Unknown'
    }
    else {
      $Mon_Model = [System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)
    }
    $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)", '')
    $Mon_Attached_Computer = $env:COMPUTERNAME
    $Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)", '')

    if ($Mon_Model -like '*800 AIO*' -or $Mon_Model -like '*8300 AiO*') { continue }

    $Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer

    if ($null -eq $Mon_Manufacturer_Friendly) {
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

$myarray = @()
#count how many monitors we have and loope
for ($i = 0; $i -lt $monitors.Count; $i++) {
    $monitor = $monitors[$i]

    $monitorObj = [PSCustomObject]@{
        MonitorNumber     = $i + 1
        Manufacturer      = $monitor.Manufacturer
        Model             = $monitor.Model
        SerialNumber      = $monitor.SerialNumber
        AttachedComputer  = $monitor.AttachedComputer
    }

    $myarray += $monitorObj
}

$myarray | ft