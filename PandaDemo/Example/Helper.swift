//
//  RandomText.swift
//  Cassowary
//
//  Created by nangezao on 2017/12/4.
//  Copyright © 2017年 nange. All rights reserved.
//

import Foundation

@discardableResult
func measureTime(desc: String? = nil,action:()->()) -> Double{
  let renderStart = CFAbsoluteTimeGetCurrent()
  action()
  let renderEnd = CFAbsoluteTimeGetCurrent()
  let renderTime = (renderEnd - renderStart)*100000/100
  if let desc = desc{
    print("\(desc) : \(renderTime)")
  }
  return renderTime
}
