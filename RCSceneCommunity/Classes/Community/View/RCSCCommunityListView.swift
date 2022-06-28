//
//  RCSceneGroupListView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

import UIKit

class RCSCCommunityListView: UIView {
    
    var createCommunityHandler: (() -> Void)?
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 66, height: 66)
        layout.scrollDirection = .vertical
        layout.footerReferenceSize = CGSize.init(width: 60, height: 66)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(RCSCCommunityListCell.self, forCellWithReuseIdentifier: RCSCCommunityListCell.reuseIdentifier)
        cv.register(RCSCCommunityAddView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RCSCCommunityAddView.reuseIdentifier)
        cv.register(RCSCCommunityEmptyFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RCSCCommunityEmptyFooterView.reuseIdentifier)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    var dataSource: Array<Array<RCSCCommunityListRecord>> = [[],[]]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        RCSCCommunityManager.manager.registerListener(listener: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTmpCommunityItem(record: RCSCDiscoverListRecord) {
        
        let record = RCSCCommunityListRecord(communityUid: record.communityUid, name: record.name, portrait: record.portrait, remark: record.remark)
        
        defer {
            RCSCCommunityManager.manager.fetchDetail(communityId: record.communityUid)
        }
        
        for (index, value) in dataSource[1].enumerated() {
            if value.communityUid == record.communityUid {
                collectionView.selectItem(at: IndexPath(row: index, section: 1), animated: false, scrollPosition: .top)
                return
            }
        }
        
        dataSource[0].removeAll()
        dataSource[0].append(record)
        collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    func removeTmpCommunityItem() -> String? {
        if dataSource[0].count > 0 {
            dataSource[0].removeAll()
            collectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
        }
        if dataSource[1].count > 0 {
            collectionView.selectItem(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .top)
            return dataSource[1][0].communityUid
        }
        return nil
    }
}

extension RCSCCommunityListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RCSCCommunityListCell.reuseIdentifier, for: indexPath) as! RCSCCommunityListCell
        let record = dataSource[indexPath.section][indexPath.row]
        cell.imageUrl = record.portrait
        cell.communityId = record.communityUid
        cell.isShowBadge = RCSCConversationMessageManager.isShowRedDot(communityId: record.communityUid)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == 0 {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RCSCCommunityEmptyFooterView.reuseIdentifier, for: indexPath)
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RCSCCommunityAddView.reuseIdentifier, for: indexPath) as! RCSCCommunityAddView
                footer.createCommunityHandler = createCommunityHandler
                return footer
            }
        }
        return UICollectionReusableView()
    }
}
 
extension RCSCCommunityListView: UICollectionViewDelegateFlowLayout {    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        } else {
            return CGSize(width: 60, height: 66)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension RCSCCommunityListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSource[indexPath.section][indexPath.row]
        RCSCCommunityManager.manager.fetchDetail(communityId: data.communityUid)
    }
}

extension RCSCCommunityListView: RCSCCommunityDataSourceDelegate {
    func updateCommunityList(list: Array<RCSCCommunityListRecord>?) {
        guard let list = list else {
            return
        }
        var needSetSelectedIndexPath = false
        /*空列表加载数据，默认选中第一个*/
        /*社区列表增加元素，新建或者关注，默认选中新增的社区*/
        needSetSelectedIndexPath = dataSource[1].count == 0 && list.count != 0 || dataSource[1].count != list.count ||  list.count == 1
        
        
        if (needSetSelectedIndexPath) {
            dataSource[0].removeAll()
        }
        dataSource[1] = list
        collectionView.reloadData()
        if (needSetSelectedIndexPath && !list.isEmpty) {
            collectionView.selectItem(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .top)
        } else if dataSource[0].count > 0 {
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    func createCommunitySuccess() { //TODO: 这里会受限,不是所有的情况都会成功
        RCSCCommunityManager.manager.fetchCommunityList()
    }
    
    func deleteCommunitySuccess(communityId: String) {
        for (index, record) in dataSource[0].enumerated() {
            if record.communityUid == communityId {
                dataSource[0].remove(at: index)
                collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                break
            }
        }
    }
    //JHNote: add: 新增一个刷新方法给外部 
    func reFreshData(){
        RCSCCommunityManager.manager.fetchCommunityList()
    }

}

