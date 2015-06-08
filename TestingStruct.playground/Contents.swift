//: Playground - noun: a place where people can play

import UIKit

struct Car {
    var doors: Int
}

struct Garage {
    var cars = [Car]()
}

var garage = Garage()
var car = Car(doors: 3)

garage.cars.append(car)


garage.cars[0].doors

car.doors = 4

garage.cars[0].doors

for car in garage.cars as [Car] {
//    car.doors = 0
}

garage.cars[0].doors
