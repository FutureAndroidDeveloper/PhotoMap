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
    
    private var tapGesture: UITapGestureRecognizer!
    
    var color: UIColor = .green {
        willSet {
            checkButton.backgroundColor = newValue
            checkButton.layer.borderColor = newValue.cgColor
            categoryLabel.textColor = newValue
        }
    }

    var isChecked: Bool {
        get {
            return checkButton.backgroundColor != .white
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
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(frameTapped))
        contentView.addGestureRecognizer(tapGesture)
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
