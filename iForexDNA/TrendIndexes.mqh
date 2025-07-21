//+------------------------------------------------------------------+
//|                                             TrendIndexes.mqh     |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class TrendIndexes:public BaseIndicator
{
   private:
      IndicatorsHelper                    *m_Indicators;
      
      double                              m_BuyTrendIndexes[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                              m_BuyTrendIndexesMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double                              m_SellTrendIndexes[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                              m_SellTrendIndexesMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];


      string                              CalculateBuySellTrendIndexes(int TimeFrameIndex, int Shift);
      void                                OnUpdateMeanStdDev(int TimeFrameIndex);

   public:
                                          TrendIndexes(IndicatorsHelper *pIndicators);
                                          ~TrendIndexes();
      
      bool                                Init();
      void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                              GetBuyTrendIndexes(int TimeFrameIndex, int Shift){return m_BuyTrendIndexes[TimeFrameIndex][Shift];};
      double                              GetBuyIndexesMean(int TimeFrameIndex, int Shift){return m_BuyTrendIndexesMean[TimeFrameIndex][Shift];};

      double                              GetSellTrendIndexes(int TimeFrameIndex, int Shift){return m_SellTrendIndexes[TimeFrameIndex][Shift];};
      double                              GetSellIndexesMean(int TimeFrameIndex, int Shift){return m_SellTrendIndexesMean[TimeFrameIndex][Shift];};


      int                                 GetBuyMeanTrend(int TimeFrameIndex, int Shift);
      int                                 GetSellMeanTrend(int TimeFrameIndex, int Shift);

      bool                                IsBuyCross(int TimeFrameIndex, int Shift);
      bool                                IsSellCross(int TimeFrameIndex, int Shift);

   
      double                              GetTotalBuyTrendIndexes(int Shift);      
      double                              GetTotalSellTrendIndexes(int Shift);
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TrendIndexes::TrendIndexes(IndicatorsHelper *pIndicators):BaseIndicator("Trend")
{
   m_Indicators=NULL;
      
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"pIndicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TrendIndexes::~TrendIndexes()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TrendIndexes::Init()
{
   ArrayInitialize(m_BuyTrendIndexes, 0);
   ArrayInitialize(m_SellTrendIndexes, 0);
   
   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      double tempBuyArray[INDEXES_BUFFER_SIZE*2];
      double tempSellArray[INDEXES_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempBuyArray);

      for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++)
      {
         if(j < INDEXES_BUFFER_SIZE)
         {
            CalculateBuySellTrendIndexes(i, j);
            tempBuyArray[j] = m_BuyTrendIndexes[i][j];
            tempSellArray[j] = m_SellTrendIndexes[i][j];
         }
         
         else
         {
            string TrendArray[2];
            StringSplit(CalculateBuySellTrendIndexes(i,j), '/', TrendArray);
      
            tempBuyArray[j] = StringToDouble(TrendArray[0]);
            tempSellArray[j] = StringToDouble(TrendArray[1]);
         }
      }
   
   
      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_BuyTrendIndexesMean[i][x] = NormalizeDouble(MathMean(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellTrendIndexesMean[i][x] = NormalizeDouble(MathMean(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
      }
   
   }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendIndexes::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(IsNewBar)
   {
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--)
      {
         m_BuyTrendIndexes[TimeFrameIndex][j]=m_BuyTrendIndexes[TimeFrameIndex][j-1];
         m_SellTrendIndexes[TimeFrameIndex][j]=m_SellTrendIndexes[TimeFrameIndex][j-1];
         
         m_BuyTrendIndexesMean[TimeFrameIndex][j]=m_BuyTrendIndexesMean[TimeFrameIndex][j-1];
         m_SellTrendIndexesMean[TimeFrameIndex][j]=m_SellTrendIndexesMean[TimeFrameIndex][j-1];
      }      
   }
   
   CalculateBuySellTrendIndexes(TimeFrameIndex, 0);
   OnUpdateMeanStdDev(TimeFrameIndex);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string TrendIndexes::CalculateBuySellTrendIndexes(int TimeFrameIndex, int Shift)
{

   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   double buy_trend_count =0, sell_trend_count = 0, total_count = 0;
   
   // ADX
   double adxplus = m_Indicators.GetADX().GetPlusDI(TimeFrameIndex, Shift);
   double adxminus = m_Indicators.GetADX().GetMinusDI(TimeFrameIndex, Shift);
   
   if(adxplus > adxminus)
      buy_trend_count++;
      
   else if(adxplus < adxminus)
      sell_trend_count++;
      
   total_count++;
   
   
   // STOCH
   double stochmain = m_Indicators.GetSTO().GetMain(TimeFrameIndex, Shift);
   double stochsignal = m_Indicators.GetSTO().GetSignal(TimeFrameIndex, Shift);
   
   if(stochmain > 50 && stochsignal > 50)
      buy_trend_count+=2;
   else if(stochmain > 50 || stochsignal > 50)
      buy_trend_count++;
   
   if(stochmain < 50 && stochsignal < 50)
      sell_trend_count+=2;
   else if(stochmain < 50 || stochsignal < 50)
      sell_trend_count++;
      
   total_count+=2;
   
   // RSI
   double rsi = m_Indicators.GetRSI().GetRSIValue(TimeFrameIndex, Shift);
   double rsi_mean = m_Indicators.GetRSI().GetRSIMean(TimeFrameIndex, Shift);
   
   
   if(rsi > 50 && rsi_mean > 50)
      buy_trend_count+=2;
   else if(rsi > 50)
      buy_trend_count++;
   
   
   if(rsi < 50 && rsi_mean < 50)
      sell_trend_count+=2;
   else if(rsi < 50)
      sell_trend_count++;
      
   total_count+=2;
   
   
   // MACD
   double macdmain = m_Indicators.GetMACD().GetMain(TimeFrameIndex, Shift);
   double macdsignal = m_Indicators.GetMACD().GetSignal(TimeFrameIndex, Shift);
   
   if(macdmain > macdsignal)
      buy_trend_count++;
   else if(macdmain < macdsignal)
      sell_trend_count++;
      
   total_count++;
   
   
   // PSAR
   double psar = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSAR().GetSar(TimeFrameIndex, Shift+1) : GetPSAR(m_Indicators.GetSAR().GetSARHandler(TimeFrameIndex), Shift+1);

   if(psar < iLow(Symbol(), timeFrameENUM, Shift+1))
      buy_trend_count++;
      
   if(psar > iHigh(Symbol(), timeFrameENUM, Shift+1))
      sell_trend_count++;
      
   total_count++;
   
   
   
   // Span A & Span B
   double spanA = 0, spanB = 0;
   
   if(Shift-ICHIMOKU_NEGATIVE_SHIFT < ICHIMOKU_SPAN_BUFFER_SIZE)
   {
      spanA = m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-(ICHIMOKU_NEGATIVE_SHIFT));
      spanB = m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-(ICHIMOKU_NEGATIVE_SHIFT));
   }

   else
   {
      spanA = GetIchimoku(m_Indicators.GetIchimoku().GetHandlers(TimeFrameIndex), SENKOUSPANA_LINE, Shift);
      spanB = GetIchimoku(m_Indicators.GetIchimoku().GetHandlers(TimeFrameIndex), SENKOUSPANB_LINE, Shift);
   }

   
   double Negative26SpanA = m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift);
   double Negative26SpanB = m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift);
   
   if(spanA > spanB && Negative26SpanA > Negative26SpanB)
      buy_trend_count+=2;

   else if(spanA < spanB && Negative26SpanA > Negative26SpanB)
      buy_trend_count++;

   if(spanA < spanB && Negative26SpanA < Negative26SpanB)
      sell_trend_count+=2;
   
   else if(spanA > spanB && Negative26SpanA < Negative26SpanB)
      sell_trend_count++;
      
   
   total_count+=2;
   
   
   // Kijun & TenKan Lines
   double tenkan = m_Indicators.GetIchimoku().GetTenkanSen(TimeFrameIndex, Shift);
   double kijun = m_Indicators.GetIchimoku().GetKijunSen(TimeFrameIndex, Shift);
   

   if(tenkan > kijun)
      buy_trend_count++;
   
   else if(tenkan < kijun)
      sell_trend_count++;
      
   total_count++;
   
   // Chikou 
   double chikou = m_Indicators.GetIchimoku().GetChikouSpan(TimeFrameIndex, Shift);

   if(chikou > iHigh(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT))
      buy_trend_count++;
      
   else if(chikou < iLow(Symbol(), timeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT))
      sell_trend_count++;
   
   total_count++;
   
   // MAs
   double ma5 = m_Indicators.GetMovingAverage().GetFastMA(TimeFrameIndex, Shift);
   double ma20 = m_Indicators.GetMovingAverage().GetMediumMA(TimeFrameIndex, Shift);
   double ma50 = m_Indicators.GetMovingAverage().GetSlowMA(TimeFrameIndex, Shift);
   double ma200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(TimeFrameIndex, Shift);
   
   double previous_close = iClose(Symbol(), timeFrameENUM, Shift+1);
   
   if(previous_close > ma200)
      buy_trend_count+=2;
   else if(previous_close < ma200)
      sell_trend_count+=2;
      
   total_count+=2;
   
   
   if(ma5 > ma20 && ma5 > ma50 && ma20 > ma50)
      buy_trend_count+=2;
   
   else if(ma5 > ma20 && ma5 < ma50)
      buy_trend_count++;
      
   if(ma5 < ma20 && ma5 < ma50 && ma20 < ma50)
      sell_trend_count+=2;
      
   else if(ma5 < ma20 && ma5 > ma50)
      sell_trend_count++;
      
   total_count+=2;
   
   
   // Bollinger Bands
   int bbcount = 0;
   
   for(int i =0 ; i <= 5; i++)
   {
      double band_mean = m_Indicators.GetBands().GetMain(TimeFrameIndex, Shift);
      double band_upper = m_Indicators.GetBands().GetUpper(TimeFrameIndex, 2, Shift);
      double band_lower = m_Indicators.GetBands().GetLower(TimeFrameIndex, 2, Shift);
      double close = iClose(Symbol(), timeFrameENUM, i);
   
      if(close > band_mean && close < band_upper)
         bbcount++;
         
      if(close < band_mean && close > band_lower)
         bbcount--;
   }
   
   if(bbcount >= 3)
      buy_trend_count++;
   if(bbcount <= -3)
      sell_trend_count++;
      
   total_count++;
   
   
   if(Shift < INDEXES_BUFFER_SIZE)
   {
      // Set Indexes
      m_BuyTrendIndexes[TimeFrameIndex][Shift] = NormalizeDouble((buy_trend_count/total_count)*100, 2);
      m_SellTrendIndexes[TimeFrameIndex][Shift] = NormalizeDouble((sell_trend_count/total_count)*100, 2);  
      
      return "";
   }
   
   return DoubleToString((buy_trend_count/total_count)*100, 2)+"/"+DoubleToString((sell_trend_count/total_count)*100, 2);
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendIndexes::OnUpdateMeanStdDev(int TimeFrameIndex)
{
   double tempBuyArray[ADVANCE_INDICATOR_PERIOD];
   double tempSellArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempBuyArray[i] = m_BuyTrendIndexes[TimeFrameIndex][i];
      tempSellArray[i] = m_SellTrendIndexes[TimeFrameIndex][i];
   }   

   m_BuyTrendIndexesMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_SellTrendIndexesMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TrendIndexes::GetBuyMeanTrend(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyTrendIndexes[TimeFrameIndex][Shift] > m_BuyTrendIndexesMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  else if(m_BuyTrendIndexes[TimeFrameIndex][Shift] < m_BuyTrendIndexesMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  return NEUTRAL;
  
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TrendIndexes::GetSellMeanTrend(int TimeFrameIndex,int Shift)
{

   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_SellTrendIndexes[TimeFrameIndex][Shift] > m_SellTrendIndexesMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  else if(m_SellTrendIndexes[TimeFrameIndex][Shift] < m_SellTrendIndexesMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  return NEUTRAL;
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TrendIndexes::IsBuyCross(int TimeFrameIndex,int Shift)
{

   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyTrendIndexes[TimeFrameIndex][Shift] > m_SellTrendIndexes[TimeFrameIndex][Shift]
   && m_BuyTrendIndexes[TimeFrameIndex][Shift+1] <= m_SellTrendIndexes[TimeFrameIndex][Shift+1]
   )
      return true;

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TrendIndexes::IsSellCross(int TimeFrameIndex,int Shift)
{

   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyTrendIndexes[TimeFrameIndex][Shift] < m_SellTrendIndexes[TimeFrameIndex][Shift]
   && m_BuyTrendIndexes[TimeFrameIndex][Shift+1] >= m_SellTrendIndexes[TimeFrameIndex][Shift+1]
   )
      return true;

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TrendIndexes::GetTotalBuyTrendIndexes(int Shift)
{

   double Indexes = 0;

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      Indexes += m_BuyTrendIndexes[i][Shift];


   return Indexes;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TrendIndexes::GetTotalSellTrendIndexes(int Shift)
{

   double Indexes = 0;

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      Indexes += m_SellTrendIndexes[i][Shift];


   return Indexes;

}

//+------------------------------------------------------------------+