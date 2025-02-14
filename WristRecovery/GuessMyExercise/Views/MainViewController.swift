/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view controller.
*/

import UIKit
import Vision
import AVKit

@available(iOS 14.0, *)
class MainViewController: UIViewController {
    /// The full-screen view that presents the pose on top of the video frames.
    @IBOutlet var imageView: UIImageView!

    /// The stack that contains the labels at the middle of the leading edge.
    @IBOutlet weak var labelStack: UIStackView!

    /// The label that displays the model's exercise action prediction.
    @IBOutlet weak var actionLabel: UILabel!

    /// The label that displays the model's confidence in its prediction.
    @IBOutlet weak var confidenceLabel: UILabel!

    /// The stack that contains the buttons at the bottom of the leading edge.
    @IBOutlet weak var buttonStack: UIStackView!

    /// The button users tap to show a summary view.
    @IBOutlet weak var summaryButton: UIButton!
    
    /// The button users tap to toggle between the front- and back-facing
    /// cameras.
    @IBOutlet weak var cameraButton: UIButton!

    @IBOutlet weak var livStack: UIStackView!
    
    @IBOutlet weak var livLabel1: UILabel!
    
    @IBOutlet weak var livLabel2: UILabel!
    
    @IBOutlet weak var livLabel3: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var flexStack: UIStackView!
    
    @IBOutlet weak var flexReps: UILabel!
    
    @IBOutlet weak var flexFeed: UIImageView!
    
    @IBOutlet weak var extStack: UIStackView!
    
    @IBOutlet weak var extReps: UILabel!
    
    @IBOutlet weak var extFeed: UIImageView!
    
    @IBOutlet weak var nonSicuroLabel: UILabel!
    
    @IBOutlet weak var extProgressBar: UIProgressView!
    
    @IBOutlet weak var flexProgressBar: UIProgressView!
    
    /// Captures the frames from the camera and creates a frame publisher.
    var videoCapture: VideoCapture!

    /// Builds a chain of Combine publishers from a frame publisher.
    ///
    /// The video-processing chain provides the view controller with:
    /// - Each video camera frame as a `CGImage`.
    /// - A `Pose` array of any people `Vision` observed in that frame.
    /// - Action predictions from the prominent person's poses over time.
    var videoProcessingChain: VideoProcessingChain!

    /// Maintains the aggregate time for each action the model predicts.
    /// - Tag: actionFrameCounts
    var actionFrameCounts = [String: Int]()
    
    var actionPredicted = [String]()
    
    var livCount = 0
    
    /// Maintains the aggregate rep for each action the model predicts.
    /// - Tag: actionRepCounts
    var actionRepCounts = [String: Int]()
    
    var meanConfidence = [Double]()
    
    var esercizio = Esercizio()
    
    var completo = false
    
    var db = DBManager()
}

// MARK: - View Controller Events
extension MainViewController {
    /// Configures the main view after it loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Esercizio \(esercizio.id) con \(esercizio.flex) flessioni e \(esercizio.ext) estensioni")

        // Disable the idle timer to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        // Round the corners of the stack and button views.
        let views = [labelStack, buttonStack, cameraButton, summaryButton]
        views.forEach { view in
            view?.layer.cornerRadius = 10
            view?.overrideUserInterfaceStyle = .dark
        }
        
        nonSicuroLabel.layer.masksToBounds = true
        nonSicuroLabel.overrideUserInterfaceStyle = .dark

        // Set the view controller as the video-processing chain's delegate.
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        // Begin receiving frames from the video capture.
        videoCapture = VideoCapture()
        videoCapture.delegate = self

        updateUILabelsWithPrediction(.startingPrediction)
        
        extProgressBar.progress = 0
        flexProgressBar.progress = 0
    }

    /// Configures the video captures session with the device's orientation.
    ///
    /// This is the app's first opportunity to retrieve the device's
    /// physical orientation with its hardware sensors.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update the device's orientation.
        videoCapture.updateDeviceOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let firstVC = presentingViewController as? PazienteViewController {
            DispatchQueue.main.async {
                firstVC.viewDidLoad()
            }
        }
    }

    /// Notifies the video capture when the device rotates to a new orientation.
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Update the the camera's orientation to match the device's.
        videoCapture.updateDeviceOrientation()
    }
}

// MARK: - Button Events
extension MainViewController {
    /// Toggles the video capture between the front- and back-facing cameras.
    @IBAction func onCameraButtonTapped(_: Any) {
        videoCapture.toggleCameraSelection()
    }

