---
external help file: Get-LocalMonitors-help.xml
Module Name: Get-LocalMonitors
online version: https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
schema: 2.0.0
---

# Get-LocalMonitors

## SYNOPSIS
This powershell function gets information about the monitors attached to any computer.
It uses EDID information provided by WMI.
If this value is not specified it pulls the monitors of the computer that the script is being run on.

## SYNTAX

```
Get-LocalMonitors [<CommonParameters>]
```

## DESCRIPTION
The function begins by looping through each computer specified.
For each computer it gets a litst of monitors.
It then gets all of the necessary data from each monitor object and converts and cleans the data and places it in a custom PSObject.
It then adds
the data to an array.
At the end the array is displayed.

This is forked from github users MaxAnderson95.

## EXAMPLES

### EXAMPLE 1
```
Get-LocalMonitors
```

-------------------------
Retrieves detailed information about all connected monitors on the local computer.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Name        : Get-LocalMonitors.ps1
Version     : 1.0
Author      : Michael Free
DateCreated : 2025-09-04

## RELATED LINKS

[https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1](https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1)

