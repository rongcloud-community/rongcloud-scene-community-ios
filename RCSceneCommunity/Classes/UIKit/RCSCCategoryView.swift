//
//  RCSCSegmentedControl.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/11.
//

import UIKit

let RCSCCategoryViewCellReuseIdentifier = "RCSCCategoryViewCellReuseIdentifier"

protocol RCSCCategoryViewDelegate: NSObjectProtocol {
    func categoryViewDidSelect(index: Int, categoryModel: RCSCCategoryViewModel)
}

struct RCSCCategoryViewModel {
    let title: String
    var count: Int
    var selected: Bool = false
    var type: RCSCCommunityUserType = .online
}

class RCSCCategoryView: UIView {
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 20)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(RCSCCategoryViewCell.self, forCellWithReuseIdentifier: RCSCCategoryViewCellReuseIdentifier)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayF6F6F6.color
        return line
    }()
    
    private lazy var indicator: UIView = {
        let indicator = UIView()
        indicator.backgroundColor = Asset.Colors.blue0099FF.color
        return indicator
    }()
    
    var selectedIndex = 0
    
    var dataSource: Array<RCSCCategoryViewModel> = Array() {
        willSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: RCSCCategoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        collectionView.addSubview(indicator)
    }
}
    
extension RCSCCategoryView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RCSCCategoryViewCellReuseIdentifier, for: indexPath) as! RCSCCategoryViewCell
        var data = dataSource[indexPath.row]
        data.selected = indexPath.row == selectedIndex
        cell.data = data
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath)
        UIView.animate(withDuration: 0.2) {
            self.indicator.center = CGPoint(x: cell.center.x, y: cell.center.y + 20)
        }
        delegate?.categoryViewDidSelect(index: indexPath.row, categoryModel: dataSource[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == selectedIndex && indicator.frame == CGRect.zero) {
            indicator.frame = CGRect(x: 0, y: 25, width: 35, height: 5)
            self.indicator.center = CGPoint(x: cell.center.x, y: cell.center.y + 20)
        }
    }
}

class RCSCCategoryViewCell: UICollectionViewCell {
    
    var data: RCSCCategoryViewModel? {
        willSet {
            if let newValue = newValue {
                let color: UIColor = newValue.selected ? .black : Asset.Colors.grayC4C4C4.color
                let titleAttributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .regular)]
                let titleAttributeString = NSMutableAttributedString(string: newValue.title, attributes: titleAttributes)
                
                let countAttributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)]
                let countAttributeString = NSMutableAttributedString(string: "  \(newValue.count)", attributes: countAttributes)
                
                titleAttributeString.append(countAttributeString)
                
                contentLabel.attributedText = titleAttributeString
            }
        }
    }
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
