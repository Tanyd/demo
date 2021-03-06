//
//  FeatureDinnerCell.swift
//  yinshijia
//
//  Created by tanyadong on 16/6/19.
//  Copyright © 2016年 tanyadong. All rights reserved.
//

import UIKit

class FeatureDinnerCell: UITableViewCell {

    private var didUpdateConstraints = false
    private var childTableH: CGFloat = 0
    private lazy var featureTable: FeatureDinnerTableView = {
        let table = FeatureDinnerTableView(frame: CGRectZero, style: .Plain)
        return table
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(featureTable)
        setNeedsUpdateConstraints()
    }

    func configureModel(model: [Menu]?) {
        if model?.count > 0 {
            var totalH: CGFloat = 0
            for menu in model! {
                let despH = (menu.desp! as NSString).getTextRectSize(UIFont.systemFontOfSize(12), size: CGSize(width: ScreenSize.SCREEN_WIDTH - 60.0.fitWidth(), height: CGFloat.max)).height
                let cellH = 720.0.fitHeight() + despH
                totalH += cellH
            }
            childTableH = totalH + 145.0.fitHeight()
            featureTable.model = model!
        }
    }
    
    override func updateConstraints() {
        if !didUpdateConstraints {
            featureTable.autoPinEdgeToSuperviewEdge(.Right)
            featureTable.autoPinEdgeToSuperviewEdge(.Top)
            featureTable.autoPinEdgeToSuperviewEdge(.Left)
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityDefaultHigh, forConstraints: { 
                featureTable.autoPinEdgeToSuperviewEdge(.Bottom)
            })
            featureTable.autoSetDimension(.Height, toSize: childTableH)
            didUpdateConstraints = true
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

