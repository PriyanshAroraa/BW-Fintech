//+------------------------------------------------------------------+
//|                                          ReversalProbability.mqh |
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ReversalProbability:public BaseIndicator
{
   private:
      CandleStickArray                    *m_CandleStickAnalysis;
      IndicatorsHelper                    *m_Indicators;
      AdvanceIndicator                    *m_AdvanceIndicators;
      
      double                              m_BuyReversalProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];
      double                              m_SellReversalProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];

      void                                CalculateBuySellReversalProbability(int TimeFrameIndex, int Shift);

   public:
                                          ReversalProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators);
                                          ~ReversalProbability();
      
      bool                                Init();
      void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                              GetBuyReversalProbability(int TimeFrameIndex, int Shift){return m_BuyReversalProbability[TimeFrameIndex][Shift];};
      double                              GetTotalBuyReversalProbability(int Shift);

      double                              GetSellReversalProbability(int TimeFrameIndex, int Shift){return m_SellReversalProbability[TimeFrameIndex][Shift];};
      double                              GetTotalSellReversalProbability(int Shift);
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ReversalProbability::ReversalProbability(CandleStickArray *pCandleStickAnalysis, IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators)
:BaseIndicator("Reversal")
{
   m_CandleStickAnalysis=NULL;
   m_Indicators=NULL;
   m_AdvanceIndicators=NULL;

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

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ReversalProbability::~ReversalProbability()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ReversalProbability::Init()
{
   ArrayInitialize(m_BuyReversalProbability, 0);
   ArrayInitialize(m_SellReversalProbability, 0);
   
   for(int i =0 ; i< ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      for(int j = 0; j < PROBABILITY_INDEX_BUFFER_SIZE; j++)
         CalculateBuySellReversalProbability(i, j);
   }
   
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ReversalProbability::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{

   if(IsNewBar)
   {
      for(int j = PROBABILITY_INDEX_BUFFER_SIZE-1; j > 0; j--)
      {
         m_BuyReversalProbability[TimeFrameIndex][j] = m_BuyReversalProbability[TimeFrameIndex][j-1];
         m_SellReversalProbability[TimeFrameIndex][j] = m_SellReversalProbability[TimeFrameIndex][j-1];
      }
   }
   
   CalculateBuySellReversalProbability(TimeFrameIndex, 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void ReversalProbability::CalculateBuySellReversalProbability(int TimeFrameIndex, int Shift)
{
   // failed to calculate
   if(Shift + 5 >= INDEXES_BUFFER_SIZE)
      return;
   
   double buy_reversal_signal = 0, sell_reversal_signal = 0, total_reversal_signal = 0;
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   // Utils
   ENUM_INDICATOR_POSITION VolatilityPosition[5];
   ENUM_INDICATOR_POSITION BollingerPostion[5];
   ENUM_INDICATOR_POSITION OBPosition[5];
   ENUM_INDICATOR_POSITION OSPosition[5];
   double                  ZigZagValue[5];
   int                     DivergenceType[5];
   
   
   ArrayInitialize(VolatilityPosition, Null);
   ArrayInitialize(BollingerPostion, Null);
   ArrayInitialize(OBPosition, Null);
   ArrayInitialize(OSPosition, Null);
   ArrayInitialize(ZigZagValue, 0);
   ArrayInitialize(DivergenceType, 0);

   for(int i = 0; i < 5; i++)
   {   
      VolatilityPosition[i] = m_AdvanceIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, Shift+i);
      BollingerPostion[i] = m_Indicators.GetBands().GetPricePosition(TimeFrameIndex, Shift+i);
      OBPosition[i] = m_AdvanceIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, Shift+i);
      OSPosition[i] = m_AdvanceIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, Shift+i);
      ZigZagValue[i] = m_AdvanceIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(timeFrameENUM, Shift+i);
      DivergenceType[i] = m_AdvanceIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(TimeFrameIndex, Shift+i);
   }


   // ZigZag Reversal Condition
   if(ZigZagValue[0] == 0 && ZigZagValue[1] <= 0 && ZigZagValue[2] < 0)
      buy_reversal_signal+=2;
   
   else if(ZigZagValue[0] == 0 && ZigZagValue[1] >= 0 && ZigZagValue[2] > 0)
      sell_reversal_signal+=2;
      
   else if(ZigZagValue[0] < 0 && ZigZagValue[1] < 0 && ZigZagValue[2] < 0)
      buy_reversal_signal++;
   
   else if(ZigZagValue[0] > 0 && ZigZagValue[1] > 0 && ZigZagValue[2] > 0)
      sell_reversal_signal++;

   total_reversal_signal+=2;
   
   
   // Divergence Reversal Condition
   if(DivergenceType[1] == BULL_DIVERGENCE && DivergenceType[1] != DivergenceType[3])
      buy_reversal_signal+=2;
   
   else if(DivergenceType[1] == BEAR_DIVERGENCE && DivergenceType[1] != DivergenceType[3])
      sell_reversal_signal+=2;

   else if(DivergenceType[1] == BULL_DIVERGENCE && DivergenceType[2] == BULL_DIVERGENCE && DivergenceType[3] == BEAR_DIVERGENCE)
      sell_reversal_signal+=2;

   else if(DivergenceType[0] == BULL_DIVERGENCE && DivergenceType[2] == BEAR_DIVERGENCE && DivergenceType[3] == BEAR_DIVERGENCE)
      buy_reversal_signal++;
      
   else if(DivergenceType[0] == BEAR_DIVERGENCE && DivergenceType[2] == BULL_DIVERGENCE && DivergenceType[3] == BULL_DIVERGENCE)
      sell_reversal_signal++;

   total_reversal_signal+=2;
   


   // OBOS Reversal Calculation
   
   // Buy Conditions
   if(OBPosition[0] == Null && OBPosition[1] == Null && OBPosition[2] == Null)
   {
      if(OSPosition[0] == Above_Mean && OSPosition[1] == Above_Mean && OSPosition[2] == Above_Mean)
         buy_reversal_signal++;
      
      else if(OSPosition[0] == Above_Mean && OSPosition[1] == Above_Mean && OSPosition[2] == Below_Mean)
         buy_reversal_signal++;


      else if(OSPosition[0] == Above_Mean && OSPosition[1] == Above_Mean && OSPosition[2] == Plus_2_StdDev)
         buy_reversal_signal++;
      
      else if(OSPosition[0] == Above_Mean && OSPosition[1] <= Plus_2_StdDev && OSPosition[2] <= Plus_2_StdDev)
         buy_reversal_signal++;
      
      else if(OSPosition[0] == Above_Mean && OSPosition[1] == Above_Mean && OSPosition[2] == Null)
         buy_reversal_signal++;
   }
   
   if(OSPosition[0] == Null && OSPosition[1] == Null && OSPosition[2] == Null)
   {
      if(OBPosition[0] == Above_Mean && OBPosition[1] == Above_Mean && OBPosition[2] == Above_Mean)
         sell_reversal_signal++;
         
      else if(OBPosition[0] == Above_Mean && OBPosition[1] == Above_Mean && OBPosition[2] == Plus_2_StdDev)
         sell_reversal_signal++;
      
      else if(OBPosition[0] == Above_Mean && OBPosition[1] == Above_Mean && OBPosition[2] == Below_Mean)
         sell_reversal_signal++;
      
      else if(OBPosition[0] == Above_Mean && OBPosition[1] <= Plus_2_StdDev && OBPosition[2] <= Plus_2_StdDev)
         sell_reversal_signal++;
      
      else if(OBPosition[0] == Above_Mean && OBPosition[1] == Above_Mean && OBPosition[2] == Null)
         sell_reversal_signal++;     
   }
   
   total_reversal_signal++;
   
   
   // Buy Bands
   if(BollingerPostion[0] == Below_Mean && BollingerPostion[1] == Below_Mean && BollingerPostion[2] >= Minus_2_StdDev)
      buy_reversal_signal++;
      
   else if(BollingerPostion[1] > BollingerPostion[0] && BollingerPostion[1] >= Minus_2_StdDev && BollingerPostion[2] == Below_Mean)
      buy_reversal_signal++;
   
   else if(BollingerPostion[0] == Below_Mean && BollingerPostion[1] == Minus_2_StdDev && BollingerPostion[2] == Below_Mean)
      buy_reversal_signal++;
   
   
   // Sell Bands
   if(BollingerPostion[0] == Above_Mean && BollingerPostion[1] == Above_Mean && BollingerPostion[2] >= Plus_2_StdDev)
      sell_reversal_signal++;
   
   else if(BollingerPostion[1] <= BollingerPostion[0] && BollingerPostion[1] >= Plus_2_StdDev && BollingerPostion[2] == Above_Mean)
      sell_reversal_signal++;
   
   else if(BollingerPostion[0] == Above_Mean && BollingerPostion[1] >= Plus_2_StdDev && BollingerPostion[2] == Above_Mean)
      sell_reversal_signal++;
      
   total_reversal_signal++;
   
   
   // setting the probability
   m_BuyReversalProbability[TimeFrameIndex][Shift] = NormalizeDouble((buy_reversal_signal/total_reversal_signal)*100, 2);
   m_SellReversalProbability[TimeFrameIndex][Shift] = NormalizeDouble((sell_reversal_signal/total_reversal_signal)*100, 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ReversalProbability::GetTotalBuyReversalProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_BuyReversalProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ReversalProbability::GetTotalSellReversalProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_SellReversalProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
