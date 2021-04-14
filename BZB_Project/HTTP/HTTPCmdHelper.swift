//
//  HTTPCmdHelper.swift
//  BZB_Project
//
//  Created by GoMax on 2021/4/13.
//

import Foundation

struct HTTPCmdHelper {
    
    /******  Command  ******/
    static let cmd_get_node_info = "/api/node_info"
    static let cmd_send_cmd = "/api/ast_sendcmd"
    static let cmd_switch_group_id = "/api/astswitch"
    
    /******  Command number  ******/
    static let _1_cmd_get_node_info = 101
    static let _2_cmd_search_get_node_info = 102
    static let _3_cmd_red_light = 103
}
