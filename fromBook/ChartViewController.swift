import UIKit
import Charts

class ChartViewController: UIViewController {
    
    let colors = Colors()
    var prefecture = UILabel()
    var pcr = UILabel()
    var pcrCount = UILabel()
    var cases = UILabel()
    var casesCount = UILabel()
    var deaths = UILabel()
    var deathsCount = UILabel()
    var segment = UISegmentedControl()
    var prefectureArr:[CovidInfo.Prefecture] = []
    var chartView:HorizontalBarChartView!
    var pattern = "cases"
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 68)
        gradientLayer.colors = [colors.mintGreen.cgColor, colors.deepGreen.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
       
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = .white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x: view.frame.size.width - 105, y: 25, width: 100, height: 30)
        nextButton.setTitle("円グラフ", for: .normal)
        nextButton.setTitleColor( .white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(goCircle), for: .touchUpInside)
        view.addSubview(nextButton)
        
        segment = UISegmentedControl(items: ["感染者","PCR検査","死者数"])
        segment.frame = CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 20)
        segment.selectedSegmentTintColor = colors.mildGreen
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colors.mildGreen], for: .normal)
        segment.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        view.addSubview(segment)
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 10, y: 100, width: view.frame.size.width - 20, height: 20)
        searchBar.delegate = self
        searchBar.placeholder = "都道府県を漢字で入力"
        searchBar.showsCancelButton = true
        searchBar.tintColor = colors.mildGreen
        view.addSubview(searchBar)
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 10, y: view.frame.size.height - 200, width: view.frame.size.width - 20, height: 167)
        uiView.layer.cornerRadius = 10
        uiView.backgroundColor = .white
        uiView.layer.shadowColor = colors.darkBlue.cgColor
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        uiView.layer.shadowOpacity = 0.4
        uiView.layer.shadowRadius = 10
        view.addSubview(uiView)
        
        bottomLabel(uiView, prefecture, 1, 10, text: "東京", size: 30, weight: .ultraLight, color: .black)
        bottomLabel(uiView, pcr, 0.39, 50, text: "PCR検査", size: 15, weight: .bold, color: colors.blueGreen)
        bottomLabel(uiView, pcrCount, 0.39, 85, text: "222222", size: 30, weight: .bold, color: colors.mintGreen)
        bottomLabel(uiView, cases, 1, 50, text: "感染者数", size: 15, weight: .bold, color: colors.blueGreen)
        bottomLabel(uiView, casesCount, 1, 85, text: "22222", size: 30, weight: .bold, color: colors.mintGreen)
        bottomLabel(uiView, deaths, 1.61, 50, text: "死者数", size: 15, weight: .bold, color: colors.blueGreen)
        bottomLabel(uiView, deathsCount, 1.61, 85, text: "2222", size: 30, weight: .bold, color: colors.mintGreen)
        
        view.backgroundColor = .systemGroupedBackground
        
        for i in 0..<CovidSingleton.shared.prefecture.count {
            if CovidSingleton.shared.prefecture[i].name_ja == "東京" {
                let curr = CovidSingleton.shared.prefecture[i]
                prefecture.text = curr.name_ja
                pcrCount.text = "\(curr.pcr)"
                casesCount.text = "\(curr.cases)"
                deathsCount.text = "\(curr.deaths)"
            }
        }
        
        chartView = HorizontalBarChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: view.frame.size.height - 353))
        chartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCirc)
        chartView.xAxis.labelCount = 10
        chartView.xAxis.labelTextColor = colors.blueGreen
        chartView.doubleTapToZoomEnabled = false
        chartView.delegate = self
        chartView.pinchZoomEnabled = false
        chartView.leftAxis.labelTextColor = colors.blueGreen
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        
        prefectureArr = CovidSingleton.shared.prefecture
        prefectureArr.sort(by: {
            a, b -> Bool in
            if pattern == "pcr" {
                return a.pcr > b.pcr
            } else if pattern == "deaths" {
                return a.deaths > b.deaths
            }
            return a.cases > b.cases
        })
        dataSet()
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    @objc func goCircle() {
        performSegue(withIdentifier: "goCircle", sender: nil)
    }

    @objc func switchAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pattern = "cases"
        case 1:
            pattern = "pcr"
        case 2:
            pattern = "deaths"
        default:
            break
        }
        loadView()
        viewDidLoad()
    }
    func bottomLabel(_ parentView: UIView, _ label: UILabel, _ x: CGFloat, _ y: CGFloat, text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor){
        
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: size, weight: weight)
        label.frame = CGRect(x: 0, y: y, width: parentView.frame.size.width / 3.5, height: 50)
        label.center.x = view.center.x * x - 10
        parentView.addSubview(label)
    }
    
    func dataSet(){
        var names:[String] = []
        for i in 0...9 {
            names += ["\(self.prefectureArr[i].name_ja)"]
        }
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
        
        var entries:[BarChartDataEntry] = []
        for i in 0...9 {
            if pattern == "cases" {
                segment.selectedSegmentIndex = 0
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.prefectureArr[i].cases))]
            } else if pattern == "pcr" {
                segment.selectedSegmentIndex = 1
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.prefectureArr[i].cases))]
            } else {
                segment.selectedSegmentIndex = 2
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.prefectureArr[i].cases))]
            }
        }
        
        let set = BarChartDataSet(entries: entries, label: "県別状況")
        set.colors = [colors.mildGreen]
        set.valueTextColor = colors.mildGreen
        set.highlightColor = .white
        chartView.data = BarChartData(dataSet: set)
        view.addSubview(chartView)
    }
}
//MARK: UISearchBarDelegate
extension ChartViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let index = prefectureArr.firstIndex(where: { $0.name_ja == searchBar.text }) {
            prefecture.text = "\(prefectureArr[index].name_ja)"
            pcrCount.text = "\(prefectureArr[index].pcr)"
            casesCount.text = "\(prefectureArr[index].cases)"
            deathsCount.text = "\(prefectureArr[index].deaths)"
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.text = ""
    }
}

extension ChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let index = dataSet.entryIndex(entry: entry)
            prefecture.text = "\(prefectureArr[index].name_ja)"
            pcrCount.text = "\(prefectureArr[index].pcr)"
            casesCount.text = "\(prefectureArr[index].cases)"
            deathsCount.text = "\(prefectureArr[index].deaths)"
        }
    }
}
//<div>Icons made by <a href="https://www.flaticon.com/authors/becris" title="Becris">Becris</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
