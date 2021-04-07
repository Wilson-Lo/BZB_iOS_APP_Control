//
//  CmdHelper.swift
//
//  Created by Wilson Lo on 2021/03/31.
//  Copyright © 2021 GoMax-ElectronicsrequireBlueriverAPI. All rights reserved.
//

import Foundation

struct CmdHelper {
    
    static let key_server_ip = "device_ip"
    static let cmd_fw_version = "0b4d4152444348ff0501bf" //fw version
    
    /******  Matrix  4 x 4 ******/
    static let cmd_4_x_4_get_network = "0a4d4152444348ff31e9"
    static let cmd_4_x_4_get_current_mapping  = "0a4d4152444348ff01b9"
    static let cmd_4_x_4_get_io_name  = "0b4d4152444348ff47f1f1"
    static let cmd_4_x_4_set_io_name  = "0b4d4152444348ff47f3f3"
    static let cmd_4_x_4_get_mapping_name  = "0b4d4152444348ff47f2f2"
    static let cmd_4_x_4_set_mapping_name  = "0b4d4152444348ff47f4f4"
    static let cmd_4_x_4_set_single_mapping  = "0c4d4152444348ff03"
    static let cmd_4_x_4_set_all_mapping  = "0e4d4152444348ff02"
    static let cmd_4_x_4_recall_mapping  = "0b4d4152444348ff51"
    static let cmd_4_x_4_save_mapping  = "0b4d4152444348ff50"
    static let cmd_4_x_4_learn_edid  = "0d4d4152444348ff0c"
    static let cmd_4_x_4_get_input_edid  = "0b4d4152444348ff0b"
    static let cmd_4_x_4_get_output_edid  = "0b4d4152444348ff0a"
    
    /******  Matrix  8 x 8 ******/
    static let cmd_8_x_8_get_network = "0a4d4152884348ff312d"
    static let cmd_8_x_8_get_current_mapping  = "0a4d4152884348ff01fd"
    static let cmd_8_x_8_get_io_name  = "0b4d4152884348ff47f135"
    static let cmd_8_x_8_set_io_name  = "4d4152884348ff47f3"
    static let cmd_8_x_8_get_mapping_name  = "0b4d4152884348ff47f236"
    static let cmd_8_x_8_set_mapping_name  = "4d4152884348ff47f4"
    static let cmd_8_x_8_set_single_mapping  = "0c4d4152884348ff03"
    static let cmd_8_x_8_set_all_mapping  = "124d4152884348ff02"
    static let cmd_8_x_8_recall_mapping  = "0b4d4152884348ff51"
    static let cmd_8_x_8_save_mapping  = "0b4d4152884348ff50"
    static let cmd_8_x_8_learn_edid  = "0d4d4152884348ff0c"
    static let cmd_8_x_8_get_input_edid  = "0b4d4152884348ff0b"
    static let cmd_8_x_8_get_output_edid  = "0b4d4152884348ff0a"
    
    /******  Default EDID item ******/
    static let default_edid_1 = "1. Full-HD (1080p@60)-24bit 2D & 2ch"
    static let default_edid_2 = "2. Full-HD (1080p@60)-24bit 2D & 7.1ch"
    static let default_edid_3 = "3. Full-HD (1080p@60)-24bit 3D & 2ch"
    static let default_edid_4 = "4. Full-HD (1080p@60)-24bit 2D & 7.1ch"
    static let default_edid_5 = "5. Full-HD (1080i@60)(720p@60)-24bit 2D & 2ch"
    static let default_edid_6 = "6. Full-HD (1080i@60)(720p@60)-24bit 2D & 7.1ch"
    static let default_edid_7 = "7. Full-HD (1080p@60)-36bit 2D & 2ch"
    static let default_edid_8 = "8. Full-HD (1080p@60)-36bit 2D & 7.1ch"
    static let default_edid_9 = "9. Full-HD (1080p@60)-24bit 2D & 2ch & Dobly 5.1ch"
    static let default_edid_10 = "10. 4k2k@30 2ch"
    static let default_edid_11 = "11. 4k2k@30 7.1ch"
    static let default_edid_12 = "12. 4k2k@30-3D-PCM2CH(2ch)"
    static let default_edid_13 = "13. 4k2k@30-3D-BITSTR(7.1ch)"
    static let default_edid_14 = "14. 4k2k@60-420-3D-PCM2CH(2ch)"
    static let default_edid_15 = "15. 4k2k@60-420-3D-BITSTR(7.1ch)"
    static let default_edid_16 = "16. 4k2k@60-3D_PCM2CH(2ch)"
    static let default_edid_17 = "17. 4k2k@60-3D-BITSTR(7.1ch)"
    
    static var default_edid = [default_edid_1, default_edid_2, default_edid_3, default_edid_4,
                               default_edid_5, default_edid_6, default_edid_7, default_edid_8,
                               default_edid_9, default_edid_10, default_edid_11, default_edid_12, default_edid_13, default_edid_14,
                               default_edid_15, default_edid_16, default_edid_17]
    
    
    /******  Command number  ******/
    static let _1_cmd_set_single_mapping = 101
    static let _2_cmd_get_mapping_status = 102
    static let _3_cmd_get_network_status = 103
    static let _4_cmd_fw_version = 104
    static let _5_cmd_get_io_name = 105
    static let _6_cmd_set_io_name = 106
    static let _7_cmd_get_mapping_name = 107
    static let _8_cmd_set_mapping_name = 108
    static let _9_cmd_set_all_mapping = 109
    static let _10_cmd_save_current_to_mapping = 110
    static let _11_cmd_recall_mapping = 111
    static let _12_cmd_learn_edid = 112
    static let _13_cmd_get_edid = 113
    
}