    /// Presents a summary view of the user's actions and their total times.
    @IBAction func onSummaryButtonTapped() {
        let main = UIStoryboard(name: "Main", bundle: nil)

        // Get the view controller based on its name.
        let vcName = "SummaryViewController"
        let viewController = main.instantiateViewController(identifier: vcName)

        // Cast it as a `SummaryViewController`.
        guard let summaryVC = viewController as? SummaryViewController else {
            fatalError("Couldn't cast the Summary View Controller.")
        }

        // Copy the current actions times to the summary view.
        summaryVC.completo = completo
        summaryVC.esercizio = esercizio
        summaryVC.fRep = actionRepCounts["Flessione"]
        summaryVC.eRep = actionRepCounts["Estensione"]
        summaryVC.actionFrameCounts = actionFrameCounts

        // Define the presentation style for the summary view.
        modalPresentationStyle = .popover
        modalTransitionStyle = .coverVertical

        // Reestablish the video-processing chain when the user dismisses the
        // summary view.
        summaryVC.dismissalClosure = {
            // Resume the video feed by enabling the camera when the summary
            // view goes away.
            self.videoCapture.isEnabled = true
            self.meanConfidence.removeAll()
        }

        // Present the summary view to the user.
        present(summaryVC, animated: true)

        // Stop the video feed by disabling the camera while showing the summary
        // view.
        videoCapture.isEnabled = false
    }
}

// MARK: - Video Capture Delegate
extension MainViewController: VideoCaptureDelegate {
    /// Receives a video frame publisher from a video capture.
    /// - Parameters:
    ///   - videoCapture: A `VideoCapture` instance.
    ///   - framePublisher: A new frame publisher from the video capture.
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher) {
        updateUILabelsWithPrediction(.startingPrediction)
        
        // Build a new video-processing chain by assigning the new frame publisher.
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - video-processing chain Delegate
extension MainViewController: VideoProcessingChainDelegate {
    /// Receives an action prediction from a video-processing chain.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - actionPrediction: An `ActionPrediction`.
    ///   - duration: The span of time the prediction represents.
    /// - Tag: detectedAction
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {

        if actionPrediction.isModelLabel {
            print("CLASSE: ", actionPrediction.label, " ", actionPrediction.confidence as Any)
            meanConfidence.append(actionPrediction.confidence)
            if (actionPrediction.label != "Altro"){
                // Update the total number of frames for this action.
                addFrameCount(frameCount, to: actionPrediction.label)
                addRepCount(1, to: actionPrediction.label)
            }
        }

        // Present the prediction in the UI.
        updateUILabelsWithPrediction(actionPrediction)
    }

    /// Receives a frame and any poses in that frame.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - poses: A `Pose` array.
    ///   - frame: A video frame as a `CGImage`.
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?,
                              in frame: CGImage) {
        // Render the poses on a different queue than pose publisher.
        DispatchQueue.global(qos: .userInteractive).async {
            // Draw the poses onto the frame.
            self.drawPoses(poses, onto: frame)
        }
    }
}

// MARK: - Helper methods
extension MainViewController {
    /// Add the incremental duration to an action's total time.
    /// - Parameters:
    ///   - actionLabel: The name of the action.
    ///   - duration: The incremental duration of the action.
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        // Add the new duration to the current total, if it exists.
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount

