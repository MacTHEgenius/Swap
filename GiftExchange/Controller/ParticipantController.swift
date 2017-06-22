//
//  ParticipantController.swift
//  GiftExchange
//
//  Created by Benoît Lévesque on 2017-04-15.
//  Copyright © 2017 Benoît Lévesque. All rights reserved.
//

import Foundation

class ParticipantController {
    
    let parent: ParticipantsController
    let participant: Participant?
    
    private(set) var cantPick: [String:Bool] = [:]
    
    init(_ participant: Participant? = nil, parent: ParticipantsController) {
        self.participant = participant
        self.parent = parent
        if let participant = self.participant {
            self.cantPick = participant.cantPick.reduce(self.cantPick) { (dict, participantId) -> [String:Bool] in
                var d = dict
                d[participantId] = true
                return d
            }
        }
    }
    
    func doNotPick(_ participant: Participant, isPicked: Bool) {
        if let current = self.participant, current.id != participant.id {
            self.cantPick[participant.id] = isPicked
        }
    }
    
    func save(_ participant: Participant) throws {
        let temp = self.cantPick.map({ (key, value) in value ? key : "" })
        participant.cantPick = temp.filter({ (str) in str != "" })
        
        if participant.valid {
            if let p = self.participant {
                self.parent.update(old: p, with: participant)
            } else {
                self.parent.add(participant)
            }
        } else {
            throw ParticipantError.notValid(errors: participant.errors)
        }
    }
}

enum ParticipantError: Error, Equatable {
    case notValid(errors: [String])
}

func ==(lhs: ParticipantError, rhs: ParticipantError) -> Bool {
    switch (lhs, rhs) {
    case (.notValid(let leftErrors), .notValid(let rightErrors)): return leftErrors == rightErrors
    }
}
