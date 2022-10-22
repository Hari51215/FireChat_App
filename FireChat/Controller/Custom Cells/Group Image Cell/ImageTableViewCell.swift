//  ImageTableViewCell.swift
//  Validation
//  Created by hari-pt5664 on 20/09/22.

import UIKit

//MARK: - Group Image Message Custom Cell Class

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var bubbleStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageMessageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    static let cellNib = UINib(nibName: "ImageTableViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(message: String, time: String, name: String) {
        self.nameLabel.text = name
        self.imageMessageView.loadImage(urlString: message)
        self.timeLabel.text = time
        self.bubbleView.layer.cornerRadius = 5.0
    }
}
