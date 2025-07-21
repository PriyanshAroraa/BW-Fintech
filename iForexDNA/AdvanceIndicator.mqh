//+------------------------------------------------------------------+
//|                                             AdvanceIndicator.mqh |
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
#include "..\iForexDNA\VolatilityIndex.mqh"
#include "..\iForexDNA\BullBearIndex.mqh"
#include "..\iForexDNA\OBOSIndex.mqh"
#include "..\iForexDNA\IndicatorsTrigger.mqh"
#include "..\iForexDNA\LineTrigger.mqh"
#include "..\iForexDNA\DivergenceIndex.mqh"
#include "..\iForexDNA\ZigZagAdvIndicator.mqh"
#include "..\iForexDNA\MarketMomentum.mqh"
#include "..\iForexDNA\TrendIndexes.mqh"
#include "..\iForexDNA\Middleline.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class AdvanceIndicator{
   private:
      BaseIndicator     *m_AdvIndicators[];
      IndicatorsHelper  *m_Indicators;
            
      bool              AddIndicatorToArray(BaseIndicator *Indicator);
   
   public:
                        AdvanceIndicator(IndicatorsHelper *pIndicators);
                        ~AdvanceIndicator();
                        
      bool              Init();
      void              OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      
      
      BullBearIndex        *GetBullBear();
      VolatilityIndex      *GetVolatility();
      OBOSIndex            *GetOBOS();
      IndicatorsTrigger    *GetIndicatorsTrigger();
      LineTrigger          *GetLineTrigger();
      DivergenceIndex      *GetDivergenceIndex();
      ZigZagAdvIndicator   *GetZigZagAdvIndicator();
      MarketMomentum       *GetMarketMomentum();
      TrendIndexes         *GetTrendIndexes();
      Middleline           *GetMiddleLine();

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

AdvanceIndicator::AdvanceIndicator(IndicatorsHelper *pIndicators)
{
   m_Indicators=NULL;
   
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

AdvanceIndicator::~AdvanceIndicator(){
   for(int i =0; i < ArraySize(m_AdvIndicators); i++)
   {
      if(CheckPointer(m_AdvIndicators[i]) != POINTER_INVALID)
         delete(m_AdvIndicators[i]);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool AdvanceIndicator::Init(){
   if(!AddIndicatorToArray(new BullBearIndex(m_Indicators))
   || !AddIndicatorToArray(new VolatilityIndex(m_Indicators))
   || !AddIndicatorToArray(new IndicatorsTrigger(m_Indicators))
   || !AddIndicatorToArray(new LineTrigger(m_Indicators))
   || !AddIndicatorToArray(new OBOSIndex(m_Indicators))
   || !AddIndicatorToArray(new DivergenceIndex(m_Indicators))
   || !AddIndicatorToArray(new ZigZagAdvIndicator(m_Indicators))
   || !AddIndicatorToArray(new MarketMomentum(m_Indicators))
   || !AddIndicatorToArray(new TrendIndexes(m_Indicators))
   || !AddIndicatorToArray(new Middleline(m_Indicators))
   )
   return false;
   
   
   int arraySize=ArraySize(m_AdvIndicators);
   for(int i=0; i<arraySize; i++)
     {
      if(i<0 || i>=arraySize)
        {
         LogError(__FUNCTION__,"Indicators array out of sync.");
         return false;
        }
      string s=typename(m_AdvIndicators[i]);
      if(!m_AdvIndicators[i].Init())
         return false;
     }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void AdvanceIndicator::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   int arraySize=ArraySize(m_AdvIndicators);
   
   for(int i=0; i<arraySize; i++)
   {
      m_AdvIndicators[i].OnUpdate(TimeFrameIndex,IsNewBar);
   }
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearIndex *AdvanceIndicator::GetBullBear()
{
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      BullBearIndex *pRes = dynamic_cast<BullBearIndex *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"BullBear Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolatilityIndex *AdvanceIndicator::GetVolatility(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      VolatilityIndex *pRes = dynamic_cast<VolatilityIndex *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Volatility Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OBOSIndex *AdvanceIndicator::GetOBOS(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      OBOSIndex *pRes = dynamic_cast<OBOSIndex *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"OBOS not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

DivergenceIndex *AdvanceIndicator::GetDivergenceIndex(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      DivergenceIndex *pRes = dynamic_cast<DivergenceIndex *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Divergence Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZigZagAdvIndicator *AdvanceIndicator::GetZigZagAdvIndicator()
{
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      ZigZagAdvIndicator *pRes = dynamic_cast<ZigZagAdvIndicator *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"ZigZag AdvIndicator Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

IndicatorsTrigger *AdvanceIndicator::GetIndicatorsTrigger(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      IndicatorsTrigger *pRes = dynamic_cast<IndicatorsTrigger *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Indicators Trigger Index not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

LineTrigger *AdvanceIndicator::GetLineTrigger(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      LineTrigger *pRes = dynamic_cast<LineTrigger *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Line Trigger not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketMomentum *AdvanceIndicator::GetMarketMomentum(){
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      MarketMomentum *pRes = dynamic_cast<MarketMomentum *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Market Momentum not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TrendIndexes *AdvanceIndicator::GetTrendIndexes()
{
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      TrendIndexes *pRes = dynamic_cast<TrendIndexes *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Trend Indexes not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Middleline *AdvanceIndicator::GetMiddleLine()
{
   int arraySize = ArraySize(m_AdvIndicators);
   for(int i =0;i < arraySize; i++){
      Middleline *pRes = dynamic_cast<Middleline *>(m_AdvIndicators[i]);
      
      if(pRes!=NULL)
         return pRes;
         
   }
   
   LogError(__FUNCTION__,"Middle Line not found.");
   return NULL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool AdvanceIndicator::AddIndicatorToArray(BaseIndicator *Indicator)
  {
   if(CheckPointer(Indicator)==POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Invalid Indicator pointer.");
      return false;
     }

   int arraySize=ArraySize(m_AdvIndicators);

   if(ArrayResize(m_AdvIndicators,arraySize+1)<0)
     {
      LogError(__FUNCTION__,"Array resize fail.");
      return false;
     }

   if(CheckPointer(m_AdvIndicators[arraySize])!=POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Indicators array out of sync.");
      return false;
     }

   m_AdvIndicators[arraySize]=Indicator;
   return true;
  }
  
//+------------------------------------------------------------------+