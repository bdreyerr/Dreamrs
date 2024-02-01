//
//  HomeManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/11/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import StabilityAIKit
import OpenAI


class HomeManager : ObservableObject {
    
    @Published var selectedMonth: String
    var months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "Novemeber", "December"]
    @Published var selectedYear: String
    var years = ["2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"]
    
    
    @Published var retrievedDreams : [Dream] = []
    @Published var retrievedImages : [String : UIImage] = [:]
    
    @Published var isCreateDreamPopupShowing: Bool = false
    
    @Published var focusedDream: Dream?
    @Published var focusedTextFormatted: NSAttributedString?
    @Published var isFocusedDreamPinned: Bool = false
    
    // AI
    // TODO: Understand what timeout interval does. If I Open the app, and wait for 60 minutes, then try to submit a dream will the openAI access but cutoff?
    let openAI = OpenAI(configuration: OpenAI.Configuration(token: Secrets().openAiToken, timeoutInterval: 60.0))
    let stabilityAiConfiguration = Configuration(apiKey: Secrets().stabilityAiToken)
    
    // Post Publish Vars (Viewing newly created dreams)
    @Published var isViewNewlyCreatedDreamPopupShowing: Bool = false
    @Published var isErrorLoadingNewDream: Bool = false
    
    @Published var isConfirmPinnedDreamPopupShowing: Bool = false
    
    @Published var isConfirmDeleteDreamAlertShowing: Bool = false
    
    // Firestore
    let db = Firestore.firestore()
    
    // Storage
    let storage = Storage.storage()
    
    init() {
        // Find the current month, set the selector
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        selectedMonth = months[currentMonth - 1]
        // Hardcoded to 2024, eventually set to current year based on calendar
        selectedYear = years[5]
    }
    
    func retrieveDreams(userId: String) {
        // validate user id
        if userId != Auth.auth().currentUser?.uid { return }
        
        self.retrievedDreams = []
        
        // read from only the selected month of the current year
        // TODO(bendreyer): add multi year functionality later
        let dreamSubcollection = selectedMonth+selectedYear
        
        // start with getting all documents from a current user (build dream individualy)
        db.collection("dreams" + dreamSubcollection).whereField("authorId", isEqualTo: userId).order(by: "rawTimestamp", descending: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: ", err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        let title = document.data()["title"] as? String
                        let plainText = document.data()["plainText"] as? String
                        let archivedData = document.data()["archivedData"] as? Data
                        let date = document.data()["date"] as? String
                        let rawTimestamp = document.data()["rawTimestamp"] as? Timestamp
                        let dayOfWeek = document.data()["dayOfWeek"] as? String
                        let karma = document.data()["karma"] as? Int
                        let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                        let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                        let tags = document.data()["tags"] as? [[String : String]]
                        let AITextAnalysis = document.data()["AITextAnalysis"] as? String
                        let hasImage = document.data()["hasImage"] as? Bool
                        
                        let dream = Dream(id: id, authorId: userId, title: title, plainText: plainText, archivedData: archivedData, date: date, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags, AITextAnalysis: AITextAnalysis, hasImage: hasImage)
                        self.retrievedDreams.append(dream)
                        
                        // append image to local map if necessary
                        if let hasImage = dream.hasImage {
                            if hasImage {
                                // Download the image from firestore
                                let imageRef = self.storage.reference().child("dreams" + dreamSubcollection + "/" + dream.id! + ".jpg")
                                
                                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                                imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                    if let error = error {
                                        print("Error downloading image from storage: ", error.localizedDescription)
                                    } else {
                                        // Data for "images/island.jpg" is returned
                                        let image = UIImage(data: data!)
                                        self.retrievedImages[dream.id!] = image
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
    }
    
    // Called after a dream is created in CreateDreamManager, processes the AI aspects of the dream
    func processNewDream(dream: Dream, shouldVisualizeDream: Bool, shouldAnalyzeDream: Bool) async {
        
        // Process the text analysis first, then the image ( called in seperate functions )
        
        // Options:
        //  1. Generate text and image
        //  2. Generate only text
        //  3. Generate only image
        
        if shouldAnalyzeDream && shouldVisualizeDream {
            // process Text Analysis will can processImageGeneration if the image is needed
            await processTextAnalysis(dream: dream, isImageGenerationNeeded: true)
        } else if shouldAnalyzeDream {
            await processTextAnalysis(dream: dream, isImageGenerationNeeded: false)
        } else if shouldVisualizeDream {
//            processImageGeneration(dream: dream)
            await processImageGeneration(dream: dream)
        }
        
    }
    
    func processTextAnalysis(dream: Dream, isImageGenerationNeeded: Bool) async {
        let dreamPrompt = "Analyze the following dream: " + dream.plainText!
        
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: dreamPrompt)])
        openAI.chats(query: query) { result in
            // Handle OpenAI response
            switch result {
            case .success(let result):
                if let response = result.choices[0].message.content {
                    // Save the AI dream analysis onto the dream object in firestore
                    do {
                        // Get dream collection
                        let timestamp = dream.rawTimestamp!
                        let date = timestamp.dateValue()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
                        let formattedString = dateFormatter.string(from: date)
                        let dreamCollection = "dreams" + formattedString

                        try self.db.collection(dreamCollection).document(dream.id!).updateData([
                            "AITextAnalysis": response
                        ])
                        
//                        print("AI text analysis successfully saved to firestore")
                        
                        // AI is finished, call retrieve dreams to load the new dream and dismiss the loading view, or do it in image if needed
                        if isImageGenerationNeeded {
                            Task {
                                await self.processImageGeneration(dream: dream)
                            }
                        } else {
                            self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                            self.isViewNewlyCreatedDreamPopupShowing = false
                        }
                        
                    } catch {
//                        print("Error saving AI text analysis to firestore")
                    }
                } else {
//                    print("Text response from OpenAI is empty")
                }
            case .failure(let error):
                print("Failure generating AI Dream Analysis: ", error.localizedDescription)
                
            }
        }
    }
    
    func processImageGeneration(dream: Dream) async {
        let imagePrompt = "Visualize this dream:" + dream.plainText!
        
        
        let client = Client(configuration: stabilityAiConfiguration)
        let request = TextToImageRequest(textPrompts: [.init(text: imagePrompt)])
        
        do {
            let results = try await client.getImageFromText(request, engine: "stable-diffusion-xl-1024-v1-0")
            // Make a UI Image with the response
            
            // Convert the response payload to UIImage
            if let response = results[0].data {
                let image = UIImage(data: response)
                
                // Convert the image into JPEG and compress the quality to reduce its size
                if let image = image {
                    let data = image.jpegData(compressionQuality: 0.8)
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpg"
                    
                    
                    // Save the compressed jpeg to firestore under the dreamId
                    
                    // Get dream collection
                    let timestamp = dream.rawTimestamp!
                    let date = timestamp.dateValue()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
                    let formattedString = dateFormatter.string(from: date)
                    let dreamCollection = "dreams" + formattedString
                    
                    // Create a storage reference
                    let storageRef = storage.reference().child(dreamCollection + "/" + dream.id! + ".jpg")
                    
                    if let data = data {
                        storageRef.putData(data, metadata: metadata) { (metadata, error) in
                            if let error = error {
                                print("Error while uploading file to storage: ", error)
                                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                                self.isViewNewlyCreatedDreamPopupShowing = false
                            } else {
                                if let metadata = metadata {
//                                    print("Metadata: ", metadata)
                                }
                                self.setHasImageBitOnDream(dreamId: dream.id!, dreamCollection: dreamCollection)
                            }
                            
                        }
                    } else {
//                        print("failure compressing image")
                        self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                        self.isViewNewlyCreatedDreamPopupShowing = false
                    }
                } else {
//                    print("failure getting UIimage from response")
                }
            } else {
//                print("failing getting response from results[0].data")
                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                self.isViewNewlyCreatedDreamPopupShowing = false
            }
        } catch {
            print("error generating image with stable diffusion: ", error)
            self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
            self.isViewNewlyCreatedDreamPopupShowing = false
            
        }
    }
    
    // This old method uses OpenAI's DALLE. The new method above uses stability.ai's stable diffusion. It's cheaper and higher quality.
//    func processImageGeneration(dream: Dream) {
//        // TODO: Determine if we want to pass in the entire dream plainText (this could be very long)
//        //       OR simply generate a summary of the dream with OpenAI chat query and pass that.
//        let imagePrompt = dream.plainText!
//        
//        let query = ImagesQuery(prompt: imagePrompt, n: 1, size: "1024x1024")
//        openAI.images(query: query) { result in
//            switch result {
//            case .success(let result):
//
//                print("trying to grab the url: ", result.data[0].url ?? "no url")
//                // Download the image from the url
//                self.downloadImageFromURL(result.data[0].url ?? "no url") { image, urlString in
//                    if let imageObject = image {
//                        // We now have access to the imageObject, we can store it how we like in firebase storage
//                        self.uploadImgToStorage(image: imageObject, dreamId: dream.id!, rawTimestamp: dream.rawTimestamp!)
//                    } else {
//                        print("return false from completion on downloadImage URL")
//                        self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
//                        self.isViewNewlyCreatedDreamPopupShowing = false
//                    }
//                }
//                
////                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
////                self.isViewNewlyCreatedDreamPopupShowing = false
//            case .failure(let error):
//                print("Error generating image with DALLE: ", error.localizedDescription)
//                
//                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
//                self.isViewNewlyCreatedDreamPopupShowing = false
//            }
//        }
//        
////        self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
////        self.isViewNewlyCreatedDreamPopupShowing = false
//        return
//    }
    
//    func downloadImageFromURL(_ urlString: String, completion: ((_ uiImage: UIImage?, _ urlString: String?) -> ())?) {
//        guard let url = URL(string: urlString) else {
//            completion?(nil, urlString)
//            return
//        }
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("error in downloading image from url: \(error)")
//                completion?(nil, urlString)
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
//                completion?(nil, urlString)
//                return
//            }
//            
//            if let data = data, let image = UIImage(data: data) {
//                completion?(image, urlString)
//                return
//            }
//            completion?(nil, urlString)
//        }.resume()
//    }
    
//    func uploadImgToStorage(image: UIImage, dreamId: String, rawTimestamp: Timestamp) {
//        
//        // Get dream collection
//        let timestamp = rawTimestamp
//        let date = timestamp.dateValue()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
//        let formattedString = dateFormatter.string(from: date)
//        let dreamCollection = "dreams" + formattedString
//        
//        // Create a storage reference
//        let storageRef = storage.reference().child(dreamCollection + "/" + dreamId + ".jpg")
//
//        // Convert the image into JPEG and compress the quality to reduce its size
//        let data = image.jpegData(compressionQuality: 0.5)
//        
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpg"
//        
//        if let data = data {
//            storageRef.putData(data, metadata: metadata) { (metadata, error) in
//                if let error = error {
//                    print("Error while uploading file to storage: ", error)
//                    self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
//                    self.isViewNewlyCreatedDreamPopupShowing = false
//                } else {
//                    if let metadata = metadata {
//                        print("Metadata: ", metadata)
//                    }
//                    self.setHasImageBitOnDream(dreamId: dreamId, dreamCollection: dreamCollection)
//                }
//                
//            }
//        } else {
//            print("failure compressing image")
//            self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
//            self.isViewNewlyCreatedDreamPopupShowing = false
//        }
//    }
    
    func setHasImageBitOnDream(dreamId: String, dreamCollection: String) {
        self.db.collection(dreamCollection).document(dreamId).updateData([
            "hasImage": true
        ]) { error in
            if let error = error {
                print("Error setting has image bit on dream: ", error.localizedDescription)
                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                self.isViewNewlyCreatedDreamPopupShowing = false
            } else {
//                print("successfully completed image flow, closing popup")
                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                self.isViewNewlyCreatedDreamPopupShowing = false
            }
        }
    }
    
    func displayDream(dream: Dream) {
        self.focusedDream = dream
        self.focusedTextFormatted = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dream.archivedData!) as? NSAttributedString
//        print("The displayed dream's raw timestamp is: ", self.focusedDream?.rawTimestamp ?? "None")
    }
    
    func deleteDream() {
        if let dream = self.focusedDream {
            // Format the dream collection based on date and year
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMMYYYY"
            let formattedDate = dateFormatter.string(from: dream.rawTimestamp!.dateValue())
            let collectionString = "dreams"+formattedDate
            
            
            self.db.collection(collectionString).document(dream.id!).delete() { err in
                if let err = err {
                    print("Error deleting dream: ", err.localizedDescription)
                } else {
//                    print("Dream deleted successefully in firestore")
                    self.focusedDream = nil
                    self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                    
                    // in the view we also check the if the dream being deleted is pinned and remove it if it is
                    
                    // also need to -1 the numDreams for the user
                    
                    self.db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
                        "numDreams": FieldValue.increment(Int64(-1))
                    ]) { err in
                        if let err = err {
//                            print("error -1ing num dreams for user")
                        } else {
//                            print("successfully -1 num dreams for user")
                        }
                    }
                }
            }
        }
    }
    
    func randomImage() -> String {
        let randomNumber = Int.random(in: 2...6)
        return "dream\(randomNumber)"
    }
    
    func convertStringToColor(color: String) -> Color {
        switch color {
        case "Red":
            return Color.red
        case "Blue":
            return Color.blue
        case "Green":
            return Color.green
        case "Purple":
            return Color.purple
        case "Cyan":
            return Color.cyan
        case "Yellow":
            return Color.yellow
        case "Orange":
            return Color.orange
        default:
            return Color.blue
            
        }
    }
}
