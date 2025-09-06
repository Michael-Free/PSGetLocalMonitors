# Get-LocalMonitors
## about_Get-LocalMonitors

# SHORT DESCRIPTION
Retrieves monitor details from the local computer using EDID data via WMI.

# LONG DESCRIPTION
The `Get-LocalMonitors` function queries the local system for monitor information
using the `WMIMonitorID` WMI class in the `root\WMI` namespace.

It extracts Extended Display Identification Data (EDID), including the monitor's
manufacturer code, model name, and serial number. These byte array values are
decoded into readable strings. A built-in dictionary is used to convert
manufacturer codes into human-friendly names.

The function returns one or more custom PowerShell objects with the following properties:

- `Manufacturer`
- `Model`
- `SerialNumber`
- `AttachedComputer`

# EXAMPLES
    Get-LocalMonitors

    Description:
    Returns detailed information about each monitor currently connected to the
    local computer.

# NOTE
- Author: Michael Free
- Date Created: 2025-09-04
- Requires: Administrator privileges (to access WMI in root\WMI)

# TROUBLESHOOTING NOTE
- This function only works on the **local** computer and does not support remote querying.
- There will likely be updates to change this to a CimInstance.
- Ensure the script is run with elevated (admin) privileges.
- WMI service must be running and accessible.
- Some monitors may return partial or invalid EDID data, leading to "Unknown" values.
- WMI corruption or permission issues may prevent data from being returned.

# SEE ALSO
- Get-WmiObject
- WMIMonitorID
- https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1

# KEYWORDS
- monitors
- WMI
- EDID
- display
- hardware inventory
- PowerShell functions
