//+------------------------------------------------------------------+
//|                                                  Probability.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\hash.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\MarketCondition.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\ContinuationProbability.mqh"
#include "..\iForexDNA\ReversalProbability.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class Probability
{
   private:
      BaseIndicator     *m_ProbabilityIndexes[];
      CandleStickArray  *m_CandleStickPriceAction;
      IndicatorsHelper  *m_Indicators;
      AdvanceIndicator  *m_AdvanceIndicators;


      
      bool              AddIndicatorToArray(BaseIndicator *ProbabilityIndex);

   
   public:
                        Probability(CandleStickArray *pCandleStickPriceAction, IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicator);
                        ~Probability();
                        
      bool              Init();
      void              OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      
      
      ContinuationProbability     *GetContinautionProbability();
      ReversalProbability         *GetReversalProbability();
      
     

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Probability::Probability(CandleStickArray *pCandleStickPriceAction, IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicator)
{
   m_Indicators = NULL;
   m_AdvanceIndicators = NULL;
   m_CandleStickPriceAction = NULL;

   if(pCandleStickPriceAction==NULL)
      LogError(__FUNCTION__,"Candlestick Price Action pointer is NULL");
   else
      m_CandleStickPriceAction=pCandleStickPriceAction;

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

Probability::~Probability()
{
   for(int i =0; i < ArraySize(m_ProbabilityIndexes); i++)
   {
      if(CheckPointer(m_ProbabilityIndexes[i]) != POINTER_INVALID)
         delete(m_ProbabilityIndexes[i]);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Probability::Init(){
   if(!AddIndicatorToArray(new ContinuationProbability(m_CandleStickPriceAction, m_Indicators, m_AdvanceIndicators))
   || !AddIndicatorToArray(new ReversalProbability(m_CandleStickPriceAction, m_Indicators, m_AdvanceIndicators))
   )
   return false;
   
   
   int arraySize=ArraySize(m_ProbabilityIndexes);
   for(int i=0; i<arraySize; i++)
     {
      if(i<0 || i>=arraySize)
        {
         LogError(__FUNCTION__,"Indicators array out of sync.");
         return false;
        }
      string s=typename(m_ProbabilityIndexes[i]);
      if(!m_ProbabilityIndexes[i].Init())
         return false;
     }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Probability::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   int arraySize=ArraySize(m_ProbabilityIndexes);
   
   for(int i=0; i<arraySize; i++)
   {
      m_ProbabilityIndexes[i].OnUpdate(TimeFrameIndex,IsNewBar);
   }
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ReversalProbability *Probability::GetReversalProbability(){
   int arraySize = ArraySize(m_ProbabilityIndexes);
   for(int i =0;i < arraySize; i++){
      ReversalProbability *pRes = dynamic_cast<ReversalProbability *>(m_ProbabilityIndexes[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Reversal Probability Index not found.");
   return NULL;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ContinuationProbability *Probability::GetContinautionProbability(){
   int arraySize = ArraySize(m_ProbabilityIndexes);
   for(int i =0;i < arraySize; i++){
      ContinuationProbability *pRes = dynamic_cast<ContinuationProbability *>(m_ProbabilityIndexes[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Continuation Probability Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Probability::AddIndicatorToArray(BaseIndicator *ProbabilityIndex)
  {
   if(CheckPointer(ProbabilityIndex)==POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Invalid Indicator pointer.");
      return false;
     }

   int arraySize=ArraySize(m_ProbabilityIndexes);

   if(ArrayResize(m_ProbabilityIndexes,arraySize+1)<0)
     {
      LogError(__FUNCTION__,"Array resize fail.");
      return false;
     }

   if(CheckPointer(m_ProbabilityIndexes[arraySize])!=POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Indicators array out of sync.");
      return false;
     }

   m_ProbabilityIndexes[arraySize]=ProbabilityIndex;
   return true;
  }
  
//+------------------------------------------------------------------+