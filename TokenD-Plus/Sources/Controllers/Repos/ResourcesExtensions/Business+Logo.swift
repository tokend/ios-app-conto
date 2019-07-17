import TokenDSDK

extension BusinessResource {
    
//    var outcome: Outcome? {
//        let details = self.creatorDetails
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: details, options: []) else {
//            return nil
//        }
//
//        guard let outcome = try? JSONDecoder().decode(
//            Outcome.self,
//            from: jsonData
//            ) else { return nil }
//
//        return outcome
//    }
}

extension BusinessResource {
    
    struct SubjectDetails: Decodable {
        let question: String
    }
    
    struct Choices: Decodable {
        let choices: [ChoiceDetails]
    }
    
    struct ChoiceDetails: Decodable {
        let number: Int
        let description: String
    }
    
    struct Outcome: Decodable {
        let outcome: [String: Int]
    }
}
