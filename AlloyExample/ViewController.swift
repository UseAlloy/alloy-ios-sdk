import Alloy
import UIKit

class ViewController: UIViewController {
    private lazy var nameFirstField: UITextField = {
        let view = UITextField()
        view.placeholder = "First name"
        view.text = "John"
        view.textAlignment = .center
        view.textColor = .black
        view.layer.borderWidth = 1
        return view
    }()

    private lazy var nameLastField: UITextField = {
        let view = UITextField()
        view.placeholder = "Last name"
        view.text = "Doe"
        view.textAlignment = .center
        view.textColor = .black
        view.layer.borderWidth = 1
        return view
    }()

    let openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open", for: .normal)
        button.addTarget(self, action: #selector(openAlloy), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(nameFirstField)
        view.addSubview(nameLastField)
        view.addSubview(openButton)

        nameFirstField.translatesAutoresizingMaskIntoConstraints = false
        nameFirstField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        nameFirstField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        nameFirstField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true

        nameLastField.translatesAutoresizingMaskIntoConstraints = false
        nameLastField.topAnchor.constraint(equalTo: nameFirstField.bottomAnchor, constant: 8).isActive = true
        nameLastField.leadingAnchor.constraint(equalTo: nameFirstField.leadingAnchor).isActive = true
        nameLastField.trailingAnchor.constraint(equalTo: nameFirstField.trailingAnchor).isActive = true

        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.topAnchor.constraint(equalTo: nameLastField.bottomAnchor, constant: 8).isActive = true
        openButton.leadingAnchor.constraint(equalTo: nameLastField.leadingAnchor).isActive = true
        openButton.trailingAnchor.constraint(equalTo: nameLastField.trailingAnchor).isActive = true
    }

    @objc private func openAlloy() {
        let alloy = Alloy(
            key: "028d85e0-aa24-4ca1-99f2-90e3ee3f4e6b",
            for: AlloyEvaluationData(
                nameFirst: nameFirstField.text ?? "",
                nameLast: nameLastField.text ?? ""
            )
        )

        alloy.open(in: self)
    }
}
