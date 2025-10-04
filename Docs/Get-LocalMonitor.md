---
external help file: PSGetLocalMonitors-help.xml
Module Name: PSGetLocalMonitors
online version:
schema: 2.0.0
---

# Get-LocalMonitor

## SYNOPSIS
Retrieves information about monitors connected to the local computer using EDID data via WMI.

## SYNTAX

```
Get-LocalMonitor [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the WMIMonitorID class to extract monitor manufacturer, model, and serial number.
Translates manufacturer codes to friendly names and handles edge cases like null or empty EDID fields.

## EXAMPLES

### EXAMPLE 1
```
Get-LocalMonitor -Verbose
Retrieves detailed information about monitors connected to the local computer, including manufacturer details and serial numbers. Outputs to the console if verbose output is enabled.
```

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
### - Manufacturer
### - Model
### - SerialNumber
### - AttachedComputer
## NOTES
- This function requires administrative privileges to query WMI instances.
- The function assumes the WMIMonitorID class is available on the local machine.
- Handles edge cases for null or empty EDID fields and translates manufacturer codes to friendly names.

## RELATED LINKS
