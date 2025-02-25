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
set tracefile [open fileupload.tr w]
$ns trace-all $tracefile

# Create a nam file
set namfile [open fileupload.nam w]
$ns namtrace-all $namfile

# Define procedure to upload file to a node
proc UploadFile {file_location node ns} {
    # Check if the file exists
    if {![file exists $file_location]} {
        puts "Error: File $file_location not found"
        return
    }

    # Open the file to upload
    set file [open $file_location r]
    set file_data [read $file]
    close $file

    # Write file data to the node
    set node_file [open "node_$node/file.txt" w]
    puts -nonewline $node_file $file_data
    close $node_file
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

# Ask user for file location and node number
puts "Enter the file location:"
flush stdout
gets stdin file_location
puts "Enter the node number (e.g., 0, 1, etc.):"
flush stdout
gets stdin node_number

# Upload the file to the specified node
UploadFile $file_location $node_number $ns

# Run simulation
$ns run

