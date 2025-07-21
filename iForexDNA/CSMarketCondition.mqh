//+------------------------------------------------------------------+
//|                                            CSMarketCondition.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class CSMarketCondition:public BaseIndicator{
   private:
      IndicatorsHelper              *m_Indicators;
      
      
      double                        m_CandleStickBody[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_CandleStickBodyMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_CandleStickBodyStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      
      void                          CalculateCandleStickMeanStdDev(int TimeFrameIndex, int Shift);
   
   
   public:
                                    CSMarketCondition(IndicatorsHelper *pIndicators);
                                    ~CSMarketCondition();
                                    
      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      
      
      double                        GetCandleStickBody(int TimeFrameIndex, int Shift){return m_CandleStickBody[TimeFrameIndex][Shift];} 
      double                        GetCandleStickBodyMean(int TimeFrameIndex, int Shift){return m_CandleStickBodyMean[TimeFrameIndex][Shift];} 
      double                        GetCandleStickBodyStdDev(int TimeFrameIndex, int Shift){return m_CandleStickBodyStdDev[TimeFrameIndex][Shift];} 
      
      double                        GetCandleStickBodyStdDevPosition(int TimeFrameIndex, int Shift);
                                   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CSMarketCondition::CSMarketCondition(IndicatorsHelper *pIndicators):BaseIndicator("CSMarketCondition")
{
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CSMarketCondition::~CSMarketCondition()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CSMarketCondition::Init()
{
   for(int i=0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      for(int j = INDEXES_BUFFER_SIZE-1; j >=0 ; j--)
      {
         m_CandleStickBody[i][j] = j < CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[i][j].GetRealBodyAbs() : iClose(Symbol(), timeFrameENUM, j) - iOpen(Symbol(), timeFrameENUM, j);
         CalculateCandleStickMeanStdDev(i,j);
      }
   }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSMarketCondition::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(IsNewBar)
   {
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--)
      {
         m_CandleStickBody[TimeFrameIndex][j] = m_CandleStickBody[TimeFrameIndex][j-1];
         m_CandleStickBodyMean[TimeFrameIndex][j] = m_CandleStickBodyMean[TimeFrameIndex][j-1];
         m_CandleStickBodyStdDev[TimeFrameIndex][j] = m_CandleStickBodyStdDev[TimeFrameIndex][j-1];
      }
   }
   
   m_CandleStickBody[TimeFrameIndex][0]=CandleSticksBuffer[TimeFrameIndex][0].GetRealBody();
   CalculateCandleStickMeanStdDev(TimeFrameIndex, 0);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSMarketCondition::CalculateCandleStickMeanStdDev(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE 
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range.");
      return;
   }
   
   // get previous ZigZag
   int startingshift = m_Indicators.GetZigZag().GetNearestZigZagShiftFromBarShift(TimeFrameIndex, Shift);

   startingshift = startingshift+1;
   int endingshift = startingshift+1;
   
   int period = m_Indicators.GetZigZag().GetZigZagShift(TimeFrameIndex, endingshift)-m_Indicators.GetZigZag().GetZigZagShift(TimeFrameIndex, startingshift);            // period for calculations

   
   double csbodybufffer[];
   ArrayResize(csbodybufffer, period);
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   // get the values for calculations
   for(int i =0 ; i < period; i++)
      csbodybufffer[i]=Shift+i < CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift+i].GetRealBody() : iClose(Symbol(), timeFrameENUM, Shift+i)-iOpen(Symbol(), timeFrameENUM, Shift+i);
   
   m_CandleStickBodyMean[TimeFrameIndex][Shift]=MathMean(csbodybufffer, 0, period);
   m_CandleStickBodyStdDev[TimeFrameIndex][Shift]=MathStandardDeviation(csbodybufffer, 0, period);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CSMarketCondition::GetCandleStickBodyStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE 
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range.");
      return -1;
   }
   
   if(m_CandleStickBodyStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
      
   return (m_CandleStickBody[TimeFrameIndex][Shift]-m_CandleStickBodyMean[TimeFrameIndex][Shift])/m_CandleStickBodyStdDev[TimeFrameIndex][Shift];
   
}

//+------------------------------------------------------------------+



