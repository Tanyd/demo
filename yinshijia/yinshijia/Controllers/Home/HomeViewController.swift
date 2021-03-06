//
//  HomeViewController.swift
//  yinshijia
//
//  Created by Developer on 16/6/10.
//  Copyright © 2016年 tanyadong. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    private var pageVC: PageViewController!
    private var titleView: BtnPageView!
    private var navigationBar: HomeNavigationBar!
    private var allChildsVC = [UIViewController]()
    private var toTopIcon: UIButton!
    private var currentViewIndex = 0
    private let titleViewHeight = 64
    private var didScroll = false
    private var didOriginal = true
    private var choicePage = 0
    private let choiceMaxPage = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addNotification()
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.transform = CGAffineTransformIdentity
    }
    
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeUI:", name: BaseTranslationViewControllerNotification.NotificationName, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setUI() {
        navigationController?.delegate = self
        navigationBar = HomeNavigationBar(frame: CGRect(x: 0, y: 20, width: ScreenSize.SCREEN_WIDTH, height: 44),searchClick: {
                            print("searchClick")
            }, bellClick: { 
                print("bellClick")
            }) {
                print("cityChange")
        }
        view.addSubview(navigationBar)
        
        titleView = BtnPageView(frame:  CGRect(x: 0, y: 64, width: Int(ScreenSize.SCREEN_WIDTH), height: titleViewHeight), buttonTitles: ["精选","主厨","推荐"])
        titleView.delegate = self
        view.addSubview(titleView)
        
        pageVC = PageViewController()
        pageVC.dataSource = self
        pageVC.delegate = self
        addChildViewController(pageVC)
        pageVC.view.frame = CGRect(x: 0, y: 64 + titleViewHeight, width: Int(ScreenSize.SCREEN_WIDTH), height: Int(ScreenSize.SCREEN_HEIGHT) - titleViewHeight)
        view.addSubview(pageVC.view)

        toTopIcon = UIButton(type: .Custom)
        toTopIcon.frame = CGRect(x: ScreenSize.SCREEN_WIDTH - 170.0.fitWidth(), y: ScreenSize.SCREEN_HEIGHT - 100.0.fitHeight(), width: 180.0.fitWidth(), height: 80.0.fitWidth())
        toTopIcon.setBackgroundImage(UIImage(named: "backToTop"), forState: .Normal)
        toTopIcon.action = {[weak self] in self?.toTop()}
        toTopIcon.sizeToFit()
        view.addSubview(toTopIcon)
        view.setNeedsUpdateConstraints()
        
    }
    
    func toTop() {
        UIView.animateWithDuration(0.3) { 
            self.translationDown()
            
            switch self.currentViewIndex {
            case 0:
                let vc = self.allChildsVC[self.currentViewIndex] as! ChoiceViewController
                vc.tableView.contentOffset = CGPointZero
            case 1:
                let vc = self.allChildsVC[self.currentViewIndex] as! TranslationCollectionViewController
                vc.collectionView!.contentOffset = CGPointZero
            case 2:
                break
            default:
                break
            }
        }
    }
    
    
    func changeUI(notif: NSNotification) {
        
        let offY = notif.userInfo![BaseTranslationViewControllerNotification.CurrentOffY] as! CGFloat
        let oldY = notif.userInfo![BaseTranslationViewControllerNotification.OldOffY] as! CGFloat
        if offY > oldY && !didScroll { // up
            UIView.animateWithDuration(0.3, animations: { 
                self.translationUp()
            })
        }else if offY < oldY && !didOriginal { // down
            UIView.animateWithDuration(0.3, animations: {
                self.translationDown()
            })
        }
    }
    
    
    private func translationUp() {
        tabBarController?.tabBar.transform = CGAffineTransformMakeTranslation(0, 70)
        navigationBar.transform = CGAffineTransformMakeTranslation(0, -64)
        pageVC.view.transform = CGAffineTransformMakeTranslation(0, -64)
        titleView.transform = CGAffineTransformMakeTranslation(0, -64)
        toTopIcon.transform = CGAffineTransformMakeTranslation(0, -64)
        didScroll = true
        didOriginal = false
    }
    
    private func translationDown() {
        tabBarController?.tabBar.transform = CGAffineTransformIdentity
        navigationBar.transform = CGAffineTransformIdentity
        pageVC.view.transform = CGAffineTransformIdentity
        titleView.transform = CGAffineTransformIdentity
        toTopIcon.transform = CGAffineTransformIdentity
        didScroll = false
        didOriginal = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension HomeViewController: PageViewControllerDataSource, PageViewControllerDelegate, BtnPageViewDelegate {
    
    func childControllersInPageView(pageView: PageViewController) -> [UIViewController] {
        
        let vc1 = ChoiceViewController()
        allChildsVC.append(vc1)
        vc1.view.tag = 0

        let vc2 = ChefViewController()
        allChildsVC.append(vc2)
        vc2.view.tag = 1
        
        let vc3 = MarketViewController()
        allChildsVC.append(vc3)
        vc3.view.tag = 2
        vc3.view.backgroundColor = UIColor.blueColor()
        
        return [vc1,vc2,vc3]
    }
    
    func pageViewExchangeView(fromIndex: Int, toIndex: Int) {
        titleView.exchangeSelectedButton(fromIndex, toIndex: toIndex)
        currentViewIndex = toIndex
    }

    
    func btnPageViewDidTouchButton(fromIndex: Int, toIndex: Int) {
        pageVC.exchangeChildView(fromIndex, toIndex: toIndex)
        currentViewIndex = toIndex
    }
    
    
}

extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController.isKindOfClass(self.classForCoder) {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }
}

