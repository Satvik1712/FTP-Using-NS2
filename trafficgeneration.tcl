# This script is created by NSG2 beta1
#===================================

#     Simulation parameters setup

#===================================
set val(stop)   10.5                         ;# time of simulation 

#===================================

#        Initialization        

#===================================
# Create a ns simulator
set ns [new Simulator]

# Open the NS trace file
set tracefile [open trafficgeneration.tr w]
$ns trace-all $tracefile

# Open the NAM trace file
set namfile [open trafficgeneration.nam w]
$ns namtrace-all $namfile

#===================================

#        Nodes Definition        

#===================================
# Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#===================================

#        Links Definition        

#===================================
# Create links between nodes
$ns duplex-link $n0 $n2 100.0Mb 10ms SFQ
$ns queue-limit $n0 $n2 50
$ns duplex-link $n3 $n2 100.0Mb 10ms SFQ
$ns queue-limit $n3 $n2 50
$ns duplex-link $n1 $n2 100.0Mb 10ms SFQ
$ns queue-limit $n1 $n2 50
$ns duplex-link $n3 $n4 100.0Mb 10ms SFQ
$ns queue-limit $n3 $n4 50
$ns duplex-link $n3 $n5 100.0Mb 10ms SFQ
$ns queue-limit $n3 $n5 50

# Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n3 $n2 orient left
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#===================================

#        Agents Definition        

#===================================
# Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink3 [new Agent/TCPSink]
$ns attach-agent $n5 $sink3
$ns connect $tcp0 $sink3
$tcp0 set packetSize_ 1500

# Setup a TCP connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n4 $tcp1
set sink2 [new Agent/TCPSink]
$ns attach-agent $n1 $sink2
$ns connect $tcp1 $sink2
$tcp1 set packetSize_ 1500

# Setup a UDP connection
set udp4 [new Agent/UDP]
$ns attach-agent $n2 $udp4
set null5 [new Agent/Null]
$ns attach-agent $n5 $null5
$ns connect $udp4 $null5
$udp4 set packetSize_ 48

#===================================

#        Applications Definition        

#===================================
# Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

# Setup a FTP Application over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

# Setup a CBR Application over UDP connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp4
$cbr2 set packetSize_ 48
$cbr2 set interval_ 50ms
$cbr2 set random_ null
$ns at 1.0 "$cbr2 start"
$ns at 10.0 "$cbr2 stop"

#===================================

#        Termination        

#===================================
# Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam httpex.nam&
    exit 0
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run

