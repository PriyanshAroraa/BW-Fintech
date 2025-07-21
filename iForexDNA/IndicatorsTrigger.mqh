//+------------------------------------------------------------------+
//|                                           IndicatorsTrigger.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BullBearIndex.mqh"


class IndicatorsTrigger:public BaseIndicator{
   private:
      IndicatorsHelper              *m_Indicators;
      int                           m_TotalIndicatorTrigger;
      
      
      double                        m_BuyPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
   
      double                        m_BuyMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];

      double                        m_BuyStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];


      string                        CalculateIndicatorTrigger(int TimeFrameIndex, int Shift);
      void                          OnUpdateIndicatorTriggerMean(int TimeFrameIndex);
      
      bool                          SetTotalIndicatorTrigger(int TotalIndicatorTrigger);    

   public:
                                    IndicatorsTrigger(IndicatorsHelper *pIndicators);
                                    ~IndicatorsTrigger();

      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
      

      double                        GetBuyPercent(int TimeFrameIndex, int Shift){return m_BuyPercent[TimeFrameIndex][Shift];};
      double                        GetSellPercent(int TimeFrameIndex, int Shift){return m_SellPercent[TimeFrameIndex][Shift];};
   
      double                        GetBuyMean(int TimeFrameIndex, int Shift){return m_BuyMean[TimeFrameIndex][Shift];};
      double                        GetSellMean(int TimeFrameIndex, int Shift){return m_SellMean[TimeFrameIndex][Shift];};

      double                        GetBuyStdDev(int TimeFrameIndex, int Shift){return m_BuyStdDev[TimeFrameIndex][Shift];};
      double                        GetSellStdDev(int TimeFrameIndex, int Shift){return m_SellStdDev[TimeFrameIndex][Shift];};
               
      double                        GetUpperBuyStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_BuyMean[TimeFrameIndex][Shift]+Multiplier*m_BuyStdDev[TimeFrameIndex][Shift];};
      double                        GetUpperSellStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_SellMean[TimeFrameIndex][Shift]+Multiplier*m_SellStdDev[TimeFrameIndex][Shift];};        
               
      double                        GetBuyStdDevPosition(int TimeFrameIndex, int Shift);
      double                        GetSellStdDevPosition(int TimeFrameIndex, int Shift);
      
      bool                          GetIsBuyCrossOver(int TimeFrameIndex, int Shift);
      bool                          GetIsSellCrossOver(int TimeFrameIndex, int Shift);
      
      
      ENUM_INDICATOR_POSITION       GetBuyPosition(int TimeFrameIndex, int Shift);
      ENUM_INDICATOR_POSITION       GetSellPosition(int TimeFrameIndex, int Shift);

        
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

