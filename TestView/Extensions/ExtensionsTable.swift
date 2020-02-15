//
//  Extensions.swift
//  TestView
//
//  Created by Евгений on 15.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

extension TableViewController{
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timerSearchDelay?.invalidate()
        timerSearchDelay = nil
        timerSearchDelay = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.doDelayedSearch), userInfo: searchText, repeats: false)
        
        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        
    }
    
    @objc func doDelayedSearch(_: Timer) {
        guard let info = timerSearchDelay?.userInfo as? String else { return }
        if info != "" {
            delegateNetwork?.makeRequest(name: info)
        }
        else{
            filteredData = data
            tableView.reloadData()
        }
        timerSearchDelay = nil
    }
}


extension TableViewController : sendDataRequest{
    func sendDataRequest(data: SearchJson) {
        self.dataRequest = data
    }
}
