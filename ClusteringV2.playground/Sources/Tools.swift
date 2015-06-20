import Foundation

public func randomSequenceGenerator(#min: Int, #max: Int) -> () -> Int {
    var numbers: [Int] = []
    return {
        if numbers.count == 0 {
            numbers = Array(min ... max)
        }
        
        let index = Int(arc4random_uniform(UInt32(numbers.count)))
        return numbers.removeAtIndex(index)
    }
}

public func randomNumbers(count: Int, min: Int, max: Int) -> [Int] {
    var numbers = [Int]()
    for i in 0..<count {
        let random = randomSequenceGenerator(min: min, max: max)
        numbers.append(random())
    }
    
    return numbers
}