IndicatorsTrigger::IndicatorsTrigger(IndicatorsHelper *pIndicators):BaseIndicator("IndicatorsTrigger"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

IndicatorsTrigger::~IndicatorsTrigger()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IndicatorsTrigger::Init()
{
    if(!SetTotalIndicatorTrigger(TOTAL_INDICATOR_TRIGGER))
        return false;
      
    for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
        double tempBuyArray[INDEXES_BUFFER_SIZE*2];
        double tempSellArray[INDEXES_BUFFER_SIZE*2];
        int arrsize = ArraySize(tempBuyArray);

        for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++){
            if(j < INDEXES_BUFFER_SIZE)
            {
               CalculateIndicatorTrigger(i,j);
               tempBuyArray[j] = m_BuyPercent[i][j];
               tempSellArray[j] = m_SellPercent[i][j];              
            }

            else
            {
               string crossBounceArray[2];
               StringSplit(CalculateIndicatorTrigger(i,j), '/', crossBounceArray);
      
               tempBuyArray[j] = StringToDouble(crossBounceArray[0]);
               tempSellArray[j] = StringToDouble(crossBounceArray[1]);
               
            }
            
        }
     

      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_BuyMean[i][x] = NormalizeDouble(MathMean(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);         
         m_BuyStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellMean[i][x] = NormalizeDouble(MathMean(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
      }

    }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void IndicatorsTrigger::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
    if(IsNewBar)
    {
        for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--)
        {
            m_BuyPercent[TimeFrameIndex][i] = m_BuyPercent[TimeFrameIndex][i-1];
            m_SellPercent[TimeFrameIndex][i] = m_SellPercent[TimeFrameIndex][i-1];

            m_BuyMean[TimeFrameIndex][i] = m_BuyMean[TimeFrameIndex][i-1];
            m_SellMean[TimeFrameIndex][i] = m_SellMean[TimeFrameIndex][i-1];

            m_BuyStdDev[TimeFrameIndex][i] = m_BuyStdDev[TimeFrameIndex][i-1];
            m_SellStdDev[TimeFrameIndex][i] = m_SellStdDev[TimeFrameIndex][i-1];
        }

    }

    // updating the latest values
    CalculateIndicatorTrigger(TimeFrameIndex, 0);
    OnUpdateIndicatorTriggerMean(TimeFrameIndex);
        
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string IndicatorsTrigger::CalculateIndicatorTrigger(int TimeFrameIndex,int Shift)
{
   double BuyIndex = 0, SellIndex = 0;
   double BuyPercent = 0, SellPercent = 0;
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
    
   double curClose = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(), timeFrameENUM, Shift);
   double prevClose = Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetClose():iClose(Symbol(), timeFrameENUM, Shift+1);
   double prev2Close = Shift+2<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+2].GetClose():iClose(Symbol(), timeFrameENUM, Shift+2);

   double curHigh = Shift<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh():iHigh(Symbol(), timeFrameENUM, Shift);
   double prevHigh = Shift+1<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift+1].GetHigh():iHigh(Symbol(), timeFrameENUM, Shift+1);
    
   double curLow = Shift<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift].GetLow():iLow(Symbol(), timeFrameENUM, Shift);
   double prevLow = Shift+1<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift+1].GetLow():iLow(Symbol(), timeFrameENUM, Shift+1);
    
   // CHIKOU
   double close26 = iClose(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT);
   double high26 = iHigh(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT);
   double low26  = iLow(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT);
   double high27 = iHigh(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT+1);
   double low27  = iLow(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT+1);
   
   
   double curChikou = m_Indicators.GetIchimoku().GetChikouSpan(TimeFrameIndex, Shift);
   double prevChikou = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetIchimoku().GetChikouSpan(TimeFrameIndex, Shift+1) : m_Indicators.GetIchimoku().CalculateChikouSpan(timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT+1);

   
   // CROSSOVER
   if(curChikou > high26 && prevChikou <= high27)
      BuyIndex++;
      
   else if(curChikou < low26 && prevChikou >= low27)
      SellIndex++;



   // Kijun TenKan Cross
   double CurTenKanKijunHist = m_Indicators.GetIchimoku().GetTenKanKijunHist(TimeFrameIndex, Shift);
   double PrevTenKanKijunHist = Shift+1<DEFAULT_BUFFER_SIZE ? m_Indicators.GetIchimoku().GetTenKanKijunHist(TimeFrameIndex, Shift+1):m_Indicators.GetIchimoku().CalculateTenKanKijunHist(timeFrameENUM, Shift+1);
   
   
   if(CurTenKanKijunHist > 0 && PrevTenKanKijunHist <= 0)
      BuyIndex++;
      
   else if(CurTenKanKijunHist < 0 && PrevTenKanKijunHist >= 0)
      SellIndex++;
   
   
   
   // Price Cross Kumo
   double spanA = Shift-ICHIMOKU_NEGATIVE_SHIFT<ICHIMOKU_SPAN_BUFFER_SIZE?m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT):m_Indicators.GetIchimoku().CalculateSenkouSpanA(timeFrameENUM, Shift);
   double prevSpanA = Shift-ICHIMOKU_NEGATIVE_SHIFT+1<ICHIMOKU_SPAN_BUFFER_SIZE?m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT+1):m_Indicators.GetIchimoku().CalculateSenkouSpanA(timeFrameENUM, Shift+1); 
   
   double spanB = Shift-ICHIMOKU_NEGATIVE_SHIFT<ICHIMOKU_SPAN_BUFFER_SIZE?m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT):m_Indicators.GetIchimoku().CalculateSenkouSpanB(timeFrameENUM, Shift);
   double prevSpanB = Shift-ICHIMOKU_NEGATIVE_SHIFT+1<ICHIMOKU_SPAN_BUFFER_SIZE?m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT+1):m_Indicators.GetIchimoku().CalculateSenkouSpanB(timeFrameENUM, Shift+1); 
   
   
   if(spanA > spanB && prevSpanA <= prevSpanB)
      BuyIndex++;
      
   else if(spanA < spanB && prevSpanA >= prevSpanB)
      SellIndex++;
   

   
   // ADX /DI+/DI-
   double curDIHist = m_Indicators.GetADX().GetDIHist(TimeFrameIndex, Shift);
   double prevDIHist = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetADX().GetDIHist(TimeFrameIndex, Shift+1): m_Indicators.GetADX().CalculateDIHist(timeFrameENUM, Shift+1);
   
   // CROSSOVER
   if(curDIHist > 0 && prevDIHist <= 0)
      BuyIndex++;
      
   else if(curDIHist < 0 && prevDIHist >= 0)
      SellIndex++;
      
   
   // PSAR
   double curSAR = m_Indicators.GetSAR().GetSar(TimeFrameIndex, Shift);   
   double prevSAR = Shift+1<DEFAULT_BUFFER_SIZE ? m_Indicators.GetSAR().GetSar(TimeFrameIndex, Shift+1) : m_Indicators.GetSAR().CalculateSar(timeFrameENUM, Shift+1);   
   
   if(curLow > curSAR && prevSAR >= prevHigh)
      BuyIndex++;
      
   else if(curSAR > curHigh && prevLow >= prevSAR)
      SellIndex++;

   
   // STOCH
   double curStochHist = m_Indicators.GetSTO().GetSTOHist(TimeFrameIndex, Shift);
   double prevStochHist = Shift+1<DEFAULT_BUFFER_SIZE ? m_Indicators.GetSTO().GetSTOHist(TimeFrameIndex, Shift+1):m_Indicators.GetSTO().CalculateSTOHist(timeFrameENUM, Shift+1);
   
   if(curStochHist > 0 && prevStochHist <= 0)
      BuyIndex++;
      
   else if(curStochHist < 0 && prevStochHist >= 0)
      SellIndex++;
      
  
  
   // RVI
   double curRVIHist = m_Indicators.GetRVI().GetRVIHist(TimeFrameIndex, Shift);
   double prevRVIHist = Shift+1<DEFAULT_BUFFER_SIZE ? m_Indicators.GetRVI().GetRVIHist(TimeFrameIndex, Shift+1):m_Indicators.GetRVI().CalculateRVIHist(timeFrameENUM, Shift+1);

   if(curRVIHist > 0 && prevRVIHist <= 0)
      BuyIndex++;
      
   else if(curRVIHist < 0 && prevRVIHist >= 0)
      SellIndex++;


   // MACD
   double MACDHist = m_Indicators.GetMACD().GetHistogram(TimeFrameIndex, Shift);
   double prevMACDHist = Shift+1<DEFAULT_BUFFER_SIZE ? m_Indicators.GetMACD().GetHistogram(TimeFrameIndex, Shift+1):m_Indicators.GetMACD().CalculateMACDHist(timeFrameENUM, Shift+1);

   if(MACDHist > 0 && prevMACDHist <= 0)
      BuyIndex++;
      
   else if(MACDHist < 0 && prevMACDHist >= 0)
      SellIndex++;

   
   BuyPercent = NormalizeDouble((BuyIndex/(double)m_TotalIndicatorTrigger)*100, 2);
   SellPercent = NormalizeDouble((SellIndex/(double)m_TotalIndicatorTrigger)*100, 2);
   
   
   // summarize the calculation (Calculation for StdDev/ Basic Calculation)
   if(Shift < INDEXES_BUFFER_SIZE)
   {
      m_BuyPercent[TimeFrameIndex][Shift] = BuyPercent;
      m_SellPercent[TimeFrameIndex][Shift] = SellPercent;
      return "";
   }
   
   return DoubleToString(BuyPercent, 2) + "/" + DoubleToString(SellPercent, 2);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void IndicatorsTrigger::OnUpdateIndicatorTriggerMean(int TimeFrameIndex)
{
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double tempBuyArray[ADVANCE_INDICATOR_PERIOD];
   double tempSellArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempBuyArray[i] = m_BuyPercent[TimeFrameIndex][i];
      tempSellArray[i] = m_SellPercent[TimeFrameIndex][i];
   }   

   m_BuyMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_BuyStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);

   m_SellMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_SellStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IndicatorsTrigger::GetIsBuyCrossOver(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   return (m_BuyPercent[TimeFrameIndex][Shift] > m_SellPercent[TimeFrameIndex][Shift] 
   && m_BuyPercent[TimeFrameIndex][Shift+1] <= m_SellPercent[TimeFrameIndex][Shift+1]);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IndicatorsTrigger::GetIsSellCrossOver(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   return (m_BuyPercent[TimeFrameIndex][Shift] < m_SellPercent[TimeFrameIndex][Shift]
   && m_BuyPercent[TimeFrameIndex][Shift+1] >= m_SellPercent[TimeFrameIndex][Shift+1]);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsTrigger::GetBuyStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return 0;
   }
   
   if(m_BuyStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
   
   return (m_BuyPercent[TimeFrameIndex][Shift] - m_BuyMean[TimeFrameIndex][Shift])/m_BuyStdDev[TimeFrameIndex][Shift];
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsTrigger::GetSellStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return 0;
   }
   
   if(m_SellStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
   
   return (m_SellPercent[TimeFrameIndex][Shift] - m_SellMean[TimeFrameIndex][Shift])/m_SellStdDev[TimeFrameIndex][Shift];
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION IndicatorsTrigger::GetBuyPosition(int TimeFrameIndex,int Shift)
{
   if(m_BuyPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_BuyPercent[TimeFrameIndex][Shift] > GetUpperBuyStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] > GetUpperBuyStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] > m_BuyMean[TimeFrameIndex][Shift])
      return Above_Mean;
  
   else if(m_BuyPercent[TimeFrameIndex][Shift] < m_BuyMean[TimeFrameIndex][Shift])
      return Below_Mean;
  
   else
      return Equal_Mean;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION IndicatorsTrigger::GetSellPosition(int TimeFrameIndex,int Shift)
{
   if(m_SellPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_SellPercent[TimeFrameIndex][Shift] > GetUpperSellStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] > GetUpperSellStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] > m_SellMean[TimeFrameIndex][Shift])
      return Above_Mean;

   else if(m_SellPercent[TimeFrameIndex][Shift] < m_SellMean[TimeFrameIndex][Shift])
      return Below_Mean;
  
   else
      return Equal_Mean;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IndicatorsTrigger::SetTotalIndicatorTrigger(int TotalIndicatorTrigger)
{
   if(TotalIndicatorTrigger<0)
     {
      LogError(__FUNCTION__,"Invalid Total Indicator Trigger input.");
      m_TotalIndicatorTrigger=0;
      return false;
     }

   m_TotalIndicatorTrigger=TotalIndicatorTrigger;
   return true;

}

//+------------------------------------------------------------------+