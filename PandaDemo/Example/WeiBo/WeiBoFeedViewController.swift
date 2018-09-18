//
//  WeiBoFeedViewController.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/2/26.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class WeiBoFeedViewController: UITableViewController {
  
  let statusNode = StatusNode()
  var statusViewModels = [WBStatusViewModel]()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      tableView.separatorStyle = .none
      
      // optimize point. if use estimatedRowHeight, it will create a lot of new cell when tableView is load, which will slow down launch time
      tableView.estimatedRowHeight = 0
      statusNode.width == UIScreen.main.bounds.width
//      statusNode.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 500)
    
      
      DispatchQueue.global().async {
        for index in 0..<8{
          autoreleasepool {
            let data = try! Data(contentsOf: URL(fileURLWithPath:Bundle.main.path(forResource: "weibo_\(index)", ofType: "json")! ))
            let items = WBTimelineItem.model(withJSON: data)
            let models = items?.statuses.map{ return WBStatusViewModel(status: $0) }
            self.statusViewModels.append(contentsOf: models!)
          }
        }
        for status in self.statusViewModels{
          self.statusNode.update(status)
          self.statusNode.layoutIfNeeded()
          status.layoutValues = self.statusNode.layoutValues
          status.height = self.statusNode.frame.height
        }
        
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
      
    }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WeiBo",for: indexPath) as! WeiBoCell
//    let time = measureTime(desc: "cellForRow:") {
      cell.statusNode.disableLayout()
      cell.update(for: statusViewModels[indexPath.row], needLayout: false)
      cell.statusNode.apply(statusViewModels[indexPath.row].layoutValues!)
//    }
    
    return cell
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return statusViewModels.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    let viewModel = statusViewModels[indexPath.row]
    
    if viewModel.height != 0{
      return viewModel.height
    }
  
    let time = measureTime(desc: "heightForRow:") {
      statusNode.update(viewModel)
      statusNode.layoutIfNeeded()
      viewModel.layoutValues = statusNode.layoutValues
    }
    
    viewModel.height = statusNode.layoutRect.height

    return viewModel.height
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}