        // Assign the new total frame count for this action.
        actionFrameCounts[actionLabel] = totalFrames
    }
    /// Add the incremental rep to an action's total time.
    /// - Parameters:
    ///   - actionLabel: The name of the action.
    ///   - repCount: The incremental rep of the action.
    private func addRepCount(_ repCount: Int, to actionLabel: String) {
        // Add the new duration to the current total, if it exists.
        let totalReps = (actionRepCounts[actionLabel] ?? 0) + repCount

        // Assign the new total rep count for this action.
        actionRepCounts[actionLabel] = totalReps
        
        print("REP: \(actionLabel)  \(totalReps)")
        
        livCount += 1
        
        if(actionLabel == "Flessione"){
            DispatchQueue.main.async {
                self.flexReps.text = " " + String (totalReps) + " "
                self.flexProgressBar.progress = Float(totalReps)/Float(self.esercizio.flex)
            }
            if(totalReps == esercizio.flex && actionRepCounts["Estensione"] == esercizio.ext){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SpeechService.shared.startSpeech(text: "Esercizio completato")
                }
                completo = true
                db.updateEsercizio(id: esercizio.id)
                self.onSummaryButtonTapped()
            }
        } else if (actionLabel == "Estensione"){
            DispatchQueue.main.async {
                self.extReps.text = " " + String (totalReps) + " "
                self.extProgressBar.progress = Float(totalReps)/Float(self.esercizio.ext)
            }
            if(totalReps == esercizio.ext && actionRepCounts["Flessione"] == esercizio.flex){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SpeechService.shared.startSpeech(text: "Esercizio completato")
                }
                completo = true
                db.updateEsercizio(id: esercizio.id)
                self.onSummaryButtonTapped()
            }
        }
        /*
        //LIV1 - LIV2 - LIV3 TEST COMMIT
        if(livCount == 4){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                SpeechService.shared.startSpeech(text: "Livello 1 superato")
            }
            livStack.isHidden = false
            livLabel1.isHidden = false
            statusLabel.text = "PUOI FARE DI MEGLIO"
        } else if(livCount == 7){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                SpeechService.shared.startSpeech(text: "Livello 2 superato")
            }
            livLabel2.isHidden = false
            statusLabel.text = "ANCORA UNA SFORZO"
        } else if(livCount == 10){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                SpeechService.shared.startSpeech(text: "Livello 3 superato")
            }
            livLabel3.isHidden = false
            if #available(iOS 15.0, *) {
                livStack.backgroundColor = UIColor.systemCyan
            }
            livStack.layer.cornerRadius = 10
            statusLabel.text = "COMPLIMENTI!"
        }
        
        //RESOCONTO
        if(livCount == 10){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.onSummaryButtonTapped()
            }
        }*/
    }

    /// Updates the user interface's labels with the prediction and its
    /// confidence.
    /// - Parameters:
    ///   - label: The prediction label.
    ///   - confidence: The prediction's confidence value.
    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
        // Update the UI's prediction label on the main thread.
        DispatchQueue.main.async { self.actionLabel.text = prediction.label }
        
        actionPredicted.append(prediction.label)
        
        if actionPredicted.count == 1 {
            SpeechService.shared.startSpeech(text: actionPredicted.first!)
            if(actionPredicted.first == "Flessione"){
                flexStack.isHidden = false
                extStack.isHidden = true
            } else if (actionPredicted[(actionPredicted.count)-1] == "Estensione"){
                flexStack.isHidden = true
                extStack.isHidden = false
            } else {
                flexStack.isHidden = true
                extStack.isHidden = true
            }
        } else if actionPredicted.count > 1{
            if(actionPredicted[(actionPredicted.count)-1] == "Altro"){
                nonSicuroLabel.isHidden = true
                flexStack.isHidden = true
                extStack.isHidden = true
                SoundManager.instance.playSound(sound: .wrong)
            }
            else if(actionPredicted[(actionPredicted.count)-1] == "Non sono sicuro"){
                nonSicuroLabel.isHidden = false
                flexStack.isHidden = true
                extStack.isHidden = true
                SpeechService.shared.startSpeech(text: actionPredicted[(actionPredicted.count)-1])
            }
            else if actionPredicted[(actionPredicted.count)-1] != actionPredicted[(actionPredicted.count)-2] {
                SpeechService.shared.startSpeech(text: actionPredicted[(actionPredicted.count)-1])
                if(actionPredicted[(actionPredicted.count)-1] == "Flessione"){
                    nonSicuroLabel.isHidden = true
                    flexStack.isHidden = false
                    extStack.isHidden = true
                } else if (actionPredicted[(actionPredicted.count)-1] == "Estensione"){
                    nonSicuroLabel.isHidden = true
                    flexStack.isHidden = true
                    extStack.isHidden = false
                } else {
                    nonSicuroLabel.isHidden = false
                    flexStack.isHidden = true
                    extStack.isHidden = true
                }
                
            } else {
                if(actionPredicted[(actionPredicted.count)-1] == "Flessione"){
                    SoundManager.instance.playSound(sound: .flex)
                    nonSicuroLabel.isHidden = true
                    flexStack.isHidden = false
                    extStack.isHidden = true
                } else if (actionPredicted[(actionPredicted.count)-1] == "Estensione"){
                    SoundManager.instance.playSound(sound: .ext)
                    nonSicuroLabel.isHidden = true
                    flexStack.isHidden = true
                    extStack.isHidden = false
                }
            }
        }

        // Update the UI's confidence label on the main thread.
        let confidenceString = prediction.confidenceString ?? "Observing..."
        DispatchQueue.main.async { self.confidenceLabel.text = confidenceString }
    }

    /// Draws poses as wireframes on top of a frame, and updates the user
    /// interface with the final image.
    /// - Parameters:
    ///   - poses: An array of human body poses.
    ///   - frame: An image.
    /// - Tag: drawPoses
    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        // Create a default render format at a scale of 1:1.
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0

        // Create a renderer with the same size as the frame.
        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
                                                   format: renderFormat)

        // Draw the frame first and then draw pose wireframes on top of it.
        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            // The`UIGraphicsImageRenderer` instance flips the Y-Axis presuming
            // we're drawing with UIKit's coordinate system and orientation.
            let cgContext = rendererContext.cgContext

            // Get the inverse of the current transform matrix (CTM).
            let inverse = cgContext.ctm.inverted()

            // Restore the Y-Axis by multiplying the CTM by its inverse to reset
            // the context's transform matrix to the identity.
            cgContext.concatenate(inverse)

            // Draw the camera image first as the background.
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)

            // Create a transform that converts the poses' normalized point
            // coordinates `[0.0, 1.0]` to properly fit the frame's size.
            //let pointTransform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)

            //guard let poses = poses else { return }

            // Draw all the poses Vision found in the frame.
            /*for pose in poses {
                // Draw each pose as a wireframe at the scale of the image.
                pose.drawWireframeToContext(cgContext, applying: pointTransform)
            }*/
        }

        // Update the UI's full-screen image view on the main thread.
        DispatchQueue.main.async { self.imageView.image = frameWithPosesRendering }
    }
}

class SoundManager {
    
    static let instance = SoundManager() // Singleton
    var player: AVAudioPlayer?
    enum SoundOption: String {
        case ext
        case flex
        case wrong
    }
    
    
    func playSound(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Errore nella riproduzione del suono: \(error.localizedDescription)")
        }
    }
}
