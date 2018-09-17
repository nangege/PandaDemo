//
//  TestViewController.swift
//  Cassowary
//
//  Created by nangezao on 2017/10/25.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

let CassoawayIdeitifier = "identifier"
let AutolayoutIdentifier = "autolayoutIdentifier"
let layoutIdentifier = "layoutIdentifier"

class QHotel{
  var hotelName = randomText() + "生命是跌撞得曲折，死亡时宁静的星辰，归于尘土，归于雨露。这世上不再有我，却又无处不是我"
  var score = randomText()
  var address = randomText()
  var price = randomText()
  var imageName = "pia"
}

class ImageTextViewController: UIViewController {
  
  let tableView = UITableView()
  var barItem:UIBarButtonItem!
  
  let hotelRender = ImageTextNode()
  let heightCell = AutoLayoutCell()
  
  lazy var height: CGFloat = {
    hotelRender.update(hotels[0])
    hotelRender.layoutIfNeeded()
    return hotelRender.layoutRect.height
  }()
  
  func heightFor(_ hotel: QHotel) -> CGFloat{
    hotelRender.update(hotel)
    hotelRender.layoutIfNeeded()
    return hotelRender.layoutRect.height
  }
  
  lazy var hotels: [QHotel] = {
    return (0 ..< 100).map{ _ in QHotel() }
  }()
  
  var layoutCache = [LayoutValues]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 0
    self.title = useAutolayout ? "UIKit" : "Cassowary"
    hotelRender.width == UIScreen.main.bounds.width
    DispatchQueue.global().async {
      //self.updateCache()
      DispatchQueue.main.async(execute: {
//        self.updateCache()
        self.initTableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        let rightItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action:   #selector(self.switchMode))
        self.barItem = rightItem
        self.navigationItem.rightBarButtonItem = rightItem

      })
      
    }
  }
  
  var useAutolayout = true
    
  func initTableView(){
    view.addSubview(tableView)
    tableView.register(ImageTextCell.self, forCellReuseIdentifier: CassoawayIdeitifier)
    tableView.register(AutoLayoutCell.self, forCellReuseIdentifier: AutolayoutIdentifier)
    tableView.register(PureFrameCell.self, forCellReuseIdentifier: layoutIdentifier)
    tableView.frame = view.bounds
  }
  
  func updateCache(){
    layoutCache.removeAll()
    hotels.forEach{
      let start = CFAbsoluteTimeGetCurrent()
      hotelRender.update($0)
      hotelRender.layoutIfNeeded()
      let end = CFAbsoluteTimeGetCurrent()
      let duration = (end - start)*1000
      print("Time Duration: \(duration)")
      layoutCache.append(hotelRender.layoutValues)
    }
    
    
  }
  
  @objc func switchMode(){
    useAutolayout = !useAutolayout
    self.title = useAutolayout ? "UIKit" : "Cassowary"
    tableView.reloadData()
  }

}

extension ImageTextViewController: UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hotels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if useAutolayout{
      let cell = tableView.dequeueReusableCell(withIdentifier: AutolayoutIdentifier, for: indexPath) as! AutoLayoutCell
      cell.update(hotels[indexPath.row])
//      let cell = tableView.dequeueReusableCell(withIdentifier: layoutIdentifier, for: indexPath) as! PureFrameCell
//      cell.updateHotel(hotels[indexPath.row], layout: layoutCache[indexPath.row])
      return cell
    }else{
      let cell = tableView.dequeueReusableCell(withIdentifier: CassoawayIdeitifier, for: indexPath) as! ImageTextCell
//      cell.updateHotel(hotels[indexPath.row], layout: layoutCache[indexPath.row])
      cell.update(hotels[indexPath.row])
  
      return cell
    }

  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if useAutolayout{
      heightCell.update(hotels[indexPath.row])
      heightCell.layoutIfNeeded()
      return heightCell.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity)).height
    }else{
      return heightFor(hotels[indexPath.row])
    }
  }
  
}
