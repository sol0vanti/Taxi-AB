import UIKit

struct TarifButtonWithImageViewModel {
    let tarifCost: String
    let tarifType: String
    let tarifImage: String
}

final class TarifButtonWithImage: UIButton {
    private let tarifType: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let tarifCost: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let tarifImage: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tarifCost)
        addSubview(tarifType)
        addSubview(tarifImage)
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
        backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with viewModel: TarifButtonWithImageViewModel) {
        tarifCost.text = viewModel.tarifCost + "$"
        tarifType.text = viewModel.tarifType
        tarifImage.text = viewModel.tarifImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tarifCost.frame = CGRect(x: frame.size.width/3, y: 0, width: frame.size.width, height: frame.size.height/2)
        tarifType.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/2)
        tarifImage.frame = CGRect(x: frame.size.width*3, y: 0, width: frame.size.width, height: frame.size.height/2)
    }
}


