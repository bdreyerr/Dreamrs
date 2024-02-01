//
//  AdminManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/31/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import OpenAI
import StabilityAIKit

class AdminManager : ObservableObject {
    
    // Firestore
    let db = Firestore.firestore()
    
    // Storage
    let storage = Storage.storage()
    
    let openAI = OpenAI(configuration: OpenAI.Configuration(token: Secrets().openAiToken, timeoutInterval: 60.0))
    let stabilityAiConfiguration = Configuration(apiKey: Secrets().stabilityAiToken)
    
    var botUsers : [[String: String]] = [
        ["userId" : "XmdaBDcFQIt71hoPA2QT", "userColor" : "Blue", "userHandle" : "gkittle"],
        ["userId" : "TDcr5qoRdcPqPvK434WL", "userColor" : "Purple", "userHandle" : "arose"],
        ["userId" : "2EboIKb1bgr9ICzk8Pcz", "userColor" : "Yellow", "userHandle" : "liamjones"],
        ["userId" : "BRpaoW5CiyzA74QewsuF", "userColor" : "Orange", "userHandle" : "mayapatel"],
        ["userId" : "ffL918HWwTEVHBKsO6CH", "userColor" : "Cyan", "userHandle" : "egarcia"],
        ["userId" : "1fFuZd1Vf7NIYzahDRBM", "userColor" : "Red", "userHandle" : "livhernandez"],
        ["userId" : "i5N71qbgFtgJEt0q7yWG", "userColor" : "Blue", "userHandle" : "nomiller"],
    ]
    
    func generateRandomDreamsForForYouPage() {
        for user in self.botUsers {
            submitDream(userId: user["userId"]!, userColor: user["userColor"]!, userHandle: user["userHandle"]!)
        }
    }
    
    func submitDream(userId: String, userColor: String, userHandle: String) {
        // Steps:
        
        // 1. Generate a random dream title, 5 words or less
        // 2. Generate a dream description based on the title, 100 words or less
        // 3. Submit the dream to firestore
        // 4. Go through the AI process for text analysis, save it to the dream object
        // 5. Go through the AI process for image generation, save it to storage and set bit on the dream in firestore
        
        let dreamPrompt = "Generate the title of a dream you might have had, five words or less, don't include quotes. Avoid dreams about flying or floating."
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: dreamPrompt)])
        openAI.chats(query: query) { result in
            switch result {
            case .success(let result):
                do {
                    
                    if let response = result.choices[0].message.content {
                        // Now generate a dream description based on the dream title
                        let dreamDescriptionPrompt = "Generate a dream based on the following title, one hundred words or less: " + response
                        
                        let queryDescription = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: dreamDescriptionPrompt)])
                        self.openAI.chats(query: queryDescription) { result in
                            switch result {
                            case .success(let result):
                                do {
                                    if let responseDescription = result.choices[0].message.content {
                                        let date = Date()
                                        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
                                        let calendar = Calendar.current
                                        let dayOfWeek = calendar.component(.weekday, from: Date())
                                        let dayOfWeekString = calendar.weekdaySymbols[dayOfWeek - 1]
                                        let timestamp = Timestamp(date: Date())
                                        let dateValue = timestamp.dateValue()
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
                                        let formattedString = dateFormatter.string(from: dateValue)
                                        let dreamCollection = "dreams" + formattedString
                                        
                                        let archivedData: Data = try! NSKeyedArchiver.archivedData(withRootObject: NSAttributedString(string: responseDescription), requiringSecureCoding: false)
                                        
                                        // Now create a dream object and save it firestore
                                        // Create a dream object
                                        var dream = Dream(authorId: userId, authorHandle: userHandle, authorColor: userColor, title: response, plainText: responseDescription, archivedData: archivedData, date: formattedDate, rawTimestamp: timestamp, dayOfWeek: dayOfWeekString, karma: 1, sharedWithFriends: true, sharedWithCommunity: true, tags: [])
                                        
                                        // Store the dream in firestore
                                        let dreamsRef = self.db.collection("dreams" + formattedString)
                                        do {
                                            let newDreamRef = try dreamsRef.addDocument(from: dream)
                                            print("Dream stored with new doc reference: ", newDreamRef.documentID)
                                            
                                            // update the local dream id
                                            dream.id = newDreamRef.documentID
                                            
                                            // Add 1 to users num derams
                                            // TODO add error handling
                                            let userRef = self.db.collection("users").document(userId)
                                            userRef.updateData([
                                                "numDreams": FieldValue.increment(Int64(1))
                                            ])
                                            
                                            // AI Steps. Call analyze text, which will call generate image
                                            self.analyzeDreamText(dreamId: newDreamRef.documentID, dreamContent: responseDescription)
                                            return
                                        } catch {
                                            print("Error saving dream to firestore: ", error.localizedDescription)
                                            return
                                        }
                                        
                                    }
                                } catch {
                                    print("Failure idk")
                                }
                            case .failure(let error):
                                print("Failure generating dream description: ", error)
                            }
                        }
                    }
                } catch {
                    print("Failure big idk")
                }
            case .failure(let error):
                print("failure getting gpt response: ", error)
            }
        }
    }
    
    func analyzeDreamText(dreamId: String, dreamContent: String) {
        let dreamPrompt = "Analyze the following dream: " + dreamContent
        
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: dreamPrompt)])
        openAI.chats(query: query) { result in
            // Handle OpenAI response
            switch result {
            case .success(let result):
                if let response = result.choices[0].message.content {
                    // Save the AI dream analysis onto the dream object in firestore
                    do {
                        // Get dream collection
                        let timestamp = Timestamp(date: Date())
                        let date = timestamp.dateValue()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
                        let formattedString = dateFormatter.string(from: date)
                        let dreamCollection = "dreams" + formattedString

                        try self.db.collection(dreamCollection).document(dreamId).updateData([
                            "AITextAnalysis": response
                        ])
                        
                        print("AI text analysis successfully saved to firestore")
                        
                        // Text is done, now call visualizeDream
                        Task {
                            await self.visualizeDream(dreamId: dreamId, dreamContent: dreamContent)
                        }
                        
                    } catch {
                        print("Error saving AI text analysis to firestore")
                    }
                } else {
                    print("Text response from OpenAI is empty")
                }
            case .failure(let error):
                print("Failure generating AI Dream Analysis: ", error.localizedDescription)
                
            }
        }
    }
    
    func visualizeDream(dreamId: String, dreamContent: String) async {
        let imagePrompt = "Visualize this dream:" + dreamContent
        
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
                    let timestamp = Timestamp(date: Date())
                    let date = timestamp.dateValue()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMMYYYY"  // Set the desired format
                    let formattedString = dateFormatter.string(from: date)
                    let dreamCollection = "dreams" + formattedString
                    
                    // Create a storage reference
                    let storageRef = storage.reference().child(dreamCollection + "/" + dreamId + ".jpg")
                    
                    if let data = data {
                        storageRef.putData(data, metadata: metadata) { (metadata, error) in
                            if let error = error {
                                print("Error while uploading file to storage: ", error)
                            } else {
                                if let metadata = metadata {
                                    print("Metadata: ", metadata)
                                }
                                self.db.collection(dreamCollection).document(dreamId).updateData([
                                    "hasImage": true
                                ]) { error in
                                    if let error = error {
                                        print("Error setting has image bit on dream: ", error.localizedDescription)
                                        
                                    } else {
                                        print("successfully completed image flow, closing popup")
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        } catch {
            print("error generating image with stable diffusion: ", error)
        }
    }
}
