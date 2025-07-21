//+------------------------------------------------------------------+
//|                                      ContinuationProbability.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ContinuationProbability:public BaseIndicator
{
   private:
      CandleStickArray                    *m_CandleStickAnalysis;
      IndicatorsHelper                    *m_Indicators;
      AdvanceIndicator                    *m_AdvanceIndicators;
      
      double                              m_BuyContinuationProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];
      double                              m_SellContinuationProbability[ENUM_TIMEFRAMES_ARRAY_SIZE][PROBABILITY_INDEX_BUFFER_SIZE];

      void                                CalculateBuySellContinuationProbability(int TimeFrameIndex, int Shift);

   public:
                                          ContinuationProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators);
                                          ~ContinuationProbability();
      
      bool                                Init();
      void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                              GetBuyContinuationProbability(int TimeFrameIndex, int Shift){return m_BuyContinuationProbability[TimeFrameIndex][Shift];};
      double                              GetTotalBuyContinuationProbability(int Shift);

      double                              GetSellContinuationProbability(int TimeFrameIndex, int Shift){return m_SellContinuationProbability[TimeFrameIndex][Shift];};
      double                              GetTotalSellContinuationProbability(int Shift);
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ContinuationProbability::ContinuationProbability(CandleStickArray *pCandleStickAnalysis,IndicatorsHelper *pIndicators,AdvanceIndicator *pAdvanceIndicators)
:BaseIndicator("Continuation")
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

ContinuationProbability::~ContinuationProbability()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ContinuationProbability::Init()
{
   ArrayInitialize(m_BuyContinuationProbability, 0);
   ArrayInitialize(m_SellContinuationProbability, 0);
   
   for(int i =0 ; i< ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      for(int j = 0; j < PROBABILITY_INDEX_BUFFER_SIZE; j++)
         CalculateBuySellContinuationProbability(i, j);
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ContinuationProbability::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{

   if(IsNewBar)
   {
      for(int j = PROBABILITY_INDEX_BUFFER_SIZE-1; j > 0; j--)
      {
         m_BuyContinuationProbability[TimeFrameIndex][j] = m_BuyContinuationProbability[TimeFrameIndex][j-1];
         m_SellContinuationProbability[TimeFrameIndex][j] = m_SellContinuationProbability[TimeFrameIndex][j-1];
      }
   }
   
   CalculateBuySellContinuationProbability(TimeFrameIndex, 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void ContinuationProbability::CalculateBuySellContinuationProbability(int TimeFrameIndex, int Shift)
{
  
   // PUT YOUR LOGIC HERE FOR CONTINUATION PROBABILITY CALCULATION


/*

   // setting the probability
   m_BuyContinuationProbability[TimeFrameIndex][Shift] = NormalizeDouble((buy_reversal_signal/total_reversal_signal)*100, 2);
   m_SellContinuationProbability[TimeFrameIndex][Shift] = NormalizeDouble((sell_reversal_signal/total_reversal_signal)*100, 2);
   
*/

   return;

   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ContinuationProbability::GetTotalBuyContinuationProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_BuyContinuationProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ContinuationProbability::GetTotalSellContinuationProbability(int Shift)
{
   double total=0;
   
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      total+=m_SellContinuationProbability[i][Shift];
      
   return total;
   
}

//+------------------------------------------------------------------+
