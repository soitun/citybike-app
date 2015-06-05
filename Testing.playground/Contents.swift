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


var arr1 = [1, 2, 3]
var arr2 = [1]

var set1 = Set(arr1)
var set2 = Set(arr2)

set1.subtract(set2)




