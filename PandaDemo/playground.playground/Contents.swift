//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Cassowary

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
//PlaygroundPage.current.liveView = MyViewController()

let a1 = Variable()
print(a1.hashValue)
var a2 = a1
print(a2.hashValue)

//print(a2 == a1)
print(a2.hashValue)
let v3 = Variable()

struct test{
  var value = 10
  init(){
    print("init")
  }
}

let t1 = test()
var t2 = t1
t2.value = 30



a2.value = 10
a2.hashValue

print(v3)




