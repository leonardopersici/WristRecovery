/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Creates a common instance of the Exercise Classifier.
 The app only uses one instance anyway and using a static property initializes
 the model at launch instead of when the the main view loads.
*/

import CoreML

extension WristRecoveryClassifier {
    /// Creates a shared Exercise Classifier instance for the app at launch.
    static let shared: WristRecoveryClassifier = {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an Exercise Classifier instance.
        guard let exerciseClassifier = try? WristRecoveryClassifier(configuration: defaultConfig) else {
            // The app requires the action classifier to function.
            fatalError("WristRecovery Classifier failed to initialize.")
        }

        // Ensure the Exercise Classifier.Label cases match the model's classes.
        //WristRecoveryClassifier.checkLabels()

        return exerciseClassifier
    }()
}
