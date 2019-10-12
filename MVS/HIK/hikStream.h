#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <pthread.h>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "MvCameraControl.h"

class HikStream{
    public:
    cv::Mat srcImage;
    HikStream(){
        memset(&stDeviceList, 0, sizeof(MV_CC_DEVICE_INFO_LIST));
        // 枚举设备
        // enum device
        nRet = MV_CC_EnumDevices(MV_GIGE_DEVICE | MV_USB_DEVICE, &stDeviceList);
        if (MV_OK != nRet)
        {
            printf("MV_CC_EnumDevices fail! nRet [%x]\n", nRet);
        }

        if (stDeviceList.nDeviceNum > 0)
        {
            for (int i = 0; i < stDeviceList.nDeviceNum; i++)
            {
                printf("[device %d]:\n", i);
                MV_CC_DEVICE_INFO* pDeviceInfo = stDeviceList.pDeviceInfo[i];
                if (NULL == pDeviceInfo)
                {
                   printf("DeviceInfo error!\n");
                } 
                PrintDeviceInfo(pDeviceInfo);            
            }  
        } 
        else
        {
            printf("Find PointgreyNo Devices!\n");
        }
        
        if (nIndex >= stDeviceList.nDeviceNum)
        {
            printf("Intput error!\n");
        }

        // 选择设备并创建句柄
        // select device and create handle
        nRet = MV_CC_CreateHandle(&handle, stDeviceList.pDeviceInfo[nIndex]);
        if (MV_OK != nRet)
        {
            printf("MV_CC_CreateHandle fail! nRet [%x]\n", nRet);
        }

        // 打开设备
        // open device
        nRet = MV_CC_OpenDevice(handle);
        if (MV_OK != nRet)
        {
            printf("MV_CC_OpenDevice fail! nRet [%x]\n", nRet);
        }

        // 设置触发模式为off
        // set trigger mode as off
        nRet = MV_CC_SetEnumValue(handle, "TriggerMode", 0);
        if (MV_OK != nRet)
        {
            printf("MV_CC_SetTriggerMode fail! nRet [%x]\n", nRet);
            
        }

        // 开始取流
        // start grab image
        nRet = MV_CC_StartGrabbing(handle);
        if (MV_OK != nRet)
        {
            printf("MV_CC_StartGrabbing fail! nRet [%x]\n", nRet);
        }

    }

     ~HikStream()
     {

        // 停止取流
        // end grab image
        nRet = MV_CC_StopGrabbing(handle);
        if (MV_OK != nRet)
        {
            printf("MV_CC_StopGrabbing fail! nRet [%x]\n", nRet);
        }

        // 关闭设备
        // close device
        nRet = MV_CC_CloseDevice(handle);
        if (MV_OK != nRet)
        {
            printf("MV_CC_CloseDevice fail! nRet [%x]\n", nRet);
        }

        // 销毁句柄
        // destroy handle
        nRet = MV_CC_DestroyHandle(handle);
        if (MV_OK != nRet)
        {
            printf("MV_CC_DestroyHandle fail! nRet [%x]\n", nRet);
        }
     };

    //
    void PressEnterToExit(void)
    {
        int c;
        while ( (c = getchar()) != '\n' && c != EOF );
        fprintf( stderr, "\nPress enter to exit.\n");
        while( getchar() != '\n');
        g_bExit = true;
        sleep(1);
    }

    //
    int RGB2BGR( unsigned char* pRgbData, unsigned int nWidth, unsigned int nHeight )
    {
        if ( NULL == pRgbData )
        {
            return MV_E_PARAMETER;
        }

        for (unsigned int j = 0; j < nHeight; j++)
        {
            for (unsigned int i = 0; i < nWidth; i++)
            {
                unsigned char red = pRgbData[j * (nWidth * 3) + i * 3];
                pRgbData[j * (nWidth * 3) + i * 3]     = pRgbData[j * (nWidth * 3) + i * 3 + 2];
                pRgbData[j * (nWidth * 3) + i * 3 + 2] = red;
            }
        }

        return MV_OK;
    }

