import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Window constraints
    self.minSize = NSSize(width: 480, height: 320)
    self.setContentSize(NSSize(width: 800, height: 600))
    self.center()

    // Modern title bar
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.title = "RemoteFlow"

    // Allow full-screen
    self.collectionBehavior.insert(.fullScreenPrimary)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
