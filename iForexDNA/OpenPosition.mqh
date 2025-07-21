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
#include "..\iForexDNA\hash.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\AccountManager.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MarketCondition.mqh"
#include "..\iForexDNA\Strategy\BaseStrategy.mqh"
#include "..\iForexDNA\Probability.mqh"


#include "..\iForexDNA\Strategy\CSVStrategy.mqh"
//#include "..\iForexDNA\Strategy\GuanStrategy.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class OpenPosition
{
   private:      
        IndicatorsHelper        *m_Indicators;
        AdvanceIndicator        *m_AdvIndicators;
        AccountManager          *m_AccountManager;     
        CandleStickArray        *m_CandleStick;
        MarketCondition         *m_MarketCondition;
        Probability             *m_Probability;

        // Guan Strategy (For testing #26 Sept)
        //GuanStrategy             *m_GuanStrategy;
        CSVStrategy                 *m_CSVStrategy;
        

   public:
                                 OpenPosition(IndicatorsHelper *pIndicators, AccountManager *pAccountManager, AdvanceIndicator *pAdvIndicators, CandleStickArray *pCandleStick, MarketCondition *pMarketCondition, Probability *pProbability);
                                 ~OpenPosition();
                                 
        bool                     Init();
        void                     OnUpdate();
        
       
        // Breakout Getter
        //GuanStrategy                      *GetGuanStrategy(){return m_GuanStrategy;};
        CSVStrategy                          *GetCSVStrategy(){return m_CSVStrategy;};

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OpenPosition::OpenPosition(IndicatorsHelper *pIndicators ,AccountManager *pAccountManager, AdvanceIndicator *pAdvIndicators, CandleStickArray *pCandleStick, MarketCondition *pMarketCondition, Probability *pProbability)
{
   m_Indicators=NULL;
   m_AdvIndicators=NULL;
   m_AccountManager=NULL;
   m_MarketCondition=NULL;
   m_Probability=NULL;

   if(pAccountManager==NULL)
      LogError(__FUNCTION__,"AccountManager pointer is NULL");
   else
      m_AccountManager=pAccountManager;
      
   if(pIndicators==NULL)
      LogError(__FUNCTION__,"IndicatorHelper pointer is NULL");
   else
      m_Indicators=pIndicators;
   
   if(pAdvIndicators==NULL)
      LogError(__FUNCTION__,"AdvIndicators pointer is NULL");
   else
      m_AdvIndicators=pAdvIndicators;
      
   if(pAdvIndicators==NULL)
      LogError(__FUNCTION__,"CandleStickArray pointer is NULL");
   else
      m_CandleStick=pCandleStick;

   if(pMarketCondition==NULL)
      LogError(__FUNCTION__,"MarketCondition pointer is NULL");
   else
      m_MarketCondition=pMarketCondition;

   if(pProbability==NULL)
      LogError(__FUNCTION__,"Probability pointer is NULL");
   else
      m_Probability=pProbability;
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OpenPosition::~OpenPosition()
{
    delete(m_CSVStrategy);
    m_CSVStrategy=NULL;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OpenPosition::Init()
{
   // Guan Strategy (Testing)
   m_CSVStrategy = new CSVStrategy(m_Indicators, m_AdvIndicators, m_AccountManager);
   
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OpenPosition::OnUpdate()
{
   if(ALLOW_OPEN_TRADE && (IsTokyoMarketOpen() || IsLondonMarketOpen() || IsNewYorkMarketOpen()))
      m_CSVStrategy.OnUpdate();
}

//+------------------------------------------------------------------+