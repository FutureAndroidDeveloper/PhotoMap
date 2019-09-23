//
//  PostView.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

extension UIView {
    static func createSeparator(color: UIColor, width: CGFloat = 1) -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.borderWidth = width
        line.layer.borderColor = color.cgColor
        
        return line
    }
}

class PostView: UIView {
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        
        return label
    }()
    
    lazy var categoryMarkerView: CategoryMarker = {
        let markerView = CategoryMarker()
        markerView.color = .gray
        return markerView
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.pickCategory().uppercased()
        return label
    }()
    
    lazy var categoryStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryMarkerView, categoryLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        
        return stack
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = nil
        textView.returnKeyType = .done
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        
        return textView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.red, for: .normal)
        
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.blue, for: .normal)
        
        return button
    }()
    
    private let fisrtLine = UIView.createSeparator(color: .black)
    private let secondLine = UIView.createSeparator(color: .black)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        addSubview(photoImageView)
        addSubview(dateLabel)
        addSubview(textView)
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(fisrtLine)
        addSubview(secondLine)
        addSubview(categoryStackView)
        photoImageView.isUserInteractionEnabled = true
        
        let leadingGuide = UILayoutGuide()
        let middleGuide = UILayoutGuide()
        let trailingGuide = UILayoutGuide()
        
        addLayoutGuide(leadingGuide)
        addLayoutGuide(middleGuide)
        addLayoutGuide(trailingGuide)
        
        layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let margins = layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: margins.topAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.5, constant: 0),
            
            dateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            dateLabel.topAnchor.constraint(equalToSystemSpacingBelow: photoImageView.bottomAnchor, multiplier: 2.0),
            
            fisrtLine.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            fisrtLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            fisrtLine.topAnchor.constraint(equalToSystemSpacingBelow: dateLabel.bottomAnchor, multiplier: 1.0),
            fisrtLine.heightAnchor.constraint(equalToConstant: 1),
            
            categoryStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            categoryStackView.topAnchor.constraint(equalToSystemSpacingBelow: fisrtLine.bottomAnchor, multiplier: 1.0),
            
            secondLine.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            secondLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            secondLine.topAnchor.constraint(equalToSystemSpacingBelow: categoryStackView.bottomAnchor, multiplier: 1.0),
            secondLine.heightAnchor.constraint(equalToConstant: 1),
            
            textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            textView.topAnchor.constraint(equalToSystemSpacingBelow: secondLine.bottomAnchor, multiplier: 1.0),
            textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.22, constant: 0),
            
            
            leadingAnchor.constraint(equalTo: leadingGuide.leadingAnchor),
            leadingGuide.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: middleGuide.leadingAnchor),
            middleGuide.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: trailingGuide.leadingAnchor),
            trailingGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            cancelButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor),
            
            leadingGuide.widthAnchor.constraint(equalTo: trailingGuide.widthAnchor),
            middleGuide.widthAnchor.constraint(equalTo: leadingGuide.widthAnchor, multiplier: 0.5),
            
            cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 1.0),
            cancelButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            
            doneButton.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 1.0),
            doneButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            ])
    }
}
