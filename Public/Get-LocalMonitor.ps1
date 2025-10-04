<#
.SYNOPSIS
Retrieves information about monitors connected to the local computer using EDID data via WMI
.DESCRIPTION
Queries the WMIMonitorID class to extract monitor manufacturer, model, and serial number.
Translates manufacturer codes to friendly names and handles edge cases like null EDID fields
.OUTPUTS
[PSCustomObject] with properties:
    - Manufacturer
    - Model
    - SerialNumber
    - AttachedComputer
#>
function Get-LocalMonitor {
  [CmdletBinding()]
  param ()

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
    $rawManufacturer = if ($monitor.ManufacturerName) {
      [System.Text.Encoding]::ASCII.GetString($monitor.ManufacturerName) -replace "`0"
    }
    else {
      ''
    }

    $monitorManufacturer = if ($ManufacturerHash.ContainsKey($rawManufacturer)) {
      $ManufacturerHash[$rawManufacturer]
    }
    else {
      'Unknown'
    }

    $monitorModel = if ($monitor.UserFriendlyName) {
      $decoded = [System.Text.Encoding]::ASCII.GetString($monitor.UserFriendlyName) -replace "`0"
      if ($decoded -match '800 AIO|8300 AiO') {
        'Unknown'
      }
      else {
        $decoded
      }
    }
    else {
      'Unknown'
    }

    $monitorSerialNumber = if ($monitor.SerialNumberID) {
      $decodedSerialNumber = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID) -replace "`0"
      if ([string]::IsNullOrWhiteSpace($decodedSerialNumber) -or $decodedSerialNumber -eq '0') {
        'Unknown'
      }
      else {
        $decodedSerialNumber
      }
    }
    else {
      'Unknown'
    }

    $computerName = $env:COMPUTERNAME

    $monitorObject = [PSCustomObject]@{
      Manufacturer     = $monitorManufacturer
      Model            = $monitorModel
      SerialNumber     = $monitorSerialNumber
      AttachedComputer = $computerName
    }

    $monitorArray += $monitorObject
  }

  return , $monitorArray
}

