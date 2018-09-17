//
//  RandomText.swift
//  Cassowary
//
//  Created by nangezao on 2017/12/4.
//  Copyright © 2017年 nange. All rights reserved.
//

import Foundation

func randomText() -> String{
  let count = arc4random()%16
  let text = "abcdefghijklmnopqrstuvwxyz"
  var result = "😆😆哈哈"
  for i in 0..<count{
    let index = text.index(text.startIndex, offsetBy: Int(i))
    result += text[index].description
  }
  return result
}

@discardableResult func measureTime(desc: String? = nil,action:()->()) -> Double{
  let renderStart = CFAbsoluteTimeGetCurrent()
  action()
  let renderEnd = CFAbsoluteTimeGetCurrent()
  let renderTime = (renderEnd - renderStart)*100000/100
  if let desc = desc{
    print("\(desc) : \(renderTime)")
  }
  return renderTime
}
