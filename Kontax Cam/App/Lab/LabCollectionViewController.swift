//
//  LabCollectionViewController.swift
//  Kontax Cam
//
//  Created by Kevin Laminto on 25/5/20.
//  Copyright © 2020 Kevin Laminto. All rights reserved.
//

import UIKit
import DTPhotoViewerController

private let reuseIdentifier = "labCell"

class LabCollectionViewController: UICollectionViewController {
    
    private var isSelecting = false
    
    private var images: [UIImage] = []
    private var selectedImageIndex: Int = 0
    private let photoLibraryEngine = PhotoLibraryEngine()
    private let selectButton: UIButton = {
        let v = UIButton()
        v.setImage(IconHelper.shared.getIconImage(iconName: "square.and.pencil"), for: .normal)
        v.titleLabel?.numberOfLines = 0
        v.tintColor = .label
        return v
    }()
    private let fabDeleteButton: UIButton = {
        let v = UIButton()
        v.setImage(IconHelper.shared.getIconImage(iconName: "trash"), for: .normal)
        v.tintColor = .white
        v.backgroundColor = .systemRed
        v.isHidden = true
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Making the back button has no title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.configureNavigationBar(tintColor: .label, title: "Lab", preferredLargeTitle: false, removeSeparator: true)
        
        let closeButton = CloseButton()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectButton)
        
        //UICollectionView setup
        self.collectionView.collectionViewLayout = makeLayout()
        
        // Fetch all images
        images = fetchData()
        
        // Setup FABDeleteButton
        fabDeleteButton.addTarget(self, action: #selector(confirmDeleteTapped), for: .touchUpInside)
        self.view.addSubview(fabDeleteButton)
        
        fabDeleteButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(self.view.getSafeAreaInsets().bottom + 20))
            make.width.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        images.count == 0 ? setEmptyView() : removeEmptyView()
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabCollectionViewCell
        let currentImage = images[indexPath.row]
        
        cell.photoView.image = currentImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticHelper.shared.mediumTaptic()
        self.selectedImageIndex = indexPath.row
        self.presentPhotoDisplayVC(indexPath: indexPath)
    }
}

extension LabCollectionViewController {
    // MARK: - Class functions
    private func makeLayout() -> UICollectionViewLayout  {
        let margin: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: margin,
            leading: margin,
            bottom: margin,
            trailing: margin
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.425))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 3
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [makeSectionHeader()]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40))
        
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return layoutSectionHeader
    }
    
    /// Helper to present the photo display VC
    private func presentPhotoDisplayVC(indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LabCollectionViewCell {
            let viewController = PhotoDisplayViewController(referencedView: cell.photoView, image: cell.photoView.image)
            viewController.photoDisplayDelegate = self
            viewController.dataSource = self
            viewController.delegate = self
            present(viewController, animated: true, completion: nil)
        }
        
    }
    
    private func fetchData() -> [UIImage] {
        var images: [UIImage] = []
        let imageUrls = DataEngine.shared.readDataToURLs()
        
        for url in imageUrls {
            if let image = UIImage(contentsOfFile: url.path) {
                let filename = url.path.replacingOccurrences(of: DataEngine.shared.getDocumentsDirectory().path, with: "", options: .literal, range: nil)
                image.accessibilityIdentifier = filename
                images.append(image)
            }
        }
        
        return images
    }
    
    /// Setting a meaningful empty view when the collectionview is empty
    private func setEmptyView() {
        let v = EmptyView(frame: self.collectionView.frame)
        self.collectionView.backgroundView = v
    }
    
    /// Remove the emptyview when an item is present
    private func removeEmptyView() {
        self.collectionView.backgroundView = nil
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func selectButtonTapped() {
        let onPosition: CGFloat = 0
        let offPosition: CGFloat = 100
        let duration: Double = 0.25
        
        isSelecting.toggle()
        
        if isSelecting {
            selectButton.setTitle("Cancel", for: .normal)
            selectButton.setImage(nil, for: .normal)
            
            fabDeleteButton.isHidden = false
            fabDeleteButton.transform = CGAffineTransform(translationX: 0, y: offPosition)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.fabDeleteButton.transform = CGAffineTransform(translationX: 0, y: onPosition)
            }, completion: nil)
            
        } else {
            selectButton.setTitle(nil, for: .normal)
            selectButton.setImage(IconHelper.shared.getIconImage(iconName: "square.and.pencil"), for: .normal)
            
            fabDeleteButton.transform = CGAffineTransform(translationX: 0, y: onPosition)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.fabDeleteButton.transform = CGAffineTransform(translationX: 0, y: offPosition)
            }, completion: { _ in self.fabDeleteButton.isHidden = true })
        }
        
        selectButton.sizeToFit()
    }
    
    @objc private func confirmDeleteTapped() {
        print("confirm delete")
    }
}

// MARK: DTPhotoViewerControllerDataSource
extension LabCollectionViewController: DTPhotoViewerControllerDataSource {
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, referencedViewForPhotoAt index: Int) -> UIView? {
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView?.cellForItem(at: indexPath) as? LabCollectionViewCell {
            return cell.photoView
        }
        
        return nil
    }
    
    func numberOfItems(in photoViewerController: DTPhotoViewerController) -> Int {
        return images.count
    }
    
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, configurePhotoAt index: Int, withImageView imageView: UIImageView) {
        imageView.image = images[index]
    }
}

// MARK: DTPhotoViewerControllerDelegate
extension LabCollectionViewController: DTPhotoViewerControllerDelegate {
    func photoViewerControllerDidEndPresentingAnimation(_ photoViewerController: DTPhotoViewerController) {
        photoViewerController.scrollToPhoto(at: selectedImageIndex, animated: false)
    }
    
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, didScrollToPhotoAt index: Int) {
        selectedImageIndex = index
        if let collectionView = collectionView {
            let indexPath = IndexPath(item: selectedImageIndex, section: 0)
            
            // If cell for selected index path is not visible
            if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
                // Scroll to make cell visible
                collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
            }
        }
    }
}

// MARK: - PhotoDisplayDelegate
extension LabCollectionViewController: PhotoDisplayDelegate {
    func photoDisplayWillShare(photoAt index: Int) {
        if let child = self.presentedViewController {
            ShareHelper.shared.presentShare(withImage: images[index], toView: child)
        }
    }
    
    func photoDisplayWillSave(photoAt index: Int) {
        photoLibraryEngine.saveImageToAlbum(images[index]) { (success) in
            if success {
                DispatchQueue.main.async {
                    SPAlertHelper.shared.present(title: "Saved", message: nil, preset: .done)
                }
                TapticHelper.shared.successTaptic()
            } else {

                DispatchQueue.main.async {
                    if let child = self.presentedViewController {
                        AlertHelper.shared.presentDefault(title: "Kontax Cam does not have permission.", message: "Looks like we could not save the photo to your camera roll due to lack of permission. Please check the app's permission under settings.", to: child)
                    }
                }
                TapticHelper.shared.errorTaptic()
            }
        }
    }
    
    func photoDisplayWillDelete(photoAt index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        SPAlertHelper.shared.present(title: "Image deleted.")
        DataEngine.shared.deleteData(imageToDelete: images[index]) { (success) in
            if !success {
                if let child = self.presentedViewController {
                    AlertHelper.shared.presentDefault(title: "Something went wrong.", message: "We are unable to delete the image.", to: child)
                }
                
            }
        }
        images.remove(at: index)
        
        collectionView.deleteItems(at: [indexPath])
        collectionView.reloadData()
    }
    
    
}


