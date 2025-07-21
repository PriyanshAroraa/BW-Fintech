//+------------------------------------------------------------------+
//|                                                       ZZTest.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ZZTest{
   private:
      IndicatorsHelper  *m_Indicators;
   
      string            FileName[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int               ZZFileHandle[ENUM_TIMEFRAMES_ARRAY_SIZE];    
      double            LastZZValue[ENUM_TIMEFRAMES_ARRAY_SIZE];
      datetime          LastZZDateTime[ENUM_TIMEFRAMES_ARRAY_SIZE];  
      
   public:
                        ZZTest(IndicatorsHelper *pIndicators);
                        ~ZZTest();
      
      
      bool              Init();
      void              OnUpdate(int TimeFrameIndex);
      
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZZTest::ZZTest(IndicatorsHelper *pIndicators){
   // initialized indicator
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators; 
      

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZZTest::~ZZTest(){
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      FileClose(ZZFileHandle[i]);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ZZTest::Init(){
      // Check if File is Available if not create file
      
      FileName[0] = Symbol()+"-"+GetTimeFramesString(PERIOD_M15)+"-ZZ.csv";
      FileName[1] = Symbol()+"-"+GetTimeFramesString(PERIOD_H1)+"-ZZ.csv";
      FileName[2] = Symbol()+"-"+GetTimeFramesString(PERIOD_H4)+"-ZZ.csv";
      FileName[3] = Symbol()+"-"+GetTimeFramesString(PERIOD_D1)+"-ZZ.csv";
      
      for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      {
         FileDelete(FileName[i]);
      
         ZZFileHandle[i] = FileOpen(FileName[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");     
   
         if(ZZFileHandle[i]  == -1)
         {
            int error=GetLastError();
            Print("Error Opening "+FileName[i]+" file -",error);
            return false;
         }
         else
         {
            Print("Success - Opening "+"-"+FileName[i]+" file");
         }   
      }
      
      return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZZTest::OnUpdate(int TimeFrameIndex)
{

     double    zzValue;
     int       zzShift; 
     datetime  zzDateTime;
     string    zzDateTimeStr;
     
     
     zzValue = m_Indicators.GetZigZag().GetZigZagPrice(TimeFrameIndex, 1);
     zzShift = m_Indicators.GetZigZag().GetZigZagShift(TimeFrameIndex,1);   
     zzDateTime = m_Indicators.GetZigZag().GetZigZagDateTime(TimeFrameIndex,1); 
     zzDateTimeStr = TimeToStr(zzDateTime, TIME_DATE|TIME_MINUTES); 
  

     
     if(m_Indicators.GetZigZag().GetZigZagTrend(TimeFrameIndex, 1) == 'H')
     {
         FileWrite(ZZFileHandle[TimeFrameIndex] , zzDateTimeStr, zzValue, "Sell");
         LastZZValue[TimeFrameIndex] = zzValue;
         LastZZDateTime[TimeFrameIndex] = zzDateTime;
         
     }
     else if(m_Indicators.GetZigZag().GetZigZagTrend(TimeFrameIndex, 1) == 'L')
     {
         FileWrite(ZZFileHandle[TimeFrameIndex] , zzDateTimeStr, zzValue, "Buy");    
         LastZZValue[TimeFrameIndex] = zzValue;
         LastZZDateTime[TimeFrameIndex] = zzDateTime;     
     }

}

//+------------------------------------------------------------------+