import AppKit

class CommandFactory {
    
    static func build(forOperation operation: Operation, withArgs args: Args?) -> Command {
        switch operation {
        
        case .quit:
            return Quit()
        
        case .shell:
            precondition(args?.list != nil && args!.list!.count > 0, "No command was provided for execution.")
            return Shell(commands: args!.list!)
            
        case .show_main_window:
            return ShowMainWindow()
            
        case .show_url:
            precondition(args != nil, "Did not receive a URL to open.")
            return ShowURL(url: args!.asURL()!)
            
        case .terminal:
            precondition(args?.dictionary != nil, "Expected a dictionary.")
            precondition(args!.dictionary!.count > 0, "Expected a non-empty dictionary.")
            precondition(args!.dictionary!["command"] != nil, "No command was provided for execution.")
            let command = args!.dictionary!["command"] as! String
            let title = args!.dictionary!["title"] as? String
            let icon = args!.dictionary!["icon"] as? String
            return Terminal(command, title, icon)
            
        case .get_url:
            precondition(args != nil, "Did not receive a URL to get.")
            guard let url = args!.asURL() else {
                preconditionFailure("Did not receive a URL to get.")
            }
            return GetURL(url: url)
            
        case .post_url:
            precondition(args != nil, "Did not receive a URL to POST to.")
            guard let url = args!.asURL() else {
                preconditionFailure("Did not receive a URL to get.")
            }
            var swiftPayload = args!.dictionary
            swiftPayload?.removeValue(forKey: URL_KEY)
            
            do {
                let jsonPayload = try JSONSerialization.data(withJSONObject: swiftPayload!, options: [])
                return PostURL(url: url, payload: jsonPayload)
            } catch {
                // TODO Error handling.
                print(error.localizedDescription)
                fatalError()
            }
        
        case .show_splash_screen:
            precondition(args != nil, "Did not receive arguments")
            let background = NSImage(contentsOfFile: args!.dictionary!["background"] as! String)
            let message = args!.dictionary!["message"] as? String ?? ""
            let showProgressBar = args!.dictionary!["progress_bar"] as? Bool == true
            
            precondition(background != nil, "A splash screen can not be created without a background.")
            return ShowSplashScreen(background: background, message: message, showProgressBar: showProgressBar)
            
        case .update_splash_screen:
            precondition(args == nil || args!.dictionary != nil, "Expected args to be a dictionary.")
            var progress = args!.dictionary!["progress"] as? Double
            if (progress != nil) {
                /* The Bar Progress Indicator requries a value on the range [0;100] but
                such values are on the range [0.0;1.0] in the config file. */
                progress! *= 100
            }
            let message = args!.dictionary!["message"] as? String ?? ""
            return UpdateSplashScreen(progress ?? 0, message)
            
        case .hide_splash_screen:
            return HideSplashScreen()
            
        case .hide_main_window:
            return HideMainWindow()
            
        case .set_status:
            guard let status: String = args?.dictionary?["status"] as? String else {
                preconditionFailure("Status was not provided as an argument.")
            }
            return SetStatus(status)
        }
        
        
    }
    
}
