//
//  MqttClient.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 5/24/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation
import CocoaMQTT

class MqttClient: CocoaMQTTDelegate {
    
    
    let mqtt = CocoaMQTT(clientID: "MQTT" + String(ProcessInfo().processIdentifier), host: "192.168.1.35", port: 1883)
    
    func connectMqtt(){
        
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 60
        mqtt.delegate = self
        
        if mqtt.connState != .connected && mqtt.connState != .connecting {
            print("aboutToConect", mqtt.connState)
            mqtt.connect()
        }

    }

    func subscribeToTopic(topic:String) {
                if mqtt.connState == .connected {
                    print("Subscribe to: ", topic)
                    mqtt.subscribe(topic, qos: .qos1)
                } else {
                    print("Can't subscribe to \(topic). Not connected.")
                }
    }
    
    func unSubToTopic(topic:String){
        if mqtt.connState == .connected {
            mqtt.unsubscribe(topic)
        }else {
            print("unSubToTopic Can't subscribe to \(topic). Not connected.")
        }

    }
    
    func publishToTopic(topic:String, payload:String) {
                if mqtt.connState == .connected {
                    print("Publish: ", topic, ": ", payload)
                    mqtt.publish(topic, withString: payload, qos: .qos1, retained: true, dup: true)
                } else {
                    print("Can't publish to \(topic). Not connected.")
                }
    }
    
    func disconnectMqtt(){
        mqtt.disconnect()
    }
    
    //CocoaMQTT Delegates
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("mqttDidConnect \(host):\(port)")
        
        let name = NSNotification.Name(rawValue: "mqttDidConnect")
        NotificationCenter.default.post(name: name, object: self, userInfo:  ["host": host, "port": port])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck",ack)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage",message)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck",id)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didReceiveMessage \(String(describing: message.string!))")
        
        let name = NSNotification.Name(rawValue: "mqttReceive")
        NotificationCenter.default.post(name: name, object: self, userInfo:  ["message": message.string!, "topic": message.topic])
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("Subscribed to topic: ", topic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("Unsubscribed to topic: ", topic)
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("Ping!")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("Pong!")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("mqttDidDisconnect ")
        
        let name = NSNotification.Name(rawValue: "mqttDidDisconnect")
        NotificationCenter.default.post(name: name, object: self)
    }

    
}
