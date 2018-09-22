//
//  ViewController.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2017/7/24.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit
import Panda
import Cassowary
import Layoutable

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func caculate(_ sender: Any) {
    let viewController = ImageTextViewController()
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @IBAction func addHotelView(_ sender: Any) {
    testAddConstraintPerformance()
    testUpdateConstantPerformance()

    for count in [5,10,20,30,40,50,60,70,100,200]{
      print("=========== \(count) ============")
      testNest(count)
      testNestView(count)
      testNodelayout(count)
      testViewLayout(count)
      testAutoLayout(count)
      testNestAutoLayout(count)
    }
    
    let node = ViewNode()
    node.width == 100
    node.width == 200
    node.layoutIfNeeded()
    print(node.frame)
  }
  
  func testConflicExplanation(){
    
    let v1 = Variable(), v2 = Variable()
    let solver = SimplexSolver()
    do{
      try solver.add(constraint: v1 >= 10)
      try solver.add(constraint: v1 == 100)
      try solver.add(constraint: v2 == 200)
      try solver.add(constraint: v1 == v2)
      try solver.solve()
    }catch{
      print(error)
    }
    
  }
  
  func testNest(_ testNumber: Int = 100) {
    
    measureTime(desc:"testNestPerformance ") {
      let node = ViewNode()
      var nodes = [ViewNode]()
      node.size == (320.0,640.0)
      for index in 0..<testNumber{
        
        let newNode = ViewNode()
        if nodes.count == 0{
          node.addSubnode(newNode)
          newNode.edge == node + (0.5,0.5,0.5,0.5)
        }else{
          let aNode = nodes[index - 1]
          aNode.addSubnode(newNode)
          newNode.edge == aNode.edge.insets((1,1,1,1))
        }
        nodes.append(newNode)
      }
      node.layoutIfEnabled()
    }
  }
  
  func testNestView(_ testNumber: Int = 100) {
    
    measureTime(desc:"testNestViewPerformance ") {
      let node = UIView()
      var nodes = [UIView]()
      node.size == (320.0,640.0)
      for index in 0..<testNumber{
        
        let newNode = UIView()
        if nodes.count == 0{
          node.addSubview(newNode)
          newNode.edge == node + (0.5,0.5,0.5,0.5)
        }else{
          let aNode = nodes[index - 1]
          aNode.addSubview(newNode)
          newNode.edge == aNode.edge.insets((1,1,1,1))
        }
        nodes.append(newNode)
      }
      node.layoutIfEnabled()
    }
  }
  
  func testNodelayout(_ testNumber: Int = 100) {
    measureTime(desc:"testNodelayoutPerformance ") {
      let node = ViewNode()
      var nodes = [ViewNode]()
      node.size == (320.0,640.0)
      for _ in 0..<testNumber{
        var leftNode = node
        var rightNode = node
        if nodes.count != 0{
          let left = Int(arc4random())%nodes.count
          let right = Int(arc4random())%nodes.count
          leftNode = nodes[left]
          rightNode = nodes[right]
        }
        
        let newNode = ViewNode()
        node.addSubnode(newNode)
        
        newNode.left >= node.left
        newNode.right <= node.right
        
        newNode.top >= node.top + 20
        newNode.bottom <= node.bottom - 20
        
        newNode.left == leftNode.left + CGFloat(arc4random()%20) ~ .strong
        newNode.top == rightNode.top + CGFloat(arc4random()%20) ~ .strong
        
        nodes.append(newNode)
      }
      node.layoutIfEnabled()
    }
  }
  
  func testViewLayout(_ testNumber: Int = 100) {
    measureTime(desc:"testSystemPerformance ") {
      let node = UIView()
      var nodes = [UIView]()
      node.size == (320.0,640.0)
      for _ in 0..<testNumber{
        var leftNode = node
        var rightNode = node
        if nodes.count != 0{
          let left = Int(arc4random())%nodes.count
          let right = Int(arc4random())%nodes.count
          leftNode = nodes[left]
          rightNode = nodes[right]
        }
        
        let newNode = UIView()
        node.addSubview(newNode)
        
        newNode.left >= node.left
        newNode.right <= node.right
        
        newNode.top >= node.top + 20
        newNode.bottom <= node.bottom - 20
        
        newNode.left == leftNode.left + CGFloat(arc4random()%20) ~ .strong
        newNode.top == rightNode.top + CGFloat(arc4random()%20) ~ .strong
        
        nodes.append(newNode)
      }
      node.layoutIfEnabled()
    }
  }
  
  func testAutoLayout(_ testNumber: Int = 100) {
    measureTime(desc:"testAutolayoutPerformance ") {
      let node = UIView()
      var nodes = [UIView]()
      node.widthAnchor.constraint(equalToConstant: 320).isActive = true
      node.heightAnchor.constraint(equalToConstant: 640).isActive = true
      node.translatesAutoresizingMaskIntoConstraints = false
      for _ in 0..<testNumber{
        var leftNode = node
        var rightNode = node
        if nodes.count != 0{
          let left = Int(arc4random())%nodes.count
          let right = Int(arc4random())%nodes.count
          leftNode = nodes[left]
          rightNode = nodes[right]
        }
        
        let newNode = UIView()
        newNode.translatesAutoresizingMaskIntoConstraints = false
        node.addSubview(newNode)

        NSLayoutConstraint.activate([
          newNode.leftAnchor.constraint(greaterThanOrEqualTo:node.leftAnchor , constant: 0),
          newNode.rightAnchor.constraint(lessThanOrEqualTo: node.rightAnchor),
          
          newNode.topAnchor.constraint(greaterThanOrEqualTo: node.topAnchor, constant: 20),
          newNode.bottomAnchor.constraint(lessThanOrEqualTo: node.bottomAnchor,constant: -20)])

        
        let c1 = newNode.leftAnchor.constraint(equalTo: leftNode.leftAnchor,constant: CGFloat(arc4random()%20))
        let c2 = newNode.topAnchor.constraint(equalTo: rightNode.topAnchor, constant: CGFloat(arc4random()%20))
        c1.priority = .defaultHigh
        c2.priority = .defaultHigh
        NSLayoutConstraint.activate([c1,c2])
        
        nodes.append(newNode)
      }
      node.layoutIfNeeded()
    }
  }
  
  func testNestAutoLayout(_ testNumber: Int = 100) {
    measureTime(desc:"testNestAutolayoutPerformance ") {

      var nodes = [UIView]()

      for index in 0..<testNumber{
        if nodes.count == 0{
          let node = UIView()
          node.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
           nodes.append(node)
        }else{
          let node = UIView()
          let superNode = nodes[index - 1]
          superNode.addSubview(node)
          node.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            node.leftAnchor.constraint(greaterThanOrEqualTo:superNode.leftAnchor , constant: 1),
            node.rightAnchor.constraint(lessThanOrEqualTo: superNode.rightAnchor, constant: -1),
            
            node.topAnchor.constraint(greaterThanOrEqualTo: superNode.topAnchor, constant: 1),
            node.bottomAnchor.constraint(lessThanOrEqualTo: superNode.bottomAnchor,constant: -1)])
          
          nodes.append(node)
        }
        
      }
      nodes[0].layoutIfNeeded()
    }
  }
  
  func uniformramdom() -> Double{
    return Double(arc4random()/2)/Double(RAND_MAX)
  }
  
  func grainedRand() -> Double{
    let grain = 1.0e-4
    return Double(Int(uniformramdom()/grain))*grain
  }
    

  func testAddConstraintPerformance() {
    let constraintNumber = 500
    let vars = (0..<constraintNumber).map{ _ in return Variable()}
    
    var constraints = [Constraint]()
    
    let exprMaxVars: UInt32 = 3
    
    let constraintMake = constraintNumber * 2
    let inEqualProb = 0.12
    
    for _ in 0..<constraintMake{
      let expr = Expression(constant: grainedRand() * 20.0 - 10)
      let exprVarNumber = Int(uniformramdom()*Double(exprMaxVars)) + 1
      for _ in 0..<exprVarNumber{
        let index = Int(uniformramdom()*Double(constraintNumber - 1))
        let variable = vars[index]
        expr += variable * (grainedRand() * 10.0 - 5.0)
      }
      
      if uniformramdom() < inEqualProb{
        constraints.append(expr <= 0)
      }else{
        constraints.append(expr == 0)
      }
    }
    
    measureTime(desc: "testAddConstraintPerformance") {
      
      let solver = SimplexSolver()
      solver.autoSolve = true
      
      var added = 0,eCount = 0
      
      added = 0
      eCount = 0
      for c in constraints{
        if added < constraintNumber{
          do{
            try solver.add(constraint: c)
            added += 1
          }catch{
            eCount += 1
          }
          
        }else{
          break
        }
      }
    }
  }
  
  func testUpdateConstantPerformance(){
    
    let vars = (0..<500).map{ _ in return Variable()}
    
    var constraints = [Constraint]()
    
    let exprMaxVars: UInt32 = 3
    let constraintNumber = 500
    let constraintMake = constraintNumber * 2
    let inEqualProb = 0.12
    
    for _ in 0..<constraintMake{
      let expr = Expression(constant: grainedRand() * 20.0 - 10)
      let exprVarNumber = Int(uniformramdom()*Double(exprMaxVars)) + 1
      for _ in 0..<exprVarNumber{
        let index = Int(uniformramdom()*499)
        let variable = vars[index]
        expr += variable * (grainedRand() * 10.0 - 5.0)
      }
      
      if uniformramdom() < inEqualProb{
        constraints.append(expr <= 0)
      }else{
        constraints.append(expr == 0)
      }
    }
    
    let solver = SimplexSolver()
    solver.autoSolve = true
    
    var added = [Constraint]()
    
    for c in constraints{
      if added.count < constraintNumber{
        do{
          try solver.add(constraint: c)
          added.append(c)
        }catch{
          
        }
      }else{
        break
      }
    }
    
    
    measureTime(desc:"testUpdateConstantPerformance"){
      added.forEach{
        solver.updateConstant(for: $0, to:  grainedRand() * 20.0 - 10)
      }
    }
    
  }

}

