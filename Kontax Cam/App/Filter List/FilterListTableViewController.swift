//
//  FilterListTableViewController.swift
//  Kontax Cam
//
//  Created by Kevin Laminto on 24/5/20.
//  Copyright © 2020 Kevin Laminto. All rights reserved.
//

import UIKit

protocol FilterListDelegate {
    func didSelectFilter(filterName: String)
}

enum FilterName: String, CaseIterable {
    case KC01, KC02, KC03
}

class FilterListTableViewController: UITableViewController {
    
    private let CELL_ID = "filtersCell"
    private let filters: [Filter] = [
        .init(title: FilterName.KC01.rawValue, subtitle: "A perfect soft film preset best suited for day to day photo.", image: #imageLiteral(resourceName: "kc01-ex")),
        .init(title: FilterName.KC02.rawValue, subtitle: "A Beautifully crafted black and white preset to emulate old film.", image: #imageLiteral(resourceName: "kc02-ex")),
        .init(title: FilterName.KC03.rawValue, subtitle: "Soft purple preset best suited for sunset and dusk.", image: #imageLiteral(resourceName: "kc03-ex"))
    ]
    var delegate: FilterListDelegate?
    var selectedFilterName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar(title: "Filter List")
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancel
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filtersCell", for: indexPath) as! FilterListTableViewCell
        
        cell.filterImageView.image = filters[indexPath.section].image
        cell.filterTitleLabel.text = filters[indexPath.section].title
        cell.filterSubLabel.text = filters[indexPath.section].subtitle
        
        if filters[indexPath.section].title == selectedFilterName {
            cell.backgroundColor = .systemBlue
            cell.filterTitleLabel.textColor = .label
            cell.filterSubLabel.textColor = .secondaryLabel
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.section]
        delegate?.didSelectFilter(filterName: selectedFilter.title)
        cancelTapped()
    }
    
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}