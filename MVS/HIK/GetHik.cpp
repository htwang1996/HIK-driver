#include "hikStream.h"
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>


int main()
{
   cv::Mat curr_image_;
    HikStream *myHik = new HikStream();
    
    char key = 0;
    while(key!='q')
    {
      myHik->getData();
      curr_image_=  myHik->srcImage;
      cv::imshow("image", curr_image_);
      key=cv::waitKey(10);
    }
    return 0;
}
    
