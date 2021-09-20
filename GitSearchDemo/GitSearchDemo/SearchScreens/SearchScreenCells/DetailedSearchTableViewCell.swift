//
//  DetailedSearchTableViewCell.swift
//  GitSearchDemo
//
//  Created by Sergei Morozov on 20.09.21.
//

import UIKit

class DetailedSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleRepositoryImageView: UIImageView!
    @IBOutlet weak var repositoryOwnerLabel: UILabel!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var repositoryDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 5
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 5, right: 10))
    }
    
    func setDetiledRepositoryCell (repository : Repository) {
        repositoryNameLabel.text = repository.name
        repositoryDescriptionLabel.text = repository.description
        if repository.owner?.login != nil {
            repositoryOwnerLabel.text = repository.owner?.login
        } else {
            repositoryOwnerLabel.text = ""
        }
        titleRepositoryImageView.image = nil
        guard let imageUrl = repository.owner?.avatar_url else {return}
        titleRepositoryImageView.load(url: imageUrl)
    }
}
