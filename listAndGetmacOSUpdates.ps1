#command string for final softwareupdate


#build custom class that acts like a hashtable, but allows for duplicate keynames
#it's a custom object with three strings: one labeled "index", one labeled "title", the other "version"
#we make the index a string because then it left justifiess on display instead of right justifying
class OSUpdate {
     [string]$index
     [string]$title
     [string]$version;

     OSUpdate(
          [string]$index,
          [string]$title,
          [string]$version
     ){
          $this.index = $index
          $this.title = $title
          $this.version = $version
     }
}

#set up our arraylists
[System.Collections.ArrayList]$softareUpdateArrayList=@()
[System.Collections.ArrayList]$availableOSUpdates=@()

#get the currently available installers for this machine
$softareUpdateArrayList = /usr/sbin/softwareupdate --list-full-installers

#remove the first two garbage lines, we don't need them
$softareUpdateArrayList.RemoveAt(0) 
$softareUpdateArrayList.RemoveAt(0) 

foreach ($installer in $softareUpdateArrayList  ) {
     #get the index of the item
     [string]$theIndex = $softareUpdateArrayList.IndexOf($installer)
     #remove the *<space> chars in each line
     $installer = $installer.Substring(2)
     #split on the comma to create a string array 
     $OSVersionStringArray = $installer.Split(",")
     
     #get just the title from the string array
     $OSTitleTemp = $OSVersionStringArray[0].Split(":")
     #grab just the title and delete the leading space
     $OSTitle =  $OSTitleTemp[1].Substring(1)

     #get just the version number from the string array
     $OSVersionTemp = $OSVersionStringArray[1].Split(":")
     #grab just the version and delete the leading space
     $OSVersion = $OSVersionTemp[1].Substring(1)
     
     #create new OSUpdate Object
     $OSUpdateItem = @([OSUpdate]::new($theIndex,$OSTitle ,$OSVersion))

     #add the item to the arraylist of updates, suppress index output
     $availableOSUpdates.Add($OSUpdateItem)|Out-Null
}

#without piping things through out-host, we'll never see the list
#of updates because of how Read-Host messes that up. 
Write-Host "The available updates for this Mac are:`n" | Out-Host
#this simulates the generic green array headers in the output
#the `e[4m  is the "start underlining" escape, and the `e[24m is the "stop underlining escape"
Write-Host "`e[4mIndex`tTitle`t`tVersion`e[24m`n" -ForegroundColor Green| Out-Host

#write each entry to the console window
foreach ($update in $availableOSUpdates) {
     $update.index + "`t" + $update.title + "`t" + $update.version | Out-Host  
}

#get the input from the user, cast it as an int (by default it's a string)
[Int32]$desiredUpdate = Read-Host "Enter the index of the update you want to download"
#get the item in the array we want
$updateToFetch = $availableOSUpdates[$desiredUpdate]
Write-Host "Downloading Installer"
#build the command
$theSoftwareUpdateCommand = $getFullInstallerByVersion + $updateToFetch.version
#run the command via Invoke-Expression
Invoke-Expression $theSoftwareUpdateCommand