    //
    bool Convert2Mat(MV_FRAME_OUT_INFO_EX* pstImageInfo, unsigned char * pData,cv::Mat &srcImage)
    {
        if ( pstImageInfo->enPixelType == PixelType_Gvsp_Mono8 )
        {
            std::cout<<"PixelType = PixelType_Gvsp_Mono8"<<std::endl;
            srcImage = cv::Mat(pstImageInfo->nHeight, pstImageInfo->nWidth, CV_8UC1, pData);
        }
        else if ( pstImageInfo->enPixelType == PixelType_Gvsp_RGB8_Packed )
        {
            RGB2BGR(pData, pstImageInfo->nWidth, pstImageInfo->nHeight);
            srcImage = cv::Mat(pstImageInfo->nHeight, pstImageInfo->nWidth, CV_8UC3, pData);
        }
        else
        {
            printf("unsupported pixel format\n");
            return false;
        }

        if ( NULL == srcImage.data )
        {
            return false;
        }

    //save converted image in a local file
    //     try {
    // #if defined (VC9_COMPILE)
    //         cvSaveImage("MatImage.bmp", &(IplImage(srcImage)));
    // #else
    //         cv::imwrite("MatImage.bmp", srcImage);
    // #endif
    //     }
    //     catch (cv::Exception& ex) {
    //         fprintf(stderr, "Exception saving image to bmp format: %s\n", ex.what());
    //     }

    //     srcImage.release();

        return true;
    }

    //
    bool PrintDeviceInfo(MV_CC_DEVICE_INFO* pstMVDevInfo)
{
    if (NULL == pstMVDevInfo)
    {
        printf("The Pointer of pstMVDevInfo is NULL!\n");
        return false;
    }
    if (pstMVDevInfo->nTLayerType == MV_GIGE_DEVICE)
    {
        int nIp1 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0xff000000) >> 24);
        int nIp2 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x00ff0000) >> 16);
        int nIp3 = ((pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x0000ff00) >> 8);
        int nIp4 = (pstMVDevInfo->SpecialInfo.stGigEInfo.nCurrentIp & 0x000000ff);

        // ch:打印当前相机ip和用户自定义名字 | en:print current ip and user defined name
        printf("Device Model Name: %s\n", pstMVDevInfo->SpecialInfo.stGigEInfo.chModelName);
        printf("CurrentIp: %d.%d.%d.%d\n" , nIp1, nIp2, nIp3, nIp4);
        printf("UserDefinedName: %s\n\n" , pstMVDevInfo->SpecialInfo.stGigEInfo.chUserDefinedName);
    }
    else if (pstMVDevInfo->nTLayerType == MV_USB_DEVICE)
    {
        printf("Device Model Name: %s\n", pstMVDevInfo->SpecialInfo.stUsb3VInfo.chModelName);
        printf("UserDefinedName: %s\n\n", pstMVDevInfo->SpecialInfo.stUsb3VInfo.chUserDefinedName);
    }
    else
    {
        printf("Not support.\n");
    }

    return true;
}

 void getData()
 {
    memset(&stParam, 0, sizeof(MVCC_INTVALUE));
    nRet = MV_CC_GetIntValue(handle, "PayloadSize", &stParam);
    if (MV_OK != nRet)
    {
        printf("Get PayloadSize fail! nRet [0x%x]\n", nRet);
    }
    memset(&stImageInfo, 0, sizeof(MV_FRAME_OUT_INFO_EX));
    unsigned char * pData = (unsigned char *)malloc(sizeof(unsigned char) * stParam.nCurValue);

    if (NULL == pData)
    {
        std::cout << "hik capture error" << std::endl;
    }
    unsigned int nDataSize = stParam.nCurValue;
    nRet = MV_CC_GetOneFrameTimeout(handle, pData, nDataSize, &stImageInfo, 1000);
    if (nRet == MV_OK)
    {
        printf("GetOneFrame, Width[%d], Height[%d], nFrameNum[%d],int PixelType[%d]\n", 
            stImageInfo.nWidth, stImageInfo.nHeight, stImageInfo.nFrameNum,stImageInfo.enPixelType);
    }
    else{
        printf("No data[%x]\n", nRet);
    }
        bool bConvertRet = false;
        bConvertRet = Convert2Mat(&stImageInfo, pData,srcImage);
        if ( bConvertRet )
    {
     //   printf("OpenCV format convert finished.\n");
    //  std::cout<<"cols:"<< srcImage.cols<<"rows:"<<srcImage.rows<<std::endl;
        //free(pData);
        // pData = NULL;
    }
    else
    {
        printf("OpenCV format convert failed.\n");
        //free(pData);
        //pData = NULL;
        //break;
    }


 }


    private:
        bool g_bExit = false;
        int nRet = MV_OK;
        void* handle = NULL;
        unsigned int nIndex = 0;
        MV_CC_DEVICE_INFO_LIST stDeviceList;
        MVCC_INTVALUE stParam;
        MV_FRAME_OUT_INFO_EX stImageInfo = {0};
};      