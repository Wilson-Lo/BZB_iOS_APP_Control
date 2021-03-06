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
    static let cmd_video_wall_preset = "/api/video_wall_preset"
    static let cmd_set_video_wall = "/api/set_vw"
    static let cmd_get_mobile_preview = "/api/mobile/preview"
    static let cmd_get_mapping_preset = "/api/list_preset"

    /******  Command number  ******/
    static let _1_cmd_get_node_info = 101
    static let _2_cmd_search_get_node_info = 102
    static let _3_cmd_red_light = 103
    static let _4_cmd_video_wall_preset = 104
    static let _5_cmd_set_video_wall = 105
    static let _6_cmd_get_node_info_without_loading = 106
    static let _7_cmd_get_mobile_preview = 107
    static let _8_cmd_get_node_info_for_preset = 108
    static let _9_cmd_get_mapping_preset = 109
    static let _10_cmd_set_click_video_wall_preset = 110
}

