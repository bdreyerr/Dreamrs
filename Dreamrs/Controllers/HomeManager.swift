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
    
    @Published var retrievedDreams : [Dream] = []
    @Published var retrievedImages : [String : UIImage] = [:]
    @Published var lastDocumentSnapshot: DocumentSnapshot? = nil
    @Published var isLoadingMoreDreams: Bool = false
    @Published var noMoreDreamsAvailable: Bool = false
    
    // Sort by ascending or descending date (false = oldest first)
    @Published var sortByDateDescending: Bool = false
    
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
    
    let defaultNumberDreamsToRetrieve: Int = 10 
    
    // Storage
    let storage = Storage.storage()
    
    init() {
        // Find the current month, set the selector
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
    }
    
    func retrieveDreams(userId: String, loadMore: Bool = false) {
        // validate user id
        if userId != Auth.auth().currentUser?.uid { return }
        
        if !loadMore {
            DispatchQueue.main.async {
                self.retrievedDreams = []
                self.lastDocumentSnapshot = nil
                self.noMoreDreamsAvailable = false
            }
        }
        
        // Set loading state
        DispatchQueue.main.async {
            self.isLoadingMoreDreams = true
        }
        
        // start with getting all documents from a current user (build dream individualy)
        var query = db.collection("dreams")
            .whereField("authorId", isEqualTo: userId)
            .order(by: "rawTimestamp", descending: sortByDateDescending)
            .limit(to: defaultNumberDreamsToRetrieve)
        
        // If loading more, start after the last document
        if loadMore, let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: ", err.localizedDescription)
                DispatchQueue.main.async {
                    self.isLoadingMoreDreams = false
                }
            } else {
                // Check if there are any more dreams available
                if querySnapshot!.documents.isEmpty {
                    DispatchQueue.main.async {
                        self.noMoreDreamsAvailable = true
                        self.isLoadingMoreDreams = false
                    }
                    return
                }
                
                // Save the last document for pagination
                self.lastDocumentSnapshot = querySnapshot!.documents.last
                
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
                    let hasAdultContent = document.data()["hasAdultContent"] as? Bool
                    
                    let dream = Dream(id: id, authorId: userId, title: title, plainText: plainText, archivedData: archivedData, date: date, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags, AITextAnalysis: AITextAnalysis, hasImage: hasImage, hasAdultContent: hasAdultContent)
                    self.retrievedDreams.append(dream)
                    
                    // append image to local map if necessary
                    if let hasImage = dream.hasImage {
                        if hasImage {
                            // Download the image from firestore
                            let imageRef = self.storage.reference().child("dreams" + "/" + dream.id! + ".jpg")
                            
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
                
                DispatchQueue.main.async {
                    self.isLoadingMoreDreams = false
                }
            }
        }
    }
    
    func loadMoreDreams() {
        if let user = Auth.auth().currentUser {
            self.retrieveDreams(userId: user.uid, loadMore: true)
        }
    }
    
    func toggleSortOrder(isNewest: Bool) {
        sortByDateDescending = isNewest
        if let user = Auth.auth().currentUser {
            self.retrieveDreams(userId: user.uid)
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
        } else {
            DispatchQueue.main.async {
                if let user = Auth.auth().currentUser {
                    self.retrieveDreams(userId: user.uid)
                    self.isViewNewlyCreatedDreamPopupShowing = false
                }
            }
        }
        
    }
    
    func processTextAnalysis(dream: Dream, isImageGenerationNeeded: Bool) async {
        let dreamPrompt = "Analyze the following dream: " + dream.plainText!
        
        // Create a non-optional Chat message
        
        guard let message = ChatQuery.ChatCompletionMessageParam(role: .user, content: dreamPrompt) else {
            print( "Failed to create Chat message")
            return
        }
        
        let query = ChatQuery(messages: [message], model: .gpt4_o_mini)
        openAI.chats(query: query) { result in
            // Handle OpenAI response
            switch result {
            case .success(let result):
                if let response = result.choices[0].message.content {
                    // Save the AI dream analysis onto the dream object in firestore
                    do {
                        self.db.collection("dreams").document(dream.id!).updateData([
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
                            DispatchQueue.main.async {
                                self.isViewNewlyCreatedDreamPopupShowing = false
                            }
                        }
                        
                    } catch {
//                        print("Error saving AI text analysis to firestore")
                    }
                } else {
//                    print("Text response from OpenAI is empty")
                }
            case .failure(let error):
                print("Failure generating AI Dream Analysis: ", error.localizedDescription)
                print(result)
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
                    
                    let dreamCollection = "dreams"
                    
                    // Create a storage reference
                    let storageRef = storage.reference().child(dreamCollection + "/" + dream.id! + ".jpg")
                    
                    if let data = data {
                        storageRef.putData(data, metadata: metadata) { (metadata, error) in
                            if let error = error {
                                print("Error while uploading file to storage: ", error)
                                self.retrieveDreams(userId: Auth.auth().currentUser!.uid)
                                self.isViewNewlyCreatedDreamPopupShowing = false
                            } else {
                                if let _ = metadata {
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
            let collectionString = "dreams"
            
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
            
            // delete the image from storage
            if let hasImage = dream.hasImage, hasImage {
                let imageRef = self.storage.reference().child("dreams" + "/" + dream.id! + ".jpg")
                
                imageRef.delete { error in
                    if let error = error {
                        print("Error deleting image from storage: ", error.localizedDescription)
                    } else {
                        print("Image successfully deleted from storage")
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
