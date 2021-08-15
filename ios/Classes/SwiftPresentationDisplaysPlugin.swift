import Flutter
import UIKit

public class SwiftPresentationDisplaysPlugin: NSObject, FlutterPlugin {
    static var additionalWindows = [UIScreen:UIWindow]()
    static var screens = [UIScreen]()
    var flutterEngineChannel:FlutterMethodChannel=FlutterMethodChannel()
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "presentation_displays_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftPresentationDisplaysPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        screens.append(UIScreen.main)
        
        NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                               object: nil, queue: nil) {
            notification in
            
            // Get the new screen information.
            let newScreen = notification.object as! UIScreen
            let screenDimensions = newScreen.bounds
            
            // Configure a window for the screen.
            let newWindow = UIWindow(frame: screenDimensions)
            newWindow.screen = newScreen
            
            // You must show the window explicitly.
            newWindow.isHidden = true
            
            // Save a reference to the window in a local array.
            self.screens.append(newScreen)
            self.additionalWindows[newScreen]=newWindow
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //    result("iOS " + UIDevice.current.systemVersion)
        if call.method=="showPresentation"{
            let args = call.arguments as? String
            let data = args?.data(using: .utf8)!
                do {
                    if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options : .allowFragments) as? Dictionary<String,Any>
                        {
                        print(json)
                        showPresentation(index:json["displayId"] as? Int ?? 1, routerName: json["routerName"] as? String ?? "presentation")
                    }
                    else {
                    print("bad json")
                }
                }
                    catch let error as NSError {
                    print(error)
                }
                }
                    else if call.method=="transferDataToPresentation"{
                    self.flutterEngineChannel.invokeMethod("DataTransfer", arguments: call.arguments)
                }
        }

        private  func showPresentation(index:Int, routerName:String )
        {
            let screen=SwiftPresentationDisplaysPlugin.screens[index]
            let window=SwiftPresentationDisplaysPlugin.additionalWindows[screen]
            
            // You must show the window explicitly.
            window?.isHidden=false
            
            let extVC = FlutterViewController()
            extVC.setInitialRoute(routerName)
            window?.rootViewController = extVC
            
            
            self.flutterEngineChannel = FlutterMethodChannel(name: "presentation_displays_plugin_engine", binaryMessenger: extVC.binaryMessenger)
        }

    }
