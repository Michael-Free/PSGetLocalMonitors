---
external help file: PSGetLocalMonitors-help.xml
Module Name: PSGetLocalMonitors
online version:
schema: 2.0.0
---

# Get-LocalMonitor

## SYNOPSIS
Retrieves information about monitors connected to the local computer using EDID data via WMI

## SYNTAX

```
Get-LocalMonitor [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the WMIMonitorID class to extract monitor manufacturer, model, and serial number.
Translates manufacturer codes to friendly names and handles edge cases like null EDID fields

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### [PSCustomObject] with properties:
###     - Manufacturer
###     - Model
###     - SerialNumber
###     - AttachedComputer
## NOTES

## RELATED LINKS
