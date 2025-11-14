import UIKit

class OrderViewController: UIViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var passengersPicker: UIPickerView!
    @IBOutlet weak var luggageSwitch: UISwitch!
    @IBOutlet weak var childSeatSwitch: UISwitch!
    @IBOutlet weak var petSwitch: UISwitch!
    @IBOutlet weak var priceLabel: UILabel!
    
    let passengers = ["1", "2", "3", "4", "5", "6"]
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedData()
        updatePrice()
    }
    
    func setupUI() {
        title = "Забронировать поездку"
        
        // Настройка форматтеров
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm"
        
        // Добавляем кнопки в навигацию
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "📞", style: .plain, target: self, action: #selector(callTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "💬", style: .plain, target: self, action: #selector(whatsappTapped)
        )
        
        // Убираем клавиатуру при тапе
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        // Привязываем picker
        passengersPicker.delegate = self
        passengersPicker.dataSource = self
        
        // Устанавливаем текущую дату и время
        dateTextField.text = dateFormatter.string(from: Date())
        timeTextField.text = timeFormatter.string(from: Date())
        
        // Обновляем цену при изменении полей
        fromTextField.addTarget(self, action: #selector(updatePrice), for: .editingChanged)
        toTextField.addTarget(self, action: #selector(updatePrice), for: .editingChanged)
        dateTextField.addTarget(self, action: #selector(updatePrice), for: .editingChanged)
        timeTextField.addTarget(self, action: #selector(updatePrice), for: .editingChanged)
        passengersPicker.addTarget(self, action: #selector(updatePrice), for: .valueChanged)
        luggageSwitch.addTarget(self, action: #selector(updatePrice), for: .valueChanged)
        childSeatSwitch.addTarget(self, action: #selector(updatePrice), for: .valueChanged)
        petSwitch.addTarget(self, action: #selector(updatePrice), for: .valueChanged)
    }
    
    func updatePrice() {
        let base = 300
        let perKm = 10
        let distance = 150 // можно заменить на реальное значение
        let total = base + perKm * distance
        priceLabel.text = "Цена: \(total) руб."
    }
    
    func loadSavedData() {
        if let from = UserDefaults.standard.string(forKey: "from") {
            fromTextField.text = from
        }
        if let to = UserDefaults.standard.string(forKey: "to") {
            toTextField.text = to
        }
        if let date = UserDefaults.standard.string(forKey: "date") {
            dateTextField.text = date
        }
        if let time = UserDefaults.standard.string(forKey: "time") {
            timeTextField.text = time
        }
        luggageSwitch.isOn = UserDefaults.standard.bool(forKey: "luggage")
        childSeatSwitch.isOn = UserDefaults.standard.bool(forKey: "childSeat")
        petSwitch.isOn = UserDefaults.standard.bool(forKey: "pet")
        
        // Устанавливаем пассажиров
        if let passengersIndex = UserDefaults.standard.integer(forKey: "passengers"), passengersIndex < passengers.count {
            passengersPicker.selectRow(passengersIndex, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        // Сохраняем данные
        UserDefaults.standard.set(fromTextField.text, forKey: "from")
        UserDefaults.standard.set(toTextField.text, forKey: "to")
        UserDefaults.standard.set(dateTextField.text, forKey: "date")
        UserDefaults.standard.set(timeTextField.text, forKey: "time")
        UserDefaults.standard.set(luggageSwitch.isOn, forKey: "luggage")
        UserDefaults.standard.set(childSeatSwitch.isOn, forKey: "childSeat")
        UserDefaults.standard.set(petSwitch.isOn, forKey: "pet")
        UserDefaults.standard.set(passengersPicker.selectedRow(inComponent: 0), forKey: "passengers")
        
        showAlert(title: "✅ Готово", message: "Заказ сохранён. Скоро свяжемся!")
    }
    
    @objc func callTapped() {
        if let url = URL(string: "tel://+79193153869"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func whatsappTapped() {
        let message = """
Заказ на поездку:

Откуда: \(fromTextField.text ?? "")
Куда: \(toTextField.text ?? "")
Дата: \(dateTextField.text ?? "")
Время: \(timeTextField.text ?? "")
Пассажиров: \(passengers[passengersPicker.selectedRow(inComponent: 0)])
Багаж: \(luggageSwitch.isOn ? "Да" : "Нет")
Детское кресло: \(childSeatSwitch.isOn ? "Да" : "Нет")
С животным: \(petSwitch.isOn ? "Да" : "Нет")
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let url = URL(string: "https://wa.me/79193153869?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension OrderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return passengers.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return passengers[row]
    }
}
