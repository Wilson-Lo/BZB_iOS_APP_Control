//
//  Edid.cpp
//  GoMaxAVP
//
//  Created by DarrenHuang on 2020/6/17.
//  Copyright © 2020 DarrenHuang. All rights reserved.
//

#include "Edid.hpp"


char* testCC::edidParser(unsigned char *buf,int len){
    
    this->m_EdidBuffer = new unsigned char[len]();
    for(int i=0;i<len;++i)
        this->m_EdidBuffer[i] = buf[i];
    
    std::string result = "";
    unsigned char *p = this->m_EdidBuffer,temp=0;
    char cbuf[50];
    int i = 0;
    unsigned int j=0,k=0;
    float fbuf = 0;
    result.clear();
    // 0-7 header check
    if(p[i] != 0)    {result = "error edid format";return strdup(result.c_str());}
    for(i=1;i<7;++i)    if(p[i] != 255)    {result = "error edid format";return strdup(result.c_str());}
    if(p[i] != 0)    {result = "error edid format";return strdup(result.c_str());}    ++i;
    //8-9  .........Manufacturer ID
    result += "Manufacturer ID: ";
    result += (char) (((p[i] & 0x7c) >> 2) +64);++i;
    result += (char) (((p[i-1] & 0x3) << 3) + ((p[i] & 0xE0) >> 5) +64);
    result += (char) ((p[i] & 0x1F) +64);++i;
    sprintf(cbuf,"%02X%02X\r\n",p[i+1],p[i]);
    //10?V11: Product ID Code
    result += "\r\nProduct ID: ";
    i+=2;
    result += cbuf;
    //12?V15: 32-bit Serial Number
    j = p[i++],j += (p[i++]<<8),j += (p[i++]<<16),j += (p[i++]<<24);
    result += "Serial Number: ";
    sprintf(cbuf,"%d\r\n",j);    result += cbuf;
    //16 -17 Week and year of Manufacture
    result += "Manufacture date: ";
    j = p[i++],k = p[i++];
    sprintf(cbuf,"week %d, year %d\r\n",j,k+1990);    result += cbuf;
    //18-19 EDID Version Number
    result += "EDID Version Number: ";
    j = p[i++],k = p[i++];
    sprintf(cbuf,"%d.%d\r\n",j,k);    result += cbuf;
    //20-24: BASIC DISPLAY PARAMETERS
    // 20: VIDEO INPUT DEFINITION
    result += "Signal Type: ";
    if(p[i] & 0x80)
        {
        if(p[i] & 1)    result += "digital DFP 1.x compatible\r\n";    //digital type
        else    result += "digital\r\n";
        }
    else    //analog
        {
        result += "analog\r\n";
        j = (p[i] & 0x60)>>5;
        switch (j){
        case 0:    result += "video level : 0.7, 0.3\r\n";break;
        case 1:    result += "video level : 0.714, 0.286\r\n";break;
        case 2:    result += "video level : 1, 0.4\r\n";break;
        case 3:    result += "video level : 0.7, 0\r\n";break; }
        if(p[i] & 0x10)    result += "blank-to-black setup\r\n";
        if(p[i] & 0x08)    result += "separate syncs\r\n";
        if(p[i] & 0x04)    result += "composite sync\r\n";
        if(p[i] & 0x02)    result += "sync on green\r\n";
        if(p[i] & 0x01)    result += "serration vsync\r\n";
        }++i;
    // 21-22: Maximum Vertical ,Horizontal Image Size
    result += "Max Image Size: ";
    sprintf(cbuf,"%d x %d mm\r\n",p[i]*10,p[i+1]*10);    result += cbuf;i+=2;
    //23: Display Gamma.
    result += "Display Gamma: ";
    sprintf(cbuf,"%3.2f\r\n",p[i++]/100.0+1);    result += cbuf;
    //24: Power Management and Supported Feature
    result += "Feature Supported: \r\n";
    j = (p[i] & 0x18)>>3;
    switch (j){
        case 0:    result += "\tdisplay type :monochrome\r\n";break;
        case 1:    result += "\tdisplay type :RGB color\r\n";break;
        case 2:    result += "\tdisplay type :non RGB multicolour\r\n";break;
        case 3:    result += "\tdisplay type :undefined\r\n";break; }
    if(p[i] & 0x80)    result += "\tstandby\r\n";
    if(p[i] & 0x40)    result += "\tsuspend\r\n";
    if(p[i] & 0x20)    result += "\tactive-off/low power\r\n";
    if(p[i] & 0x04)    result += "\tstandard colour space\r\n";
    if(p[i] & 0x02)    result += "\tpreferred timing mode\r\n";
    if(p[i] & 0x01)    result += "\tdefault GTF supported\r\n";
    ++i;
    //25-34: CHROMATICITY COORDINATES
    j = ((p[i] & 0xC0) >> 6) + (p[i+2] << 2);    //Red-x
    fbuf = calinvert(j);
    result += "Color characteristics:\r\n";
    sprintf(cbuf,"\tRed-x %1.3f  ",fbuf);    result += cbuf;
    j = ((p[i] & 0x30) >> 4) + (p[i+3] << 2);    //Red-y
    fbuf = calinvert(j);
    sprintf(cbuf,"Red-y %1.3f\r\n",fbuf);    result += cbuf;
    j = ((p[i] & 0x0C) >> 2) + (p[i+4] << 2);    //Green-x
    fbuf = calinvert(j);
    sprintf(cbuf,"\tGreen-x %1.3f  ",fbuf);    result += cbuf;
    j = (p[i] & 3) + (p[i+5] << 2);    //Green-y
    fbuf = calinvert(j);
    sprintf(cbuf,"Green-y %1.3f\r\n",fbuf);    result += cbuf;
    j = ((p[i+1] & 0xC0) >> 6) + (p[i+6] << 2);    //Blue-x
    fbuf = calinvert(j);
    sprintf(cbuf,"\tBlue-x %1.3f  ",fbuf);    result += cbuf;
    j = ((p[i+1] & 0x30) >> 4) + (p[i+7] << 2);    //Blue-y
    fbuf = calinvert(j);
    sprintf(cbuf,"Blue-y %1.3f\r\n",fbuf);    result += cbuf;
    j = ((p[i+1] & 0x0C) >> 2) + (p[i+8] << 2);    //White-x
    fbuf = calinvert(j);
    sprintf(cbuf,"\tWhite-x %1.3f  ",fbuf);    result += cbuf;
    j = (p[i+1] & 3) + (p[i+9] << 2);    //White-y
    fbuf = calinvert(j);
    sprintf(cbuf,"White-y %1.3f\r\n",fbuf);    result += cbuf;i += 10;
    //35-37: ESTABLISHED TIMING I , II , MANUFACTURER'S RESERVED TIMING
    result += "Etablished Timings :\r\n";
    //timing 1
    if(p[i] &128)    result += "\t720x400@70 Hz\r\n";
    if(p[i] &64)    result += "\t720x400@88 Hz\r\n";
    if(p[i] &32)    result += "\t640x480@60 Hz\r\n";
    if(p[i] &16)    result += "\t640x480@67 Hz\r\n";
    if(p[i] &8)    result += "\t640x480@72 Hz\r\n";
    if(p[i] &4)    result += "\t640x480@75 Hz\r\n";
    if(p[i] &2)    result += "\t800x600@56 Hz\r\n";
    if(p[i++] &1)    result += "\t800x600@60 Hz\r\n";
    //timing 2
    if(p[i] &128)    result += "\t800x600@72 Hz\r\n";
    if(p[i] &64)    result += "\t800x600@75 Hz\r\n";
    if(p[i] &32)    result += "\t832x624@75 Hz\r\n";
    if(p[i] &16)    result += "\t1024x768@87 Hz\r\n";
    if(p[i] &8)    result += "\t1024x768@60 Hz\r\n";
    if(p[i] &4)    result += "\t1024x768@70 Hz\r\n";
    if(p[i] &2)    result += "\t1024x768@75 Hz\r\n";
    if(p[i++] &1)    result += "\t1280x1024@75 Hz\r\n";
    //MANUFACTURER'S RESERVED TIMING
    if(p[i] &128)    result += "\t1152x870@75 Hz\r\n";i++;
    //38?V53: STANDARD TIMING IDENTIFICATION
    result += "Standard Timing :\r\n";
    for(j=0;j<16;j += 2)
        {
        if(p[i+j] == 1)    continue;
        k = p[i+j]*8+248;
        sprintf(cbuf,"Resolution : %d x ",k);    result += cbuf;
        switch ((p[i+j+1] & 0xC0)>>6){
        case 0:    sprintf(cbuf,"%.0f@%d Hz 16:10\r\n",k*0.625,(p[i+j+1] & 0x3f)+60);    result += cbuf;break;
        case 1:    sprintf(cbuf,"%.0f@%d Hz 4:3\r\n",k*0.75,(p[i+j+1] & 0x3f)+60);    result += cbuf;break;
        case 2:    sprintf(cbuf,"%.0f@%d Hz 5:4\r\n",k*0.8,(p[i+j+1] & 0x3f)+60);    result += cbuf;break;
        case 3:    sprintf(cbuf,"%.0f@%d Hz 16:9\r\n",k*0.5625,(p[i+j+1] & 0x3f)+60);    result += cbuf;break; }
        }
    i += 16;
    //54?V71: DESCRIPTOR BLOCK 1
    for(k=1;k<5;++k)
        i = descriptorBlockPaser(result,i);
    //126 - 127 extension flag and checksum
    sprintf(cbuf,"checksum : %02X\r\n\r\n",p[i+1]);    result += cbuf;
    if(p[i] != 1)    return strdup(result.c_str());    //no extension block
    i+=2;
    //start extension block
    if(p[i] != 2)    return strdup(result.c_str()); //128 non CEA Extension
    sprintf(cbuf,"CEA Extension \r\nRevision Number : %02X\r\n",p[i+1]);    result += cbuf;i+=2;
    j = p[i++];
    sprintf(cbuf,"supports underscan : %s\r\n",(p[i]&128)?"true":"false");    result += cbuf;
    sprintf(cbuf,"supports basic audio : %s\r\n",(p[i]&64)?"true":"false");    result += cbuf;
    sprintf(cbuf,"supports YCbCr 4:4:4 : %s\r\n",(p[i]&32)?"true":"false");    result += cbuf;
    sprintf(cbuf,"supports YCbCr 4:2:2 : %s\r\n",(p[i]&16)?"true":"false");    result += cbuf;
    ++i;
    if(j == 0 || j == 255)    return strdup(result.c_str());    //no detailed timing descriptions are provide
    if(j > 4)    //CEA data block
        {
        result += "\r\nCEA Extension Reserved Block\r\n";
        i = ceaBlockPaser(result,i,j-4);
        }
    while(i+18 < 256)
        i = descriptorBlockPaser(result,i);
    sprintf(cbuf,"checksum : %02X\r\n",p[255]);    result += cbuf;
    return strdup(result.c_str());

}

