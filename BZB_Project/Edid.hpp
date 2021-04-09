//
//  Edid.hpp
//  GoMaxAVP
//
//  Created by DarrenHuang on 2020/6/17.
//  Copyright © 2020 DarrenHuang. All rights reserved.
//

#ifndef Edid_hpp
#define Edid_hpp

#include <stdio.h>
#include <string>

class testCC {
private:
    unsigned char *m_EdidBuffer;
    float calinvert(unsigned int input);
    int descriptorBlockPaser(std::string &result,int i);
    int ceaBlockPaser(std::string &result,int i,int len);
public:
    char* edidParser(unsigned char *buf,int len);
};

#endif /* Edid_hpp */
