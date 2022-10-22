//  LeftTableViewCell.swift
//  Validation
//  Created by hari-pt5664 on 02/09/22.

import UIKit

//MARK: - Left Text Custom Cell Class

class LeftTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var leftCellLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var bubbleStackView: UIStackView!
    static let cellNib = UINib(nibName: "LeftTableViewCell", bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(message: String, time: String) {
        self.leftCellLabel.text = message
        self.leftTimeLabel.text = time
        self.bubbleView.layer.cornerRadius = 5.0
    }
}
