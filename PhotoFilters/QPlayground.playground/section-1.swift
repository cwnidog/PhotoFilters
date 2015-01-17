// Implement an integer queue using and array. Provide enqueue(), dequeue(), and peek() methods.

import UIKit

class IntQueue {
  var items = [Int]()
  
  // add an item to the tail of the queue
  func enqueue (newItem : Int) {
    items.append(newItem)
  } // enqueue()
  
  // remove an item from the head of the queue and return its value. If queue is empty returns nil.
  func dequeue() -> Int? {
    if !items.isEmpty {
      return items.removeAtIndex(0)
    }
    else {
      return nil
    }
  } // dequeue
  
  // return the value of the item at the head of the queue, but leave the item on the queue
  func peek() -> Int? {
    if !items.isEmpty {
      return items.first!
    }
    else {
      return nil
    }
  } // peek()
} // IntQueue

var myQ = IntQueue()

myQ.dequeue()
myQ.peek()

myQ.enqueue(17)
myQ.enqueue(3)
myQ.enqueue(587)

println(myQ.peek()!)
println(myQ.dequeue()!)
println(myQ.peek()!)

myQ.enqueue(35)



