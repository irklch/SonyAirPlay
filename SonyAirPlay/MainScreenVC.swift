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
    var size: CGSize

    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.imageName == rhs.imageName && lhs.size == rhs.size // или другие уникальные свойства
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(imageName)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
}

// Вью-модель, хранящая данные для коллекции
class CollectionViewModel {
    // Начальные данные
    var items: [CellModel] = [
        CellModel(title: "Item 1", imageName: "image1", size: .init(width: 100, height: 150)),
        CellModel(title: "Item 2", imageName: "image2", size: .init(width: 100, height: 150)),
        CellModel(title: "Item 3", imageName: "image3", size: .init(width: 100, height: 150))
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
//        layout.itemSize = CGSize(width: 100, height: 150) // Размер ячеек
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

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
            cell.backgroundColor = .red
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

        // Кнопка "Изменить размер"
        alert.addAction(UIAlertAction(title: "Изменить размер", style: .default, handler: { _ in
            self.showResizeAlert(for: indexPath.row)
        }))

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

            self?.moveItem(from: indexPath.row, to: newPosition)
        }

        moveAlert.addAction(moveAction)
        moveAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(moveAlert, animated: true, completion: nil)
    }

    func moveItem(from oldPosition: Int, to newPosition: Int) {
        var validPosition = min(max(newPosition, 1), viewModel.items.count) // Если позиции нет, переместим в конец
        validPosition -= 1 // Приводим к индексу

        guard oldPosition != validPosition else { return } // Если позиция не меняется

        let itemToMove = viewModel.items[oldPosition]
        viewModel.items.remove(at: oldPosition) // Удаляем элемент из старой позиции
        viewModel.items.insert(itemToMove, at: validPosition) // Вставляем в новую позицию

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
        let dublicateItem: CellModel = .init(title: item.title, imageName: item.imageName, size: item.size)
        viewModel.items.append(dublicateItem)
        updateSnapshot()
    }

    // Показ алерта для изменения размера ячейки
    private func showResizeAlert(for index: Int) {
        let resizeAlert = UIAlertController(title: "Изменить размер", message: "Введите новый размер", preferredStyle: .alert)

        resizeAlert.addTextField { textField in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Ширина"
        }

        resizeAlert.addTextField { textField in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Высота"
        }

        resizeAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let widthText = resizeAlert.textFields?.first?.text, let heightText = resizeAlert.textFields?.last?.text,
               let width = Double(widthText), let height = Double(heightText) {
                self.viewModel.items[index].size = CGSize(width: width, height: height)
                self.updateSnapshot()
            }
        }))

        resizeAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(resizeAlert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleCellTap(at: indexPath)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.items[indexPath.item].size
    }
}
