# Get-LocalMonitors
Get-LocalMonitors is a PowerShell function designed to retrieve detailed information about monitors connected to the local computer. It uses Windows Management Instrumentation (WMI) to query the WMIMonitorID class in the root\WMI namespace and extracts Extended Display Identification Data (EDID) such as manufacturer, model, and serial number.

The function translates raw manufacturer codes into human-friendly names using a built-in dictionary, making it easier to identify connected displays.

## Features
- Retrieves detailed monitor information directly from the local machine.
- Extracts manufacturer, model, and serial number data from EDID.
- Translates manufacturer codes to friendly names.
- Returns results as custom PowerShell objects with clear properties.
- Does not support remote querying (local machine only).
- Requires administrator privileges to access WMI data.

## Usage
Simply run the function without any parameters:
```powershell
Get-LocalMonitors
```
This returns a list of objects with connected monitor information.

```powershell
Manufacturer Model    SerialNumber AttachedComputer
------------ -----    ------------ ----------------
HP           HP E241i CN12345678   SSL1-F1102-1G2Z
HP           HP E241i CN91234567   SSL1-F1102-1G2Z
```

## Requirements
- PowerShell with access to WMI (root\WMI namespace).
- Administrator privileges (to query WMI).
- Function works only on the local computer.
- WMI service must be running and accessible.

## Troubleshooting
- Ensure you run PowerShell with elevated privileges.
- If the WMI service is unavailable or corrupted, no monitor information will be returned.
- Some monitors may provide incomplete or invalid EDID data, resulting in "Unknown" values.
- Remote querying is not supported at this time.
- Future updates may migrate the function to use CIM instances instead of WMI.

