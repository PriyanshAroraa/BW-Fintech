//+------------------------------------------------------------------+
//|                                                   MarketMomentum.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BullBearIndex.mqh"


class MarketMomentum:public BaseIndicator{
   private:
      IndicatorsHelper              *m_Indicators;
      int                           m_TotalMarketMomentum;
      
      
      double                        m_BuyPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
   
      double                        m_BuyMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double                        m_BuyStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
            
      string                        CalculateMarketMomentum(int TimeFrameIndex, int Shift);
      void                          OnUpdateMarketMomentumMeanStdDev(int TimeFrameIndex);
      
      bool                          SetTotalMarketMomentumIndicator(int TotalMarketMomentum);    

   public:
                                    MarketMomentum(IndicatorsHelper *pIndicators);
                                    ~MarketMomentum();

      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
      

      double                        GetBuyPercent(int TimeFrameIndex, int Shift){return m_BuyPercent[TimeFrameIndex][Shift];};
      double                        GetSellPercent(int TimeFrameIndex, int Shift){return m_SellPercent[TimeFrameIndex][Shift];};
   
      double                        GetBuyMean(int TimeFrameIndex, int Shift){return m_BuyMean[TimeFrameIndex][Shift];};
      double                        GetSellMean(int TimeFrameIndex, int Shift){return m_SellMean[TimeFrameIndex][Shift];};
      
      int                           GetBuyMeanTrend(int TimeFrameIndex, int Shift);
      int                           GetSellMeanTrend(int TimeFrameIndex, int Shift);

      bool                          GetIsBuyCrossSell(int TimeFrameIndex, int Shift);
      bool                          GetIsSellCrossBuy(int TimeFrameIndex, int Shift);
      
      bool                          GetIsBuyCrossMean(int TimeFrameIndex, int Shift);
      bool                          GetIsSellCrossMean(int TimeFrameIndex, int Shift);
      
      double                        GetBuyUpperStdDev(int TimeFrameIndex, int Shift, float multiplier=2){return m_BuyMean[TimeFrameIndex][Shift]+multiplier*m_BuyStdDev[TimeFrameIndex][Shift];};
      double                        GetBuyLowerStdDev(int TimeFrameIndex, int Shift, float multiplier=2){return m_BuyMean[TimeFrameIndex][Shift]-multiplier*m_BuyStdDev[TimeFrameIndex][Shift];};

