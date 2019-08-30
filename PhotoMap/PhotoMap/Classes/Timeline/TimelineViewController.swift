//
//  TimelineViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimelineViewController: UIViewController, StoryboardInitializable {

    @IBOutlet weak var tableView: UITableView!
    private lazy var searchBar = UISearchBar()
    private let categoriesButton = UIBarButtonItem(title: "Category", style: .plain, target: nil, action: nil)
    private let bag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
    var viewModel: TimelineViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        viewModel.posts
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.category
                cell.detailTextLabel?.text = "\(element.date)"
            }
            .disposed(by: bag)
        
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.setPositionAdjustment(.zero, for: .search)
            })
            .disposed(by: bag)
        
        searchBar.rx.textDidEndEditing
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .filter { $0 == "" }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.setCenteredPlaceHolder(with: self.navigationItem.rightBarButtonItem!)
            })
            .disposed(by: bag)
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.endEditing(true)
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
        
        categoriesButton.rx.tap
            .bind(to: viewModel.showCategories)
            .disposed(by: bag)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.endEditing(true)
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        searchBar.setCenteredPlaceHolder(with: navigationItem.rightBarButtonItem!)
    }
    
    private func setupView() {
        searchBar.placeholder = "Search"
        let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField
        searchTextField?.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8941176471, blue: 0.9019607843, alpha: 1)
        self.navigationItem.rightBarButtonItem = categoriesButton
        self.navigationItem.titleView = searchBar
        view.addGestureRecognizer(tapGesture)
    }

}


extension UISearchBar {
    func setCenteredPlaceHolder(with barButton: UIBarButtonItem){
        let textFieldInsideSearchBar = self.value(forKey: "_searchField") as? UITextField
        
        //get the sizes
        let searchBarWidth = self.frame.width
        let placeholderIconWidth = textFieldInsideSearchBar?.leftView?.frame.width
        let placeHolderWidth = textFieldInsideSearchBar?.attributedPlaceholder?.size().width
        let rightButtonWidth = (barButton.value(forKey: "view") as? UIView)!.frame.width
        let offsetIconToPlaceholder: CGFloat = 8
        let placeHolderWithIcon = placeholderIconWidth! + offsetIconToPlaceholder
        
        let offset = UIOffset(horizontal: (searchBarWidth / 2 - placeHolderWidth! / 2 - placeHolderWithIcon - rightButtonWidth / 1.5), vertical: 0)
        self.setPositionAdjustment(offset, for: .search)
    }
}
