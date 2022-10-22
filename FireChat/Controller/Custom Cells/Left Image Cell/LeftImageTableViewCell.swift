//  LeftImageTableViewCell.swift
//  Validation
//  Created by hari-pt5664 on 09/09/22.

import UIKit

//MARK: - Left Image Custom Cell Class

class LeftImageTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var bubbleStackView: UIStackView!
    static let cellNib = UINib(nibName: "LeftImageTableViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(message: String, time: String) {
        self.leftImageView.loadImage(urlString: message)
        self.leftTimeLabel.text = time
        self.bubbleView.layer.cornerRadius = 5.0
    }
}
