---
external help file: Get-LocalMonitors-help.xml
Module Name: Get-LocalMonitors
online version: https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
schema: 2.0.0
---

# Get-LocalMonitors

## SYNOPSIS
Retrieves information about monitors connected to the local computer using EDID data via WMI.

## SYNTAX

```
Get-LocalMonitors [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-LocalMonitors function queries the local computer's WMI class 'WMIMonitorID' to extract detailed information about connected monitors.
This includes manufacturer name, model, serial number, and the computer the monitor is attached to.

It translates the EDID manufacturer codes into friendly manufacturer names using a built-in mapping table.

Note: This function only supports querying the **local** computer.

## EXAMPLES

### EXAMPLE 1
```
Get-LocalMonitors
```

Returns detailed information for all monitors currently connected to the local machine.

## PARAMETERS

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [PSCustomObject]
### Each monitor is returned as a custom object with the following properties:
### - Manufacturer
### - Model
### - SerialNumber
### - AttachedComputer
## NOTES
Author      : Michael Free
Version     : 0.0.1
DateCreated : 2025-09-04
Requires    : Administrator privileges (to access WMI in root\WMI)

## RELATED LINKS

[https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1](https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1)

