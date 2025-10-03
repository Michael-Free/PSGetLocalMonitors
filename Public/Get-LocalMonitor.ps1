function Get-LocalMonitor {
  <#
  .SYNOPSIS
  Retrieves information about monitors connected to the local computer using EDID data via WMI.

  .DESCRIPTION
  The Get-LocalMonitor function queries the local computer's WMI class 'WMIMonitorID' to extract detailed information about connected monitors. This includes manufacturer name, model, serial number, and the computer the monitor is attached to.

  It translates the EDID manufacturer codes into friendly manufacturer names using a built-in mapping table.

  Note: This function only supports querying the **local** computer.

  .EXAMPLE
  Get-LocalMonitor

  Returns detailed information for all monitors currently connected to the local machine.

  .OUTPUTS
  [PSCustomObject]

  Each monitor is returned as a custom object with the following properties:
  - Manufacturer
  - Model
  - SerialNumber
  - AttachedComputer

  .NOTES
  Author      : Michael Free
  DateCreated : 2025-09-04
  Requires    : Administrator privileges (to access WMI in root\WMI)

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
    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WMIMonitorID -ErrorAction Stop
  }
  catch {
    throw "Failed to query CIM Instance on localhost: $_"
  }

  $monitorArray = @()

  foreach ($monitor in $monitors) {
    if ($null -eq $monitor.UserFriendlyName) {
      $monitorModel = 'Unknown'
    }
    elseif ($monitorModel -like '*800 AIO*' -or $monitorModel -like '*8300 AiO*') {
      $monitorModel = 'Unknown'
    }
    else {
      $monitorModel = [System.Text.Encoding]::ASCII.GetString($monitor.UserFriendlyName)
    }

    $monitorSerialNumber = ([System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID)).Replace("$([char]0x0000)", '')

    if ($null -eq $monitorSerialNumber -or $monitorSerialNumber -eq "0" -or $monitorSerialNumber -eq "") {
      $monitorSerialNumber = 'Unknown'
    }

    $monitorManufacturer = ([System.Text.Encoding]::ASCII.GetString($monitor.ManufacturerName)).Replace("$([char]0x0000)", '')

    if ($ManufacturerHash.ContainsKey($monitorManufacturer)) {
      $monitorManufacturerFriendlyName = $ManufacturerHash[$monitorManufacturer]
    }
    else {
      $monitorManufacturerFriendlyName = 'Unknown'
    }

    $monitorAttachedComputer = $env:COMPUTERNAME

    $monitorObject = [PSCustomObject]@{
      Manufacturer     = $monitorManufacturerFriendlyName
      Model            = $monitorModel
      SerialNumber     = $monitorSerialNumber
      AttachedComputer = $monitorAttachedComputer
    }

    $monitorArray += $monitorObject
  }
  return , $monitorArray #adding comma because powershell 5.1 won't return an array if there's just 1 object.
}

