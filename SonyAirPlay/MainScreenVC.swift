//
//  MainScreenVC.swift
//  SonyAirPlay
//
//  Created by Ирина Кольчугина on 03.12.2023.
//

import UIKit
import SnapKit

// Модель данных для ячейки
struct CellModel: Hashable {
    let id = UUID() // Уникальный идентификатор
    let title: String
    let imageName: String
}

// Вью-модель, хранящая данные для коллекции
class CollectionViewModel {
    // Начальные данные
    var items: [CellModel] = [
        CellModel(title: "Item 1", imageName: "image1"),
        CellModel(title: "Item 2", imageName: "image2"),
        CellModel(title: "Item 3", imageName: "image3")
    ]
}
class CollectionViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, CellModel>!
    private var viewModel = CollectionViewModel() // Вью-модель

    // Определение секций коллекции (в нашем случае одна секция)
    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
        updateSnapshot()
    }

    // Инициализация и настройка UICollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 150) // Размер ячеек
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    // Конфигурация dataSource для UICollectionView
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, CellModel> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            content.text = item.title
            content.image = UIImage(named: item.imageName)
            content.imageProperties.maximumSize = CGSize(width: 80, height: 80)
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, CellModel>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    // Обновление снапшота коллекции
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // Обработка действия нажатия на ячейку
    private func handleCellTap(at indexPath: IndexPath) {
        let selectedItem = viewModel.items[indexPath.row]

        let alert = UIAlertController(title: "Действия", message: "Выберите действие с элементом", preferredStyle: .alert)

        // Кнопка "Удалить"
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteItem(selectedItem)
        }

        // Кнопка "Дублировать"
        let duplicateAction = UIAlertAction(title: "Дублировать", style: .default) { [weak self] _ in
            self?.duplicateItem(selectedItem)
        }

        // Кнопка "Переместить"
        let moveAction = UIAlertAction(title: "Переместить", style: .default) { [weak self] _ in
            self?.showMoveAlert(for: selectedItem, at: indexPath)
        }

        alert.addAction(deleteAction)
        alert.addAction(duplicateAction)
        alert.addAction(moveAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func showMoveAlert(for item: CellModel, at indexPath: IndexPath) {
        let moveAlert = UIAlertController(title: "Переместить элемент", message: "Введите номер позиции", preferredStyle: .alert)

        // Добавляем текстовое поле для ввода номера позиции
        moveAlert.addTextField { textField in
            textField.placeholder = "Введите номер позиции"
            textField.keyboardType = .numberPad
        }

        let moveAction = UIAlertAction(title: "Переместить", style: .default) { [weak self] _ in
            guard let positionText = moveAlert.textFields?.first?.text,
                  let newPosition = Int(positionText) else { return }

            self?.moveItem(item, from: indexPath.row, to: newPosition)
        }

        moveAlert.addAction(moveAction)
        moveAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(moveAlert, animated: true, completion: nil)
    }

    func moveItem(_ item: CellModel, from oldPosition: Int, to newPosition: Int) {
//        var snapshot = dataSource.snapshot()
//
//        // Удаляем элемент из текущей позиции
//        snapshot.deleteItems([item])

        // Рассчитываем новую позицию
        var validPosition = min(newPosition, viewModel.items.count) // Если позиции нет, переместим в конец
        validPosition = max(1, validPosition) - 1
        // Вставляем элемент в новую позицию
//        snapshot.insertItems([item], afterItem: snapshot.itemIdentifiers(inSection: .main)[validPosition - 1])
        let lastElement = viewModel.items[oldPosition]
        let newElement = viewModel.items[validPosition]
        viewModel.items[oldPosition] = newElement
        viewModel.items[validPosition] = lastElement

        // Применяем новый снапшот
        updateSnapshot()
    }

    // Удаление ячейки
    private func deleteItem(_ item: CellModel) {
        if let index = viewModel.items.firstIndex(of: item) {
            viewModel.items.remove(at: index)
            updateSnapshot()
        }
    }

    // Дублирование ячейки
    private func duplicateItem(_ item: CellModel) {
        let dublicateItem: CellModel = .init(title: item.title, imageName: item.imageName)
        viewModel.items.append(dublicateItem)
        updateSnapshot()
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleCellTap(at: indexPath)
    }
}
