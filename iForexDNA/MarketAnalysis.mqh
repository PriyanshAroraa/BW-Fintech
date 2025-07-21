//+------------------------------------------------------------------+
//|                                                 OpenPosition.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\GraphicTool.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class MarketAnalysis
{
   private:
      IndicatorsHelper        *m_Indicators;
      AdvanceIndicator        *m_AdvIndicators;
      
      ENUM_MARKET_BIAS        m_MarketBias[MARKET_CONDITION_ARRAY_SIZE];

      void                    OnUpdateMarketBias(int Shift); 
      
   public:
                              MarketAnalysis(IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicator);
                              ~MarketAnalysis();

      bool                    Init();
      void                    OnUpdate();
      
      ENUM_MARKET_BIAS        GetMarketBias(int Shift);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketAnalysis::MarketAnalysis(IndicatorsHelper *pIndicators,AdvanceIndicator *pAdvanceIndicator)
{
   m_Indicators=NULL;
   m_AdvIndicators=NULL;
   
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"IndicatorHelper pointer is NULL");
   else
      m_Indicators=pIndicators;
   
   if(pAdvanceIndicator==NULL)
      LogError(__FUNCTION__,"AdvIndicators pointer is NULL");
   else
      m_AdvIndicators=pAdvanceIndicator;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MarketAnalysis::~MarketAnalysis()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MarketAnalysis::Init()
{
   for(int i =0 ; i < MARKET_CONDITION_ARRAY_SIZE; i++)
   {
      OnUpdateMarketBias(i);  
   }  
         
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketAnalysis::OnUpdate()
{
   if(isNewBar[2])
   {
      for(int i = MARKET_CONDITION_ARRAY_SIZE-1; i > 0; i--)
      {
         m_MarketBias[i] = m_MarketBias[i-1];
      }
   }
      
   OnUpdateMarketBias(0);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketAnalysis::OnUpdateMarketBias(int Shift)
{
   if(Shift < 0 || Shift >= MARKET_CONDITION_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "Market Bias array out of range.");
      return;
   }


   int dailybar=iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(), PERIOD_H4, Shift));


   double D1buymarketbias=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(3,dailybar);
   double D1sellmarketbias=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(3,dailybar);

   double H4buymarketbias=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(2,Shift);
   double H4sellmarketbias=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(2,Shift);

   if(D1buymarketbias > 50 && D1sellmarketbias < 50)
   {
      if(H4buymarketbias > 50)
         m_MarketBias[Shift]=StrongBull;
         
      else if(H4sellmarketbias > 50)         // D1 = Bull && H4 = Bear
         m_MarketBias[Shift]=WeakBull;
   }
   
   else if(D1sellmarketbias > 50 && D1buymarketbias < 50)
   {
      if(H4sellmarketbias > 50)
         m_MarketBias[Shift]=StrongBear;
         
      else if(H4buymarketbias > 50)         // D1 = Bull && H4 = Bear
         m_MarketBias[Shift]=WeakBear;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_MARKET_BIAS MarketAnalysis::GetMarketBias(int Shift)
{
   if(Shift < 0 || Shift >= MARKET_CONDITION_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "Current Market Bias array is out of range.");
      return NULL; 
   }
   
   return m_MarketBias[Shift];
}

//+------------------------------------------------------------------+