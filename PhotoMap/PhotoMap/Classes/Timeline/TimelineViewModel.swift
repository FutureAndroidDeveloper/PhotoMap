//
//  TimelineViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/29/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class TimelineViewModel {
    // MARK: - Private Properies
    private var savedsectionModels = [SectionOfPostAnnotation]()
    private var sectionData = [String: [PostAnnotation]]()
    private let defaults = UserDefaults.standard
    private let dateService: DateService
    private let coreDataService: CoreDataService
    
    // MARK: - Input
    let showCategories: AnyObserver<Void>
    let downloadUserPost: AnyObserver<Void>
    let updateFilteredPosts: AnyObserver<[PostAnnotation]>
    let categoriesSelected: AnyObserver<Void>
    let showFullPhoto: AnyObserver<PostAnnotation>
    let searchText: AnyObserver<String>
    
    // MARK: - Output
    let categoriesTapped: Observable<Void>
    let sections: Observable<[SectionOfPostAnnotation]>
    let selectedPost: Observable<PostAnnotation>
    
    init(firebaseService: FirebaseDeleagate = FirebaseService(),
         firebaseDownloadDelegate: FirebaseDownloading = FirebaseDownloadDelegate(),
         dateService: DateService = DateService(),
         coreDataService: CoreDataService = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate)) {
        
        firebaseService.setDownloadDelegate(firebaseDownloadDelegate)
        
        self.dateService = dateService
        self.coreDataService = coreDataService
        
        let _categories = PublishSubject<Void>()
        showCategories = _categories.asObserver()
        categoriesTapped = _categories.asObservable()
        
        let _sections = PublishSubject<[SectionOfPostAnnotation]>()
        sections = _sections.asObservable()
        
        let _shouldDownload = PublishSubject<Void>()
        downloadUserPost = _shouldDownload.asObserver()
        
        let _updatePosts = PublishSubject<[PostAnnotation]>()
        updateFilteredPosts = _updatePosts.asObserver()
        
        let _categoriesSelected = PublishSubject<Void>()
        categoriesSelected = _categoriesSelected.asObserver()
        
        let _showFullPhoto = PublishSubject<PostAnnotation>()
        showFullPhoto = _showFullPhoto.asObserver()
        selectedPost = _showFullPhoto.asObservable()
        
        let _searchText = PublishSubject<String>()
        searchText = _searchText.asObserver()
        
        _ = _searchText
            .filter { $0.isEmpty }
            .map { _ in self.filter() }
            .flatMap { self.buildSections(posts: $0) }
            .subscribe(onNext: { _sections.onNext($0) })
        
        _ = _searchText
            .filter { $0.count > 1 }
            .map { $0.hashtags() }
            .map { [weak self] hashtags -> [PostAnnotation] in
                guard let self = self else { return [] }
                return self.getPosts(with: hashtags)
            }
            .flatMap { self.buildSections(posts: $0) }
            .subscribe(onNext: { _sections.onNext($0) })
        
        _ = _categoriesSelected
            .map { [weak self] _ -> [PostAnnotation] in
                guard let self = self else { return  [] }
                return self.filter()
            }
            .bind(to: _updatePosts)
        
        _ = _shouldDownload
            .flatMap { _ in
                firebaseService.downloadUserPosts()
                    .distinctUntilChanged()
                    .flatMap { [weak self] posts -> Observable<[SectionOfPostAnnotation]> in
                        guard let self = self else { return .empty() }
                        return self.buildSections(posts: posts)
                }
            }
            .do(onNext: { [weak self] sections in
                guard let self = self else { return }
                self.savedsectionModels = sections
            })
            .flatMap { [weak self] _ -> Observable<[SectionOfPostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.buildSections(posts: self.filter())
            }
            .bind(to: _sections)
        
        _ = _updatePosts
            .flatMap { self.buildSections(posts: $0) }
            .subscribe(onNext: { _sections.onNext($0) })
    }
    
    func getPostDate(timestamp: Int) -> String {
        return dateService.getShortDate(timestamp: timestamp, yearLength: .short)
    }
    
    func getLocalizedCategoryName(engName: String) -> Observable<String> {
        return coreDataService.fetch()
            .compactMap { $0.first(where: { category -> Bool in
                category.engName.uppercased() == engName.uppercased()
            })}
            .map { $0.description.uppercased() }
            .take(1)
    }
    
    private func filter() -> [PostAnnotation] {
        let uncheckedCategories = defaults.object(forKey: "savedCategories") as? [String] ?? []
        var filteredPosts = [PostAnnotation]()
        
        self.savedsectionModels.forEach { sectionOfPostAnnotation in
            sectionOfPostAnnotation.items.forEach { post in
                if !uncheckedCategories.contains(post.category.lowercased()) {
                    filteredPosts.append(post)
                }
            }
        }
        return filteredPosts
    }
    
    private func getPosts(with hashtags: [String]) -> [PostAnnotation] {
        let uncheckedCategories = defaults.object(forKey: "savedCategories") as? [String] ?? []
        var resultPosts = [PostAnnotation]()
        
        self.savedsectionModels.forEach { section in
            section.items.forEach { post in
                guard let postHashtags = post.postDescription?.hashtags() else { return }
                hashtags.forEach{ hashtag in
                    if postHashtags.contains(hashtag) && !resultPosts.contains(post)
                        && !uncheckedCategories.contains(post.category.lowercased()) {
                        resultPosts.append(post)
                    }
                }
            }
        }
        return resultPosts
    }
    
    public func buildSections(posts: [PostAnnotation]) -> Observable<[SectionOfPostAnnotation]> {
        sectionData.removeAll()
        for post in posts {
            let sectionTitle = dateService.getMonthAndYear(timestamp: post.date)
            if let _ =  sectionData[sectionTitle] {
                sectionData[sectionTitle]!.append(post)
            } else {
                sectionData[sectionTitle] = [post]
            }
        }
        // Sections sorted by date
        return Observable.just(sectionData
            .map(SectionOfPostAnnotation.init)
            .sorted(by: >))
    }
}

extension String {
    func hashtags() -> [String] {
        var hashtags: [String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: self, options: [], range: NSMakeRange(0, self.count)) {
            for match in matches {
                hashtags.append(NSString(string: self).substring(with: NSRange(location: match.range.location,
                                                                               length: match.range.length )))
            }
        }
        return hashtags
    }
}
