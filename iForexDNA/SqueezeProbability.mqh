//+------------------------------------------------------------------+
//|                                                      Squeeze.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
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

class SqueezeProbability:public BaseIndicator
{
   private:
      CandleStickArray                    *m_CandleStickAnalysis;
      IndicatorsHelper                    *m_Indicators;
      AdvanceIndicator                    *m_AdvanceIndicators;
      MarketCondition                     *m_MarketCondition;
      
      double                              m_BuySqueezeProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];
      double                              m_SellSqueezeProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];

      void                                CalculateBuySellSqueezeProbability(int TimeFrameIndex, int Shift);

   public:
                                          SqueezeProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators, MarketCondition *pMarketCondition);
                                          ~SqueezeProbability();
      
      bool                                Init();
      void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                              GetBuySqueezeProbability(int TimeFrameIndex, int Shift){return m_BuySqueezeProbability[TimeFrameIndex][Shift];};
      double                              GetTotalBuySqueezeProbability(int Shift);

      double                              GetSellSqueezeProbability(int TimeFrameIndex, int Shift){return m_SellSqueezeProbability[TimeFrameIndex][Shift];};
      double                              GetTotalSellSqueezeProbability(int Shift);
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

SqueezeProbability::SqueezeProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators,AdvanceIndicator *pAdvanceIndicators,MarketCondition *pMarketCondition)
:BaseIndicator("Continuation")
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
      LogError(__FUNCTION__,"MarketCondition pointer is NULL");
   else
      m_MarketCondition=pMarketCondition;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

SqueezeProbability::~SqueezeProbability()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool SqueezeProbability::Init()
{
   ArrayInitialize(m_BuySqueezeProbability, 0);
   ArrayInitialize(m_SellSqueezeProbability, 0);
   
   for(int i =0 ; i< ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      for(int j = 0; j < PROBABILITY_INDEX_BUFFER_SIZE; j++)
         CalculateBuySellSqueezeProbability(i, j);
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SqueezeProbability::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{

   if(IsNewBar)
   {
      for(int j = PROBABILITY_INDEX_BUFFER_SIZE-1; j > 0; j--)
      {
         m_BuySqueezeProbability[TimeFrameIndex][j] = m_BuySqueezeProbability[TimeFrameIndex][j-1];
         m_SellSqueezeProbability[TimeFrameIndex][j] = m_SellSqueezeProbability[TimeFrameIndex][j-1];
      }
   }
   
   CalculateBuySellSqueezeProbability(TimeFrameIndex, 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void SqueezeProbability::CalculateBuySellSqueezeProbability(int TimeFrameIndex, int Shift)
{
  
   // PUT YOUR LOGIC HERE FOR CONTINUATION PROBABILITY CALCULATION


/*

   // setting the probability
   m_BuySqueezeProbability[TimeFrameIndex][Shift] = NormalizeDouble((buy_reversal_signal/total_reversal_signal)*100, 2);
   m_SellSqueezeProbability[TimeFrameIndex][Shift] = NormalizeDouble((sell_reversal_signal/total_reversal_signal)*100, 2);
   
*/

   return;

   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double SqueezeProbability::GetTotalBuySqueezeProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_BuySqueezeProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double SqueezeProbability::GetTotalSellSqueezeProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_SellSqueezeProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
