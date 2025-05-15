//
//  ViewController.swift
//  EditableTextView
//
//  Created by 양호준 on 5/15/25.
//

import UIKit

import SnapKit

final class ViewController: UIViewController {
    private let textView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributes()
        configureSubviewLayout()
    }

    private func setAttributes() {
        view.backgroundColor = .white
    }

    private func configureSubviewLayout() {
        view.addSubview(textView)

        textView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
}
