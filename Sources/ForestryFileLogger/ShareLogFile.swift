//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension FileLogger {
    /// Presents UIActivityViewController on UIViewController with the fileToShare.
    @MainActor
    func shareLogFile(on viewController: UIViewController) {
        guard let file = configuration.logFileURL else { return }
        let fileToShare: [Any] = [file]
        let activityViewController = UIActivityViewController(activityItems: fileToShare, applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
#endif
