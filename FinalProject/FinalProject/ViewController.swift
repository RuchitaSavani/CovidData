//
//  ViewController.swift
//  FinalProject
//
//  Created by user197868 on 12/12/21.
//

import UIKit
import Charts
import CoreLocation

class ViewController: UIViewController , ChartViewDelegate,  CLLocationManagerDelegate{

    @IBOutlet var lblTotal: UILabel!
     
    @IBOutlet var lblRecover: UILabel!
    
    @IBOutlet var lblDeath: UILabel!
    
    @IBOutlet var barChartData: BarChartView!
    @IBOutlet var lblPerDeath: UILabel!
    @IBOutlet var lblPerTotal: UILabel!
    var locationManager:CLLocationManager?
    @IBOutlet var countryDataTxt: UITextView!
    var totalCases = 0
    var recoveredCase = 0
    var totalDeath = 0
    var totalPer = 0.01
    var totalPerDeath = 0.01
    var recoverOn = 0.01
    
    var tempArray:[Int]=[]
    let data = ["Cases", "Recover", "Cases(ON)", "Recover(ON)"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
          locationManager?.delegate = self
          locationManager?.requestAlwaysAuthorization()
                    
        getCandaData(urls: "https://api.opencovid.ca")
        
         
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            print("Error in using location \(error) \(error.errorUserInfo)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status: CLAuthorizationStatus = locationManager!.authorizationStatus
        if status == .notDetermined{
            locationManager?.requestAlwaysAuthorization()
        }else if status == .authorizedAlways || status == .authorizedWhenInUse{
           
        }
        else{
            print("Authorization status is: \(status.rawValue)")
        }
    }
    
    func getCandaData(urls: String)
    {
      
       let session = URLSession.shared
        let queryString = URL(string:urls )!
       let dailyWeatherTask = session.dataTask(with: queryString)
       {
            data, response, error  in
            if(error != nil || data == nil)
            {
                print("No data found")
                return
            }
            
            let resp = response as? HTTPURLResponse
            guard let response = response as? HTTPURLResponse,(200...299).contains(response.statusCode)
            else
            {
                print("No data found from server.")
                print("error \(String(describing: resp?.statusCode))")
                return
            }
            guard let mime = response.mimeType, mime == "application/json"
            else
            {
                print("Incorrect format")
                print("Format incorrect \(String(describing: resp?.mimeType))")
                return
            }
      
            do
            {
                let jsonObjectMain = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                let jsonObj = jsonObjectMain?["summary"] as? [Any]
                
                for i in 1...jsonObj!.count
                {
                    
                    self.totalCases = (jsonObj?[i-1] as? [String:Any])?["cumulative_cases"] as! Int
                    self.recoveredCase = (jsonObj?[i-1] as? [String:Any])?["cumulative_recovered"] as! Int
                    self.totalDeath = (jsonObj?[i-1] as? [String:Any])?["cumulative_deaths"] as! Int
                    
                    
                    
                }
                self.tempArray.append(self.totalCases)
                self.tempArray.append(self.recoveredCase)
              //  self.tempArray.append(self.totalDeath)
                DispatchQueue.main.async
                {
                    self.lblTotal.text = "Total Case \n\(self.totalCases)"
                    self.lblRecover.text = "Total Recover \n\(self.recoveredCase)"
                    self.lblDeath.text = "Total Death \n\(self.totalDeath)"
                    
                    self.getOntarioData(urls: "https://api.opencovid.ca/summary?date=01-09-2020")
                    
                }
            }catch
            {
                print("Error in loading json data")
            }
       }
       
      dailyWeatherTask.resume()
    }

    func getOntarioData(urls: String)
    {
      
       let session = URLSession.shared
        let queryString = URL(string:urls )!
       let caseData = session.dataTask(with: queryString)
       {
            data, response, error  in
            if(error != nil || data == nil)
            {
                print("No data found")
                return
            }
            
            let resp = response as? HTTPURLResponse
            guard let response = response as? HTTPURLResponse,(200...299).contains(response.statusCode)
            else
            {
                print("No data found from server.")
                print("error \(String(describing: resp?.statusCode))")
                return
            }
            guard let mime = response.mimeType, mime == "application/json"
            else
            {
                print("Incorrect format")
                print("Format incorrect \(String(describing: resp?.mimeType))")
                return
            }
      
            do
            {
                let jsonObjectMain = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                let jsonObj = jsonObjectMain?["summary"] as? [Any]
                
                
                     
                    self.totalPer = (jsonObj?[8] as? [String:Any])?["cumulative_cases"] as! Double
                self.tempArray.append((jsonObj?[8] as? [String:Any])?["cumulative_cases"] as! Int)
                
                                      print(self.totalPer)
                                      self.totalPer = (100*self.totalPer)/Double(self.totalCases)
                    
                    self.recoverOn = (jsonObj?[8] as? [String:Any])?["cumulative_recovered"] as! Double
                self.tempArray.append((jsonObj?[8] as? [String:Any])?["cumulative_recovered"] as! Int)
                                        self.totalPerDeath = (100*self.recoverOn)/Double(self.recoveredCase)
                    
                
                DispatchQueue.main.async
                {
                    self.lblPerTotal.text = String(format: "%.2f", self.totalPer)+"% \n Total Case(%)"
                    
                                      self.lblPerDeath.text = String(format: "%.2f", self.totalPerDeath)+"% \n Total Recovered(%)"
                    print(self.tempArray)
                    self.loadDataInChart()
                    
                }
            }catch
            {
                print("Error in loading json data")
            }
       }
        caseData.resume()
    }
    func colorPicker(value : Double) -> UIColor {
        if value == 3 {
            return UIColor.red
        }
        else {
            return UIColor.black
        }
    }
    
    func loadDataInChart(){
            barChartData.noDataText = "You need to provide data for the chart."
                    var dataEntries: [BarChartDataEntry] = []
            print(self.data.count)

                    for i in 0..<self.data.count {

                        let dataEntry = BarChartDataEntry(x: Double(i) , y: Double(self.tempArray[i]))
                        dataEntries.append(dataEntry)

                       

                    }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Cases")
          //  let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Unit Bought")

                    let dataSets: [BarChartDataSet] = [chartDataSet]
                    chartDataSet.colors = [UIColor(red: 13/255, green: 169/255, blue: 226/255, alpha: 1)]
                    //chartDataSet.colors = ChartColorTemplates.colorful()
                    //let chartData = BarChartData(dataSet: chartDataSet)

                    let chartData = BarChartData(dataSets: dataSets)


            
                    let barWidth = 0.50
                    // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"
 
            
            //legend
                        

                        let xaxis = barChartData.xAxis
                      //  xaxis.valueFormatter = axisFormatDelegate
                        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .topInside
                        xaxis.centerAxisLabelsEnabled = false
                        xaxis.valueFormatter = IndexAxisValueFormatter(values:self.data)
                        xaxis.granularity = 1

 

                        let yaxis = barChartData.leftAxis
                        yaxis.spaceTop = 0.55
                        yaxis.axisMinimum = 0
                        yaxis.drawGridLinesEnabled = false

        barChartData.rightAxis.enabled = false


                    chartData.barWidth = barWidth;
        
        barChartData.notifyDataSetChanged()

        barChartData.data = chartData






                    //background color
        barChartData.backgroundColor = UIColor(red: 209/255, green: 224/255, blue: 246/255, alpha: 1)

                    //chart animation
        barChartData.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

        }
}

