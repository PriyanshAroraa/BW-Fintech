//+------------------------------------------------------------------+
//|                                              MarketCondition.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\MathFunc.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class MarketCondition
{
   private:
      CandleStickArray                 *m_CandleStick;
      IndicatorsHelper                 *m_Indicators;
      AdvanceIndicator                 *m_AdvanceIndicators;
      
      ENUM_MARKET_CONDITION            m_MarketCondition[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      bool                             m_CrossOver[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      ENUM_MARKET_BIAS                 m_MarketMomentum[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      int                              m_SqueezeCandleStickCounter[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                              m_SqueezeCandleStickWickBias[ENUM_TIMEFRAMES_ARRAY_SIZE][2];
      
      double                           m_AnchoredSupport[ENUM_TIMEFRAMES_ARRAY_SIZE];
      double                           m_AnchoredResistance[ENUM_TIMEFRAMES_ARRAY_SIZE];
      
      double                           m_BuyTrendPercentage;
      double                           m_SellTrendPercentage;

      void                             CalculateMarketBias(int TimeFrameIndex, int Shift);
      void                             CalculateBullBearMarketCondition(int TimeFrameIndex, int Shift);
      void                             CalculateSqueezeCandleStickWickBias(int TimeFrameIndex);
 
   public:
                                       MarketCondition(CandleStickArray *pCSPriceAction, IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicator);
                                       ~MarketCondition();
                                       
      
      bool                             Init();
      void                             OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      // Market Condition Getter
      ENUM_MARKET_CONDITION            GetEnumMarketCondition(int TimeFrameIndex, int Shift){return m_MarketCondition[TimeFrameIndex][Shift];};
      bool                             GetIsCrossOverMarketCondition(int TimeFrameIndex, int Shift){return m_CrossOver[TimeFrameIndex][Shift];};
      string                           GetStringMarketCondition(int TimeFrameIndex, int Shift){return GetEnumMarketConditionString(m_MarketCondition[TimeFrameIndex][Shift]);};
      int                              GetSqueezeCandleStickWickBias(int TimeFrameIndex, int Shift){return m_SqueezeCandleStickWickBias[TimeFrameIndex][Shift];};
      
      double                           GetAnchoredSupport(int TimeFrameIndex){return m_AnchoredSupport[TimeFrameIndex];};
      double                           GetAnchoredResistance(int TimeFrameIndex){return m_AnchoredResistance[TimeFrameIndex];};
      
      
      double                           GetTotalBuyTrendPercentage(){return m_BuyTrendPercentage;};
      double                           GetTotalSellTrendPercentage(){return m_SellTrendPercentage;};
      
      // Market Bias Getter
      ENUM_MARKET_BIAS                 GetMarketMomentum(int TimeFrameIndex, int Shift);
      string                           GetMarketMomentumString(int TimeFrameIndex, int Shift);
      
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketCondition::MarketCondition(CandleStickArray *pCSPriceAction, IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicator)
{
   m_CandleStick=NULL;
   m_Indicators=NULL;
   m_AdvanceIndicators=NULL;

   if(pCSPriceAction==NULL)
      LogError(__FUNCTION__,"Candlestick Price Action pointer is NULL");
   else
      m_CandleStick=pCSPriceAction;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

   if(pAdvanceIndicator==NULL)
      LogError(__FUNCTION__,"Advance Indicators pointer is NULL");
   else
      m_AdvanceIndicators=pAdvanceIndicator;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketCondition::~MarketCondition()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketCondition::Init()
{
   ArrayInitialize(m_MarketMomentum, Uncertainty);
   ArrayInitialize(m_MarketCondition, UnknownMarketCondition);
   ArrayInitialize(m_CrossOver, false); 
   ArrayInitialize(m_AnchoredResistance, 0);
   ArrayInitialize(m_AnchoredSupport, 0);
   ArrayInitialize(m_SqueezeCandleStickCounter, 0);
   ArrayInitialize(m_SqueezeCandleStickWickBias, NEUTRAL);

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {   
      int squeeze_counter = 0;
   
      for(int j = INDEXES_BUFFER_SIZE-1; j >= 0 ; j--)
      {
         CalculateMarketBias(i, j);
         CalculateBullBearMarketCondition(i,j);
         
         // Squeeze starts 
         if(m_MarketCondition[i][j] == Bull_Squeeze || m_MarketCondition[i][j] == Bear_Squeeze)
            m_SqueezeCandleStickCounter[i]++;
         else
            m_SqueezeCandleStickCounter[i] = 0;
      }
   }

   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketCondition::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(IsNewBar)
   {         
      // Add the squeeze ones
      if(m_MarketCondition[TimeFrameIndex][0] == Bull_Squeeze || m_MarketCondition[TimeFrameIndex][0] == Bear_Squeeze)
         m_SqueezeCandleStickCounter[TimeFrameIndex]++;
      else if(m_SqueezeCandleStickCounter[TimeFrameIndex] > 0 
      && m_MarketCondition[TimeFrameIndex][0] != Bull_Squeeze && m_MarketCondition[TimeFrameIndex][0] != Bear_Squeeze
      )
      {
         m_SqueezeCandleStickWickBias[TimeFrameIndex][1] = m_SqueezeCandleStickWickBias[TimeFrameIndex][0];
         m_SqueezeCandleStickCounter[TimeFrameIndex] = 0; 
      }
      else
         m_SqueezeCandleStickCounter[TimeFrameIndex] = 0;   

      for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--)
      {
         m_MarketMomentum[TimeFrameIndex][i] = m_MarketMomentum[TimeFrameIndex][i-1];
         m_MarketCondition[TimeFrameIndex][i]=m_MarketCondition[TimeFrameIndex][i-1];
      }
   }
      
   CalculateMarketBias(TimeFrameIndex, 0);
   CalculateBullBearMarketCondition(TimeFrameIndex, 0);
   CalculateSqueezeCandleStickWickBias(TimeFrameIndex);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketCondition::CalculateBullBearMarketCondition(int TimeFrameIndex,int Shift)
{
/*
   Context:

   If Price plays around in between the old fractal High and Low, it means it's either a channelling or squeezing
   The cause of this is accumulate liquidity to breakout through either the support or resistance 
   depending on whether it's a channelling or not 
*/

   if(Shift+1 >= FRACTAL_BUFFER_SIZE)
   {
      m_MarketCondition[TimeFrameIndex][Shift] = NULL;
      return;
   }

   double atr = m_Indicators.GetATR().GetATRValue(TimeFrameIndex, Shift+1);
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   string symbol = Symbol();

   double curr_fractal_supp = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(TimeFrameIndex, Shift);
   double curr_fractal_lower_supp = m_Indicators.GetFractal().GetFractalSupportBarShiftLowerPrice(TimeFrameIndex, Shift);
   int prev_fractal_supp_index = iBarShift(symbol, timeFrameENUM, m_Indicators.GetFractal().GetFractalSupportDateTime(TimeFrameIndex, Shift+1));

   double curr_fractal_ress = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(TimeFrameIndex, Shift);
   double curr_fractal_upper_ress = m_Indicators.GetFractal().GetFractalResistanceBarShiftUpperPrice(TimeFrameIndex, Shift);
   int prev_fractal_res_index = iBarShift(symbol, timeFrameENUM, m_Indicators.GetFractal().GetFractalResistanceDateTime(TimeFrameIndex, Shift+1));

   double prev_fractal_upper_ress = m_Indicators.GetFractal().GetFractalResistanceUpperPrice(TimeFrameIndex, Shift+1);
   double prev_fractal_lower_supp = m_Indicators.GetFractal().GetFractalSupportLowerPrice(TimeFrameIndex, Shift+1);
   
   double prev_fractal_ress = m_Indicators.GetFractal().GetFractalResistancePrice(TimeFrameIndex, Shift+1);
   double prev_fractal_supp = m_Indicators.GetFractal().GetFractalSupportPrice(TimeFrameIndex, Shift+1);
      
   double Bull_Momentum_Percent = m_AdvanceIndicators.GetMarketMomentum().GetBuyPercent(TimeFrameIndex, Shift);
   double Bear_Momentum_Percent = m_AdvanceIndicators.GetMarketMomentum().GetSellPercent(TimeFrameIndex, Shift);

   double Bull_Percent = m_AdvanceIndicators.GetBullBear().GetReactiveBullPercent(TimeFrameIndex, Shift);
   double Bear_Percent = m_AdvanceIndicators.GetBullBear().GetReactiveBearPercent(TimeFrameIndex, Shift);

   double curr_bull_trend_mean = m_AdvanceIndicators.GetTrendIndexes().GetBuyIndexesMean(TimeFrameIndex, Shift);
   double curr_bear_trend_mean = m_AdvanceIndicators.GetTrendIndexes().GetSellIndexesMean(TimeFrameIndex, Shift);

   double curr_bull_trend_percent = m_AdvanceIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, Shift);
   double curr_bear_trend_percent = m_AdvanceIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, Shift);

   double prev_bull_trend_percent = m_AdvanceIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, Shift+1);
   double prev_bear_trend_percent = m_AdvanceIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, Shift+1);
   
   double curr_buy_market_bias_mean = m_AdvanceIndicators.GetMarketMomentum().GetBuyMean(TimeFrameIndex, Shift);
   double curr_sell_market_bias_mean = m_AdvanceIndicators.GetMarketMomentum().GetSellMean(TimeFrameIndex, Shift);
   
   double prev_buy_market_bias_mean = m_AdvanceIndicators.GetMarketMomentum().GetBuyMean(TimeFrameIndex, Shift+1);
   double prev_sell_market_bias_mean = m_AdvanceIndicators.GetMarketMomentum().GetSellMean(TimeFrameIndex, Shift+1);

   double size = Normalize(prev_fractal_ress-prev_fractal_supp);
   
   double band_pos = m_Indicators.GetBands().GetBandStdDevPosition(0, 0);

   // Check whether should invalidate the Anchor first
   if(m_AnchoredResistance[TimeFrameIndex] > 0 && m_AnchoredSupport[TimeFrameIndex] > 0)
   {
      // Break Up Resistance
      if(CandleSticksBuffer[TimeFrameIndex][0].GetHigh() >= m_AnchoredResistance[TimeFrameIndex]
      && CandleSticksBuffer[TimeFrameIndex][1].GetOpen() < m_AnchoredResistance[TimeFrameIndex]
      )
      {
         // M15 && H1 Market Regime Identification
         if(CandleSticksBuffer[TimeFrameIndex][0].GetHigh() >= m_AnchoredResistance[TimeFrameIndex]
         && CandleSticksBuffer[TimeFrameIndex][1].GetOpen() < m_AnchoredResistance[TimeFrameIndex]
         )
         {
            if(curr_bull_trend_mean > 70)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
            else if(curr_bear_trend_mean > 70)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
            else if(band_pos >= 2)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
            else if(band_pos <= -2)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
         }
         
         // H4 && D1 Market Regime Identification
         else
         {
            if(Bull_Percent == 100)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
            else if(Bear_Percent == 100)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
            else if(Bull_Percent > Bear_Percent)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
            else if(Bear_Percent > Bull_Percent)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
         }
         
         m_AnchoredResistance[TimeFrameIndex] = 0;
         m_AnchoredSupport[TimeFrameIndex] = 0;
         
      }
      
      
      // Break down Support
      else if(CandleSticksBuffer[TimeFrameIndex][0].GetLow() <= m_AnchoredSupport[TimeFrameIndex]
      && CandleSticksBuffer[TimeFrameIndex][1].GetOpen() > m_AnchoredSupport[TimeFrameIndex]
      )
      {      
         // M15 && H1 Market Regime Identification
         if(TimeFrameIndex < 2)
         {
            if(curr_bull_trend_mean > 70)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
            else if(curr_bear_trend_mean > 70)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
            else if(band_pos >= 2)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
            else if(band_pos <= -2)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
         }
         
         // H4 && D1 Market Regime Identification
         else
         {
            if(Bull_Percent == 100)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
            else if(Bear_Percent == 100)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
            else if(Bull_Percent > Bear_Percent)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
            else if(Bear_Percent > Bull_Percent)
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
         }  
         
         m_AnchoredResistance[TimeFrameIndex] = 0;
         m_AnchoredSupport[TimeFrameIndex] = 0;
         
      }
      
      else
      {
         // 0.35 is used as a threshold for now 
         if(TimeFrameIndex >= 2 || size > m_CandleStick.GetAverageDailyPriceMovement()*0.35)
         {
            if(m_AdvanceIndicators.GetMarketMomentum().GetBuyMeanTrend(TimeFrameIndex, Shift) == BULL_TRIGGER)
               m_MarketCondition[TimeFrameIndex][Shift] = Bull_Channel;
            else
               m_MarketCondition[TimeFrameIndex][Shift] = Bear_Channel;
         }
                  
         else if(Bull_Momentum_Percent > Bear_Momentum_Percent)
            m_MarketCondition[TimeFrameIndex][Shift] = Bull_Squeeze;
         else
            m_MarketCondition[TimeFrameIndex][Shift] = Bear_Squeeze;
      }
  
   }

   // Check if Consolidation happening
   else if(curr_fractal_ress < prev_fractal_ress && curr_fractal_supp > prev_fractal_supp
   && size + MEDIUM_STOP_LOSS_MULTIPLIER*atr < m_CandleStick.GetAverageDailyPriceMovement() 
   && CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() > prev_fractal_supp && CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() < prev_fractal_ress
   && CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() > curr_fractal_supp && CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() < curr_fractal_ress
   )
   {   
      // Setting the base of the HL 
      m_AnchoredResistance[TimeFrameIndex] = prev_fractal_ress - curr_fractal_ress > EXTREME_LOOSE_STOP_LOSS_MULTIPLIER * atr ? curr_fractal_upper_ress : prev_fractal_upper_ress;
      m_AnchoredSupport[TimeFrameIndex] = curr_fractal_supp - prev_fractal_supp > EXTREME_LOOSE_STOP_LOSS_MULTIPLIER * atr ? curr_fractal_lower_supp : prev_fractal_lower_supp;   
   
      // 0.5 is used as a threshold for now 
      if(TimeFrameIndex >= 2 || size > m_CandleStick.GetAverageDailyPriceMovement()*0.35)
      {
         if(m_AdvanceIndicators.GetMarketMomentum().GetBuyMeanTrend(TimeFrameIndex, Shift) == BULL_TRIGGER)
            m_MarketCondition[TimeFrameIndex][Shift] = Bull_Channel;
         else
            m_MarketCondition[TimeFrameIndex][Shift] = Bear_Channel;
      }
      else if(Bull_Momentum_Percent > Bear_Momentum_Percent)
         m_MarketCondition[TimeFrameIndex][Shift] = Bull_Squeeze;
      else
         m_MarketCondition[TimeFrameIndex][Shift] = Bear_Squeeze;
      
   }
   
   // Trending
   
   // M15 && H1 Market Regime Identification
   else if(TimeFrameIndex < 2)
   {
      if(curr_bull_trend_mean > 70)
         m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
      else if(curr_bear_trend_mean > 70)
         m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
      else if(curr_bull_trend_percent > prev_bull_trend_percent && m_MarketMomentum[TimeFrameIndex][Shift] <= WeakBull)
         m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
      else if(curr_bear_trend_percent > prev_bear_trend_percent && m_MarketMomentum[TimeFrameIndex][Shift] >= StrongBear && m_MarketMomentum[TimeFrameIndex][Shift] <= WeakBear)
         m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
      else
         m_MarketCondition[TimeFrameIndex][Shift] = m_MarketCondition[TimeFrameIndex][Shift+1]; 
   }
   
   // H4 && D1 Market Regime Identification
   else
   {
      if(Bull_Percent == 100)
         m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_3x;
      else if(Bear_Percent == 100)
         m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_3x; 
      else if(Bull_Percent > Bear_Percent)
         m_MarketCondition[TimeFrameIndex][Shift] = Bull_Trend_2x;
      else if(Bear_Percent > Bull_Percent)
         m_MarketCondition[TimeFrameIndex][Shift] = Bear_Trend_2x;
      else
         m_MarketCondition[TimeFrameIndex][Shift] = m_MarketCondition[TimeFrameIndex][Shift+1];
   }      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketCondition::CalculateSqueezeCandleStickWickBias(int TimeFrameIndex)
{
   // Squeeze is not up yet
   if(m_SqueezeCandleStickCounter[TimeFrameIndex] < 0)
      return;

   // save the squeeze 
   int topwick_bias = 0, botwick_bias = 0;
   
   for(int i = 0; i < MathMin(m_SqueezeCandleStickCounter[TimeFrameIndex], CANDLESTICKS_BUFFER_SIZE); i++)
   {
      if(m_CandleStick.GetCummTopBotBias(TimeFrameIndex, i) == BULL_TRIGGER)
         botwick_bias++;
      else if(m_CandleStick.GetCummTopBotBias(TimeFrameIndex, i) == BEAR_TRIGGER)
         topwick_bias++;
   }
   
   // Finalize
   if(topwick_bias > botwick_bias)
      m_SqueezeCandleStickWickBias[TimeFrameIndex][0] = BEAR_TRIGGER;
   else if(topwick_bias < botwick_bias)
      m_SqueezeCandleStickWickBias[TimeFrameIndex][0] = BULL_TRIGGER;
   else
      m_SqueezeCandleStickWickBias[TimeFrameIndex][0] = NEUTRAL;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketCondition::CalculateMarketBias(int TimeFrameIndex, int Shift)
{

   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "Market Bias Shift/TimeFrameIndex out of range.");
      return;
   }


   // Buy Situations
   if(m_AdvanceIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, Shift) > 50)
   {
      if(m_AdvanceIndicators.GetMarketMomentum().GetBuyPercent(TimeFrameIndex, Shift) > 50)
         m_MarketMomentum[TimeFrameIndex][Shift] = StrongBull;
         
      else
         m_MarketMomentum[TimeFrameIndex][Shift] = WeakBull;
   }
   
   
   else if(m_AdvanceIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, Shift) > 50)
   {     
      if(m_AdvanceIndicators.GetMarketMomentum().GetSellPercent(TimeFrameIndex, Shift) > 50)
         m_MarketMomentum[TimeFrameIndex][Shift] = StrongBear;
         
      else
         m_MarketMomentum[TimeFrameIndex][Shift] = WeakBear;
         
   }
   
   
   else
      m_MarketMomentum[TimeFrameIndex][Shift] = Uncertainty;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_MARKET_BIAS MarketCondition::GetMarketMomentum(int TimeFrameIndex, int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "Current Market Bias array is out of range.");
      return NULL; 
   }
   
   return m_MarketMomentum[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string MarketCondition::GetMarketMomentumString(int TimeFrameIndex, int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "Current Market Bias array is out of range.");
      return ""; 
   }
   
   return GetEnumMarketBiasString(m_MarketMomentum[TimeFrameIndex][Shift]);
   
}
