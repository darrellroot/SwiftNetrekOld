# SwiftNetrek
This is an attempt by Darrell Root to rewrite the MacTrek Netrek client (by Chris Lukassen) from Objective-C to Swift

As of 24Feb2019 there are 25,535 lines of Objective-C in 120 *.m files in the distribution.
I've converted SoundEffect.m to SoundEffect.swift (1 file) and converted audio from QuickTime
(no longer supported) to AVFoundation.  I also updated some build parameters.

It builds!  It works (barely).  It crashes after a while with selector errors.  If you try to create
a new netrek login it crashs (but guest works).

I hope this port is worthy of Chris Lukassen's excellent work getting Netrek working on the Mac.