int testCC::ceaBlockPaser(std::string &result,int i,int len)
{
    unsigned char *p = this->m_EdidBuffer;
    char temp[50];
    len += i;
    int blockLen = 0;
    if(len>255) return 256;
    while(i < len)
        {
        switch((p[i]&224)>>5){
        case 1:    //audio data block
            blockLen = (p[i]&31)+i;++i;
            if(blockLen >=255)    return 256;
            result += "**********Audio Data Block**********\r\n";
            while(i < blockLen)
                {
                switch((p[i]&120)>>3){
                case 0:    i+=3;break;//reserve
                case 1:         //LPCM
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nLPCM %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nLPCM %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    if(p[i+1]&1)    result += ", 16 bit ";
                    if(p[i+1]&2)    result += ", 20 bit ";
                    if(p[i+1]&4)    result += ", 24 bit ";
                    break;
                case 2:         //AC-3
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nDolby Digital %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nDolby Digital %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 3:         //MPEG1(Layers 1 & 2)
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nMPEG1(Layers 1 & 2) %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nMPEG1(Layers 1 & 2) %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 4:         //MP3
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nMP3 %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nMP3 %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 5:         //MPEG2
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nMPEG2 %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nMPEG2 %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 6:         //AAC
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nAAC %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nAAC %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 7:         //DTS
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nDTS %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nDTS %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 8:         //ATRAC
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nATRAC %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nATRAC %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    sprintf(temp,", Max bit rate %dkHz  ",p[i+1]*8);
                    result += temp;
                    break;
                case 9:         //One Bit Audio
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nOne Bit Audio %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nOne Bit Audio %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    break;
                case 10:         //Dolby Digital +
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nDolby Digital + %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nDolby Digital + %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    break;
                case 11:         //DTS-HD  ?~?????R DTS-HD Master
                    if(p[i+2]&1)
                        {
                        if((p[i]&7)==5 || (p[i]&7)==7)
                            sprintf(temp,"\r\nDTS-HD Master %d.1 channels ",(p[i]&7));
                        else
                            sprintf(temp,"\r\nDTS-HD Master %d channels ",(p[i]&7)+1);
                        }
                    else
                        {
                        if((p[i]&7)==5 || (p[i]&7)==7)
                            sprintf(temp,"\r\nDTS-HD %d.1 channels ",(p[i]&7));
                        else
                            sprintf(temp,"\r\nDTS-HD %d channels ",(p[i]&7)+1);
                        }
                    result += temp;++i;
                    break;
                case 12:         //MAT(MLP)
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nDolby TrueHD %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nDolby TrueHD %d channels ",(p[i]&7)+1);
                    //sprintf(temp,"Dolby TrueHD %d channels  ",(p[i]&7)+1);
                    result += temp;++i;
                    break;
                case 13:         //DST
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nDST %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nDST %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    break;
                case 14:         //WMA Pro
                    if((p[i]&7)==5 || (p[i]&7)==7)
                        sprintf(temp,"\r\nWMA Pro %d.1 channels ",(p[i]&7));
                    else
                        sprintf(temp,"\r\nWMA Pro %d channels ",(p[i]&7)+1);
                    result += temp;++i;
                    break;
                case 15:         //Reserved for audio format 15
                    sprintf(temp,"Reserved for audio format 15 %d channels  ",(p[i]&7)+1);
                    result += temp;++i;
                    break;}
                if(p[i]&1)    result += ", 32 kHz ";
                if(p[i]&2)    result += ", 44.1 kHz ";
                if(p[i]&4)    result += ", 48 kHz ";
                if(p[i]&8)    result += ", 88.2 kHz ";
                if(p[i]&16)    result += ", 96 kHz ";
                if(p[i]&32)    result += ", 176.4 kHz ";
                if(p[i]&64)    result += ", 192 kHz ";
                result +="\r\n";++i,++i;
                }
            break;
        case 2:    //video data block
            blockLen = (p[i]&31)+i;++i;
            if(blockLen >=255)    return 256;
            result += "**********Video Data Block**********\r\n";
            while(i <= blockLen)
                {
                switch(p[i]&127){
                case 0:    break;//reserve
                case 1:
                    //result += "640x480p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 1:1\r\n";
                    result += "640x480p@59.94(60)Hz  4:3\r\n";
                    break;
                case 2:
                    //result += "720x480p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720x480p@59.94(60)Hz  4:3\r\n";
                    break;
                case 3:
                    //result += "720x480p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720x480p@59.94(60)Hz 16:9\r\n";
                    break;
                case 4:
                    //result += "1280x720p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@59.94(60)Hz 16:9\r\n";
                    break;
                case 5:
                    //result += "1920x1080i@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080i@59.94(60)Hz 16:9\r\n";
                    break;
                case 6:
                    //result += "720(1440)x480i@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720(1440)x480i@59.94(60)Hz  4:3\r\n";
                    break;
                case 7:
                    //result += "720(1440)x480i@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720(1440)x480i@59.94(60)Hz 16:9\r\n";
                    break;
                case 8:
                    //result += "720(1440)x240p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 4:9\r\n";
                    result += "720(1440)x240p@59.94(60)Hz  4:3\r\n";
                    break;
                case 9:
                    //result += "720(1440)x240p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 16:27\r\n";
                    result += "720(1440)x240p@59.94(60)Hz 16:9\r\n";
                    break;
                case 10:
                    //result += "2880x480i@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 2:9-20:9^3\r\n";
                    result += "2880x480i@59.94(60)Hz  4:3\r\n";
                    break;
                case 11:
                    //result += "2880x480i@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 8:27-80:27\r\n";
                    result += "2880x480i@59.94(60)Hz 16:9\r\n";
                    break;
                case 12:
                    //result += "2880x480p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 1:9-10:9\r\n";
                    result += "2880x480p@59.94(60)Hz  4:3\r\n";
                    break;
                case 13:
                    //result += "2880x480p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 4:27-40:27\r\n";
                    result += "2880x480p@59.94(60)Hz 16:9\r\n";
                    break;
                case 14:
                    //result += "1440x480p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 4:9\r\n";
                    result += "1440x480p@59.94(60)Hz  4:3\r\n";
                    break;
                case 15:
                    //result += "1440x480p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 16:27\r\n";
                    result += "1440x480p@59.94(60)Hz 16:9\r\n";
                    break;
                case 16:
                    //result += "1920x1080p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@59.94(60)Hz 16:9\r\n";
                    break;
                case 17:
                    //result += "720x576p@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720x576p@50Hz  4:3\r\n";
                    break;
                case 18:
                    //result += "720x576p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720x576p@50Hz 16:9\r\n";
                    break;
                case 19:
                    //result += "1280x720p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@50Hz 16:9\r\n";
                    break;
                case 20:
                    //result += "1920x1080i@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080i@50Hz 16:9\r\n";
                    break;
                case 21:
                    //result += "720(1440)x576i@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720(1440)x576i@50Hz  4:3\r\n";
                    break;
                case 22:
                    //result += "720(1440)x576i@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720(1440)x576i@50Hz 16:9\r\n";
                    break;
                case 23:
                    //result += "720(1440)x288p@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:15\r\n";
                    result += "720(1440)x288p@50Hz  4:3\r\n";
                case 24:
                    //result += "720(1440)x288p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:45\r\n";
                    result += "720(1440)x288p@50Hz 16:9\r\n";
                    break;
                case 25:
                    //result += "2880x576i@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 2:15-20:15\r\n";
                    result += "2880x576i@50Hz  4:3\r\n";
                    break;
                case 26:
                    //result += "2880x576i@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 16:45-160:45\r\n";
                    result += "2880x576i@50Hz 16:9\r\n";
                    break;
                case 27:
                    //result += "2880x288p@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 1:15-10:15\r\n";
                    result += "2880x288p@50Hz  4:3\r\n";
                    break;
                case 28:
                    //result += "2880x288p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 8:45-80:45\r\n";
                    result += "2880x288p@50Hz 16:9\r\n";
                    break;
                case 29:
                    //result += "1440x576p@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:15\r\n";
                    result += "1440x576p@50Hz  4:3\r\n";
                    break;
                case 30:
                    //result += "1440x576p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:45\r\n";
                    result += "1440x576p@50Hz 16:9\r\n";
                    break;
                case 31:
                    //result += "1920x1080p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@50Hz 16:9\r\n";
                    break;
                case 32:
                    //result += "1920x1080p@24Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@23.97(24)Hz 16:9\r\n";
                    break;
                case 33:
                    //result += "1920x1080p@25Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@25Hz 16:9\r\n";
                    break;
                case 34:
                    //result += "1920x1080p@30Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@29.97(30)Hz 16:9\r\n";
                    break;
                case 35:
                    //result += "2880x480p@60Hz Picture(H:V) 4:3 ,Pixel(H:V) 2:9\r\n";
                    result += "2880x480p@59.94(60)Hz  4:3\r\n";
                    break;
                case 36:
                    //result += "2880x480p@60Hz Picture(H:V) 16:9 ,Pixel(H:V) 8:27\r\n";
                    result += "2880x480p@59.94(60)Hz 16:9\r\n";
                    break;
                case 37:
                    //result += "2880x576p@50Hz Picture(H:V) 4:3 ,Pixel(H:V) 4:15\r\n";
                    result += "2880x576p@50Hz  4:3\r\n";
                    break;
                case 38:
                    //result += "2880x576p@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 16:45\r\n";
                    result += "2880x576p@50Hz 16:9\r\n";
                    break;
                case 39:
                    //result += "1920x1080i@50Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080i@50Hz 16:9\r\n";
                    break;
                case 40:
                    //result += "1920x1080i@100Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080i@100Hz 16:9\r\n";
                    break;
                case 41:
                    //result += "1280x720p@100Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@100Hz 16:9\r\n";
                    break;
                case 42:
                    //result += "720x576p@100Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720x576p@100Hz  4:3\r\n";
                    break;
                case 43:
                    //result += "720x576p@100Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720x576p@100Hz 16:9\r\n";
                    break;
                case 44:
                    //result += "720(1440)x576i@100Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720(1440)x576i@100Hz  4:3\r\n";
                    break;
                case 45:
                    //result += "720(1440)x576i@100Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720(1440)x576i@100Hz 16:9\r\n";
                    break;
                case 46:
                    //result += "1920x1080i@120Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080i@119.88(120)Hz 16:9\r\n";
                    break;
                case 47:
                    //result += "1280x720p@120Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@119.88(120)Hz 16:9\r\n";
                    break;
                case 48:
                    //result += "720x480p@120Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720x480p@119.88(120)Hz  4:3\r\n";
                    break;
                case 49:
                    //result += "720x480p@120Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720x480p@119.88(120)Hz 16:9\r\n";
                    break;
                case 50:
                    //result += "720(1440)x480i@120Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720(1440)x480i@119.88(120)Hz  4:3\r\n";
                    break;
                case 51:
                    //result += "720(1440)x480i@120Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720(1440)x480i@119.88(120)Hz 16:9\r\n";
                    break;
                case 52:
                    //result += "720x576p@200Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720x576p@200Hz  4:3\r\n";
                    break;
                case 53:
                    //result += "720x576p@200Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720x576p@200Hz 16:9\r\n";
                    break;
                case 54:
                    //result += "720(1440)x576i@200Hz Picture(H:V) 4:3 ,Pixel(H:V) 16:15\r\n";
                    result += "720(1440)x576i@200Hz  4:3\r\n";
                    break;
                case 55:
                    //result += "720(1440)x576i@200Hz Picture(H:V) 16:9 ,Pixel(H:V) 64:45\r\n";
                    result += "720(1440)x576i@200Hz 16:9\r\n";
                    break;
                case 56:
                    //result += "720x480p@240Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720x480p@239.76(240)Hz  4:3\r\n";
                    break;
                case 57:
                    //result += "720x480p@240Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720x480p@239.76(240)Hz 16:9\r\n";
                    break;
                case 58:
                    //result += "720(1440)x480i@240Hz Picture(H:V) 4:3 ,Pixel(H:V) 8:9\r\n";
                    result += "720(1440)x480i@239.76(240)Hz  4:3\r\n";
                    break;
                case 59:
                    //result += "720(1440)x480i@240Hz Picture(H:V) 16:9 ,Pixel(H:V) 32:27\r\n";
                    result += "720(1440)x480i@239.76(240)Hz 16:9\r\n";
                    break;
                case 60:
                    //result += "1280x720p@23.97Hz/24Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@23.97(24)Hz\r\n";
                    break;
                case 61:
                    //result += "1280x720p@25Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@25Hz\r\n";
                    break;
                case 62:
                    //result += "1280x720p@29.97Hz/30Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1280x720p@29.97(30)Hz\r\n";
                    break;
                case 63:
                    //result += "1920x1080p@119.88Hz/120Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@119.88(120)Hz\r\n";
                    break;
                case 64:
                    //result += "1920x1080p@100Hz Picture(H:V) 16:9 ,Pixel(H:V) 1:1\r\n";
                    result += "1920x1080p@100Hz\r\n";
                    break;
                case 65:
                    result += "1280x720p@23.98(24)Hz\r\n";
                    break;
                case 66:
                    result += "1280x720p@25Hz\r\n";
                    break;
                case 67:
                    result += "1280x720p@29.97(30)Hz\r\n";
                    break;
                case 68:
                    result += "1280x720p@50Hz\r\n";
                    break;
                case 69:
                    result += "1280x720p@59.94(60)Hz\r\n";
                    break;
                case 70:
                    result += "1280x720p@100Hz\r\n";
                    break;
                case 71:
                    result += "1280x720p@119.88(120)Hz\r\n";
                    break;
                case 72:
                    result += "1920x1080p@23.98(24)Hz\r\n";
                    break;
                case 73:
                    result += "1920x1080p@25Hz\r\n";
                    break;
                case 74:
                    result += "1920x1080p@29.97(30)Hz\r\n";
                    break;
                case 75:
                    result += "1920x1080p@50Hz\r\n";
                    break;
                case 76:
                    result += "1920x1080p@59.94(60)Hz\r\n";
                    break;
                case 77:
                    result += "1920x1080p@100Hz\r\n";
                    break;
                case 78:
                    result += "1920x1080p@119.88(120)Hz\r\n";
                    break;
                case 79:
                    result += "1680x720p@23.98(24)Hz\r\n";
                    break;
                case 80:
                    result += "1680x720p@25Hz\r\n";
                    break;
                case 81:
                    result += "1680x720p@29.97(30)Hz\r\n";
                    break;
                case 82:
                    result += "1680x720p@50Hz\r\n";
                    break;
                case 83:
                    result += "1680x720p@59.94(60)Hz\r\n";
                    break;
                case 84:
                    result += "1680x720p@100Hz\r\n";
                    break;
                case 85:
                    result += "1680x720p@119.88(120)Hz\r\n";
                    break;
                case 86:
                    result += "2560x1080p@23.98(24)Hz\r\n";
                    break;
                case 87:
                    result += "2560x1080p@25Hz\r\n";
                    break;
                case 88:
                    result += "2560x1080p@29.97(30)Hz\r\n";
                    break;
                case 89:
                    result += "2560x1080p@50Hz\r\n";
                    break;
                case 90:
                    result += "2560x1080p@59.94(60)Hz\r\n";
                    break;
                case 91:
                    result += "2560x1080p@100Hz\r\n";
                    break;
                case 92:
                    result += "2560x1080p@119.88(120)Hz\r\n";
                    break;
                case 93:
                    result += "3840x2160p@23.98(24)Hz\r\n";
                    break;
                case 94:
                    result += "3840x2160p@25Hz\r\n";
                    break;
                case 95:
                    result += "3840x2160p@29.97(30)Hz\r\n";
                    break;
                case 96:
                    result += "3840x2160p@50Hz\r\n";
                    break;
                case 97:
                    result += "3840x2160p@59.94(60)Hz\r\n";
                    break;
                case 98:
                    result += "4096x2160p@23.98(24)Hz\r\n";
                    break;
                case 99:
                    result += "4096x2160p@25Hz\r\n";
                    break;
                case 100:
                    result += "4096x2160p@29.97(30)Hz\r\n";
                    break;
                case 101:
                    result += "4096x2160p@50Hz\r\n";
                    break;
                case 102:
                    result += "4096x2160p@59.94(60)Hz\r\n";
                    break;
                case 103:
                    result += "3840x2160p@23.98(24)Hz\r\n";
                    break;
                case 104:
                    result += "3840x2160p@25Hz\r\n";
                    break;
                case 105:
                    result += "3840x2160p@29.97(30)Hz\r\n";
                    break;
                case 106:
                    result += "3840x2160p@50Hz\r\n";
                    break;
                case 107:
                    result += "3840x2160p@59.94(60)Hz\r\n";
                    break;
                    }++i;
                }
            break;
        case 3:    //vendor specific data block
            blockLen = (p[i]&31);
            if(blockLen<6)    {i += blockLen;++i;}
            else
                {
                unsigned char gap=0;
                result += "**********Vendor Specific Data Block**********\r\n";++i;
                sprintf(temp,"CEC Physical Address:%X.%X.%X.%X\r\n",(p[i+3]&0xf0)>>4,p[i+3]&15,(p[i+4]&0xf0)>>4,p[i+4]&15);
                result += temp;
                if(p[i+5]&1)    result += "DVI Dual Link Operation\r\n";
                //if(p[i]&2)    result += "Reserved";
                //if(p[i]&4)    result += "Reserved";
                if(p[i+5]&8)    result += "4:4:4 in deep color modes\r\n";
                if(p[i+5]&16)    result += "10-bit-per-channel deep color\r\n";
                if(p[i+5]&32)    result += "12-bit-per-channel deep color\r\n";
                if(p[i+5]&64)    result += "16-bit-per-channel deep color\r\n";
                if(p[i+5]&128)    result += "Supports_AI\r\n";
                if(blockLen>=7)
                    {
                    sprintf(temp,"Max TMDS Clock : %d MHz\r\n",p[i+6]*5);
                    result += temp;
                    }
                if(blockLen>=8)
                    {
                    if(p[i+7]&128)gap=2;
                    if(p[i+7]&64)gap+=2;
                    if(p[i+7]&32)//HDMI video present
                        {
                        unsigned char muti3Dpresent=0,vncLen=0;
                        vncLen=((p[i+9+gap]&224)>>5);//vic length
                        for(int j=0;j<vncLen;++j)
                            {
                            if(p[i+10+gap+j]==1)result += "4K x 2K@(29.97)30 Hz\r\n";
                            if(p[i+10+gap+j]==2)result += "4K x 2K@25 Hz\r\n";
                            if(p[i+10+gap+j]==3)result += "4K x 2K@(23.98)24 Hz\r\n";
                            if(p[i+10+gap+j]==4)result += "4K x 2K@24 Hz(SMPTE)\r\n";
                            }
                        if(p[i+8+gap]&128)//3D support
                            {
                            muti3Dpresent=((p[i+8+gap]&96)>>5);
                            gap+=vncLen;//vic length
                            if(muti3Dpresent==1 || muti3Dpresent==2)
                                {
                                result +="3D Support:\r\n";
                                if(p[i+10+gap])    result += "Side-by-Side(Half) with all sub-sampling\r\n";
                                if(p[i+11+gap]&1)    result += "Frame packing\r\n";
                                if(p[i+11+gap]&2)    result += "Field alternative\r\n";
                                if(p[i+11+gap]&4)    result += "Line alternative\r\n";
                                if(p[i+11+gap]&8)    result += "Side-by-Side(Full)\r\n";
                                if(p[i+11+gap]&16)    result += "L + depth\r\n";
                                if(p[i+11+gap]&32)    result += "L + depth + graphics + graphics-depth\r\n";
                                }
                            }
                        }
                        /*
                    if((p[i+7]&192)==192 && blockLen>=13)
                        {
                        if(p[i+12]&96)    result += "Multi 3D Supports\r\n";
                        if(p[i+12]&128)    result += "3D Supports\r\n";
                        }
                    else if((p[i+7]&192)>=64 && blockLen>=11)
                        {
                        if(p[i+10]&96)    result += "Multi 3D Supports\r\n";
                        if(p[i+10]&128)    result += "3D Supports\r\n";
                        }
                    else if((p[i+7]&192)<64 && blockLen>=9)
                        {
                        if(p[i+8]&96)    result += "Multi 3D Supports\r\n";
                        if(p[i+8]&128)    result += "3D Supports\r\n";
                        }*/
                    }
                i += blockLen;
                }
            break;
        case 4:    //speaker allocation data block
            blockLen = (p[i]&31)+i;++i;
            if(blockLen >=255)    return 256;
            result += "**********Speaker Allocation Block**********\r\n";
            while(i < blockLen)
                {
                if(p[i]&1)    result += " FL/FR ";
                if(p[i]&2)    result += " LFE ";
                if(p[i]&4)    result += " FC ";
                if(p[i]&8)    result += " RL/RR ";
                if(p[i]&16)    result += " RC ";
                if(p[i]&32)    result += " FLC/FRC ";
                if(p[i]&64)    result += " RLC/RRC ";
                result += "\r\n";i += 3;
                }
            break;
        case 5:    //VESA DTC data block
            blockLen = (p[i]&31);i += blockLen;++i;
            if(blockLen >=255)    return 256;
            break;
        case 6:    //reserved
            blockLen = (p[i]&31);i += blockLen;++i;
            if(blockLen >=255)    return 256;
            break;
        case 7:    //Use Extended Tag
            blockLen = (p[i]&31)+i;
            if(blockLen >=255)    return 256;
            //result += "**********Use Extended Tag Block**********\r\n";
            if(p[i+1]==6)//HDR block
                {
                result += "**********HDR Static Metadata**********\r\n";
                result += "Supported EOTF:\r\n";
                if(p[i+2]&1)    result += "Traditional SDR\r\n";
                if(p[i+2]&2)    result += "Traditional HDR\r\n";
                if(p[i+2]&4)    result += "SMPTE ST 2084\r\n";
                if(p[i+2]&8)    result += "Hybrid Log-Gamma(HLG)\r\n";
                result += "Supported Static Metadata Descriptor:\r\n";
                if(p[i+3]&1)    result += "Type 1\r\n";
                result += "\r\n";
                }
            i += (p[i]&31);i++;
            break;
        case 0:    //Reserved
            blockLen = (p[i]&31);
            if(blockLen+i >=255)    return 256;
            i += blockLen;++i;
            break;
        default://faild
            i = len;
            break;
            }
        }
    return i;
}

