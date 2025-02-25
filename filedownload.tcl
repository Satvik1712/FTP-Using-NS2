# Set up simulation parameters
set val(chan)   Channel/WirelessChannel
set val(prop)   Propagation/TwoRayGround
set val(netif)  Phy/WirelessPhy
set val(mac)    Mac/802_11
set val(ifq)    Queue/DropTail/PriQueue
set val(ll)     LL
set val(ant)    Antenna/OmniAntenna
set val(ifqlen) 50
set val(x)      500 ;# X dimension of topography
set val(y)      500 ;# Y dimension of topography

# Create a new simulator instance
set ns [new Simulator]

# Create nodes
for {set i 0} {$i < 6} {incr i} {
    set node_($i) [$ns node]
}

# Create a trace file
set tracefile [open filedownload.tr w]
$ns trace-all $tracefile

# Create a nam file
set namfile [open filedownload.nam w]
$ns namtrace-all $namfile

# Define procedure to download file from a node
proc DownloadFile {node file_name download_location ns} {
    set file_location "$download_location/downloaded_$file_name"
    set node_file [open "node_$node/$file_name" r]
    set file_data [read $node_file]
    close $node_file
    set downloaded_file [open $file_location w]
    puts -nonewline $downloaded_file $file_data
    close $downloaded_file
    puts "File downloaded successfully to $file_location"
}

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

# Ask user for file name to download
puts "Enter the name of the file to download from the node:"
flush stdout
gets stdin file_to_download

# Ask user for node number to download file from
puts "Enter the node number to download the file from (e.g., 0, 1, etc.):"
flush stdout
gets stdin download_node_number

# Ask user for the location to save the downloaded file
puts "Enter the location to save the downloaded file:"
flush stdout
gets stdin download_location

# Download the specified file from the specified node to the specified location
DownloadFile $download_node_number $file_to_download $download_location $ns

# Run simulation
$ns run

