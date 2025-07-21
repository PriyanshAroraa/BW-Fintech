//+------------------------------------------------------------------+
//|                                             TrendProbability.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MarketCondition.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class TrendProbability:public BaseIndicator
{
   private:
      CandleStickArray                    *m_CandleStickAnalysis;
      IndicatorsHelper                    *m_Indicators;
      AdvanceIndicator                    *m_AdvanceIndicators;
      MarketCondition                     *m_MarketCondition;
      
      double                              m_BuyTrendProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                              m_BuyTrendProbabilityMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double                              m_SellTrendProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                              m_SellTrendProbabilityMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];


      string                              CalculateBuySellTrendProbability(int TimeFrameIndex, int Shift);
      void                                OnUpdateMeanStdDev(int TimeFrameIndex);

   public:
                                          TrendProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators, MarketCondition *pMarketCondition);
                                          ~TrendProbability();
      
      bool                                Init();
      void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                              GetBuyTrendProbability(int TimeFrameIndex, int Shift){return m_BuyTrendProbability[TimeFrameIndex][Shift];};
      double                              GetBuyProbabilityMean(int TimeFrameIndex, int Shift){return m_BuyTrendProbabilityMean[TimeFrameIndex][Shift];};

      double                              GetSellTrendProbability(int TimeFrameIndex, int Shift){return m_SellTrendProbability[TimeFrameIndex][Shift];};
      double                              GetSellProbabilityMean(int TimeFrameIndex, int Shift){return m_SellTrendProbabilityMean[TimeFrameIndex][Shift];};


      int                                 GetBuyMeanTrend(int TimeFrameIndex, int Shift);
      int                                 GetSellMeanTrend(int TimeFrameIndex, int Shift);

   
      double                              GetTotalBuyTrendProbability(int Shift);      
      double                              GetTotalSellTrendProbability(int Shift);
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TrendProbability::TrendProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators,AdvanceIndicator *pAdvanceIndicators,MarketCondition *pMarketCondition)
:BaseIndicator("Trend")
{
   m_CandleStickAnalysis=NULL;
   m_Indicators=NULL;
   m_AdvanceIndicators=NULL;
   m_MarketCondition=NULL;

   if(pCandleStickAnalysis==NULL)
      LogError(__FUNCTION__,"pCandleStickAnalysis pointer is NULL");
   else
      m_CandleStickAnalysis=pCandleStickAnalysis;
      
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"pIndicators pointer is NULL");
   else
      m_Indicators=pIndicators;
      
   if(pAdvanceIndicators==NULL)
      LogError(__FUNCTION__,"pAdvanceIndicators pointer is NULL");
   else
      m_AdvanceIndicators=pAdvanceIndicators;

   if(pMarketCondition==NULL)
      LogError(__FUNCTION__,"MarketCondition pointer is 0");
   else
      m_MarketCondition=pMarketCondition;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TrendProbability::~TrendProbability()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TrendProbability::Init()
{
   ArrayInitialize(m_BuyTrendProbability, 0);
   ArrayInitialize(m_SellTrendProbability, 0);
   
   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      double tempBuyArray[INDEXES_BUFFER_SIZE*2];
      double tempSellArray[INDEXES_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempBuyArray);

      for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++)
      {
         if(j < INDEXES_BUFFER_SIZE)
         {
            CalculateBuySellTrendProbability(i, j);
            tempBuyArray[j] = m_BuyTrendProbability[i][j];
            tempSellArray[j] = m_SellTrendProbability[i][j];
         }
         
         else
         {
            string TrendArray[2];
            StringSplit(CalculateBuySellTrendProbability(i,j), '/', TrendArray);
      
            tempBuyArray[j] = StrToDouble(TrendArray[0]);
            tempSellArray[j] = StrToDouble(TrendArray[1]);
         }
      }
   
   
      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_BuyTrendProbabilityMean[i][x] = NormalizeDouble(iMAOnArray(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD, 0, MODE_SMA, arrsize-ADVANCE_INDICATOR_PERIOD-x), 2);
         m_SellTrendProbabilityMean[i][x] = NormalizeDouble(iMAOnArray(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD, 0, MODE_SMA, arrsize-ADVANCE_INDICATOR_PERIOD-x), 2);
      }
   
   }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendProbability::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(IsNewBar)
   {
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--)
      {
         m_BuyTrendProbability[TimeFrameIndex][j]=m_BuyTrendProbability[TimeFrameIndex][j-1];
         m_SellTrendProbability[TimeFrameIndex][j]=m_SellTrendProbability[TimeFrameIndex][j-1];
         m_BuyTrendProbabilityMean[TimeFrameIndex][j]=m_BuyTrendProbabilityMean[TimeFrameIndex][j-1];
         m_SellTrendProbabilityMean[TimeFrameIndex][j]=m_SellTrendProbabilityMean[TimeFrameIndex][j-1];
      }
   }
   
   CalculateBuySellTrendProbability(TimeFrameIndex, 0);
   OnUpdateMeanStdDev(TimeFrameIndex);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string TrendProbability::CalculateBuySellTrendProbability(int TimeFrameIndex, int Shift)
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
   
   if(stochmain > stochsignal && stochmain < STO_LOWER_THRESHOLD)
   {
      buy_trend_count++;
      
      for(int i =5 ; i > 0; i--)
      {
         double stomain = Shift+i < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSTO().GetMain(TimeFrameIndex, Shift+i) : NormalizeDouble(iStochastic(Symbol(), timeFrameENUM, STO_KPERIOD, STO_DPERIOD, STO_SLOWING, APPLIED_MA_METHOD, STO_PRICE_FIELD, MODE_MAIN, Shift+i), 2);
       
         if(stomain < STO_LOWER_THRESHOLD)
            buy_trend_count++; 
      }

   }

   if(stochmain < stochsignal && stochmain > STO_UPPER_THRESHOLD)
   {
      sell_trend_count++;
      
      for(int i =5 ; i > 0; i--)
      {
         double stomain = Shift+i < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSTO().GetMain(TimeFrameIndex, Shift+i) : NormalizeDouble(iStochastic(Symbol(), timeFrameENUM, STO_KPERIOD, STO_DPERIOD, STO_SLOWING, APPLIED_MA_METHOD, STO_PRICE_FIELD, MODE_MAIN, Shift+i), 2);
       
         if(stomain > STO_UPPER_THRESHOLD)
            sell_trend_count++; 
      }
      
   }
   

   total_count+=2;
   
   
   // RSI
   double rsi = m_Indicators.GetRSI().GetRSI(TimeFrameIndex, Shift);
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
   double psar = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSAR().GetSar(TimeFrameIndex, Shift+1) : iSAR(Symbol(), timeFrameENUM, SAR_STEP, SAR_MAXIMUM, Shift+1);

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
      spanA = iIchimoku(Symbol(), timeFrameENUM, ICHIMOKU_TENKANSEN, ICHIMOKU_KIJUNSEN, ICHIMOKU_SENKOU_SPAN, MODE_SENKOUSPANA, Shift);
      spanB = iIchimoku(Symbol(), timeFrameENUM, ICHIMOKU_TENKANSEN, ICHIMOKU_KIJUNSEN, ICHIMOKU_SENKOU_SPAN, MODE_SENKOUSPANB, Shift);
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
      
   else if(ma5 < ma20 && ma5 < ma50 && ma20 < ma50)
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
      // Set Probability
      m_BuyTrendProbability[TimeFrameIndex][Shift] = NormalizeDouble((buy_trend_count/total_count)*100, 2);
      m_SellTrendProbability[TimeFrameIndex][Shift] = NormalizeDouble((sell_trend_count/total_count)*100, 2);  
      
      return "";
   }
   
   return DoubleToStr((buy_trend_count/total_count)*100, 2)+"/"+DoubleToStr((sell_trend_count/total_count)*100, 2);
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendProbability::OnUpdateMeanStdDev(int TimeFrameIndex)
{
   double tempBuyArray[ADVANCE_INDICATOR_PERIOD];
   double tempSellArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempBuyArray[i] = m_BuyTrendProbability[TimeFrameIndex][i];
      tempSellArray[i] = m_SellTrendProbability[TimeFrameIndex][i];
   }   

   m_BuyTrendProbabilityMean[TimeFrameIndex][0] = NormalizeDouble(iMAOnArray(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD, 0, MODE_SMA, 0), 2);
   m_SellTrendProbabilityMean[TimeFrameIndex][0] = NormalizeDouble(iMAOnArray(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD, 0, MODE_SMA, 0), 2);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TrendProbability::GetBuyMeanTrend(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_BuyTrendProbability[TimeFrameIndex][Shift] > m_BuyTrendProbabilityMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  else if(m_BuyTrendProbability[TimeFrameIndex][Shift] < m_BuyTrendProbabilityMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  return NEUTRAL;
  
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TrendProbability::GetSellMeanTrend(int TimeFrameIndex,int Shift)
{

   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   if(m_SellTrendProbability[TimeFrameIndex][Shift] > m_SellTrendProbabilityMean[TimeFrameIndex][Shift])
      return BEAR_TRIGGER;
      
  else if(m_SellTrendProbability[TimeFrameIndex][Shift] < m_SellTrendProbabilityMean[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
  return NEUTRAL;
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TrendProbability::GetTotalBuyTrendProbability(int Shift)
{

   double probability = 0;

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      probability += m_BuyTrendProbability[i][Shift];


   return probability;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TrendProbability::GetTotalSellTrendProbability(int Shift)
{

   double probability = 0;

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      probability += m_SellTrendProbability[i][Shift];


   return probability;

}

//+------------------------------------------------------------------+