int testCC::descriptorBlockPaser(std::string &result,int i)
{
    unsigned char *p = this->m_EdidBuffer;
    char cbuf[50];
    int j = 0;
    sprintf(cbuf,"\r\nDescriptor Block:\r\n\r\n");
    result += cbuf;
    if(p[i] != 0 && p[i+1] != 0)
        {
        j = p[i+1] * 256 + p[i];
        sprintf(cbuf,"Pixel Clock : %.2f MHZ\r\n",j/100.0);    result += cbuf,i+=2;
        //56-58 Horizontal
        j = ((p[i+2] & 0xF0) >> 4) * 256 + p[i];
        sprintf(cbuf,"Horizontal Active : %d pixels\r\n",j);    result += cbuf;
        j = (p[i+2] & 0x0F) * 256 + p[i+1];
        sprintf(cbuf,"Horizontal Blanking : %d pixels\r\n",j);    result += cbuf;i+=3;
        //59-61 Vertical
        j = ((p[i+2] & 0xF0) >> 4) * 256 + p[i];
        sprintf(cbuf,"Vertical Active : %d pixels\r\n",j);    result += cbuf;
        j = (p[i+2] & 0x0F) * 256 + p[i+1];
        sprintf(cbuf,"Vertical Blanking : %d lines\r\n",j);    result += cbuf;i+=3;
        //62-63 Horizontal Sync Offset ,Pulse Width(in pixels)
        j = ((p[i+3] & 0xC0) >> 6) * 256 + p[i];
        sprintf(cbuf,"Horizontal Sync Offset : %d pixels\r\n",j);    result += cbuf;
        j = ((p[i+3] & 0x30) >> 4) * 256 + p[i+1];
        sprintf(cbuf,"Horizontal Pulse Width : %d pixels\r\n",j);    result += cbuf;
        //64-65 Vertical Sync Offset ,Pulse Width(in pixels)
        j = ((p[i+3] & 0x0C) << 2) + ((p[i+2]&0xF0)>>4);
        sprintf(cbuf,"Vertical Sync Offset : %d pixels\r\n",j);    result += cbuf;
        j = ((p[i+3] & 0x03) << 4) + (p[i+2]&0x0F);
        sprintf(cbuf,"Vertical Pulse Width : %d pixels\r\n",j);    result += cbuf;i+=4;
        //66-67: Horizontal ,Vertical Image Size (in mm)
        j = ((p[i+2] & 0xF0) >> 4) * 256 + p[i];
        sprintf(cbuf,"Horizontal Size : %d mm\r\n",j);    result += cbuf;
        j = (p[i+2] & 0x0F) * 256 + p[i+1];
        sprintf(cbuf,"Vertical Size : %d mm\r\n",j);    result += cbuf;i+=3;
        //69-70: Horizontal ,Vertical Border
        sprintf(cbuf,"Horizontal , Vertical Border : %d , %d\r\n",p[i],p[i+1]);    result += cbuf;i+=2;
        //71 flags
        sprintf(cbuf,"Interlaced or not : %s\r\n",(p[i]&128)?"true":"false");    result += cbuf;
        sprintf(cbuf,"Stereo or not : %s\r\n",(p[i]&0x60)?"true":"false");    result += cbuf;
        sprintf(cbuf,"Separate Sync or not : %s\r\n",(p[i]&12)?"true":"false");    result += cbuf;
        sprintf(cbuf,"Vertical Sync positive or not : %s\r\n",(p[i]&4)?"true":"false");    result += cbuf;
        sprintf(cbuf,"Horizontal Sync positive or not : %s\r\n",(p[i]&2)?"true":"false");    result += cbuf;
        sprintf(cbuf,"Stereo Mode : %s\r\n",(p[i]&1)?"true":"false");    result += cbuf;    ++i;
        }
    else
        {i+=5;    j=i+13;
        switch(p[i-2]){
        case 0xFC:
            result += "Monitor name : ";
            while(i != j)    result += (char)p[i++];
            result += "\r\n";    break;
        case 0xFF:
            result += "Monitor Serial Number : ";
            while(i != j)    result += (char)p[i++];
            result += "\r\n";    break;
        case 0xFE:
            result += "ASCII string : ";
            while(i != j)    result += (char)p[i++];
            result += "\r\n";    break;
        case 0xFD:
            result += "Monitor Range Limits : \r\n";
            sprintf(cbuf,"Vertical Rate Min , Max : %d , %d Hz\r\n",p[i],p[i+1]);    result += cbuf;i+=2;
            sprintf(cbuf,"Horizontal Rate Min , Max : %d , %d Hz\r\n",p[i],p[i+1]);    result += cbuf;i+=2;
            sprintf(cbuf,"Max Supported Pixel Clock: %d MHz\r\n",p[i]*10);result += cbuf;i+=9;    break;
        default:result += "Block Type Unknown Or Padding Block\r\n";i += 13;}
        }
    return i;
}

float testCC::calinvert(unsigned int input)
{
    int i = 0,mask=512;
    float result =0;
    for(i=0;i<10;++i)
        {
        if((input & mask) == mask)
            result += 1.0/(1024.0/mask);
        mask >>=1;
        }
    return result;
}

