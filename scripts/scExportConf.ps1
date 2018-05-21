####
#
# Description: Script used to pull extract configurationsSecurityCenter.
#
####

# Pull in any needed modules.
Import-Module PSExcel

# Variables
$user = "Replace with user ID"
$password = "replace with user password"
$outFile = "c:\temp\SecurityCenter.XLSX"
$sc = "replace with fqdn or IP of SecurityCenter"

# Build credentials object - could be simplified but I prefer to use ConvertTo-Json
$Login = New-Object PSObject
$Login | Add-Member -MemberType NoteProperty -Name username -Value $user
$Login | Add-member -MemberType Noteproperty -Name password -Value $password
$Data = (ConvertTo-Json -compress $Login)

# Login to SC5
$ret = Invoke-WebRequest -URI https://$sc/rest/token -Method POST -Body $Data -UseBasicParsing -SessionVariable sv

# Extract the token
$token = (convertfrom-json $ret.Content).response.token

# Get list of scanners
function scanners()
{
  $ret = Invoke-RestMethod -Method Get -URI "https://$sc/rest/scanner?fields=name,description,ip,port,enabled,verifyHost,authType,zones,username" -UseBasicParsing -Headers @{"X-SecurityCenter"="$token"}  -Websession $sv
  $hashtable = @()
  foreach($scanner in $ret.response) {
      foreach($zone in $scanner.zones) {
          $row = new-object PSObject -property @{
              name = $scanner.name;
              description = $scanner.description;
              username = $scanner.username;
              ip = $scanner.ip;
              port = $scanner.port;
              enabled = $scanner.enabled;
              verifyHost = $scanner.verifyHost;
              authType = $scanner.authType;
              zone_name = $zone.name;
              zone_description = $zone.description
          }
      }
      $hashtable += $row
  }
  $hashtable | sort-object name | select-object name, description, username, ip, port, enabled, verifyHost, authType, zone_name, zone_description | Get-unique -AsString | Export-XLSX $outFile -WorksheetName Scanners -Table -AutoFit
}

# Get list of scan zones
function scanZones()
{
  $ret = Invoke-RestMethod -Method Get -URI "https://$sc/rest/zone"  -UseBasicParsing -Headers @{"X-SecurityCenter"="$token"}  -Websession $sv
  $hashtable = @()
  foreach($zone in $ret.response) {
    foreach($scanner in $zone.scanners) {
      $row = new-object PSObject -property @{
      zone_id = $zone.id;
      zone_name = $zone.name;
      zone_description = $zone.description;
      zone_ipList = $zone.ipList;
      zone_activeScanners = $zone.activeScanners
      scanner_id = $scanner.id;
      scanner_name = $scanner.name;
      scanner_description = $scanner.description
    }
  }
  $hashtable += $row
  }
  $hashtable | sort-object zone_id | select-object scan_id, zone_name, zone_description, zone_ipList, zone_activeScanners, scanner_id, scanner_name, scanner_description | Get-unique -AsString | Export-XLSX $outFile -WorksheetName ScanZones -Table -AutoFit
}

# Get list of scan policies
function scanPolicy()
{
  $ret = Invoke-RestMethod -Method Get -URI "https://$sc/rest/policy?fields=name,description,status,policyTemplate,creator,createdTime,auditFiles,targetGroup,owner" -UseBasicParsing -Headers @{"X-SecurityCenter"="$token"}  -Websession $sv
  $hashtable = @()
  foreach($policy in $ret.response) {
    $row = new-object PSObject -property @{
    name = $policy.name;
    description = $policy.description;
    status = $policy.status;
    policyTemplate = $policy.policyTemplate;
    creator = $policy.creator;
    createdTime = $policy.createdTime;
    auditFiles = $policy.auditFiles;
    targetGroup = $policy.targetGroup;
    owner = $policy.owner;
  }
  $hashtable += $row
  }
  $hashtable | sort-object name | select-object name, description, status, policyTemplate, creator, createdTime, auditFiles, targetGroup, owner | Get-unique -AsString | Export-XLSX $outFile -WorksheetName scanPolicies -Table -AutoFit
}

# Get list of scans
function scans()
{
  $ret = Invoke-RestMethod -Method Get -URI "https://$sc/rest/scan?fields=id,name,description,status,repository,zone,ipList,type,createdTime,reports,assets,credentials,schedule,policy" -UseBasicParsing -Headers @{"X-SecurityCenter"="$token"}  -Websession $sv
  $hashtable = @()
  foreach($scans in $ret.response) {
    $row = new-object PSObject -property @{
    id = $scans.id;
    name = $scans.name;
    description = $scans.description;
    status = $scans.status;
    repository = $scans.repository;
    zone = $scans.zone;
    ipList = $scans..ipList;
    type = $policy.auditFiles;
    createdTime = $scans.createdTime;
    reports = $scans.reports;
    assets = $scans.
    credentials = $scans.
    schedule = $scans.
    policy = $scans.
  }
  $hashtable += $row
  }
  $hashtable | sort-object name | select-object id, name, description, status, repository, zone, ipList, type, createdTime, reports, assets, credentials, schedule, policy| Get-unique -AsString | Export-XLSX $outFile -WorksheetName scans -Table -AutoFit
}

scanners
scanZones
scanPolicy
scans
