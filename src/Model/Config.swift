import AppKit
import os.log

class Config {
    var app_name: String
    var app_icon: String
    var require_gui: String?
    var main_window: MainWindow?
    var indicator: Indicator!
    var icons = Images()
    var fontStyles: FontStyles?
    var http_cookies: [MPHTTPCookie]?
    
    /** If true, then the .app will refuse to run when located on a DMG file. */
    var never_run_from_dmg: Bool?
    
    /** A message to be shown in a popover, from the status bar when the application is launched, or `null` if the
        popover is not to be shown. */
    var status_bar_popover_message: String?
    
    init(app_name: String,
         app_icon: String,
         require_gui: String?,
         main_window: MainWindow?,
         indicators: Indicator!,
         icons: Images,
         fontStyles: FontStyles?,
         http_cookies: [MPHTTPCookie]?,
         never_run_from_dmg: Bool?,
         status_bar_popover_message: String?) {
        self.app_name = app_name
        self.app_icon = app_icon
        self.main_window = main_window
        self.indicator = indicators
        
        guard (app_icon.contains(":") || URL.isAFullyQualifiedFilePath(app_icon)) else {
            let error: StaticString = "The provided app_icon is neither a reference nor a fully qualified path."
            os_log(error, log: OSLog.default, type: .fault)
            preconditionFailure("\(error)")
            
        }
        self.icons = icons
        
        self.fontStyles = fontStyles
        self.http_cookies = http_cookies
        self.never_run_from_dmg = never_run_from_dmg
        self.status_bar_popover_message = status_bar_popover_message
    }
}
