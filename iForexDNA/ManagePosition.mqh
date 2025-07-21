//+------------------------------------------------------------------+
//|                                                    iForexDNA.mq4 |
//|                                          Copyright 2016, iPayDNA |
//|                                               http://ipaydna.biz |
//+------------------------------------------------------------------+

#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AccountManager.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MarketCondition.mqh"
#include "..\iForexDNA\OpenPosition.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ManagePosition
{
    private:
        CandleStickArray                *m_CandleStick;
        IndicatorsHelper                *m_Indicators;
        AdvanceIndicator                *m_AdvIndicators;
        MarketCondition                 *m_MarketCondition;
        AccountManager                  *m_AccountManager;
        OpenPosition                    *m_OpenPosition;
        
        datetime                        m_LastUpdateDatetime;


        // Managing all the Strategy's Positions
        void                            ManageBuyPositions();
        void                            ManageSellPositions();


    public:
                                        ManagePosition(CandleStickArray *pCandleStick, AccountManager *pAccountManager, IndicatorsHelper *pIndiactors, AdvanceIndicator *pAdvIndicators, MarketCondition *pMarketCondition, OpenPosition *pOpenPosition);
                                        ~ManagePosition();

        bool                            Init();
        void                            OnUpdate();


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ManagePosition::ManagePosition(CandleStickArray *pCandleStick, AccountManager *pAccountManager, IndicatorsHelper *pIndiactors, AdvanceIndicator *pAdvIndicators, MarketCondition *pMarketCondition, OpenPosition *pOpenPosition)
{
   m_CandleStick=NULL;
   m_AccountManager=NULL;
   m_Indicators=NULL;
   m_AdvIndicators=NULL;
   m_MarketCondition=NULL;
   m_OpenPosition=NULL;

   if(pCandleStick==NULL)
      LogError(__FUNCTION__,"pCandleStick pointer is NULL");
   else
      m_CandleStick=pCandleStick;

   if(pAccountManager==NULL)
      LogError(__FUNCTION__,"pAccountManager pointer is NULL");
   else
      m_AccountManager=pAccountManager;
      
   if(pIndiactors==NULL)
      LogError(__FUNCTION__,"pIndicators pointer is NULL");
   else
      m_Indicators=pIndiactors;
      
   if(pAdvIndicators==NULL)
      LogError(__FUNCTION__,"pAdvanceIndicators pointer is NULL");
   else
      m_AdvIndicators=pAdvIndicators;

   if(pMarketCondition==NULL)
      LogError(__FUNCTION__,"MarketCondition pointer is NULL");
   else
      m_MarketCondition=pMarketCondition;

   if(pOpenPosition==NULL)
      LogError(__FUNCTION__,"OpenPosition pointer is NULL");
   else
      m_OpenPosition=pOpenPosition;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ManagePosition::~ManagePosition()
{

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  ManagePosition::Init()
{
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManagePosition::OnUpdate()
{
   datetime curtime = TimeCurrent();

   if(curtime-m_LastUpdateDatetime >= 60)
   {
      ManageBuyPositions();   
      ManageSellPositions();
   
      m_LastUpdateDatetime = curtime;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ManagePosition::ManageBuyPositions(void)
{
   for(int i = 0; i < m_AccountManager.GetTotalNumberOfOpenBuyOrders(); i++)
   {
      Order *order = m_AccountManager.GetBuyOrderByIndex(i);
      m_OpenPosition.GetCSVStrategy().BuyOrderManagement(order);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ManagePosition::ManageSellPositions(void)
{
   for(int i = 0; i < m_AccountManager.GetTotalNumberOfOpenSellOrders(); i++)
   {
      Order *order = m_AccountManager.GetSellOrderByIndex(i);
      m_OpenPosition.GetCSVStrategy().SellOrderManagement(order);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void ManagePosition::ManageBuyPositions()
{
   // Insert your Strategy here for management
   bool isGuanReversalStrategyExists = false, isGuanBreakoutExists = false, isGuanTrendingExists = false, isGuanContinuationExists = false, isGuanFakeoutExists = false;

   for(int i =0; i < m_AccountManager.GetTotalNumberOfOpenBuyOrders(); i++)
   {
      Order *order = m_AccountManager.GetBuyOrderByIndex(i);
      int strategy_magic_number = order.GetMagicNumber();

      if(strategy_magic_number == GUAN_REVERSAL_BUY_STRATEGY)
      {
         isGuanReversalStrategyExists = true;
         m_OpenPosition.GetGuanStrategy().BuyOrderManagement(order);    // Manage the order if exists
      }
      else if(strategy_magic_number == GUAN_CONTINUATION_BUY_STRATEGY)
      {
         isGuanContinuationExists = true;
         m_OpenPosition.GetGuanStrategy().BuyOrderManagement(order);    // Manage the order if exists
      }
      else if(strategy_magic_number == GUAN_TRENDING_BUY_STRATEGY)
      {
         isGuanTrendingExists = true;
         m_OpenPosition.GetGuanStrategy().BuyOrderManagement(order);    // Manage the order if exists
      }
      else if(strategy_magic_number == GUAN_BREAKOUT_BUY_STRATEGY)
      {
         isGuanBreakoutExists = true;
         m_OpenPosition.GetGuanStrategy().BuyOrderManagement(order);    // Manage the order if exists
      }
      else if(strategy_magic_number == GUAN_FAKEOUT_BUY_STRATEGY)
      {
         isGuanFakeoutExists = true;
         m_OpenPosition.GetGuanStrategy().BuyOrderManagement(order);    // Manage the order if exists
      }
   }


   // Reset Strategy Status Based on the Order Status
   if(!isGuanReversalStrategyExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Reversal))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Reversal, Filter_2);
            
         } 
         
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Reversal, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Reversal, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Reversal, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Reversal);
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      if(!m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Reversal))
      {
         // Filter 1 checking 
         if(!m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_1)
         && m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Reversal, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Reversal, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Reversal, Filter_4, "----");
         }
      }
   }


   // Breakout Management
   if(!isGuanBreakoutExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Breakout))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Breakout, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Breakout, Filter_2);
         }  
      
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Breakout, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Breakout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Breakout, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Breakout);
      }
      
      
      // Still in the filtering process
      if(!m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Breakout))
      {
         // Filter 1 checking 
         if(!m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_1)
         && m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Breakout, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Breakout, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Breakout, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Breakout, Filter_4, "----");
         }
      }
   }


   // Trending Management
   if(!isGuanTrendingExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Trend))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_2);
            //m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Trend, Filter_1);           // Does not reset Comment because may want to know what are the previous trend to follow
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Trend, Filter_2);
         }  
         
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Trend, Filter_4);

         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Trend, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Trend, Filter_4);

         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      if(!m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Trend))
      {     
         // Filter 1 checking 
         if(!m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_1)
         && m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_1)
         )
         {
            // m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Trend, Filter_1, "----");       // Does not reset Comment because may want to know what are the previous trend to follow
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Trend, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Trend, Filter_4, "----");
         }
      }
   }


   // Continuation Management
   if(!isGuanContinuationExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Continuation))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Continuation, Filter_2);
         }  
         
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyFlag(Type_Continuation, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Continuation, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Continuation, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Continuation);
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Continuation))
      {
         // Filter 1 checking 
         if(!m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_1)
         && m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Continuation, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Continuation, Filter_4, "----");
         }
      }
   }


   // Fakeout Management
   if(!isGuanFakeoutExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Fakeout))
      {
         m_OpenPosition.GetGuanStrategy().ResetAllFilterBuyFlag(Type_Fakeout);
         
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Fakeout, Filter_1);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Fakeout, Filter_2); 
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Fakeout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterBuyComment(Type_Fakeout, Filter_4);
         
         m_OpenPosition.GetGuanStrategy().ResetBuyOrder(Type_Fakeout);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenBuyFlag(Type_Fakeout))
      {
         // Filter 1 checking 
         if(!m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_1)
         && m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Fakeout, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Fakeout, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Fakeout, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Buy_Comments(Type_Fakeout, Filter_4, "----");
         }
      }
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ManagePosition::ManageSellPositions()
{
   // Insert your Strategy here for management
   bool isGuanReversalStrategyExists = false, isGuanBreakoutExists = false, isGuanTrendingExists = false, isGuanContinuationExists = false, isGuanFakeoutExists = false;

   for(int i =0; i < m_AccountManager.GetTotalNumberOfOpenSellOrders(); i++)
   {
      Order *order = m_AccountManager.GetSellOrderByIndex(i);
      int strategy_magic_number = order.GetMagicNumber();

      // Manage sell orders

      if(strategy_magic_number == GUAN_REVERSAL_SELL_STRATEGY)
      {
         isGuanReversalStrategyExists = true;
         m_OpenPosition.GetGuanStrategy().SellOrderManagement(order);
      }
      else if(strategy_magic_number == GUAN_CONTINUATION_SELL_STRATEGY)
      {
         isGuanContinuationExists = true;
         m_OpenPosition.GetGuanStrategy().SellOrderManagement(order);
      }
      else if(strategy_magic_number == GUAN_TRENDING_SELL_STRATEGY)
      {
         isGuanTrendingExists = true;
         m_OpenPosition.GetGuanStrategy().SellOrderManagement(order);
      }
      else if(strategy_magic_number == GUAN_BREAKOUT_SELL_STRATEGY)
      {
         isGuanBreakoutExists = true;
         m_OpenPosition.GetGuanStrategy().SellOrderManagement(order);
      }
      else if(strategy_magic_number == GUAN_FAKEOUT_SELL_STRATEGY)
      {
         isGuanFakeoutExists = true;
         m_OpenPosition.GetGuanStrategy().SellOrderManagement(order);
      }
   }

   // Reset Strategy Status Based on the Order Status
   if(!isGuanReversalStrategyExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Reversal))
      {      
         if(m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Reversal, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Reversal, Filter_2);
         }  
         
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Reversal, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Reversal, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Reversal, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Reversal);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Reversal))
      {      
         // Filter 1 checking 
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_1)
         && !m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Reversal, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Reversal, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Reversal, Filter_4, "----");
         }
      }
   }


   // Breakout Management
   if(!isGuanBreakoutExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Breakout))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_1))
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Breakout, Filter_2);
         
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Breakout, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Breakout, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Breakout, Filter_3);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Breakout, Filter_4);
         }  
         
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Breakout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Breakout, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Breakout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Breakout, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Breakout);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Breakout))
      {
         // Filter 1 checking 
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_1)
         && !m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Breakout, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Breakout, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Breakout, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Breakout, Filter_4, "----");
         }
      }
   }


   // Trending Management
   if(!isGuanTrendingExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Trend))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_2);
            //m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Trend, Filter_1);        // Does not reset Comment because may want to know what are the previous trend to follow 
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Trend, Filter_2);
         }  
         
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Trend, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Trend, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Trend, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Trend))
      {      
         // Filter 1 checking 
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_1)
         && !m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_1)
         )
         {
            // m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Trend, Filter_1, "----");      // Does not reset Comment because may want to know what are the previous trend to follow
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Trend, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Trend, Filter_4, "----");
         }
      }
   }


   // Continuation Management
   if(!isGuanContinuationExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Continuation))
      {
         if(m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_1))
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_2);
         }
         else
         {
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_2);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Continuation, Filter_1);
            m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Continuation, Filter_2);
         }
         
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellFlag(Type_Continuation, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Continuation, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Continuation, Filter_4);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Continuation);
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Trend);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Continuation))
      {
         // Filter 1 checking 
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_1)
         && !m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Continuation, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Continuation, Filter_4, "----");
         }
      }
   }
   
   // Continuation Management
   if(!isGuanFakeoutExists)
   {
      // Order was existed
      if(m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Fakeout))
      {
         m_OpenPosition.GetGuanStrategy().ResetAllFilterSellFlag(Type_Fakeout);
         
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Fakeout, Filter_1);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Fakeout, Filter_2);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Fakeout, Filter_3);
         m_OpenPosition.GetGuanStrategy().ResetFilterSellComment(Type_Fakeout, Filter_4);
         
         m_OpenPosition.GetGuanStrategy().ResetSellOrder(Type_Fakeout);
      }
      
      
      // Still in the filtering process
      else if(!m_OpenPosition.GetGuanStrategy().GetOpenSellFlag(Type_Fakeout))
      {
         // Filter 1 checking 
         if(m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_1)
         && !m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout, Filter_1)
         )
         {
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Fakeout, Filter_1, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Fakeout, Filter_2, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Fakeout, Filter_3, "----");
            m_OpenPosition.GetGuanStrategy().Shift_Filter_Sell_Comments(Type_Fakeout, Filter_4, "----");
         }
      }
   }
  
}

*/

//+------------------------------------------------------------------+