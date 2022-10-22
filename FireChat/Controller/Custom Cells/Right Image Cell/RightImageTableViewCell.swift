//  RightImageTableViewCell.swift
//  Validation
//  Created by hari-pt5664 on 09/09/22.

import UIKit

//MARK: - Right Image Custom Cell Class

class RightImageTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var bubbleStackView: UIStackView!
    static let cellNib = UINib(nibName: "RightImageTableViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(message: String, time: String) {
        self.rightImageView.loadImage(urlString: message)
        self.rightTimeLabel.text = time
        self.bubbleView.layer.cornerRadius = 5.0
    }
}
