//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var arr = [1, 2, 3]

for i in 0..<arr.count {
    arr[i] += 1
}

arr



class ArrObj {
    var internalObjects = [ArrObj]()
}

var objects = [ArrObj(), ArrObj()]


for obj in objects {
    obj.internalObjects.append(ArrObj())
}

for obj in objects {
    println(obj.internalObjects.count)
}