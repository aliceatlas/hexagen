  /*****\\\\
 /       \\\\    main.swift
/  /\ /\  \\\\   (part of HexagenExamples)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


import Hexagen

func _counter(n: Int) (yield: Int -> Void) {
    for i in 0..<n {
        yield(i)
    }
}
let counter = genFunc(_counter)

let kounter = genFunc { (n: Int) in { (yield: Int -> Void) in
    for i in 0..<n {
        yield(i)
    }
}}
  
func gounter(n: Int) -> SimpleGenerator<Int> {
    return SimpleGenerator { yield in
        for i in 0..<n {
            yield(i)
        }
    }
}

for i in counter(5) {
    println(i)
    //if i == 2 { break }
}

let g = kounter(5)
let h = gounter(5)
for i in 0...3 {
    println(g.next()!, h.next()!)
}

func _doubler() (yield: Int! -> Int?) {
    var val = yield(nil)
    while val != nil {
        val = yield(val! * 2)
    }
    println("dun")
}
func _doubler2() (yield: Int! -> Int?) {
    yield(nil)
    var ret: Int!
    while let val = yield(ret) {
        ret = val * 2
    }
    println("dun")
}
let doubler = coroFunc(_doubler2)

func ok() {
    let x = doubler()
    x.start()
    for i in 0...3 {
        println(x.send(i)!)
    }
    x.send(nil)
    //x.send(nil)
}
ok()
