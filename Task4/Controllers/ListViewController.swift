//
//  ATMListViewController.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import SnapKit

protocol ATMListVCDelegate: AnyObject {
    func collectinItemSelected(installPlace: String)
}

final class ListViewController: UIViewController {
    
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
    var atms = [ATMElement]()
    var infoboxes = [InfoboxElement]()
    var filials = [FilialElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Список элементов"
        view.addSubview(collectionView)
        setupConstraints()
        applySnapshot(animatingDifferences: false)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, AnyHashable> {
            let dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
                collectionView: collectionView,
                cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, element: AnyHashable) ->
                    UICollectionViewCell? in
                    let cell = collectionView.dequeueReusableCell(
                                                withReuseIdentifier: String(describing: ListCollectionViewCell.self),
                                                for: indexPath) as? ListCollectionViewCell
                    switch element {
                    case let element as ATMElement:
                        cell?.setPropertiesForATM(atm: element)
                        return cell
                    case let element as InfoboxElement:
                        cell?.setPropertiesForInfobox(infobox: element)
                        return cell
                    case let element as FilialElement:
                        cell?.setPropertiesForFilial(filial: element)
                        return cell
                    default:
                        break
                    }
                    return UICollectionViewCell()
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
        var sections = [Section]()
        var atmsByCityDict = [String: [ATMElement]]()
        var infoboxByCityDict = [String: [InfoboxElement]]()
        var filialByCityDict = [String: [FilialElement]]()
        DispatchQueue.global().async {
            for atm in self.atms {
                if !atmsByCityDict.keys.contains(atm.city) {
                    atmsByCityDict[atm.city] = [atm]
                } else {
                    atmsByCityDict[atm.city]?.append(atm)
                }
            }
            for infobox in self.infoboxes {
                if !infoboxByCityDict.keys.contains(infobox.city) {
                    infoboxByCityDict[infobox.city] = [infobox]
                } else {
                    infoboxByCityDict[infobox.city]?.append(infobox)
                }
            }
            for filial in self.filials {
                if !filialByCityDict.keys.contains(filial.city) {
                    filialByCityDict[filial.city] = [filial]
                } else {
                    filialByCityDict[filial.city]?.append(filial)
                }
            }
            atmsByCityDict.forEach { city, atms in
                let section = Section(title: city, atms: atms)
                section.title += ": банкоматы"
                sections.append(section)
            }
            infoboxByCityDict.forEach { city, infoboxes in
                let section = Section(title: city, infoboxes: infoboxes)
                section.title += ": инфокиоски"
                sections.append(section)
            }
            filialByCityDict.forEach { city, filials in
                let section = Section(title: city, filials: filials)
                section.title += ": филиалы"
                sections.append(section)
            }
            let sortedSections = sections.sorted { $0.title < $1.title}
            let infoBoxSections = sections.filter { $0.title.hasSuffix("инфокиоски")
            }
            let atmSections = sections.filter { $0.title.hasSuffix("банкоматы")
            }
            let filialsSections = sections.filter { $0.title.hasSuffix("филиалы")
            }
            DispatchQueue.main.async {
                var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                snapshot.appendSections(sortedSections)
                infoBoxSections.forEach { section in
                    guard let infoboxes = section.infoboxes else { return }
                    snapshot.appendItems(infoboxes, toSection: section)
                }
                atmSections.forEach { section in
                    guard let atms = section.atms else { return }
                    snapshot.appendItems(atms, toSection: section)
                }
                filialsSections.forEach { section in
                    guard let filials = section.filials else { return }
                    snapshot.appendItems(filials, toSection: section)
                }
                self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
            }
        }
    }
}
    
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) as? any BelarusbankElement else { return }
        delegate?.collectinItemSelected(installPlace: item.installPlace)
    }
}
