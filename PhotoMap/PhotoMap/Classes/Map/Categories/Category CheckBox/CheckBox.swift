//
//  CheckBox.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/28/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

class CheckBox: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var removeCategoryButton: UIButton!
    
    private var tapGesture: UITapGestureRecognizer!
    
    weak var delegate: CheckBoxDelegate?
    var color: UIColor = .green {
        willSet {
            checkButton.backgroundColor = newValue
            checkButton.layer.borderColor = newValue.cgColor
        }
    }

    var isChecked: Bool {
        get {
            return checkButton.backgroundColor != .white
        }
        set {
            if newValue {
                checkButton.backgroundColor = color
            } else {
                checkButton.backgroundColor = .white
            }
        }
    }
    
    var categoryName: String = "" {
        willSet {
            let strokeTextAttributes = [
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.strokeWidth: -1.5,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)
                ] as [NSAttributedString.Key: Any]
            
            let customizedText = NSMutableAttributedString(string: newValue,
                                                           attributes: strokeTextAttributes)
            categoryLabel.attributedText = customizedText
        }
    }
    
    var verticalSpacing: CGFloat = 10

    var height: CGFloat {
        get {
            return verticalSpacing * 2 + checkButton.bounds.height
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        _ = R.nib.checkBox(owner: self)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.heightAnchor.constraint(equalToConstant: height)
            ])

        checkButton.layer.cornerRadius = checkButton.bounds.height / 2
        checkButton.layer.borderWidth = 2
        removeCategoryButton.setImage(R.image.removeCategory(), for: .normal)
        removeCategoryButton.setImage(R.image.removeCategorySelected(), for: .highlighted)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(frameTapped))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func removeCategory(_ sender: UIButton) {
        guard let delegate = self.delegate else { return }
            delegate.removeCategoryTapped(with: color, name: categoryLabel.text!)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        animateCheckBox()
    }
    
    @objc private func frameTapped() {
        animateCheckBox()
    }
    
    private func animateCheckBox() {
        UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
            if self.checkButton.backgroundColor == .white {
                self.checkButton.backgroundColor = self.color
            } else {
                self.checkButton.backgroundColor = .white
            }
        }.startAnimation()
    }
}

protocol CheckBoxDelegate: class {
    func removeCategoryTapped(with color: UIColor, name: String)
}
