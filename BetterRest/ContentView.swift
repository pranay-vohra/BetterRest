//
//  ContentView.swift
//  BetterRest
//
//  Created by pranay vohra on 11/11/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp=computedDate
    @State private var sleepAmount=8.0
    @State private var cofeeAmount=1
    @State private var showAlert=false
    @State private var alertTitle=""
    @State private var alertMessage=""
    
    static var computedDate:Date{
        var component=DateComponents()
        component.hour=7
        component.minute=0
        
        return Calendar.current.date(from: component) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form{
                VStack(alignment:.leading,spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection:$wakeUp,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    
                }
                
                VStack(alignment:.leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in:3...12,step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily Coffee intake")
                        .font(.headline)
                    Stepper("\(cofeeAmount.formatted()) cup(s)",value: $cofeeAmount,in:1...20,step: 1)
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate",action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK"){}
            }message: {
                Text(alertMessage)
            }
            
        }
    }
    
    func calculateBedTime(){
        do{
            let config=MLModelConfiguration()
            let model=try sleepCalculator(configuration: config)
            
            let components=Calendar.current.dateComponents([.hour,.minute],from: wakeUp)
            
            let hour=components.hour!*60*60
            let min=components.minute!*60
            
            let prediction=try model.prediction(wake: Int64(hour+min), estimatedSleep: Double(sleepAmount), coffee: Int64(cofeeAmount))
            
            let sleepTime=wakeUp-prediction.actualSleep
            
            alertTitle="your wake-up time is.."
            alertMessage="\(sleepTime.formatted(date:.omitted, time:.shortened))"
            showAlert=true
            
        }catch{
            alertTitle="eroor"
            alertMessage="sorry,there was a problem calculating your bedtime"

        }
        
    }
}

#Preview {
    ContentView()
}
