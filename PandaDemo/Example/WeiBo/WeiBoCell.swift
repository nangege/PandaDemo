//
//  WeiBoCell.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/2/26.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda
import Layoutable

class WeiBoCell: UITableViewCell {


  let statusNode = StatusNode()
  
  override func awakeFromNib() {
      super.awakeFromNib()
    print("newly alloc WBCell")
    contentView.addSubview(statusNode.view)
    statusNode.width == UIScreen.main.bounds.width
    statusNode.setNeedsLayout()
  }
  
  func update(for status: WBStatusViewModel, needLayout: Bool = true){
    statusNode.update(status, needLayout: needLayout)
    statusNode.layoutIfNeeded()
  }
}
