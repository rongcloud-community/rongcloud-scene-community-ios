//
//  RCSCSearchBar.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/11.
//

import UIKit

class RCSCSearchBar: UIView {
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect.zero)
        searchBar.barStyle = .default
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchTextField.backgroundColor = Asset.Colors.grayF6F6F6.color
        searchBar.backgroundColor = Asset.Colors.grayF6F6F6.color
        searchBar.barTintColor = Asset.Colors.grayF6F6F6.color
        searchBar.placeholder = "搜索昵称"
        return searchBar
    }()
    
    var searchBarDelegate: UISearchBarDelegate? {
        willSet {
            searchBar.delegate = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 22
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
