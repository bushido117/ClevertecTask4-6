//
//  SectionModel.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import Foundation

class Section: Hashable {
    
  var id = UUID()
  var title: String
  var atms: [ATMElement]?
  var infoboxes: [InfoboxElement]?
  var filials: [FilialElement]?
  
    init(title: String, atms: [ATMElement]?) {
    self.title = title
    self.atms = atms
  }
    
    init(title: String, infoboxes: [InfoboxElement]?) {
    self.title = title
    self.infoboxes = infoboxes
  }
  
    init(title: String, filials: [FilialElement]?) {
    self.title = title
    self.filials = filials
  }
    
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Section, rhs: Section) -> Bool {
    lhs.id == rhs.id
  }
}
