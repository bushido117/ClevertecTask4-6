//
//  ATMListViewController.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import Foundation
import UIKit
import SnapKit

protocol ATMListVCDelegate: AnyObject {
    func collectinItemSelected(installPlace: String)
}

final class ATMListViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.delegate = self
        collectionView.register(ListCollectionViewCell.self,
                                forCellWithReuseIdentifier: String(describing: ListCollectionViewCell.self))
        collectionView.register(HeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: "header",
                                withReuseIdentifier: String(describing: HeaderCollectionReusableView.self))
        return collectionView
    }()
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1 / 3
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fraction),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(0.35))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let inset: CGFloat = 2.5
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(30))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: "header",
            alignment: .top)
        headerItem.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }()
    private lazy var dataSource = makeDataSource()
    weak var delegate: ATMListVCDelegate?
    var atms: [ATMElement]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Список банкоматов"
        view.addSubview(collectionView)
        setupConstraints()
        applySnapshot(animatingDifferences: false)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ATMElement> {
            let dataSource = UICollectionViewDiffableDataSource<Section, ATMElement>(
                collectionView: collectionView,
                cellProvider: { (collectionView, indexPath, atm) ->
                    UICollectionViewCell? in
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ListCollectionViewCell.self),
                        for: indexPath) as? ListCollectionViewCell
                    cell?.setProperties(atm: atm)
                    return cell
                })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
          guard kind == "header" else {
            return HeaderCollectionReusableView()
          }
          let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: HeaderCollectionReusableView.self),
            for: indexPath) as? HeaderCollectionReusableView
          let section = dataSource.snapshot()
            .sectionIdentifiers[indexPath.section]
          view?.titleLabel.text = section.title
          return view
        }
            return dataSource
        }

    private func applySnapshot(animatingDifferences: Bool = true) {
        guard let atms = atms else { return }
        var sections = [Section]()
        var atmsByCityDict = [String: [ATMElement]]()
        for atm in atms {
            if !atmsByCityDict.keys.contains(atm.city) {
                atmsByCityDict[atm.city] = [atm]
            } else {
                atmsByCityDict[atm.city]?.append(atm)
            }
        }
        atmsByCityDict.forEach { city, atms in
            let section = Section(title: city, atms: atms)
            sections.append(section)
        }
        let sortedSections = sections.sorted { $0.title < $1.title}
        var snapshot = NSDiffableDataSourceSnapshot<Section, ATMElement>()
        snapshot.appendSections(sortedSections)
        sortedSections.forEach { section in
          snapshot.appendItems(section.atms, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ATMListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.collectinItemSelected(installPlace: item.installPlace)
    }
}
