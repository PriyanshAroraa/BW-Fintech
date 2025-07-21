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
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AccountManager.mqh"
#include "..\iForexDNA\Divergence.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ClosePosition
  {
private:
   CandleStickArray *m_CSAnalysis;
   AccountManager   *m_AccountManager;
   IndicatorsHelper *m_Indicators;
   Divergence       *m_Divergence;
   
   int               Channel_Count;
   
   ENUM_TIMEFRAMES timeFrameENUM;
   

public:
   ClosePosition(CandleStickArray *pCSAnalysis,AccountManager *pAccountManager,IndicatorsHelper *pIndicators, Divergence *pDivergence);
   ~ClosePosition();
   bool              Init();
   
   void              OnUpdate();

private:
   
   bool              CloseBuyPosition();
   bool              CloseSellPosition();
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ClosePosition::ClosePosition(CandleStickArray *pCSAnalysis,AccountManager *pAccountManager,IndicatorsHelper *pIndicators, Divergence *pDivergence)
  {

   m_CSAnalysis=NULL;
   m_AccountManager=NULL;
   m_Indicators=NULL;
   m_Divergence=NULL;
   

   if(pCSAnalysis==NULL)
      LogError(__FUNCTION__,"CSAnalysis pointer is NULL");
   else
      m_CSAnalysis=pCSAnalysis;

   if(pAccountManager==NULL)
      LogError(__FUNCTION__,"AccountManager pointer is NULL");
   else
      m_AccountManager=pAccountManager;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
      
   if(pDivergence==NULL)
      LogError(__FUNCTION__,"Divergence pointer is NULL");
   else
      m_Divergence=pDivergence;
      

   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ClosePosition::~ClosePosition()
  {
   
  }
//+------------------------------------------------------------------+
//| OpenPOsition Function                                   |
//+------------------------------------------------------------------+
bool ClosePosition::Init()
{
   /*
   if(IsTesting())
      Position_Shift = 1;
   */
      
   return true;
}
//+------------------------------------------------------------------+
//| OnUpdate Function                                   |
//+------------------------------------------------------------------+
void ClosePosition::OnUpdate()
{
   /*
   if(m_AccountManager.GetTotalNumberOfOpenBuyOrders() > 0 && AllowCloseBuy)
   {
      CloseBuyPosition();
      AllowCloseBuy = false;
   }
   
   if(m_AccountManager.GetTotalNumberOfOpenSellOrders() > 0  && AllowCloseSell)
   {
      CloseSellPosition();
      AllowCloseSell = false;
   }
   */
}


//+------------------------------------------------------------------+
//| OpenBuyPosition Function                                         |
//+------------------------------------------------------------------+
bool ClosePosition::CloseBuyPosition()
{
   m_AccountManager.CloseAllOrders(Symbol(), OP_BUY);
   
   return true;
}

//+------------------------------------------------------------------+
//| OpenSellPosition Function                                        |
//+------------------------------------------------------------------+
bool ClosePosition::CloseSellPosition()
{
   m_AccountManager.CloseAllOrders(Symbol(), OP_SELL);
   return true;
}


