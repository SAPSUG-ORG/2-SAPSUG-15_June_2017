#---------------------------------------------------------------------------
#Provide a brief synopsis of your proposted topic in the space below:
<#
PowerShell Output Lightning Demo
#>
#---------------------------------------------------------------------------
#Provide a more detailed description of your proposed topic and what you will demo in the space below:
<#
Short lightning demo on PowerShell output and some helpful things to understand
#>
#---------------------------------------------------------------------------
#code for your presentation should be put below this line:
#---------------------------------------------------------------------------

Get-EventLog -LogName System -Newest 10 
# The default output is useless, you get the ellipsis. . . 
# Format-List EventID,EntryType,Message,Source,TimeGenerated 

Get-Help about_Format
# C:\Windows\System32\WindowsPowerShell\v1.0\Event.Format.ps1xml

# AliasProperty where this can be a problem
# Format-Table has a -GroupBy Parameter that can let you split the table in 2 or more parts
Get-Service | Sort-Object -Property Status | Format-Table -GroupBy Status -AutoSize

Get-Process
Get-Process | Format-Table ProcessName,'WS(K)','CPU(s)',ID
# What happened? Did VERN screw up let's try it your way

Get-Process | Format-Table ProcessName,WS,CPU,ID
# That seems to have worked but oops the values are no longer in KB it's Bytes
Get-Process | Get-Member
# It does however work with sorting
Get-Process | Sort-Object WS -Descending

# Sorting output
Sort-Object 
Group-Object
cd c:\windows 
Get-ChildItem | Sort-Object -Property extension | Group-Object -Property extension

# Get-Command -Verb Write | Get-Help | FT Name,SYNOPSIS -AutoSize -Wrap

# Rendering and finalizing the output
Out-Default      # Sends the output to the default formatter and to the default output cmdlet.
Out-File         # Sends output to a file.
Out-GridView     # Sends output to an interactive table in a separate window. ## DEMO Out-Gridview -PassThrough
Get-Service | Where-Object {$_.Status -like "Running"} | Out-GridView -PassThru | Stop-Service

Out-Host         # Sends output to the command line. ## BONUS it has the paging parameter
Get-EventLog -LogName System | Out-Host -Paging
Out-Null         # Deletes output instead of sending it down the pipeline.
Out-Printer      # Sends output to a printer.
Out-String       # Sends objects to the host as a series of strings.

# BONUS > and >>

# writing output explicitly 
Write-Debug      # Writes a debug message to the console.
Write-Error      # Writes an object to the error stream.
Write-Host       # Writes customized output to a host.
Write-Output     # Sends the specified objects to the next command in the pipeline. If the command is the last command in the
Write-Verbose    # Writes text to the verbose message stream.
Write-Warning    # Writes a warning message.

# Formatting 2nd to last in the pipeline ## The only thing that should ever follow a Format command is an "Out" command
Format-List      # Formats the output as a list of properties in which each property appears on a new line. ## 3.5 I also use it like Get-Member
Format-Table     # Formats the output as a table.
Format-Wide      # Formats objects as a wide table that displays only one property of each object.
Get-Command -Verb Out 

 
# Redirecting the output 
# Simply put this is the pipeline 

# Exporting output
Export-Csv               Converts objects into a series of comma-separated (CSV) strings and saves the strings in a CSV file.
ConvertTo-Csv            Converts objects into a series of comma-separated value (CSV) variable-length strings.
ConvertTo-Html           Converts Microsoft .NET Framework objects into HTML that can be displayed in a Web browser.
ConvertTo-Json           Converts an object to a JSON-formatted string.
ConvertTo-SecureString   Converts encrypted standard strings to secure strings. It can also convert plain text to secure strings....
ConvertTo-Xml            Creates an XML-based representation of an object.

# BONUS -F operator ## The number after the "N" is the number of decimal places
'{0:N0}' -F (8GB/12KB)
'{0:N2}' -F (8GB/12KB)

# BONUS CommonParameters -OutVariable
$BITS = Get-Service -Name BITS
Get-Service -Name BITS -OutVariable BITS2
Write-Output -InputObject $BITS2

## BONUS DOUBLE ROUND if you had this much time do better next time
Tee-Object # Saves command output in a file or variable and also sends it down the pipeline.
Get-Help -Name Tee-Object -Full