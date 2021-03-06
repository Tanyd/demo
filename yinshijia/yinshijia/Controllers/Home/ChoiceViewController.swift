//
//  SelectionViewController.swift
//  yinshijia
//
//  Created by Developer on 16/6/10.
//  Copyright © 2016年 tanyadong. All rights reserved.
//

import UIKit

class ChoiceViewController: TranslationTableViewController {

    private var headerView: HeaderView!
    private var choicePage = 0
    private let choiceMaxPage = 5
    private var arrayIndex = [NSIndexPath]()
    private var isLoding: Bool = false {
        didSet{
            tableView.reloadEmptyDataSet()
        }
    }
    var choiceModel: Choice?{
        didSet{
            headerView.categorys = (choiceModel?.data?.catalog)!
            headerView.banners = (choiceModel?.data?.banner)!
            tableView.reloadData()
        }
    }
    
    var dinnerLists = [Dinnerlist](){
        didSet{
            choiceModel!.data!.dinnerList! = (choiceModel!.data!.dinnerList!) + dinnerLists
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
//        tableView.mj_header.beginRefreshing()
    }

    private func setUI() {
        tableView.registerClass(ChoiceCell.self, forCellReuseIdentifier: String(ChoiceCell))
        headerView = HeaderView(frame: CGRectMake(0, 0, 0, 540.0.fitHeight()))
        headerView.hidden = true
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func tableRefreshHeader() {
        tableView.mj_footer.resetNoMoreData()
        let callBack: BaseApiCallBack = {[weak self](result, error) in
            guard error == nil else {
                self!.tableView.mj_header.endRefreshing()
                return
            }
            let model = result as! Choice
            self!.choiceModel = model
            self!.tableView.mj_header.endRefreshing()
            self!.isLoding = false
            self!.headerView.hidden = false
        }
        Choice.loadChoiceBaseData(callBack)
    }
    
    override func tableRefreshFooter() {
        choicePage += 1
        
        if choicePage > choiceMaxPage || choiceModel == nil{
            tableView.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        let callBack: BaseApiCallBack = {[weak self] (result, error) in
            guard error == nil else {
                self!.tableView.mj_footer.endRefreshing()
                self!.choicePage -= 1
                return
            }
            let model = result as! ChoiceOnlyDinnerlists
            self!.dinnerLists = model.data!
            self!.tableView.mj_footer.endRefreshing()
        }
        Choice.loadChoiceMoreData(callBack, page: choicePage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceModel?.data?.dinnerList?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = String(ChoiceCell)
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ChoiceCell
        if cell == nil {
            cell = ChoiceCell(style: .Default, reuseIdentifier: identifier)
        }
        let model = choiceModel?.data?.dinnerList?[indexPath.row]
        cell!.choiceModel = model
        cell!.dinnerChefClick = { (chefID) in
            DebugPrint("点击了chef id\(chefID)")
            let chefInfoVC = ChefInfoViewController()
            chefInfoVC.chefID = chefID
            self.navigationController?.pushViewController(chefInfoVC, animated: true)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       return tableView.fd_heightForCellWithIdentifier(String(ChoiceCell), cacheByIndexPath: indexPath) { (cell) in
            let cell = cell as! ChoiceCell
            let model = self.choiceModel?.data?.dinnerList?[indexPath.row]
            cell.choiceModel = model
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChoiceCell
        DebugPrint("点击了dinner \(cell.tag)")
        let toView = DinnerDetailViewController()
        toView.chefDinnerID = cell.tag
        navigationController?.pushViewController(toView, animated: true)
    }
    
}

extension ChoiceViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if isLoding == true {
            return NSAttributedString(string: "拼命加载中ing...", attributes: [NSFontAttributeName:UIFont(name: Constant.Common.DefaultFont, size: 13)!,NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        }else{
            return NSAttributedString(string: "网络故障，请尝试刷新", attributes: [NSFontAttributeName:UIFont(name: Constant.Common.DefaultFont, size: 13)!,NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        if isLoding == true {
            return UIImage(named: "loading")
        }else{
            return UIImage(named: "placeholder_remote")
        }
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -50
    }
    
    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool {
        return isLoding
    }
    
    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.cumulative = true
        animation.repeatCount = MAXFLOAT
        return animation
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        isLoding = true
        tableRefreshHeader()
    }
   
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        isLoding = true
        tableRefreshHeader()
    }
}


extension ChoiceViewController: HeaderViewDelegate {

    func headerViewBannerDidClick(index: Int) {
        DebugPrint("点击了banner \(index)")
        let listVC = ChoiceListTableViewController()
        listVC.bannerId = index
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    func headerViewCateoryDidClick(categoryBtn: UIButton) {
        DebugPrint("点击了CategoryButton \(index)")
        let listVC = ChoiceListTableViewController()
        listVC.categoryId = categoryBtn.tag
        listVC.navigationItem.title = categoryBtn.currentTitle
        navigationController?.pushViewController(listVC, animated: true)
    }
}