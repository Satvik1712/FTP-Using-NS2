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

# Create a trace file
set tracefile [open filetransfer.tr w]
$ns trace-all $tracefile

# Create a nam file
set namfile [open filetransfer.nam w]
$ns namtrace-all $namfile

# Define nodes
for {set i 0} {$i < 6} {incr i} {
    set node($i) [$ns node]
}

# Set up links
$ns duplex-link $node(0) $node(2) 100.0Mb 10ms SFQ
$ns queue-limit $node(0) $node(2) 50
$ns duplex-link $node(3) $node(2) 100.0Mb 10ms SFQ
$ns queue-limit $node(3) $node(2) 50
$ns duplex-link $node(1) $node(2) 100.0Mb 10ms SFQ
$ns queue-limit $node(1) $node(2) 50
$ns duplex-link $node(3) $node(4) 100.0Mb 10ms SFQ
$ns queue-limit $node(3) $node(4) 50
$ns duplex-link $node(3) $node(5) 100.0Mb 10ms SFQ
$ns queue-limit $node(3) $node(5) 50

# Set up routing
$ns rtproto DV

# Define FTP procedure using TCP
proc FTP {src dest file size} {
    global ns node

    set ftp_file_src "node_$src/$file"
    set ftp [open $ftp_file_src r]
    if {[eof $ftp]} {
        puts "Error: $ftp_file_src not found"
        exit 1
    }
    set ftp_data [read $ftp $size]
    close $ftp

    set ftp_file_dest "node_$dest/$file"
    set dest_file [open $ftp_file_dest w]
    puts -nonewline $dest_file $ftp_data
    close $dest_file

    set tcp_agent [new Agent/TCP]
    $ns attach-agent $node($src) $tcp_agent
    set sink [new Agent/TCPSink]
    $ns attach-agent $node($dest) $sink
    $ns connect $tcp_agent $sink
    $tcp_agent set window_ 100
    $tcp_agent set packetSize_ 1000
    $tcp_agent send $ftp_data

    # Schedule a command to stop the simulation after 2 seconds
    $ns at 2.0 "$ns halt"
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

# Prompt user for source node, destination node, and file name
puts "Enter source node (0-5):"
flush stdout
set source_node [gets stdin]
puts "Enter destination node (0-5):"
flush stdout
set dest_node [gets stdin]
puts "Enter file name (e.g., sample.txt):"
flush stdout
set file_name [gets stdin]

# Call FTP function to transfer file
FTP $source_node $dest_node $file_name 1000000 ;# 1MB file

# Run simulation
$ns run

