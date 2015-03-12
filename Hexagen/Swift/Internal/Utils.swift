  /*****\\\\
 /       \\\\    Hexagen/Swift/Internal/Utils.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


import Foundation

internal var threadDictionary: NSMutableDictionary { return NSThread.currentThread().threadDictionary }
internal var mainQueue: dispatch_queue_t { return dispatch_get_main_queue() }