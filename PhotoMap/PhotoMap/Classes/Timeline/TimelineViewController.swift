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
import RxDataSources
import Kingfisher

class TimelineViewController: UIViewController, StoryboardInitializable, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private lazy var searchBar = UISearchBar()
    private var categoriesButton: UIBarButtonItem!
    private let bag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfPostAnnotation>!
    var viewModel: TimelineViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfPostAnnotation>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let self = self else { fatalError(#function) }
                let cell = tableView.dequeueReusableCell(withIdentifier: TimelineTableViewCell.reuseIdentifier, for: indexPath) as! TimelineTableViewCell

                cell.isUserInteractionEnabled = false
                let date = self.viewModel.getPostDate(timestamp: item.date)
                cell.postView.dateLabel.text = "\(date) / \(item.category)"
                cell.postView.descriptionLabel.text = item.postDescription

                let url = URL(string: item.imageUrl!)
                cell.postView.photoImageView.kf.indicatorType = .activity
                cell.postView.photoImageView.kf.setImage(with: url, completionHandler: { (image, _, _, _) in
                    cell.isUserInteractionEnabled = true
                    item.image = image
                })
                
                return cell
        })
        
        searchBar.rx.text
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: bag)

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return self.dataSource[indexPath]
            }
            .bind(to: viewModel.showFullPhoto)
            .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
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
        if !(searchBar.positionAdjustment(for: .search) == .zero) {
            searchBar.setCenteredPlaceHolder(with: navigationItem.rightBarButtonItem!)
        }
    }
    
    private func setupView() {
        searchBar.placeholder = "Search"
        let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField
        searchTextField?.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8941176471, blue: 0.9019607843, alpha: 1)
        categoriesButton = UIBarButtonItem(title: "Category", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = categoriesButton
        self.navigationItem.titleView = searchBar
        view.addGestureRecognizer(tapGesture)
    }
}

extension TimelineViewController {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TimelineTableHeader(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        headerView.dateLabel.text = dataSource[section].header
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