      double                        GetSellUpperStdDev(int TimeFrameIndex, int Shift, float multiplier=2){return m_SellMean[TimeFrameIndex][Shift]+multiplier*m_SellStdDev[TimeFrameIndex][Shift];};
      double                        GetSellLowerStdDev(int TimeFrameIndex, int Shift, float multiplier=2){return m_SellMean[TimeFrameIndex][Shift]-multiplier*m_SellStdDev[TimeFrameIndex][Shift];}; 
      
            
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketMomentum::MarketMomentum(IndicatorsHelper *pIndicators):BaseIndicator("MarketMomentum"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketMomentum::~MarketMomentum()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::Init()
{
    if(!SetTotalMarketMomentumIndicator(TOTAL_MARKET_MOMENTUM_INDEX))
        return false;
      
    for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
        double tempBuyArray[INDEXES_BUFFER_SIZE*2];
        double tempSellArray[INDEXES_BUFFER_SIZE*2];
        int arrsize=ArraySize(tempBuyArray);

        for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++){
            if(j < INDEXES_BUFFER_SIZE)
            {
               CalculateMarketMomentum(i,j);
               tempBuyArray[j] = m_BuyPercent[i][j];
               tempSellArray[j] = m_SellPercent[i][j];              
            }

            else
            {
               string crossBounceArray[2];
               StringSplit(CalculateMarketMomentum(i,j), '/', crossBounceArray);
      
               tempBuyArray[j] = StringToDouble(crossBounceArray[0]);
               tempSellArray[j] = StringToDouble(crossBounceArray[1]);
               
            }
            
        }
     

      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_BuyMean[i][x] = NormalizeDouble(MathMean(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellMean[i][x] = NormalizeDouble(MathMean(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         
         m_BuyStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
      }

    }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketMomentum::OnUpdate(int TimeFrameIndex, bool IsNewBar){
   if(TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
      return;


    if(IsNewBar){
        for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--)
        {
            m_BuyPercent[TimeFrameIndex][i] = m_BuyPercent[TimeFrameIndex][i-1];
            m_SellPercent[TimeFrameIndex][i] = m_SellPercent[TimeFrameIndex][i-1];

            m_BuyMean[TimeFrameIndex][i] = m_BuyMean[TimeFrameIndex][i-1];
            m_SellMean[TimeFrameIndex][i] = m_SellMean[TimeFrameIndex][i-1];
        }

    }

    // updating the latest values
    CalculateMarketMomentum(TimeFrameIndex, 0);
    OnUpdateMarketMomentumMeanStdDev(TimeFrameIndex);
        
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string MarketMomentum::CalculateMarketMomentum(int TimeFrameIndex,int Shift)
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
    
    
   // Kijun TenKan Cross
   double CurTenKanKijunHist = m_Indicators.GetIchimoku().GetTenKanKijunHist(TimeFrameIndex, Shift);

   
   if(CurTenKanKijunHist > 0)
      BuyIndex++;
      
   else if(CurTenKanKijunHist < 0)
      SellIndex++;
   
   
   
   // MFI
   double mfi = m_Indicators.GetMoneyFlow().GetMFIValue(TimeFrameIndex, Shift);
   double mfimean = m_Indicators.GetMoneyFlow().GetMeanMFI(TimeFrameIndex, Shift);
   
   // CROSSOVER
   if(mfi > mfimean)
      BuyIndex++;
      
   else if(mfi < mfimean)
      SellIndex++;
   
   
   // Momentum
   double momentum = m_Indicators.GetMomentum().GetMomentumValue(TimeFrameIndex, Shift);
   double momentummean = m_Indicators.GetMomentum().GetMomentumMean(TimeFrameIndex, Shift);
   

   // CROSSOVER
   if(momentum > momentummean)
      BuyIndex++;
      
   else if(momentum < momentummean)
      SellIndex++;
      
      
   // Bull/Bear Power
   if(m_Indicators.GetBullBearPower().GetBullPowerValue(TimeFrameIndex, Shift) > m_Indicators.GetBullBearPower().GetBullMean(TimeFrameIndex, Shift))
      BuyIndex++;
   
   else if(m_Indicators.GetBullBearPower().GetBearPowerValue(TimeFrameIndex, Shift) > m_Indicators.GetBullBearPower().GetBearMean(TimeFrameIndex, Shift))
      SellIndex++;

   
   // ADX /DI+/DI-
   double curDIHist = m_Indicators.GetADX().GetDIHist(TimeFrameIndex, Shift);
   
   // CROSSOVER
   if(curDIHist > 0)
      BuyIndex++;
      
   else if(curDIHist < 0)
      SellIndex++;
      
   
   // STOCH
   double curStochHist = m_Indicators.GetSTO().GetSTOHist(TimeFrameIndex, Shift);

   if(curStochHist > 0)
      BuyIndex++;
      
   else if(curStochHist < 0)
      SellIndex++;
      
  
  
   // RVI
   double curRVIHist = m_Indicators.GetRVI().GetRVIHist(TimeFrameIndex, Shift);

   if(curRVIHist > 0)
      BuyIndex++;
      
   else if(curRVIHist < 0)
      SellIndex++;


   // MACD
   double MACDHist = m_Indicators.GetMACD().GetHistogram(TimeFrameIndex, Shift);

   if(MACDHist > 0)
      BuyIndex++;
      
   else if(MACDHist < 0)
      SellIndex++;

   
   BuyPercent = NormalizeDouble((BuyIndex/(double)m_TotalMarketMomentum)*100, 2);
   SellPercent = NormalizeDouble((SellIndex/(double)m_TotalMarketMomentum)*100, 2);
   
   
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

void MarketMomentum::OnUpdateMarketMomentumMeanStdDev(int TimeFrameIndex)
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
   m_SellMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
   m_BuyStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_SellStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int MarketMomentum::GetBuyMeanTrend(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyPercent[TimeFrameIndex][Shift] > m_BuyMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  else if(m_BuyPercent[TimeFrameIndex][Shift] < m_BuyMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  return NEUTRAL;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int MarketMomentum::GetSellMeanTrend(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift>= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_SellPercent[TimeFrameIndex][Shift] > m_SellMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  else if(m_SellPercent[TimeFrameIndex][Shift] < m_SellMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  return NEUTRAL;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::GetIsBuyCrossSell(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1>= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyPercent[TimeFrameIndex][Shift] > m_SellPercent[TimeFrameIndex][Shift]
   && m_BuyPercent[TimeFrameIndex][Shift+1] <= m_SellPercent[TimeFrameIndex][Shift+1]
   )
      return true;
      
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::GetIsSellCrossBuy(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1>= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyPercent[TimeFrameIndex][Shift] < m_SellPercent[TimeFrameIndex][Shift]
   && m_BuyPercent[TimeFrameIndex][Shift+1] >= m_SellPercent[TimeFrameIndex][Shift+1]
   )
      return true;
      
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::GetIsBuyCrossMean(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1>= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyPercent[TimeFrameIndex][Shift] > m_BuyMean[TimeFrameIndex][Shift]
   && m_BuyPercent[TimeFrameIndex][Shift+1] <= m_BuyMean[TimeFrameIndex][Shift+1]
   )
      return true;
      
      
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::GetIsSellCrossMean(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1>= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_SellPercent[TimeFrameIndex][Shift] > m_SellMean[TimeFrameIndex][Shift]
   && m_SellPercent[TimeFrameIndex][Shift+1] <= m_SellMean[TimeFrameIndex][Shift+1]
   )
      return true;
      
      
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketMomentum::SetTotalMarketMomentumIndicator(int TotalMarketMomentum)
{
   if(TotalMarketMomentum<0)
     {
      LogError(__FUNCTION__,"Invalid Total Indicator input.");
      m_TotalMarketMomentum=0;
      return false;
     }

   m_TotalMarketMomentum=TotalMarketMomentum;
   return true;

}

//+------------------------------------------------------------------+