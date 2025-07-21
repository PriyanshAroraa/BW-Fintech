//+------------------------------------------------------------------+
//|                                                GuanStrategy.mqh  |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\ExternVariables.mqh"
#include "..\hash.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"
#include "..\AccountManager.mqh"
#include "..\IndicatorsHelper.mqh"
#include "..\AdvanceIndicator.mqh"
#include "..\MarketCondition.mqh"
#include "..\GraphicTool.mqh"
#include "BaseStrategy.mqh"
#include "..\..\Telegram\TelegramBot.mqh"
#include "..\Probability.mqh"



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class GuanStrategy:public BaseStrategy
{
    private:
        IndicatorsHelper            *m_Indicators;
        AdvanceIndicator            *m_AdvIndicators;
        AccountManager              *m_AccountManager;
        MarketCondition             *m_MarketCondition;
        CandleStickArray            *m_CandleStick;
        TelegramBot                 *m_TelegramBot;
        Probability                 *m_Probability;

        // Filters Flag
        bool                        Filter_Buy_Flag[Strategy_Number][Filter_Numbers];
        bool                        Filter_Sell_Flag[Strategy_Number][Filter_Numbers];

        string                      Filter_Buy_Comment[Strategy_Number][Filter_Numbers][Shift_Look_Back];
        string                      Filter_Sell_Comment[Strategy_Number][Filter_Numbers][Shift_Look_Back];
        
        // Open Order
        bool                        Open_Buy_Flag[Strategy_Number];
        bool                        Open_Sell_Flag[Strategy_Number];
        
        string                      Open_Buy_Comment[Strategy_Number][Shift_Look_Back];
        string                      Open_Sell_Comment[Strategy_Number][Shift_Look_Back];

        string                      Modify_Buy_Comment[Strategy_Number];
        string                      Modify_Sell_Comment[Strategy_Number];


        bool                        Close_Buy_Flag[Strategy_Number];
        bool                        Close_Sell_Flag[Strategy_Number];

        string                      Close_Buy_Comment[Strategy_Number];
        string                      Close_Sell_Comment[Strategy_Number];

        // Stop Strategies from ordering
        bool                        Stop_Buy_Flag[Strategy_Number];
        bool                        Stop_Sell_Flag[Strategy_Number];

        string                      Stop_Buy_Comment[Strategy_Number];
        string                      Stop_Sell_Comment[Strategy_Number];

        // Order Variables
        datetime                    Last_Buy_Order_Entry[Strategy_Number];
        datetime                    Last_Sell_Order_Entry[Strategy_Number];


        // Order Management Utils
        double                      Buy_HiddenStopLoss[Strategy_Number];
        double                      Sell_HiddenStopLoss[Strategy_Number];
        
        double                      Buy_HiddenTakeProfit[Strategy_Number];
        double                      Sell_HiddenTakeProfit[Strategy_Number];
        

    public:
                                    GuanStrategy(IndicatorsHelper *pIndicators,AccountManager *pAccountManager,AdvanceIndicator *pAdvIndicators,CandleStickArray *pCandleStick,
                                    MarketCondition *pMarketCondition, TelegramBot *pTelegramBot, Probability *pProbability);
                                    ~GuanStrategy();
         
         // Main Function
         void                       OnUpdate_Strategy();
         void                       Open_Orders(int Direction, int Strategy_Type);
         

         // int                         FindUniqueNeuralNetwork(int type_strategy);
        
         // Reversal & Trend
         void                       Reversal_Filter_1(int Shift);         
         bool                       Reversal_Filter_2(int Direction);
         bool                       Reversal_Filter_3(int Direction);
         bool                       Reversal_Filter_4(int Direction);
         

         // Trending Filters
         void                       Trend_Filter_1();
         bool                       Trend_Filter_2(int Direction);
         bool                       Trend_Filter_3(int Direction);
         bool                       Trend_Filter_4(int Direction);   
         

         // Continuation Filters
         void                       Continuation_Filter_1();
         bool                       Continuation_Filter_2(int Direction);
         bool                       Continuation_Filter_3(int Direction); 
         bool                       Continuation_Filter_4(int Direction);
           


         // Breakout
         void                       Breakout_Filter_1();
         int                        Breakout_Filter_2();
         bool                       Breakout_Filter_3(int Direction);
         bool                       Breakout_Filter_4(int Direction);


         // FakeOut
         int                        Fakeout_Filter_1();
         bool                       Fakeout_Filter_2(int Direction);
         bool                       Fakeout_Filter_3(int Direction);


         // Close Trade Logics
         bool                        Is_Close_Trade(int type_strategy, int Direction);
        
   
         
        // Stop Loss Management
        void                        BuyOrderManagement(Order *order);
        void                        SellOrderManagement(Order *order); 
        double                      GetNewStopLoss(int strategy_type, int Direction);
        
        string                      GetOrderZone(string order_comment);


        // Reset all the comment to "----"
        void                         Init_Comments();


         // Shifting Comments
         bool                       Shift_Filter_Buy_Comments(int type_strategy, int Filter_Number, string order_comment);
         bool                       Shift_Filter_Sell_Comments(int type_strategy, int Filter_Number, string order_comment);
         
         void                       Shift_Open_Buy_Comments(int type_strategy, string order_comment);
         void                       Shift_Open_Sell_Comments(int type_strategy, string order_comment);
         
         bool                       Shift_Close_Buy_Comments(int type_strategy, string order_comment);
         bool                       Shift_Close_Sell_Comments(int type_strategy, string order_comment);
         
         void                       Shift_Modify_Buy_Comments(int type_strategy, string order_comment);
         void                       Shift_Modify_Sell_Comments(int type_strategy, string order_comment);
         
         

        // -------------------   Getter Functions   -------------------

        // Filter Flags
        bool GetFilterBuyFlag(int filterType, int filterNumber) {
            return Filter_Buy_Flag[filterType][filterNumber];
        }

        bool GetFilterSellFlag(int filterType, int filterNumber) {
            return Filter_Sell_Flag[filterType][filterNumber];
        }

        // Filter Comments
        string GetFilterBuyComment(int filterType, int filterNumber, int shiftLookBack) {
            return Filter_Buy_Comment[filterType][filterNumber][shiftLookBack];
        }

        string GetFilterSellComment(int filterType, int filterNumber, int shiftLookBack) {
            return Filter_Sell_Comment[filterType][filterNumber][shiftLookBack];
        }

        // Open Order Flags
        bool GetOpenBuyFlag(int filterType) {
            return Open_Buy_Flag[filterType];
        }

        bool GetOpenSellFlag(int filterType) {
            return Open_Sell_Flag[filterType];
        }

        // Open Order Comments
        string GetOpenBuyComment(int filterType, int shiftLookBack) {
            return Open_Buy_Comment[filterType][shiftLookBack];
        }

        string GetOpenSellComment(int filterType, int shiftLookBack) {
            return Open_Sell_Comment[filterType][shiftLookBack];
        }

        // Modify Order Comments
        string GetModifyBuyComment(int filterType) {
            return Modify_Buy_Comment[filterType];
        }

        string GetModifySellComment(int filterType) {
            return Modify_Sell_Comment[filterType];
        }

        // Close Order Flags
        bool GetCloseBuyFlag(int filterType) {
            return Close_Buy_Flag[filterType];
        }

        bool GetCloseSellFlag(int filterType) {
            return Close_Sell_Flag[filterType];
        }

        // Close Order Comments
        string GetCloseBuyComment(int filterType) {
            return Close_Buy_Comment[filterType];
        }

        string GetCloseSellComment(int filterType) {
            return Close_Sell_Comment[filterType];
        }

        // Stop Order Flags
        bool GetStopBuyFlag(int filterType) {
            return Stop_Buy_Flag[filterType];
        }

        bool GetStopSellFlag(int filterType) {
            return Stop_Sell_Flag[filterType];
        }

        // Stop Order Comments
        string GetStopBuyComment(int filterType) {
            return Stop_Buy_Comment[filterType];
        }

        string GetStopSellComment(int filterType) {
            return Stop_Sell_Comment[filterType];
        }
        
        // Get Close order percentage
        double          GetBuyNumberOfOrderToClose(int type_strategy, string close_comment);
        double          GetSellNumberOfOrderToClose(int type_strategy, string close_comment);
        

        // Filter Buy ToolTip
        string                      GetFilterBuyToolTip(int type_strategy, int filter_number)
                                    {
                                       string   tmpstring = NULL; 
                                       for(int i = 0; i < Shift_Look_Back; i++)
                                       {
                                          tmpstring += (string)i+") "+Filter_Buy_Comment[type_strategy][filter_number][i]+"\n";
                                       }
                                       return tmpstring;
                                    };
        
        // Filter Sell ToolTip
        string                      GetFilterSellToolTip(int type_strategy, int filter_number)
                                    {
                                       string   tmpstring = NULL; 
                                       for(int i = 0; i < Shift_Look_Back; i++)
                                       {
                                          tmpstring += (string)i+") "+Filter_Sell_Comment[type_strategy][filter_number][i]+"\n";
                                       }
                                       return tmpstring;
                                    };

        // Filter Open Buy ToolTip
        string                      GetOpenBuyToolTip(int type_strategy)
                                    {
                                       string   tmpstring = NULL; 
                                       for(int i = 0; i < Shift_Look_Back; i++)
                                       {
                                          tmpstring += (string)i+") "+Open_Buy_Comment[type_strategy][i]+"\n";
                                       }
                                       return tmpstring;
                                    };

        // Filter Open Sell ToolTip
        string                      GetOpenSellToolTip(int type_strategy)
                                    {
                                       string   tmpstring = NULL; 
                                       for(int i = 0; i < Shift_Look_Back; i++)
                                       {
                                          tmpstring += (string)i+") "+Open_Sell_Comment[type_strategy][i]+"\n";
                                       }
                                       return tmpstring;
                                    };


        // -------------------  Reset Functions   -------------------
        void                        ResetAllFilterBuyFlag(int type_strategy){Filter_Buy_Flag[type_strategy][Filter_1]=false;Filter_Buy_Flag[type_strategy][Filter_2]=false;Filter_Buy_Flag[type_strategy][Filter_3]=false;Filter_Buy_Flag[type_strategy][Filter_4]=false;};
        void                        ResetAllFilterSellFlag(int type_strategy){Filter_Sell_Flag[type_strategy][Filter_1]=false;Filter_Sell_Flag[type_strategy][Filter_2]=false;Filter_Sell_Flag[type_strategy][Filter_3]=false;Filter_Sell_Flag[type_strategy][Filter_4]=false;};
         
        void                        ResetFilterBuyFlag(int type_strategy, int filter_number);
        void                        ResetFilterSellFlag(int type_strategy, int filter_number);
        
        void                        ResetFilterBuyComment(int type_strategy, int filter_number);
        void                        ResetFilterSellComment(int type_strategy, int filter_number);
        
        void                        ResetStopBuyOrder(int type_strategy);
        void                        ResetStopSellOrder(int type_strategy);
        void                        ResetStopBuyOrderComment(int type_strategy);
        void                        ResetStopSellOrderComment(int type_strategy);
        
        void                        ResetBuyOrder(int type_strategy);
        void                        ResetSellOrder(int type_strategy);


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

GuanStrategy::GuanStrategy(IndicatorsHelper *pIndicators,AccountManager *pAccountManager,AdvanceIndicator *pAdvIndicators,
CandleStickArray *pCandleStick,MarketCondition *pMarketCondition, TelegramBot *pTelegramBot, Probability *pProbability)
{
   m_Indicators=NULL;
   m_AdvIndicators=NULL;
   m_AccountManager=NULL;
   m_MarketCondition=NULL;
   m_TelegramBot=NULL;

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

   if(pTelegramBot!=NULL)
      m_TelegramBot=pTelegramBot;
      
   if(pProbability==NULL)
      LogError(__FUNCTION__,"Probability pointer is NULL");
   else
      m_Probability=pProbability;
      
      
   // Reset All Flags   
   Init_Comments();
   
   ArrayInitialize(Last_Buy_Order_Entry, 0);
   ArrayInitialize(Last_Sell_Order_Entry, 0);

   
   // Init reversal first
   if(m_Indicators.GetZigZag().GetZigZagShift(0, 0) < ZIGZAG_BUFFER_SIZE)
   {
      if(m_Indicators.GetZigZag().GetZigZagPrice(0, 0) > 0)
         Reversal_Filter_1(m_Indicators.GetZigZag().GetZigZagHighShift(0,0));
      else
         Reversal_Filter_1(m_Indicators.GetZigZag().GetZigZagLowShift(0,0));
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

GuanStrategy::~GuanStrategy()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Init_Comments()
{

    for(int i =0; i < Strategy_Number; i++)
    {
        Open_Buy_Flag[i] = false;
        Open_Sell_Flag[i] = false;
        Close_Buy_Flag[i] = false;
        Close_Sell_Flag[i] = false;
        Stop_Buy_Flag[i] = false;
        Stop_Sell_Flag[i] = false;
    
        for(int j=0; j < Filter_Numbers; j++)
        {
            // Flags & Open Order & Close Order & Modify Order buffer
            Filter_Buy_Flag[i][j] = false;
            Filter_Sell_Flag[i][j] = false;
        
            // Filters Comments
            for(int h = 0; h < Shift_Look_Back; h++)
            {
                Filter_Buy_Comment[i][j][h] = "----";
                Filter_Sell_Comment[i][j][h] = "----";
            }
        }

        // Comments
        for(int k = 0; k < Shift_Look_Back; k++)
        {
            Open_Buy_Comment[i][k] = "----";
            Open_Sell_Comment[i][k] = "----"; 
        }

        Close_Buy_Comment[i] = "----";
        Close_Sell_Comment[i] = "----"; 
        Modify_Buy_Comment[i] = "----";
        Modify_Sell_Comment[i] = "----"; 
        Stop_Buy_Comment[i] = "----";
        Stop_Sell_Comment[i] = "----";


    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::OnUpdate_Strategy()
{

   // Reversal Strategy
   if(TRADE_GUAN_REVERSAL_STRATEGY)
   {
      Reversal_Filter_1(0);          // Test out the current market regime

      // Buy Situation --- Check for filter 1
      if(Filter_Buy_Flag[Type_Reversal][Filter_1])
      {      
         if(Reversal_Filter_2(BULL_TRIGGER))
         {
            if(Reversal_Filter_3(BULL_TRIGGER))
               Open_Orders(BULL_TRIGGER, Type_Reversal); 
         }
      }

      // Sell Situation --- Check for filter 1
      if(Filter_Sell_Flag[Type_Reversal][Filter_1])
      {
         if(Reversal_Filter_2(BEAR_TRIGGER))
         {
            if(Reversal_Filter_3(BEAR_TRIGGER))
               Open_Orders(BEAR_TRIGGER, Type_Reversal);  
         }
      }
      
   }
   
   // ---------------------------------------------

   // Trend Strategy
   if(TRADE_GUAN_TREND_STRATEGY)
   {
      Trend_Filter_1();

      // Buy Situation --- Check for filter 1
      if(Filter_Buy_Flag[Type_Trend][Filter_1]
      && !Filter_Sell_Flag[Type_Trend][Filter_1]
      )
      {
         if(Trend_Filter_2(BULL_TRIGGER))
         {
            if(Trend_Filter_3(BULL_TRIGGER))       
            {
               if(Trend_Filter_4(BULL_TRIGGER))
                  Open_Orders(BULL_TRIGGER, Type_Trend);  
               else
               {
                  ResetFilterBuyFlag(Type_Trend, Filter_3);
                  Filter_Buy_Comment[Type_Trend][Filter_3][0] = "----";      // Reset filter 3 if risk is not in favor
               }  
            }
               
         }
      }

      // Sell Situation --- Check for filter 1
      if(Filter_Sell_Flag[Type_Trend][Filter_1]
      && !Filter_Buy_Flag[Type_Trend][Filter_1]
      )
      {
         if(Trend_Filter_2(BEAR_TRIGGER))
         {
            if(Trend_Filter_3(BEAR_TRIGGER))
            {
               if(Trend_Filter_4(BEAR_TRIGGER))
                  Open_Orders(BEAR_TRIGGER, Type_Trend);  
               else
               {
                  ResetFilterSellFlag(Type_Trend, Filter_3);
                  Filter_Sell_Comment[Type_Trend][Filter_3][0] = "----";      // Reset filter 3 if risk is not in favor
               }  
            }
         }
      }

   }

   // ---------------------------------------------
   // Continuation Strategy
   if(TRADE_GUAN_CON_STRATEGY)
   {
      Continuation_Filter_1();

      // Buy Situation --- Check for filter 1
      if(Filter_Buy_Flag[Type_Continuation][Filter_1]
      && !Filter_Sell_Flag[Type_Continuation][Filter_1]
      )
      {
         if(Continuation_Filter_2(BULL_TRIGGER))
         {
            if(Continuation_Filter_3(BULL_TRIGGER))
            {
               if(Continuation_Filter_4(BULL_TRIGGER))
                  Open_Orders(BULL_TRIGGER, Type_Continuation);  
               else
               {
                  ResetFilterBuyFlag(Type_Continuation, Filter_3);
                  Filter_Buy_Comment[Type_Continuation][Filter_3][0] = "----";      // Reset filter 3 if risk is not in favor
               }
            }
         }
      }

      // Sell Situation --- Check for filter 1
      if(Filter_Sell_Flag[Type_Continuation][Filter_1]
      && !Filter_Buy_Flag[Type_Continuation][Filter_1]
      )
      {
         if(Continuation_Filter_2(BEAR_TRIGGER))
         {
            if(Continuation_Filter_3(BEAR_TRIGGER))
            {
               if(Continuation_Filter_4(BEAR_TRIGGER))
                  Open_Orders(BEAR_TRIGGER, Type_Continuation);  
               else
               {
                  ResetFilterSellFlag(Type_Continuation, Filter_3);
                  Filter_Sell_Comment[Type_Continuation][Filter_3][0] = "----";      // Reset filter 3 if risk is not in favor
               }
            }
               
         }
      }



   }

   // ---------------------------------------------

   // Breakout Strategy
   if(TRADE_GUAN_BREAKOUT_STRATEGY)
   {
      //Breakout_Filter_1();

      /*
      // Buy Situation --- Check for filter 1
      if(Filter_Buy_Flag[Type_Breakout][Filter_1])
      {

         // Breakout Filter 2 not true yet
         if(!Filter_Buy_Flag[Type_Breakout][Filter_2])
         {
            if(Breakout_Filter_2() == BULL_TRIGGER)
            {
               if(Breakout_Filter_3(BULL_TRIGGER))
                  Open_Orders(BULL_TRIGGER, Type_Breakout);
            }
         }
         
         // Breakout Filter 2 true already
         else
         {
             if(Breakout_Filter_3(BULL_TRIGGER))
               Open_Orders(BULL_TRIGGER, Type_Breakout);
         }
        
      }

      // Sell Situation --- Check for filter 1
      if(Filter_Sell_Flag[Type_Breakout][Filter_1])
      {
         // Breakout Filter 2 not true yet
         if(!Filter_Sell_Flag[Type_Breakout][Filter_2])
         {
            if(Breakout_Filter_2() == BEAR_TRIGGER)
            {
               if(Breakout_Filter_3(BEAR_TRIGGER))
                  Open_Orders(BEAR_TRIGGER, Type_Breakout);
            }
         }
         
         // Breakout Filter 2 true already
         else
         {
             if(Breakout_Filter_3(BEAR_TRIGGER))
               Open_Orders(BEAR_TRIGGER, Type_Breakout);
         }
      }
      */
   }
   
   // ---------------------------------------------

   if(TRADE_GUAN_FAKEOUT_STRATEGY)
   {
      int direction = Fakeout_Filter_1();
   
      if(direction == BULL_TRIGGER)
      {
         if(Fakeout_Filter_2(BULL_TRIGGER))
         {
            if(Fakeout_Filter_3(BULL_TRIGGER))
               Open_Orders(BULL_TRIGGER, Type_Fakeout);
            else
            {
               ResetFilterBuyFlag(Type_Fakeout, Filter_1);
               ResetFilterBuyComment(Type_Fakeout, Filter_1);
               ResetFilterBuyFlag(Type_Fakeout, Filter_2);
               ResetFilterBuyComment(Type_Fakeout, Filter_2);
            }
      
         }
      }
      
      if(direction == BEAR_TRIGGER)
      {
         if(Fakeout_Filter_2(BEAR_TRIGGER))
         {
            if(Fakeout_Filter_3(BEAR_TRIGGER))
               Open_Orders(BEAR_TRIGGER, Type_Fakeout);
            else
            {
               ResetFilterSellFlag(Type_Fakeout, Filter_1);
               ResetFilterSellComment(Type_Fakeout, Filter_1);
               ResetFilterSellFlag(Type_Fakeout, Filter_2);
               ResetFilterSellComment(Type_Fakeout, Filter_2);
            }
               
         }
      
      }

   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Open_Orders(int Direction, int Strategy_Type)
{
   // Utils
   double openprice = 0, stoploss = 0, lots = 0, risk = 0;
   double hidden_takeprofit = 0;
   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0);
   double tenkan = m_Indicators.GetIchimoku().GetTenkanSen(0, 0), kijun = m_Indicators.GetIchimoku().GetKijunSen(0, 0), band_main = m_Indicators.GetBands().GetMain(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   string order_comments;
   
   datetime curtime = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0);
   
   if(Strategy_Type == Type_Reversal)
   {
      // Buy Reversal
      if(Direction == BULL_TRIGGER)
      {
         RefreshRates();
          
         // Setting utils
         stoploss = NormalizeDouble(Ask-TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
         stoploss = m_AccountManager.MinimizeStopLoss(Ask, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetBuyLots(Ask, stoploss, risk);
         order_comments = Filter_Buy_Comment[Type_Reversal][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_BUY, lots, Ask, 0, 0, 0, order_comments, GUAN_REVERSAL_BUY_STRATEGY, 0, BULL_COLOR))
         {
            Last_Buy_Order_Entry[Type_Reversal] = curtime;
         
            // Set Open Buy
            Open_Buy_Flag[Type_Reversal] = true;
            Shift_Open_Buy_Comments(Type_Reversal, order_comments);
            
            // Reset Filters
            ResetFilterBuyFlag(Type_Reversal, Filter_3);             
            
            LogInfo("Succesfully Entered Buy Reversal Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Buy Reversal with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol());     
         }  
      }
      
      // Sell Reversal
      else if(Direction == BEAR_TRIGGER)
      {
         RefreshRates();
                  
         // Setting utils
         stoploss = NormalizeDouble(Bid+TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
         stoploss = m_AccountManager.MinimizeStopLoss(Bid, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetSellLots(Bid, stoploss, risk);
         order_comments = Filter_Sell_Comment[Type_Reversal][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_SELL, lots, Bid, 0, 0, 0, order_comments, GUAN_REVERSAL_SELL_STRATEGY, 0, BEAR_COLOR))
         {
            Last_Sell_Order_Entry[Type_Reversal] = curtime;
         
            // Set Open Buy
            Open_Sell_Flag[Type_Reversal] = true;
            Shift_Open_Sell_Comments(Type_Reversal, order_comments);
            
            // Reset Filters
            ResetFilterSellFlag(Type_Reversal, Filter_3); 
         
            LogInfo("Succesfully Entered Sell Reversal Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Sell Reversal with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
         }
      }
   }
   

   // ------------   Continuation     --------------
   else if(Strategy_Type == Type_Continuation)
   {
      // Buy Continuation
      if(Direction == BULL_TRIGGER)
      {
         RefreshRates();
          
         // Setting utils
         double previous_low = MathMin(CandleSticksBuffer[0][1].GetLow(), CandleSticksBuffer[0][2].GetLow());
        
         stoploss = Buy_HiddenStopLoss[Type_Continuation];         
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetBuyLots(Ask, stoploss, risk);
         order_comments = Filter_Buy_Comment[Type_Continuation][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_BUY, lots, Ask, 0, stoploss, 0, order_comments, GUAN_CONTINUATION_BUY_STRATEGY, 0, BULL_COLOR))
         {
            Last_Buy_Order_Entry[Type_Continuation] = curtime;

            // Set Open Buy
            Open_Buy_Flag[Type_Continuation] = true;
            Shift_Open_Buy_Comments(Type_Continuation, order_comments);
            
            // Reset Filters
            ResetFilterBuyFlag(Type_Continuation, Filter_3);
            ResetFilterBuyFlag(Type_Continuation, Filter_4); 
            
            LogInfo("Succesfully Entered Buy Continuation Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Buy Continuation with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol());     
         }   
      }
      
      // Sell Continuation
      else if(Direction == BEAR_TRIGGER)
      {
         RefreshRates();
                  
         // Setting utils
         stoploss = Sell_HiddenStopLoss[Type_Continuation];     
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetSellLots(Bid, stoploss, risk);
         order_comments = Filter_Sell_Comment[Type_Continuation][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_SELL, lots, Bid, 0, stoploss, 0, order_comments, GUAN_CONTINUATION_SELL_STRATEGY, 0, BEAR_COLOR))
         {
            Last_Sell_Order_Entry[Type_Continuation] = curtime;
         
            // Set Open Buy
            Open_Sell_Flag[Type_Continuation] = true;
            Shift_Open_Sell_Comments(Type_Continuation, order_comments);
            
            // Reset Filters
            ResetFilterSellFlag(Type_Continuation, Filter_3); 
            ResetFilterSellFlag(Type_Continuation, Filter_4); 
         
            LogInfo("Succesfully Entered Sell Continuation Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Sell Continuation with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
         }
      }
   }
   

   // ------------------------   Trending     --------------------------
   else if(Strategy_Type == Type_Trend)
   {
      // Buy Trend
      if(Direction == BULL_TRIGGER)
      {
         RefreshRates();
          
         // Setting utils
         stoploss = Buy_HiddenStopLoss[Type_Trend];    
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetBuyLots(Ask, stoploss, risk);
         order_comments = Filter_Buy_Comment[Type_Trend][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_BUY, lots, Ask, 0, stoploss, 0, order_comments, GUAN_TRENDING_BUY_STRATEGY, 0, BULL_COLOR))
         {
            Last_Buy_Order_Entry[Type_Trend] = curtime;
         
            // Set Open Buy
            Open_Buy_Flag[Type_Trend] = true;
            Shift_Open_Buy_Comments(Type_Trend, order_comments);
            
            // Reset Filters
            ResetFilterBuyFlag(Type_Trend, Filter_3); 
            ResetFilterBuyFlag(Type_Trend, Filter_4);
            
            LogInfo("Succesfully Entered Buy Trending Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Buy Trending with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol());     
         }   
      }
      
      // Sell Trend
      else if(Direction == BEAR_TRIGGER)
      {
         RefreshRates();
                  
         // Setting utils
         stoploss = Sell_HiddenStopLoss[Type_Trend];     
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetSellLots(Bid, stoploss, risk);
         order_comments = Filter_Sell_Comment[Type_Trend][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_SELL, lots, Bid, 0, stoploss, 0, order_comments, GUAN_TRENDING_SELL_STRATEGY, 0, BEAR_COLOR))
         {
            Last_Sell_Order_Entry[Type_Trend] = curtime;
         
            // Set Open Buy
            Open_Sell_Flag[Type_Trend] = true;
            Shift_Open_Sell_Comments(Type_Trend, order_comments);
            
            // Reset Filters
            ResetFilterSellFlag(Type_Trend, Filter_3); 
            ResetFilterSellFlag(Type_Trend, Filter_4);
         
            LogInfo("Succesfully Entered Sell Trending Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Sell Trending with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
         }
      }
   }


   // ------------------------   Breakout     --------------------------
   else if(Strategy_Type == Type_Breakout)
   {
      // Buy Continuation
      if(Direction == BULL_TRIGGER)
      {
         RefreshRates();
         
         // Stop Loss should based on the trend etc... (This must be improved --- LZ)
         double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
         double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
         
         // Broke above resistance 
         if(Ask-fractal_resistance < LOOSE_STOP_LOSS_MULTIPLIER*atr)
            stoploss = NormalizeDouble(fractal_support-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
         else if(Ask-fractal_resistance >= LOOSE_STOP_LOSS_MULTIPLIER && Ask-fractal_resistance < VERY_LOOSE_STOP_LOSS_MULTIPLIER)
            stoploss = NormalizeDouble(fractal_support-MEDIUM_STOP_LOSS_MULTIPLIER*atr, Digits);
         else
            stoploss = NormalizeDouble(Ask-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
          
         // Setting utils
         stoploss = m_AccountManager.MinimizeStopLoss(Ask, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetBuyLots(Ask, stoploss, risk);
         order_comments = Filter_Buy_Comment[Type_Breakout][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_BUY, lots, Ask, 0, stoploss, 0, order_comments, GUAN_BREAKOUT_BUY_STRATEGY, 0, BULL_COLOR))         // temporarily put stop loss, remove it later --- LZ 
         {
            Last_Buy_Order_Entry[Type_Breakout] = curtime;
         
            // Set Open Buy
            Open_Buy_Flag[Type_Breakout] = true;
            Shift_Open_Buy_Comments(Type_Breakout, order_comments);
            
            // Reset Filters
            ResetFilterBuyFlag(Type_Breakout, Filter_3); 

            LogInfo("Succesfully Entered Buy Breakout Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Buy Breakout with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
            
         }
            
      }
      
      // Sell Continuation
      else if(Direction == BEAR_TRIGGER)
      {
         RefreshRates();

         // Stop Loss should based on the trend etc... (This must be improved --- LZ)
         double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
         double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);

         // Broke above resistance 
         if(fractal_support-Bid < LOOSE_STOP_LOSS_MULTIPLIER*atr)
            stoploss = NormalizeDouble(fractal_resistance+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
         else if(fractal_support-Bid >= LOOSE_STOP_LOSS_MULTIPLIER && fractal_support-Bid < VERY_LOOSE_STOP_LOSS_MULTIPLIER)
            stoploss = NormalizeDouble(fractal_resistance+MEDIUM_STOP_LOSS_MULTIPLIER*atr, Digits);
         else
            stoploss = NormalizeDouble(Bid+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
            
         // Setting utils
         stoploss = m_AccountManager.MinimizeStopLoss(Bid, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetSellLots(Bid, stoploss, risk);
         order_comments = Filter_Sell_Comment[Type_Breakout][Filter_3][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_SELL, lots, Bid, 0, stoploss, 0, order_comments, GUAN_BREAKOUT_SELL_STRATEGY, 0, BEAR_COLOR))         // temporarily put stop loss, remove it later --- LZ 
         {
            Last_Sell_Order_Entry[Type_Breakout] = curtime;
         
            // Set Open Buy
            Open_Sell_Flag[Type_Breakout] = true;
            Shift_Open_Sell_Comments(Type_Breakout, order_comments);
            
            // Reset Filters
            ResetFilterSellFlag(Type_Breakout, Filter_3); 
            
            LogInfo("Succesfully Entered Sell Breakout Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Sell Breakout with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
            
         }
      }
   }
   
   
   // ------------------------   Fakeout     --------------------------
   else if(Strategy_Type == Type_Fakeout)
   {
      // Buy Continuation
      if(Direction == BULL_TRIGGER)
      {
         RefreshRates();
         
         // Stop Loss should based on the trend etc... (This must be improved --- LZ)
         stoploss = NormalizeDouble(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0))-TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
         stoploss = m_AccountManager.MinimizeStopLoss(Ask, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetBuyLots(Ask, stoploss, risk);
         order_comments = Filter_Buy_Comment[Type_Fakeout][Filter_1][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_BUY, lots, Ask, 0, stoploss, 0, order_comments, GUAN_FAKEOUT_BUY_STRATEGY, 0, BULL_COLOR))         // temporarily put stop loss, remove it later --- LZ 
         {
            Last_Buy_Order_Entry[Type_Fakeout] = curtime;
         
            // Set Open Buy
            Open_Buy_Flag[Type_Fakeout] = true;
            Shift_Open_Buy_Comments(Type_Fakeout, order_comments);
            
            ResetFilterBuyFlag(Type_Fakeout, Filter_2);
            
            LogInfo("Succesfully Entered Buy Fakeout Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Buy Fakeout with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
         }
            
      }
      
      // Sell Continuation
      else if(Direction == BEAR_TRIGGER)
      {
         RefreshRates();

         // Stop Loss should based on the trend etc... (This must be improved --- LZ)
         stoploss = NormalizeDouble(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0)+TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
            
         // Setting utils
         stoploss = m_AccountManager.MinimizeStopLoss(Bid, stoploss);  
         risk = MAX_RISK_PER_TRADE;          // Can Try dynamic position sizing
         lots = m_AccountManager.GetSellLots(Bid, stoploss, risk);
         order_comments = Filter_Sell_Comment[Type_Fakeout][Filter_1][0];
         
         // Make sure order entered
         if(m_AccountManager.OpenOrder(m_AccountManager.GetChartCurrencySymbol(), OP_SELL, lots, Bid, 0, stoploss, 0, order_comments, GUAN_FAKEOUT_SELL_STRATEGY, 0, BEAR_COLOR))         // temporarily put stop loss, remove it later --- LZ 
         {
            Last_Sell_Order_Entry[Type_Fakeout] = curtime;
         
            // Set Open Buy
            Open_Sell_Flag[Type_Fakeout] = true;
            Shift_Open_Sell_Comments(Type_Fakeout, order_comments);
            
            ResetFilterSellFlag(Type_Fakeout, Filter_2);
            
            LogInfo("Succesfully Entered Sell Fakeout Order with Order Commment: " + order_comments);
            TelegramMessage(m_TelegramBot, "Entered Sell Fakeout with Reason: " + order_comments, m_AccountManager.GetChartCurrencySymbol()); 
         }
      }
   }


   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Reversal_Filter_1(int Shift)
{
    double zz[ENUM_TIMEFRAMES_ARRAY_SIZE];
    ArrayInitialize(zz, 0);

    for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
        zz[i] = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(i), Shift);


    // Buy Reversal Situation (Could be crazy retracement continuation too)
    if(zz[0] < 0 && !Filter_Buy_Flag[Type_Trend][Filter_2])
    {
        // D1 Reversal
        if(zz[3] < 0)
        {
            Filter_Buy_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_1, "Bull/-D1");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterSellFlag(Type_Reversal, Filter_1);
            ResetFilterSellFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Sell_Flag[Type_Reversal])
            {
                ResetFilterSellComment(Type_Reversal, Filter_1);
                ResetFilterSellComment(Type_Reversal, Filter_2);             
            }
        }

        // H4 Reversal
        else if(zz[3] == 0 && zz[2] < 0)
        {
            Filter_Buy_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_1, "Bull/-H4");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterSellFlag(Type_Reversal, Filter_1);
            ResetFilterSellFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Sell_Flag[Type_Reversal])
            {
                ResetFilterSellComment(Type_Reversal, Filter_1);
                ResetFilterSellComment(Type_Reversal, Filter_2);             
            }
        }

        // H1 Reversal
        else if(zz[3] == 0 && zz[2] == 0 && zz[1] < 0)
        {
            Filter_Buy_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_1, "Bull/-H1");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterSellFlag(Type_Reversal, Filter_1);
            ResetFilterSellFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Sell_Flag[Type_Reversal])
            {
                ResetFilterSellComment(Type_Reversal, Filter_1);
                ResetFilterSellComment(Type_Reversal, Filter_2);             
            }
        }

        else
        {
            Filter_Buy_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_1, "Bull/-M15");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterSellFlag(Type_Reversal, Filter_1);
            ResetFilterSellFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Sell_Flag[Type_Reversal])
            {
                ResetFilterSellComment(Type_Reversal, Filter_1);
                ResetFilterSellComment(Type_Reversal, Filter_2);             
            }
        }
    }

    // Sell Reversal Situation (Could be crazy retracement also)
    else if(zz[0] > 0 && !Filter_Sell_Flag[Type_Trend][Filter_2])
    {
        // D1 Reversal
        if(zz[3] > 0)
        {
            Filter_Sell_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_1, "Bear/+D1");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterBuyFlag(Type_Reversal, Filter_1);
            ResetFilterBuyFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Buy_Flag[Type_Reversal])
            {
                ResetFilterBuyComment(Type_Reversal, Filter_1);
                ResetFilterBuyComment(Type_Reversal, Filter_2);             
            }
        }

        // H4 Reversal
        else if(zz[3] == 0 && zz[2] > 0)
        {
            Filter_Sell_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_1, "Bear/+H4");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterBuyFlag(Type_Reversal, Filter_1);
            ResetFilterBuyFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Buy_Flag[Type_Reversal])
            {
                ResetFilterBuyComment(Type_Reversal, Filter_1);
                ResetFilterBuyComment(Type_Reversal, Filter_2);             
            }
        }

        // H1 Reversal
        else if(zz[3] == 0 && zz[2] == 0 && zz[1] > 0)
        {
            Filter_Sell_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_1, "Bear/+H1");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterBuyFlag(Type_Reversal, Filter_1);
            ResetFilterBuyFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Buy_Flag[Type_Reversal])
            {
                ResetFilterBuyComment(Type_Reversal, Filter_1);
                ResetFilterBuyComment(Type_Reversal, Filter_2);             
            }
        }

        else
        {
            Filter_Sell_Flag[Type_Reversal][Filter_1] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_1, "Bear/+M15");
            
            // Reset Buy Filter only if there's no opening of order or filter 2 of it being activated
            ResetFilterBuyFlag(Type_Reversal, Filter_1);
            ResetFilterBuyFlag(Type_Reversal, Filter_2); 
            
            if(!Open_Buy_Flag[Type_Reversal])
            {
                ResetFilterBuyComment(Type_Reversal, Filter_1);
                ResetFilterBuyComment(Type_Reversal, Filter_2);             
            }
        }
    }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Reversal_Filter_2(int Direction)
{
   //////////////////////////////////////////////////////////////          Reversal Filter 2         //////////////////////////////////////////////////
   
   RefreshRates();
   
   string   Fractal_Comment = "----";
   double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);

//////////////////////////////////////////////////////////////       Filter 2 Reversal Buy        //////////////////////////////////////////////////////////////  
   
   if(Direction == BULL_TRIGGER)
   {       
      // Check for Fractal D1
      if(CandleSticksBuffer[2][0].GetLow() <= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(3, 0)
      && fractal_support <= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(3, 0)
      && Ask >= fractal_support
      )
      {
         Fractal_Comment = "Frac-S/D1";
      
         // Check through the filter 1 to look for the neural node 
         if(Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-D1" || Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H4")
         { 
            Filter_Buy_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_2, Fractal_Comment);            
            return true;
         }
      } 

      // Fractal H4
      if(CandleSticksBuffer[1][0].GetLow() <= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(2, 0)
      && fractal_support <= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(2, 0)
      && Ask >= fractal_support
      )
      {
         Fractal_Comment = "Frac-S/H4";
         
         // Check through the filter 1 to look for the neural node 
         if(Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H4" || Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H1")
         { 
            Filter_Buy_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_2, Fractal_Comment);            
            return true;
         }
      }
      
      // Fractal H1
      if(CandleSticksBuffer[0][0].GetLow() <= m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0)
      && fractal_support <= m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0)
      && CandleSticksBuffer[0][0].GetLow() >= fractal_support
      )
      {
         Fractal_Comment = "Frac-S/H1";
      
         // Check through the filter 1 to look for the neural node 
         if(Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H1" || Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-M15")
         { 
            Filter_Buy_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_2, Fractal_Comment);    
            return true;
         }
      } 


      // Fractal M15
      if(CandleSticksBuffer[0][0].GetLow() <= fractal_support
      && CandleSticksBuffer[0][0].GetClose() > fractal_support
      )
      {
         Fractal_Comment = "Frac-S/M15";
      
         // Check through the filter 1 to look for the neural node 
         if((Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H1" || Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-M15")
         && m_Indicators.GetZigZag().GetZigZagLowShift(0,0) > 0
         )
         { 
            Filter_Buy_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Buy_Comments(Type_Reversal, Filter_2, Fractal_Comment);    
            return true;
         }
      } 


      // Verified the Sell Flag For filter 2
      if(Filter_Buy_Flag[Type_Reversal][Filter_2])
         return true; 
      else
         return false;
   }

   //////////////////////////////////////////////////////////////       Filter 2 Reversal Sell        //////////////////////////////////////////////////////////////  
   // Sell
   else if(Direction == BEAR_TRIGGER)
   {   
      // Fractal D1
      if(CandleSticksBuffer[2][0].GetHigh() >= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(3, 0)
      && fractal_resistance >= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(3, 0)
      && Bid <= fractal_resistance
      )
      {
         Fractal_Comment = "Frac-R/D1";
      
         // Check through the filter 1 to look for the neural node 
         if(Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+D1" || Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H4")
         { 
            Filter_Sell_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_2, Fractal_Comment);
            return true;
         }
      } 
      
      
      // Fractal H4
      if(CandleSticksBuffer[1][0].GetHigh() >= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(2, 0)
      && fractal_resistance >= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(2, 0)
      && Bid <= fractal_resistance
      )
      {
         Fractal_Comment = "Frac-R/H4";
         
         // Check through the filter 1 to look for the neural node 
         if(Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H4" || Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H1")
         { 
            Filter_Sell_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_2, Fractal_Comment);
            return true;
         }
      }
      if(CandleSticksBuffer[0][0].GetHigh() >= m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0)
      && fractal_resistance >= m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(1, 0)
      && CandleSticksBuffer[0][0].GetHigh() <= fractal_resistance
      )
      {
         Fractal_Comment = "Frac-R/H1";
      
         // Check through the filter 1 to look for the neural node 
         if(Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H1" || Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+M15")
         { 
            Filter_Sell_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_2, Fractal_Comment);
            return true;
         }
      } 

      // M15 Trending Downwards
      if(CandleSticksBuffer[0][0].GetHigh() >= fractal_resistance
      && CandleSticksBuffer[0][0].GetClose() < fractal_resistance
      )
      {
         Fractal_Comment = "Frac-R/M15";
      
         // Check through the filter 1 to look for the neural node 
         if(Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H1" || Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+M15")
         { 
            Filter_Sell_Flag[Type_Reversal][Filter_2] = true;
            Shift_Filter_Sell_Comments(Type_Reversal, Filter_2, Fractal_Comment);
            return true;
         }
      } 



      // Verified the Sell Flag For filter 2
      if(Filter_Sell_Flag[Type_Reversal][Filter_2])
         return true; 
      else
         return false;
   
   }

   // Out of Condition
   return false;  

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Reversal_Filter_3(int Direction)
{
   int                        curr_minute = Minute();
   
   // Get Support/Resistance
   double support = 0, resistance = 0;

   ENUM_QUADRANT band_quadrant[ENUM_TIMEFRAMES_ARRAY_SIZE];
   ENUM_QUADRANT tenkan_quadrant[ENUM_TIMEFRAMES_ARRAY_SIZE];
   ENUM_QUADRANT kijun_quadrant[ENUM_TIMEFRAMES_ARRAY_SIZE];

   ENUM_MARKET_CONDITION market_condition[ENUM_TIMEFRAMES_ARRAY_SIZE];

   ArrayInitialize(band_quadrant, UNKNOWN);
   ArrayInitialize(tenkan_quadrant, UNKNOWN);
   ArrayInitialize(kijun_quadrant, UNKNOWN);
   ArrayInitialize(market_condition, NULL);

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      band_quadrant[i] = m_Indicators.GetBands().GetBandBias(i, 0);
      tenkan_quadrant[i] = m_Indicators.GetIchimoku().GetTenKanQuadrant(i, 0);
      kijun_quadrant[i] = m_Indicators.GetIchimoku().GetKijunQuadrant(i, 0);

      market_condition[i] = m_MarketCondition.GetEnumMarketCondition(i, 0);
   }

   double major_fractal_support = 0, major_fractal_resistance = 0;

   double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);

   // Price Points in EMAs
   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   
   double ExtremeLowerEMA200 = ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr, ExtremeUpperEMA200 = ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr;
   double MiddleLowerEMA200 = ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr, MiddleUpperEMA200 = ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr;
   double TightLowerEMA200 = ema200-TIGHT_STOP_LOSS_MULTIPLIER*atr, TightUpperEMA200 = ema200+TIGHT_STOP_LOSS_MULTIPLIER*atr;

   // Market Bias
   double curr_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 0);
   double curr_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 0);
   
   double prev_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 1);
   double prev_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 1);

   double curr_buy_momentum_mean = m_AdvIndicators.GetMarketMomentum().GetBuyMean(0, 0);
   double curr_sell_momentum_mean = m_AdvIndicators.GetMarketMomentum().GetSellMean(0, 0);
   
   double prev_buy_momentum_mean = m_AdvIndicators.GetMarketMomentum().GetBuyMean(0, 1);
   double prev_sell_momentum_mean = m_AdvIndicators.GetMarketMomentum().GetSellMean(0, 1);

   double curr_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 0);
   double curr_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 0);

   double prev_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 1);
   double prev_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 1);
   
   double curr_close = CandleSticksBuffer[0][0].GetClose();


   // Get major fractal Support we reverse from
   if(Filter_Buy_Comment[Type_Reversal][Filter_2][0] == "Frac-S/D1")
      major_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(3, 0);
   else if(Filter_Buy_Comment[Type_Reversal][Filter_2][0] == "Frac-S/H4")
      major_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(2, 0);
   else if(Filter_Buy_Comment[Type_Reversal][Filter_2][0] == "Frac-S/H1")
      major_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0);
   else if(Filter_Buy_Comment[Type_Reversal][Filter_2][0] == "Frac-S/M15")
      major_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);


   // Get major fractal Resistance we reverse from
   if(Filter_Sell_Comment[Type_Reversal][Filter_2][0] == "Frac-R/D1")
      major_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(3, 0);
   else if(Filter_Sell_Comment[Type_Reversal][Filter_2][0] == "Frac-R/H4")
      major_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(2, 0);
   else if(Filter_Sell_Comment[Type_Reversal][Filter_2][0] == "Frac-R/H1")
      major_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(1, 0);
   else if(Filter_Sell_Comment[Type_Reversal][Filter_2][0] == "Frac-R/M15")
      major_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);

   // Get Order Zone
   string order_zone = "";
   
   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();

/*
   // Order Region
   if(curr_ohlc4 <= ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(B)";
   else if(curr_ohlc4 > ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(B)";
   else if(curr_ohlc4 >= ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/TGT";  
   else if(curr_ohlc4 >= ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(T)"; 
   else if(curr_ohlc4 >= ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(T)"; 
   else
   {
      LogError(__FUNCTION__, "Failed to identify Region!");  
      return false;
   }
*/

////////////////////////////////////////////////////////////////////          Filter 3 Buy           ///////////////////////////////////////////////////////// 
   
   if(Direction == BULL_TRIGGER && Filter_Buy_Flag[Type_Reversal][Filter_2] && !Filter_Buy_Flag[Type_Breakout][Filter_1])
   {
       // Buy - Point of Reversal
       
       // Reset Stop Entry when it goes back down, seeking crazier low
       if(Stop_Buy_Comment[Type_Reversal] == "Stop>=R-H1" && CandleSticksBuffer[0][0].GetClose() <= major_fractal_support
       && Ask < m_Indicators.GetFractal().GetFractalSupportBarShiftLowerPrice(0, 0)
       )
            Stop_Buy_Flag[Type_Reversal] = false;
       
       // Stop Entirely When it hits H1 Resistance (Big decision point)
       else if(curr_close >= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(1, 0))
       {   
            Stop_Buy_Flag[Type_Reversal] = true;
            Stop_Buy_Comment[Type_Reversal] = "Stop>=R-H1";
            return false;
       } 
       
       // Automatically Pause Trigger 3 actions
       else if(Stop_Buy_Flag[Type_Reversal])
         return false;


      // Still below support
      if(Ask < m_Indicators.GetFractal().GetFractalSupportBarShiftLowerPrice(0, 0))
         return false;   
     
       
       //      ----------------------     Start of Reversal Logics      ----------------------   
       
       // Volatility Spike Situation
       if(m_Indicators.GetHighLowCSATRPercent(2, 0) >= 250 && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(2, 0) == BULL_TRIGGER
       && CandleSticksBuffer[2][0].GetTrend() == Bearish
       )
       {               
           // Spike ones
           if(m_CandleStick.GetCummBodyPosition(0, 0) >= Minus_2_StdDev && m_CandleStick.GetCummBodyPosition(0, 0) != Null
           && m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev
           )
           {
              if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB-CS>=2x"+order_zone))
              {
                  Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                  return true;
              }
           }
           
           // Spike entries
           if((CandleSticksBuffer[1][0].GetHLDiff() > (m_Indicators.GetFractal().GetFractalResistancePrice(0, 0)-m_Indicators.GetFractal().GetFractalSupportPrice(0, 0)) * EXTREME_LOOSE_STOP_LOSS_MULTIPLIER
           || CandleSticksBuffer[1][1].GetHLDiff() > (m_Indicators.GetFractal().GetFractalResistancePrice(0, 0)-m_Indicators.GetFractal().GetFractalSupportPrice(0, 0)) * EXTREME_LOOSE_STOP_LOSS_MULTIPLIER)
           && m_CandleStick.GetCummBodyPercent(0, 0) > m_CandleStick.GetCummBodyMean(0, 0)
           )
           {
               if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "CS-FRAC>=5x"+order_zone))
               {
                   Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                   return true;
               }
           }
           
           
           // ... More Triggers for Spikes Handling
       }


        // Trading Against The Stong Trend
        if(Filter_Sell_Flag[Type_Trend][Filter_1])
        {
            // Extreme Bottom
            if(curr_ohlc4 < ExtremeLowerEMA200)
            {
               // BKT + 1x <> BB
               if(band_quadrant[0] == LOWER_QUADRANT && tenkan_quadrant[0] == LOWER_QUADRANT && kijun_quadrant[0] == LOWER_QUADRANT
               && CandleSticksBuffer[0][0].GetOHLC4() < m_Indicators.GetBands().GetLower(0, 1, 0)
               )
               {
                  // Depending on the reversal type
                  if((Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-D1" && band_quadrant[2] == LOWER_QUADRANT && tenkan_quadrant[2] == LOWER_QUADRANT && kijun_quadrant[2] == LOWER_QUADRANT && CandleSticksBuffer[2][0].GetOHLC4() < m_Indicators.GetBands().GetLower(2, 1, 0))
                  || (Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H4" && band_quadrant[1] == LOWER_QUADRANT && tenkan_quadrant[1] == LOWER_QUADRANT && kijun_quadrant[1] == LOWER_QUADRANT && CandleSticksBuffer[1][0].GetOHLC4() < m_Indicators.GetBands().GetLower(1, 1, 0))
                  )
                  {
                     // Bot Wick Mean
                     if(m_CandleStick.GetCummBotWickMean(0, 0) > m_CandleStick.GetCummBotWickMean(0, 1)
                     && (m_CandleStick.GetCummBotWickMean(0, 1) <= 40 || m_CandleStick.GetCummBotWickMean(0, 2) <= 40)
                     )
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "CummBotMean<=40"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                  
                  
                     // CS Price action
                     if(m_CandleStick.GetCummBodyPosition(0, 0) != Null && m_CandleStick.GetCummBodyPosition(0, 1) != Null
                     && m_CandleStick.GetCummBodyPosition(0, 0) < m_CandleStick.GetCummBodyPosition(0, 1) 
                     && m_CandleStick.GetCummBodyPosition(0, 1) >= Minus_2_StdDev
                     )
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "CS>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                  
                     
                     // Indicator Trigger Goes Further Below 
                     if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2)
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }


                     // Line Trigger Goes Further Below 
                     if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2)
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }              
                     
                     // Market Bias Exhaustion 
                     if(curr_minute%15 > 10 && curr_minute%15 <= 14
                     && curr_buy_momentum_percent > curr_buy_momentum_mean && curr_buy_momentum_mean > prev_buy_momentum_mean
                     )
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "MoMMean"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }


                     // Momentum STO + Cumm Body Mean
                     if(curr_minute%15 > 10 && curr_minute%15 <= 14
                     && m_Indicators.GetSTO().GetSTOHist(0, 0) > 0 && m_Indicators.GetSTO().GetMain(0, 0) >= STO_LOWER_THRESHOLD && m_Indicators.GetSTO().GetMain(0, 0) < 50
                     && m_Indicators.GetSTO().GetSignal(0, 0) <= STO_LOWER_THRESHOLD && m_CandleStick.GetCummBodyPercent(0, 0) > m_CandleStick.GetCummBodyMean(0, 0)
                     && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                     )
                     {
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "STO-MoM"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                     
                  }     // HTF BKT
               
               }        // LTF BKT
            
            }
            
            
            // In Between 2x - 5x
            else if(curr_ohlc4 < MiddleLowerEMA200 && curr_ohlc4 >= ExtremeLowerEMA200)
            {
               // Still a pure lower low (May be higher timeframes lower low 
               if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "R-LLHL" || m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "C-LLLL")
               {
                  // Continuation of the H4/H1 Reversal ---- OR BEGINNING OF REVERAL 
                  if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(1, 0) == "H-HLLL")
                  {
                     // BKT <> 1 BB
                     if(band_quadrant[0] == LOWER_QUADRANT && tenkan_quadrant[0] == LOWER_QUADRANT && kijun_quadrant[0] == LOWER_QUADRANT
                     && CandleSticksBuffer[0][0].GetOHLC4() < m_Indicators.GetBands().GetLower(0, 1, 0)
                     )
                     {
                        // Indicator Trigger Upwards
                        if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2)
                        {
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
   
                        // Line Trigger Upwards
                        if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2)
                        {
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }  
                        
                        // Bot Wick Mean
                        if(m_CandleStick.GetCummBotWickMean(0, 0) > m_CandleStick.GetCummBotWickMean(0, 1)
                        && (m_CandleStick.GetCummBotWickMean(0, 1) <= 40 || m_CandleStick.GetCummBotWickMean(0, 2) <= 40)
                        )
                        {
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "CummBotMean<=40"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                     
                        // CS Price action
                        if(m_CandleStick.GetCummBodyPosition(0, 0) != Null && m_CandleStick.GetCummBodyPosition(0, 1) != Null
                        && m_CandleStick.GetCummBodyPosition(0, 0) < m_CandleStick.GetCummBodyPosition(0, 1) 
                        && m_CandleStick.GetCummBodyPosition(0, 1) >= Minus_2_StdDev
                        )
                        {
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "CS>=2x"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                        
                        // Market Bias Exhaustion 
                        if(curr_minute%15 > 10 && curr_minute%15 <= 14
                        && curr_buy_momentum_percent > curr_buy_momentum_mean && curr_buy_momentum_mean > prev_buy_momentum_mean
                        )
                        {
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "MoMMean"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                        
                        // OBOS Mean Cross
                        if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
                        && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                        && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                        )
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB Mean"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        } 
                        
                        // Buy OB 2x Stddev
                        if(m_AdvIndicators.GetOBOS().GetOBPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30)
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        }
      
                        // Buy Volatility 2x StdDev
                        if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                        && m_AdvIndicators.GetBullBear().GetBullPercent(0, 0) > 50
                        )
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                           {
                              Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        }    
                                         
                     }     // BKT Situations
 
                  }        // End of Continuation of HTF 
               
               
                  // Is an External ZigZag
                  // --- Means M15 Aligns with the other timeframe to form: Lower Low
                  else
                  {                           
                     // Line Trigger 
                     if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2
                     && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }
                     
                     // Indicator Trigger 
                     if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2
                     && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }    
                     
                     // OBOS Mean Cross
                     if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
                     && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                     && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB Mean"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     } 
                     
                     // Buy OB 2x Stddev
                     if(m_AdvIndicators.GetOBOS().GetOBPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30)
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }
   
                     // Buy Volatility 2x StdDev
                     if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                     && m_AdvIndicators.GetBullBear().GetBullPercent(0, 0) > 50
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                        {
                           Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }  
                     
                  }     // End of Strong Continuation Low At Area: MID(B)   
                  
               }        // End of Pure Lower Low Situation At Area: MID(B)
               
               
               // Is a Higher low, means it retraced from the bottom already
               else if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "H-HLLL" || m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "C-HHHH")
               {             
                  // Market Momentum Cross
                  if(curr_buy_momentum_percent > curr_sell_momentum_percent
                  && prev_buy_momentum_percent < prev_sell_momentum_percent
                  && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  )
                  {
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "MoM-CO"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return true;
                     }
                  }
                        
                  // Line Trigger 
                  if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }
                  
                  // Indicator Trigger 
                  if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }    
                  
                  // OBOS Mean Cross
                  if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
                  && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                  && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB Mean"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  } 
                  
                  // Buy OB 2x Stddev
                  if(m_AdvIndicators.GetOBOS().GetOBPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30)
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }

                  // Buy Volatility 2x StdDev
                  if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  && m_AdvIndicators.GetBullBear().GetBullPercent(0, 0) > 50
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }       
                  
               }     //    End of All Variation of Current Market Divergence Situation
            
            }        //    End of MID(B) Area
            
            
            /* In between 1x+ to 1x- are very rare --- Can explore, but not priority --- LZ
               
               - Way too rare scenarios --- Also even if its true, profits are too less compare to the risk
                  
            else if(Curr_High >= TightLowerEMA200 && Curr_High <= TightUpperEMA200)
            {
               // Dedicated Triggers..........
               return false;
            }
            */
        }

        // Is Not Sell (Means in neutral Situation --- Mainly due to huge retracement 
        else if(!Filter_Sell_Flag[Type_Trend][Filter_1])
        {
           // Upper Situation but sell trend is off (May hint a reversal here)
           if(curr_ohlc4 < ExtremeLowerEMA200)
           {
               // Way too rare scenarios --- Also even if its true, profits are too less compare to the risk
               // This will not be the priority now, but we will still need to get it done --- LZ 
               return false;
           }
           
           
           // Between 1x Above  -5x (B)
           else if(curr_ohlc4 < TightUpperEMA200 && curr_ohlc4 >= ExtremeLowerEMA200)
           {
               // Previous trend is favoring buy 
               if((Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-H1" && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(1, 0) == "H-HLLL")
               || (Filter_Buy_Comment[Type_Reversal][Filter_1][0] == "Bull/-M15" && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "H-HLLL")
               )
               {
                  // Line Trigger 
                  if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }
                  
                  // Indicator Trigger 
                  if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }    
                  
                  // OBOS Mean Cross
                  if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
                  && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                  && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB Mean"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  } 
                  
                  // Buy OB 2x Stddev
                  if(m_AdvIndicators.GetOBOS().GetOBPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30)
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }

                  // Buy Volatility 2x StdDev
                  if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) < 30
                  && m_AdvIndicators.GetBullBear().GetBullPercent(0, 0) > 50
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Buy_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                     {
                        Filter_Buy_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }  
               }
           }         // End MID(B) Situation (Buy Continuation)           
        }
   }

////////////////////////////////////////////////////////////////////          Filter 3 Sell           /////////////////////////////////////////////////////////   
   
   
   else if(Direction == BEAR_TRIGGER && Filter_Sell_Flag[Type_Reversal][Filter_2] 
   && !Filter_Sell_Flag[Type_Breakout][Filter_1] && (!Filter_Buy_Flag[Type_Trend][Filter_2] && !Stop_Buy_Flag[Type_Trend])
   )
   {   
       // Sell - Point of Reversal
       // Reset Stop Entry when it goes back down, seeking crazier low
       if(Stop_Sell_Comment[Type_Reversal] == "Stop<=S-H1" && CandleSticksBuffer[0][0].GetClose() >= major_fractal_resistance
       && Bid > m_Indicators.GetFractal().GetFractalResistanceBarShiftUpperPrice(0, 0)
       )
            Stop_Sell_Flag[Type_Reversal] = false;
       
       // Stop Entirely When it hits H1 Support (Big decision point)
       else if(CandleSticksBuffer[0][0].GetClose() <= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(1, 0))
       {   
            Stop_Sell_Flag[Type_Reversal] = true;
            Stop_Sell_Comment[Type_Reversal] = "Stop<=S-H1";
            return false;
       } 
       
       // Automatically Pause Trigger 3 actions
       else if(Stop_Sell_Flag[Type_Reversal])
         return false;

       // Goes back above price (Do not sell anymore) --- Continuation Long incoming
       if(Bid > m_Indicators.GetFractal().GetFractalResistanceBarShiftUpperPrice(0, 0))
         return false;


//      ----------------------     Start of Reversal Logics      ----------------------
       
       
       // Volatility Spike Situation
       if(m_Indicators.GetHighLowCSATRPercent(2, 0) >= 250 && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(2, 0) == BEAR_TRIGGER
       && CandleSticksBuffer[2][0].GetTrend() == Bullish
       )
       {
           // Spike ones
           if(m_CandleStick.GetCummBodyPosition(0, 0) <= Plus_2_StdDev
           && m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev
           )
           {
              if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OB-CS>=2x"+order_zone))
              {
                  Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                  return true;
              }
           }
           
           // Spike entries
           if((CandleSticksBuffer[1][0].GetHLDiff() > (m_Indicators.GetFractal().GetFractalResistancePrice(0, 0)-m_Indicators.GetFractal().GetFractalSupportPrice(0, 0)) * EXTREME_LOOSE_STOP_LOSS_MULTIPLIER
           || CandleSticksBuffer[1][1].GetHLDiff() > (m_Indicators.GetFractal().GetFractalResistancePrice(0, 0)-m_Indicators.GetFractal().GetFractalSupportPrice(0, 0)) * EXTREME_LOOSE_STOP_LOSS_MULTIPLIER)
           && m_CandleStick.GetCummBodyPercent(0, 0) < m_CandleStick.GetCummBodyMean(0, 0)
           )
           {
               if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "CS-FRAC>=5x"+order_zone))
               {
                   Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                   return true;
               }
           }
           
           
           // ... More Triggers for Spikes Handling
           
       
       }


        // Trading Against The Stong Trend
        if(Filter_Buy_Flag[Type_Trend][Filter_1])
        {
            // Extreme Bottom
            if(curr_ohlc4 > ExtremeUpperEMA200)
            {
               // BKT + 1x <> BB
               if(band_quadrant[0] == UPPER_QUADRANT && tenkan_quadrant[0] == UPPER_QUADRANT && kijun_quadrant[0] == UPPER_QUADRANT
               && CandleSticksBuffer[0][0].GetOHLC4() > m_Indicators.GetBands().GetUpper(0, 1, 0)
               )
               {
                  // Depending on the reversal type
                  if((Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+D1" && band_quadrant[2] == UPPER_QUADRANT && tenkan_quadrant[2] == UPPER_QUADRANT && kijun_quadrant[2] == UPPER_QUADRANT && CandleSticksBuffer[2][0].GetOHLC4() > m_Indicators.GetBands().GetUpper(2, 1, 0))
                  || (Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H4" && band_quadrant[1] == UPPER_QUADRANT && tenkan_quadrant[1] == UPPER_QUADRANT && kijun_quadrant[1] == UPPER_QUADRANT && CandleSticksBuffer[1][0].GetOHLC4() > m_Indicators.GetBands().GetUpper(1, 1, 0))
                  )
                  {
                     // Top Wick Mean
                     if(m_CandleStick.GetCummTopWickMean(0, 0) > m_CandleStick.GetCummTopWickMean(0, 1)
                     && (m_CandleStick.GetCummTopWickMean(0, 1) <= 40 || m_CandleStick.GetCummTopWickMean(0, 2) <= 40)
                     )
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "CummTopMean<=40"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                  
                  
                     // CS Price action
                     if(m_CandleStick.GetCummBodyPosition(0, 0) != Null
                     && m_CandleStick.GetCummBodyPosition(0, 0) < m_CandleStick.GetCummBodyPosition(0, 1) 
                     && m_CandleStick.GetCummBodyPosition(0, 1) <= Plus_2_StdDev
                     )
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "CS>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                  
                     
                     // Indicator Trigger Goes Further Above 
                     if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2)
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }


                     // Line Trigger Goes Further Above 
                     if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2)
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }              
                     
                     // Market Bias Exhaustion 
                     if(curr_minute%15 > 10 && curr_minute%15 <= 14
                     && curr_sell_momentum_percent > curr_sell_momentum_mean && curr_sell_momentum_mean > prev_sell_momentum_mean
                     )
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "MoMMean"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }


                     // Momentum STO + Cumm Body Mean
                     if(curr_minute%15 > 10 && curr_minute%15 <= 14
                     && m_Indicators.GetSTO().GetSTOHist(0, 0) < 0 && m_Indicators.GetSTO().GetMain(0, 0) <= STO_UPPER_THRESHOLD && m_Indicators.GetSTO().GetMain(0, 0) > 50
                     && m_Indicators.GetSTO().GetSignal(0, 0) >= STO_UPPER_THRESHOLD && m_CandleStick.GetCummBodyPercent(0, 0) < m_CandleStick.GetCummBodyMean(0, 0)
                     && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                     )
                     {
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "STO-MoM"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return true;
                        }
                     }
                     
                  }     // HTF BKT
               
               }        // LTF BKT
            
            }
            
            
            // In Between 2x - 5x
            else if(curr_ohlc4 > MiddleUpperEMA200 && curr_ohlc4 <= ExtremeUpperEMA200)
            {
               // Still a pure lower low (May be higher timeframes lower low 
               if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "R-HHLH" || m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "C-HHHH")
               {
                  // Continuation of the H4/H1 Reversal ---- OR BEGINNING OF REVERAL 
                  if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(1, 0) == "H-LHHH")
                  {
                     // BKT <> 1 BB
                     if(band_quadrant[0] == UPPER_QUADRANT && tenkan_quadrant[0] == UPPER_QUADRANT && kijun_quadrant[0] == UPPER_QUADRANT
                     && CandleSticksBuffer[0][0].GetOHLC4() > m_Indicators.GetBands().GetUpper(0, 1, 0)
                     )
                     {
                        // Indicator Trigger Downwards
                        if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2)
                        {
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
   
                        // Line Trigger Downwards
                        if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2)
                        {
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }  
                        
                        // Top Wick Mean
                        if(m_CandleStick.GetCummTopWickMean(0, 0) > m_CandleStick.GetCummTopWickMean(0, 1)
                        && (m_CandleStick.GetCummTopWickMean(0, 1) <= 40 || m_CandleStick.GetCummTopWickMean(0, 2) <= 40)
                        )
                        {
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "CummTopMean<=40"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                     
                        // CS Price action
                        if(m_CandleStick.GetCummBodyPosition(0, 0) != Null 
                        && m_CandleStick.GetCummBodyPosition(0, 0) < m_CandleStick.GetCummBodyPosition(0, 1) 
                        && m_CandleStick.GetCummBodyPosition(0, 1) <= Plus_2_StdDev
                        )
                        {
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "CS>=2x"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                        
                        // Market Bias Exhaustion 
                        if(curr_minute%15 > 10 && curr_minute%15 <= 14
                        && curr_sell_momentum_percent > curr_sell_momentum_mean && curr_sell_momentum_mean > prev_sell_momentum_mean
                        )
                        {
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "MoMMean"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return true;
                           }
                        }
                        
                        // OBOS Mean Cross
                        if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
                        && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                        && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                        )
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS Mean"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        } 
                        
                        // Buy OB 2x Stddev
                        if(m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30)
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS>=2x"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        }
      
                        // Buy Volatility 2x StdDev
                        if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                        && m_AdvIndicators.GetBullBear().GetBearPercent(0, 0) > 50
                        )
                        {
                           // Check if this Trigger has been activated in the last 5 bars
                           if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                           {
                              Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                              return   true;
                           }
                        }    
                                         
                     }     // BKT Situations
 
                  }        // End of Continuation of HTF 
               
               
                  // Is an External ZigZag
                  // --- Means M15 Aligns with the other timeframe to form: Lower Low
                  else
                  {                           
                     // Line Trigger 
                     if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2
                     && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }
                     
                     // Indicator Trigger 
                     if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2
                     && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }    
                     
                     // OBOS Mean Cross
                     if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
                     && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                     && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS Mean"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     } 
                     
                     // Buy OB 2x Stddev
                     if(m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30)
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }
   
                     // Buy Volatility 2x StdDev
                     if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                     && m_AdvIndicators.GetBullBear().GetBearPercent(0, 0) > 50
                     )
                     {
                        // Check if this Trigger has been activated in the last 5 bars
                        if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                        {
                           Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                           return   true;
                        }
                     }  
                     
                  }     // End of Strong Continuation Low At Area: MID(B)   
                  
               }        // End of Pure Lower Low Situation At Area: MID(B)
               
               
               // Is a Higher low, means it retraced from the bottom already
               else if(m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "H-LHHH" || m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "C-LLLL")
               {             
                  // Market Momentum Cross
                  if(curr_buy_momentum_percent < curr_sell_momentum_percent
                  && prev_buy_momentum_percent > prev_sell_momentum_percent
                  && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  )
                  {
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "MoM-CO"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return true;
                     }
                  }
                        
                  // Line Trigger 
                  if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }
                  
                  // Indicator Trigger 
                  if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }    
                  
                  // OBOS Mean Cross
                  if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
                  && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                  && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS Mean"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  } 
                  
                  // Buy OB 2x Stddev
                  if(m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30)
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }

                  // Buy Volatility 2x StdDev
                  if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  && m_AdvIndicators.GetBullBear().GetBearPercent(0, 0) > 50
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }       
                  
               }     //    End of All Variation of Current Market Divergence Situation
            
            }        //    End of MID(B) Area
            
            
            /* In between 1x+ to 1x- are very rare --- Can explore, but not priority --- LZ
               
               - Way too rare scenarios --- Also even if its true, profits are too less compare to the risk
                  
            else if(Curr_High >= TightLowerEMA200 && Curr_High <= TightUpperEMA200)
            {
               // Dedicated Triggers..........
               return false;
            }
            */
        }

        // Is Not Sell (Means in neutral Situation --- Mainly due to huge retracement 
        else if(!Filter_Buy_Flag[Type_Trend][Filter_1])
        {
           // Upper Situation but sell trend is off (May hint a reversal here)
           if(curr_ohlc4 > ExtremeUpperEMA200)
           {
               // Way too rare scenarios --- Also even if its true, profits are too less compare to the risk
               // This will not be the priority now, but we will still need to get it done --- LZ 
               return false;
           }
           
           
           // Between 1x Above  -5x (B)
           else if(curr_ohlc4 > TightLowerEMA200 && curr_ohlc4 <= ExtremeUpperEMA200)
           {
               // Previous trend is favoring buy 
               if((Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+H1" && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(1, 0) == "H-LHHH")
               || (Filter_Sell_Comment[Type_Reversal][Filter_1][0] == "Bear/+M15" && m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(0, 0) == "H-LHHH")
               )
               {
                  // Line Trigger 
                  if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "Line>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }
                  
                  // Indicator Trigger 
                  if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2
                  && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "IND>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }    
                  
                  // OBOS Mean Cross
                  if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
                  && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
                  && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OS Mean"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  } 
                  
                  // Buy OB 2x Stddev
                  if(m_AdvIndicators.GetOBOS().GetOSPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30)
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "OB>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }

                  // Buy Volatility 2x StdDev
                  if(m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0) <= Plus_2_StdDev && m_CandleStick.GetCummBodyPercent(0, 0) > -30
                  && m_AdvIndicators.GetBullBear().GetBearPercent(0, 0) > 50
                  )
                  {
                     // Check if this Trigger has been activated in the last 5 bars
                     if(Shift_Filter_Sell_Comments(Type_Reversal, Filter_3, "VOL>=2x"+order_zone))
                     {
                        Filter_Sell_Flag[Type_Reversal][Filter_3] = true;
                        return   true;
                     }
                  }  
               }
           }         // End MID(B) Situation (Buy Continuation)           
        }

   }

   else
   {
      ResetFilterBuyFlag(Type_Reversal, Filter_3);
      ResetFilterSellFlag(Type_Reversal, Filter_3);
   }

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Reversal_Filter_4(int Direction)
{
   RefreshRates();

   // utils
   double curr_zigzag_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0);
   double curr_zigzag_low = m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0);
   
   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();
   double curr_high = CandleSticksBuffer[0][0].GetHigh();
   double curr_low = CandleSticksBuffer[0][0].GetLow();
   
   bool isUp = m_Indicators.GetFibonacci().IsUp(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   
   double curr_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double curr_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   
   double fractal_midpoint = NormalizeDouble(curr_fractal_support+((curr_fractal_resistance-curr_fractal_support)/2), Digits);
   double zigzag_midpoint = NormalizeDouble(curr_low+(curr_high-curr_low)/2, Digits);

   
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Trend_Filter_1()
{

   // Money Line + Band Trending
   if(CandleSticksBuffer[0][0].GetOHLC4() > m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0) + TIGHT_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(0, 1)
   && CandleSticksBuffer[0][0].GetOHLC4() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
   )
   {
      // D1 is also Trending
      if(CandleSticksBuffer[3][0].GetOHLC4() > m_Indicators.GetMovingAverage().GetMoneyLineMA(3, 0) + LOOSE_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(3, 1)
      && CandleSticksBuffer[3][0].GetOHLC4() > m_AdvIndicators.GetMiddleLine().GetLower(3, 0)
      )
      {
         Filter_Buy_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Trend, Filter_1, "EMA-BB/D1");
         
         ResetFilterSellFlag(Type_Trend, Filter_1);
         ResetFilterSellComment(Type_Trend, Filter_1);
         ResetFilterSellFlag(Type_Trend, Filter_2);
         ResetFilterSellFlag(Type_Trend, Filter_3);
         ResetFilterSellFlag(Type_Trend, Filter_4);
         
         if(!Open_Sell_Flag[Type_Trend])
         {
            ResetFilterSellComment(Type_Trend, Filter_2);
            ResetFilterSellComment(Type_Trend, Filter_3);
            ResetFilterSellComment(Type_Trend, Filter_4);
         }  
      }
   

      // H4 is also Trending
      else if(CandleSticksBuffer[2][0].GetOHLC4() > m_Indicators.GetMovingAverage().GetMoneyLineMA(2, 0) + LOOSE_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(2, 1)
      && CandleSticksBuffer[2][0].GetOHLC4() > m_AdvIndicators.GetMiddleLine().GetLower(2, 0)
      )
      {
         Filter_Buy_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Trend, Filter_1, "EMA-BB/H4");
         
         ResetFilterSellFlag(Type_Trend, Filter_1);
         ResetFilterSellComment(Type_Trend, Filter_1);
         ResetFilterSellFlag(Type_Trend, Filter_2);
         ResetFilterSellFlag(Type_Trend, Filter_3);
         ResetFilterSellFlag(Type_Trend, Filter_4);
         
         if(!Open_Sell_Flag[Type_Trend])
         {
            ResetFilterSellComment(Type_Trend, Filter_2);
            ResetFilterSellComment(Type_Trend, Filter_3);
            ResetFilterSellComment(Type_Trend, Filter_4);
         }  
      }   
      
      
      // Trend is below 70
      else if(m_AdvIndicators.GetTrendIndexes().GetBuyIndexesMean(0, 0) < 70)
      {
         Filter_Buy_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Trend, Filter_1, "EMA-BB-TR/M15");
         
         ResetFilterSellFlag(Type_Trend, Filter_1);
         ResetFilterSellComment(Type_Trend, Filter_1);
         ResetFilterSellFlag(Type_Trend, Filter_2);
         ResetFilterSellFlag(Type_Trend, Filter_3);
         ResetFilterSellFlag(Type_Trend, Filter_4);
         
         if(!Open_Sell_Flag[Type_Trend])
         {
            ResetFilterSellComment(Type_Trend, Filter_2);
            ResetFilterSellComment(Type_Trend, Filter_3);
            ResetFilterSellComment(Type_Trend, Filter_4);
         }  
      }
      
      else
      {
         ResetFilterSellFlag(Type_Trend, Filter_1);
         ResetFilterSellFlag(Type_Trend, Filter_2);
         ResetFilterSellFlag(Type_Trend, Filter_3);
         
         if(!Open_Sell_Flag[Type_Trend])
            ResetFilterSellComment(Type_Trend, Filter_3);       // Re-Ordering it re-enters the buy trending situation
      }
      
   }



   // Sell Situation
   // Money Line + Band Trending   
   else if(CandleSticksBuffer[0][0].GetOHLC4() < m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0) - TIGHT_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(0, 1)
   && CandleSticksBuffer[0][0].GetOHLC4() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
   )
   {
   
      // D1 is also Trending
      if(CandleSticksBuffer[3][0].GetOHLC4() < m_Indicators.GetMovingAverage().GetMoneyLineMA(3, 0) - LOOSE_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(3, 1)
      && CandleSticksBuffer[3][0].GetOHLC4() < m_AdvIndicators.GetMiddleLine().GetUpper(3, 0)
      )
      {
         Filter_Sell_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Trend, Filter_1, "EMA-BB/D1");
         
         ResetFilterBuyFlag(Type_Trend, Filter_1);
         ResetFilterBuyComment(Type_Trend, Filter_1);
         ResetFilterBuyFlag(Type_Trend, Filter_2);
         ResetFilterBuyFlag(Type_Trend, Filter_3);
         ResetFilterBuyFlag(Type_Trend, Filter_4);
         
         if(!Open_Buy_Flag[Type_Trend])
         {
            ResetFilterBuyComment(Type_Trend, Filter_2);
            ResetFilterBuyComment(Type_Trend, Filter_3);
            ResetFilterBuyComment(Type_Trend, Filter_4);
         }  
      }
   

      // H4 is also Trending
      else if(CandleSticksBuffer[2][0].GetOHLC4() < m_Indicators.GetMovingAverage().GetMoneyLineMA(2, 0) - LOOSE_STOP_LOSS_MULTIPLIER*m_Indicators.GetATR().GetATR(2, 1)
      && CandleSticksBuffer[2][0].GetOHLC4() < m_AdvIndicators.GetMiddleLine().GetUpper(2, 0)
      )
      {
         Filter_Sell_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Trend, Filter_1, "EMA-BB/H4");
         
         ResetFilterBuyFlag(Type_Trend, Filter_1);
         ResetFilterBuyComment(Type_Trend, Filter_1);
         ResetFilterBuyFlag(Type_Trend, Filter_2);
         ResetFilterBuyFlag(Type_Trend, Filter_3);
         ResetFilterBuyFlag(Type_Trend, Filter_4);
         
         if(!Open_Buy_Flag[Type_Trend])
         {
            ResetFilterBuyComment(Type_Trend, Filter_2);
            ResetFilterBuyComment(Type_Trend, Filter_3);
            ResetFilterBuyComment(Type_Trend, Filter_4);
         }  
      }   

      // Trend is below 70
      else if(m_AdvIndicators.GetTrendIndexes().GetSellIndexesMean(0, 0) < 70)
      {
         Filter_Sell_Flag[Type_Trend][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Trend, Filter_1, "EMA-BB-TR/M15");
         
         ResetFilterBuyFlag(Type_Trend, Filter_1);
         ResetFilterBuyComment(Type_Trend, Filter_1);
         ResetFilterBuyFlag(Type_Trend, Filter_2);
         ResetFilterBuyFlag(Type_Trend, Filter_3);
         ResetFilterBuyFlag(Type_Trend, Filter_4);
         
         if(!Open_Buy_Flag[Type_Trend])
         {
            ResetFilterBuyComment(Type_Trend, Filter_2);
            ResetFilterBuyComment(Type_Trend, Filter_3);
            ResetFilterBuyComment(Type_Trend, Filter_4);
         } 
      }

      else
      {
         ResetFilterBuyFlag(Type_Trend, Filter_1);
         ResetFilterBuyFlag(Type_Trend, Filter_2);
         ResetFilterBuyFlag(Type_Trend, Filter_3);
         
         if(!Open_Buy_Flag[Type_Trend])
            ResetFilterBuyComment(Type_Trend, Filter_3);       // Re-Ordering it re-enters the buy trending situation
      }
   }
   
   
   else
   {
      ResetFilterBuyFlag(Type_Trend, Filter_1);
      ResetFilterBuyFlag(Type_Trend, Filter_2);
      ResetFilterBuyFlag(Type_Trend, Filter_3);
      
      if(!Open_Buy_Flag[Type_Trend])
         ResetFilterBuyComment(Type_Trend, Filter_3);       // Re-Ordering it re-enters the buy trending situation
   
      ResetFilterSellFlag(Type_Trend, Filter_1);
      ResetFilterSellFlag(Type_Trend, Filter_2);
      ResetFilterSellFlag(Type_Trend, Filter_3);
      
      if(!Open_Sell_Flag[Type_Trend])
         ResetFilterSellComment(Type_Trend, Filter_3);       // Re-Ordering it re-enters the buy trending situation
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Trend_Filter_2(int Direction)
{

   double ZZ_M1 = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M1, 0);
   double ZZ_M5 = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M5, 0);

   // ---------------------      Bullish Trending Variation    ---------------------
   if(Direction == BULL_TRIGGER && !Filter_Buy_Flag[Type_Breakout][Filter_1])
   {
      if(ZZ_M1 > 0 && ZZ_M5 > 0)
      {
         Filter_Buy_Flag[Type_Trend][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Trend, Filter_2, "Bull/+M15");
         return true;
      }
      else if(ZZ_M1 < 0 && ZZ_M5 < 0)
      {
         ResetFilterBuyFlag(Type_Trend, Filter_2);   
         return false;
      }
      
      if(Filter_Buy_Flag[Type_Trend][Filter_2])
         return true; 
   }
         
   // ---------------------      Bearish Trending Variation    ---------------------
   else if(Direction == BEAR_TRIGGER && !Filter_Sell_Flag[Type_Breakout][Filter_1])
   {
      if(ZZ_M1 < 0 && ZZ_M5 < 0)
      {
         Filter_Sell_Flag[Type_Trend][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Trend, Filter_2, "Bear/-M15");
         return true;
      }
      else if(ZZ_M1 > 0 && ZZ_M5 > 0)
      {
         ResetFilterSellFlag(Type_Trend, Filter_2); 
         return false;
      }        
      
      if(Filter_Sell_Flag[Type_Trend][Filter_2])
         return true; 
   }
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Trend_Filter_3(int Direction)
{
   // Utils

   ENUM_QUADRANT band_quadrant[3];
   ENUM_QUADRANT tenkan_quadrant[3];
   ENUM_QUADRANT kijun_quadrant[3]; 

   ArrayInitialize(band_quadrant, UNKNOWN);
   ArrayInitialize(tenkan_quadrant, UNKNOWN);
   ArrayInitialize(kijun_quadrant, UNKNOWN);

   for(int i =0 ; i < 3; i++)
   {
      band_quadrant[i] = m_Indicators.GetBands().GetBandBias(0, i);
      tenkan_quadrant[i] = m_Indicators.GetIchimoku().GetTenKanQuadrant(0, i);
      kijun_quadrant[i] = m_Indicators.GetIchimoku().GetKijunQuadrant(0, i);
   }

   // Market Momentum
   double curr_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 0);
   double curr_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 0);

   double prev_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 1);
   double prev_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 1);
   
   double curr_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 0);
   double curr_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 0);

   double prev_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 1);
   double prev_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 1);
   
   double curr_macd_hist = m_Indicators.GetMACD().GetHistogram(0, 0);
   double prev_macd_hist = m_Indicators.GetMACD().GetHistogram(0, 1);
   
   ENUM_DUALCANDLESTICKPATTERN curr_dual_pattern = m_CandleStick.GetDualCandleStickPattern(0, 0);
   ENUM_TRIPLECANDLESTICKPATTERN curr_triple_pattern = m_CandleStick.GetTripleCandleStickPattern(0, 0);
   

   string order_zone = "";
   
   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0,0);

   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();
   int curr_minute = Minute();
   datetime curtime = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0);
   
/*
   // Order Region
   if(curr_ohlc4 <= ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(B)";
   else if(curr_ohlc4 > ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(B)";
   else if(curr_ohlc4 >= ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/TGT";  
   else if(curr_ohlc4 >= ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(T)"; 
   else if(curr_ohlc4 >= ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(T)"; 
   else
   {
      LogError(__FUNCTION__, "Failed to identify Region!");  
      return false;
   }
*/

   // Buy Situation
   if(Direction == BULL_TRIGGER && !Filter_Buy_Flag[Type_Breakout][Filter_1] && !Stop_Buy_Flag[Type_Trend] && curtime > Last_Buy_Order_Entry[Type_Trend])
   {
      // Stochastic Cross + CS Strength
      if(m_Indicators.GetSTO().GetSTOHist(0, 0) > 0 && m_Indicators.GetSTO().GetSTOHist(0, 1) <= 0
      && m_CandleStick.GetCummBodyPercent(0, 0) < 30
      )
      {
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "STO(CS)-CO"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return true;
         }
      }
      
      // Market Momentum Cross
      if(curr_buy_momentum_percent > curr_sell_momentum_percent
      && prev_buy_momentum_percent < prev_sell_momentum_percent
      && m_CandleStick.GetCummBodyPercent(0, 0) < 30
      )
      {
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "MoM-CO"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return true;
         }
      }
            
      // Line Trigger 
      if(m_AdvIndicators.GetLineTrigger().GetBuyStdDevPosition(0, 0) >= 2
      && m_CandleStick.GetCummBodyPercent(0, 0) < 30
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "Line +2"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }
      
      // Indicator Trigger 
      if(m_AdvIndicators.GetIndicatorsTrigger().GetBuyStdDevPosition(0, 0) >= 2
      && m_CandleStick.GetCummBodyPercent(0, 0) < 30
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "IND +2"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }    
      
      // OBOS Mean Cross
      if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
      && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
      && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "OB Mean"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }

      // MACD + CS Patterns
      if(curr_minute%15 > 10 && curr_minute%15 <= 14
      && GetPatternColorTriple(curr_triple_pattern) == clrSpringGreen
      && curr_macd_hist > prev_macd_hist
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "MACD+CSTriple"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }

   
      // MACD + CS Patterns
      if(curr_minute%15 > 10 && curr_minute%15 <= 14
      && GetPatternColorDual(curr_dual_pattern) == clrSpringGreen
      && curr_macd_hist > prev_macd_hist
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Trend, Filter_3, "MACD+CSDual"))
         {
            Filter_Buy_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }  
    
   }
   
   else if(Direction == BEAR_TRIGGER && !Filter_Sell_Flag[Type_Breakout][Filter_1] && !Filter_Buy_Flag[Type_Reversal][Filter_2] && !Stop_Sell_Flag[Type_Trend]
   && curtime > Last_Sell_Order_Entry[Type_Trend]
   )
   {
      // Stochastic Cross + CS Strength
      if(m_Indicators.GetSTO().GetSTOHist(0, 0) < 0 && m_Indicators.GetSTO().GetSTOHist(0, 1) >= 0
      && m_CandleStick.GetCummBodyPercent(0, 0) > -30)
      {
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "STO(CS)-CO"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return true;
         }
      }
   
      // Market Momentum Cross
      if(curr_buy_momentum_percent < curr_sell_momentum_percent
      && prev_buy_momentum_percent > prev_sell_momentum_percent
      && m_CandleStick.GetCummBodyPercent(0, 0) > -30
      )
      {
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "MoM-CO"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return true;
         }
      }
      
      // Line Trigger 
      if(m_AdvIndicators.GetLineTrigger().GetSellStdDevPosition(0, 0) >= 2
      && m_CandleStick.GetCummBodyPercent(0, 0) > -30
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "Line +2"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }
      
      // Indicator Trigger 
      if(m_AdvIndicators.GetIndicatorsTrigger().GetSellStdDevPosition(0, 0) >= 2
      && m_CandleStick.GetCummBodyPercent(0, 0) > -30
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "IND +2"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }   
      
      // OBOS Mean Cross
      if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
      && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
      && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "OS Mean"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }

      // MACD + CS Patterns
      if(curr_minute%15 > 10 && curr_minute%15 <= 14
      && GetPatternColorTriple(curr_triple_pattern) == clrOrange
      && curr_macd_hist < prev_macd_hist
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "MACD+CSTriple"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }

   
      // MACD + CS Patterns
      if(curr_minute%15 > 10 && curr_minute%15 <= 14
      && GetPatternColorDual(curr_dual_pattern) == clrOrange
      && curr_macd_hist < prev_macd_hist
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Trend, Filter_3, "MACD+CSDual"))
         {
            Filter_Sell_Flag[Type_Trend][Filter_3] = true;
            return   true;
         }
      }
     
   }
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Trend_Filter_4(int Direction)
{
   RefreshRates();

   // utils
   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();
   double hidden_takeProfit = 0, hidden_stoploss = 0;
   double RR = 0;
   string comments = "";
   
   // Buy Situation
   if(Direction == BULL_TRIGGER && (Open_Buy_Flag[Type_Continuation] || Open_Buy_Flag[Type_Reversal]))
   {
      if(Stop_Buy_Flag[Type_Trend])
         return false;
   
      // Check whether hidden profit has already been calculated before
      else if(Buy_HiddenTakeProfit[Type_Trend] > 0)
      {
         hidden_stoploss = GetNewStopLoss(Type_Trend, BULL_TRIGGER);
         RR = NormalizeDouble((Buy_HiddenTakeProfit[Type_Trend]-Ask)/(Ask-hidden_stoploss), 2);
      
         // Skip trade if minimal profit are expected from this trade
         if(Buy_HiddenTakeProfit[Type_Trend] - Ask < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Buy_Flag[Type_Trend] = true;
            Stop_Buy_Comment[Type_Trend] = ">=HP-"+DoubleToStr(Buy_HiddenTakeProfit[Type_Trend], Digits);
            return false;
         }
      
         Filter_Buy_Flag[Type_Trend][Filter_4] = true;
         return true;
      }

      // Set up Hidden Profit first
      else if(m_AdvIndicators.GetBullBear().GetBullPercent(0, 0) > 50 && m_AdvIndicators.GetBullBear().GetBullPercent(1, 0) >= 50)
      {
         // Get Hidden take profit first to see whether its viable
         if(Open_Buy_Flag[Type_Continuation])
         {
            hidden_takeProfit = Buy_HiddenTakeProfit[Type_Continuation];
            comments = Filter_Buy_Comment[Type_Continuation][Filter_4][0];
         }
         else if(Open_Buy_Flag[Type_Reversal])
         {
            hidden_takeProfit = Buy_HiddenTakeProfit[Type_Reversal];      
            comments = Filter_Buy_Comment[Type_Reversal][Filter_4][0];
         }  
         else
         {
            LogError(__FUNCTION__, "Both Continuation/Reversal are not opened...");
            return false;
         }
         
         // Set Hidden Stop Loss first
         hidden_stoploss = GetNewStopLoss(Type_Trend, BULL_TRIGGER);
         
         // Skip trade if minimal profit are expected from this trade
         if(hidden_takeProfit - Ask > m_AccountManager.GetMinimumStopLossPip()
         && Ask-hidden_stoploss < m_AccountManager.GetMaximumStopLossPip()
         )
         {
            // Still got profit to rigged (Manages stop loss to allow maximum profit)
            Filter_Buy_Flag[Type_Trend][Filter_4] = true;
            Buy_HiddenTakeProfit[Type_Trend] = hidden_takeProfit;
            Buy_HiddenStopLoss[Type_Trend] = hidden_stoploss;
            Shift_Filter_Buy_Comments(Type_Trend, Filter_4, comments);
            return true;
         }  
      }
   }  
   
   // Sell Sitaution
   else if(Direction == BEAR_TRIGGER && (Open_Sell_Flag[Type_Continuation] || Open_Sell_Flag[Type_Reversal]))
   {
      if(Stop_Sell_Flag[Type_Trend])
         return false;
   
      // Check whether hidden profit has already been calculated before
      else if(Sell_HiddenTakeProfit[Type_Trend] > 0)
      {
         hidden_stoploss = GetNewStopLoss(Type_Trend, BEAR_TRIGGER);
         RR = NormalizeDouble((Bid-Sell_HiddenTakeProfit[Type_Trend])/(hidden_stoploss-Bid), 2);
      
         // Skip trade if minimal profit are expected from this trade
         if(Bid-Sell_HiddenTakeProfit[Type_Trend] < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Sell_Flag[Type_Trend] = true;
            Stop_Sell_Comment[Type_Trend] = "<=HP-"+DoubleToStr(Sell_HiddenTakeProfit[Type_Trend], Digits);
            return false;
         }
      
         Filter_Sell_Flag[Type_Trend][Filter_4] = true;
         return true;
      }

      // Set up Hidden Profit first
      else if(m_AdvIndicators.GetBullBear().GetBearPercent(0, 0) > 50 && m_AdvIndicators.GetBullBear().GetBearPercent(1, 0) >= 50)
      {
         // Get Hidden take profit first to see whether its viable
         if(Open_Sell_Flag[Type_Continuation])
         {
            hidden_takeProfit = Sell_HiddenTakeProfit[Type_Continuation];
            comments = Filter_Sell_Comment[Type_Continuation][Filter_4][0];
         }
         else if(Open_Sell_Flag[Type_Reversal])
         {
            hidden_takeProfit = Sell_HiddenTakeProfit[Type_Reversal];      
            comments = Filter_Sell_Comment[Type_Reversal][Filter_4][0];
         }  
         else
         {
            LogError(__FUNCTION__, "Both Continuation/Reversal are not opened...");
            return false;
         }
         
         // Set Hidden stop loss
         hidden_stoploss = GetNewStopLoss(Type_Trend, BEAR_TRIGGER);
         
         // Skip trade if minimal profit are expected from this trade
         if(Bid - hidden_takeProfit > m_AccountManager.GetMinimumStopLossPip()
         && hidden_stoploss-Bid < m_AccountManager.GetMaximumStopLossPip()
         )
         {
            // Still got profit to rigged (Manages stop loss to allow maximum profit)
            Filter_Sell_Flag[Type_Trend][Filter_4] = true;
            Sell_HiddenTakeProfit[Type_Trend] = hidden_takeProfit;
            Sell_HiddenStopLoss[Type_Trend] = hidden_stoploss;
            Shift_Filter_Sell_Comments(Type_Trend, Filter_4, comments);
            return true;
         }  
      }
   }  

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Continuation_Filter_1()
{
   // Utils
   double zz[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int    divergence_type[ENUM_TIMEFRAMES_ARRAY_SIZE][4];
   
   ArrayInitialize(zz, 0);
   ArrayInitialize(divergence_type, NEUTRAL);

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      zz[i] = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(i), 0);
      
      for(int j = 0; j < 4; j++)
         divergence_type[i][j] = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(i, j);   
      
   }
   double ZZ_M1 = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M1, 0);
   double ZZ_M5 = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M5, 0);


   // ---------------------     >M15 Buy Continuation Situation    ---------------------
   if(zz[0] < 0)
   {
      // D1 Continuation
      if(divergence_type[3][0] == BEAR_TRIGGER && divergence_type[3][2] == BULL_TRIGGER)
      {
         Filter_Buy_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "Bull/+D1");
         
         
         ResetAllFilterSellFlag(Type_Continuation);
         if(!Open_Sell_Flag[Type_Continuation])
         {
            ResetFilterSellComment(Type_Continuation, Filter_1);
            ResetFilterSellComment(Type_Continuation, Filter_2);
            ResetFilterSellComment(Type_Continuation, Filter_3);
         }         
      }

      // H4 Continuation
      else if(divergence_type[2][0] == BEAR_TRIGGER && divergence_type[2][3] == BULL_TRIGGER)
      {
         Filter_Buy_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "Bull/+H4");
         
         ResetAllFilterSellFlag(Type_Continuation);
         if(!Open_Sell_Flag[Type_Continuation])
         {
            ResetFilterSellComment(Type_Continuation, Filter_1);
            ResetFilterSellComment(Type_Continuation, Filter_2);
            ResetFilterSellComment(Type_Continuation, Filter_3);
         }
      }
      
      // H1 Continuation
      else if(divergence_type[1][0] == BEAR_TRIGGER && divergence_type[1][3] == BULL_TRIGGER)
      {
         Filter_Buy_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "Bull/+H1");
         
         ResetAllFilterSellFlag(Type_Continuation);
         if(!Open_Sell_Flag[Type_Continuation])
         {
            ResetFilterSellComment(Type_Continuation, Filter_1);
            ResetFilterSellComment(Type_Continuation, Filter_2);
            ResetFilterSellComment(Type_Continuation, Filter_3);
         }
      }
      
      // Continuation With the trend
      else if(Filter_Buy_Flag[Type_Trend][Filter_1] || Filter_Buy_Comment[Type_Trend][Filter_1][0] != "----")
      {
         Filter_Buy_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "Bull/-M15");
         
         ResetAllFilterSellFlag(Type_Continuation);
         if(!Open_Sell_Flag[Type_Continuation])
         {
            ResetFilterSellComment(Type_Continuation, Filter_1);
            ResetFilterSellComment(Type_Continuation, Filter_2);
            ResetFilterSellComment(Type_Continuation, Filter_3);
         }
      }
      
      else
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
      }
      

   }
   
   // ---------------------     >M15 Sell Continuation Situation      ---------------------
   else if(zz[0] > 0)
   {
      // D1 Continuation
      if(divergence_type[3][0] == BULL_TRIGGER && divergence_type[3][2] == BEAR_TRIGGER)
      {
         Filter_Sell_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "Bear/-D1");
         
         ResetAllFilterBuyFlag(Type_Continuation);
         if(!Open_Buy_Flag[Type_Continuation])
         {
            ResetFilterBuyComment(Type_Continuation, Filter_1);
            ResetFilterBuyComment(Type_Continuation, Filter_2);
            ResetFilterBuyComment(Type_Continuation, Filter_3);
         }
      }

      // H4 Continuation
      else if(divergence_type[2][0] == BULL_TRIGGER && divergence_type[2][3] == BEAR_TRIGGER)
      {
         Filter_Sell_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "Bear/-H4");
         
         ResetAllFilterBuyFlag(Type_Continuation);
         if(!Open_Buy_Flag[Type_Continuation])
         {
            ResetFilterBuyComment(Type_Continuation, Filter_1);
            ResetFilterBuyComment(Type_Continuation, Filter_2);
            ResetFilterBuyComment(Type_Continuation, Filter_3);
         }
      }
      
      // H1 Continuation
      else if(divergence_type[1][0] == BULL_TRIGGER && divergence_type[1][3] == BEAR_TRIGGER)
      {
         Filter_Sell_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "Bear/-H1");
         
         ResetAllFilterBuyFlag(Type_Continuation);
         if(!Open_Buy_Flag[Type_Continuation])
         {
            ResetFilterBuyComment(Type_Continuation, Filter_1);
            ResetFilterBuyComment(Type_Continuation, Filter_2);
            ResetFilterBuyComment(Type_Continuation, Filter_3);
         }
      }
      
      // Continuation With the trend
      else if(Filter_Sell_Flag[Type_Trend][Filter_1] || Filter_Sell_Comment[Type_Trend][Filter_1][0] != "----")
      {
         Filter_Sell_Flag[Type_Continuation][Filter_1] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "Bear/+M15");
         
         ResetAllFilterBuyFlag(Type_Continuation);
         if(!Open_Buy_Flag[Type_Continuation])
         {
            ResetFilterBuyComment(Type_Continuation, Filter_1);
            ResetFilterBuyComment(Type_Continuation, Filter_2);
            ResetFilterBuyComment(Type_Continuation, Filter_3);
         }
      }
      
      else
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
      }
      
      
   }
   
   // ---------------------     M5 Buy Continuation Situation    ---------------------
   else if(Filter_Buy_Flag[Type_Trend][Filter_1] && ZZ_M1 < 0 && ZZ_M5 < 0)
   {
      Filter_Buy_Flag[Type_Continuation][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Continuation, Filter_1, "Bull/-M5");
         
      ResetAllFilterSellFlag(Type_Continuation);
      if(!Open_Sell_Flag[Type_Continuation])
      {
         ResetFilterSellComment(Type_Continuation, Filter_1);
         ResetFilterSellComment(Type_Continuation, Filter_2);
         ResetFilterSellComment(Type_Continuation, Filter_3);
      }
   }
   
   // ---------------------     M5 Buy Continuation Situation    ---------------------
   else if(Filter_Sell_Flag[Type_Trend][Filter_1] && ZZ_M1 > 0 && ZZ_M5 > 0)
   {
       Filter_Sell_Flag[Type_Continuation][Filter_1] = true;
       Shift_Filter_Sell_Comments(Type_Continuation, Filter_1, "Bear/+M5");
       
       ResetAllFilterBuyFlag(Type_Continuation);
       if(!Open_Buy_Flag[Type_Continuation])
       {
          ResetFilterBuyComment(Type_Continuation, Filter_1);
          ResetFilterBuyComment(Type_Continuation, Filter_2);
          ResetFilterBuyComment(Type_Continuation, Filter_3);
       }
   }
   
   
   // Not all possible scenarios (Reset Filter 2)
   else
   {
      ResetFilterBuyFlag(Type_Continuation, Filter_2);
      ResetFilterSellFlag(Type_Continuation, Filter_2);
   }
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Continuation_Filter_2(int Direction)
{
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   int timeframeIndex = 0;


   if(Direction == BULL_TRIGGER)
   {
      // Get the timeframe index to check on first
      if(Filter_Buy_Comment[Type_Continuation][Filter_1][0] == "Bull/+D1")
         timeframeIndex = 2;
      else if(Filter_Buy_Comment[Type_Continuation][Filter_1][0] == "Bull/+H4")
         timeframeIndex = 1;
      
      // Tenkan Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "Tenkan Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) -TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) +MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }
      
      // Tenkan Line Rebound
      else if(CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) 
      && CandleSticksBuffer[0][1].GetLow() <= m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetLow() > m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 2)
      && (CandleSticksBuffer[0][0].GetClose() >= m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) -TIGHT_STOP_LOSS_MULTIPLIER*atr 
      && CandleSticksBuffer[0][0].GetClose() <= m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) +MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      ) 
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "Tenkan Rebound");
         return true;
      }
      
      // Kijun Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "Kijun Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0)-TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0)+MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }
      
      // Kijun Line Rebound         
      else if(CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0) 
      && CandleSticksBuffer[0][1].GetLow() <= m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetLow() > m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 2)
      ) 
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "Kijun Rebound");
         return true;
      }
      

      // Kijun Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "BB Mean Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetBands().GetMain(timeframeIndex, 0) -TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetBands().GetMain(timeframeIndex, 0) +MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }

      
      // Band Mean Rebound         
      else if(CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetBands().GetMain(timeframeIndex, 0) 
      && CandleSticksBuffer[0][1].GetLow() <= m_Indicators.GetBands().GetMain(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetLow() > m_Indicators.GetBands().GetMain(timeframeIndex, 2)
      ) 
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "BB Mean Rebound");
         return true;
      }         


      // Continuation D1 Invalidation
      else if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "D1R Rebound"
      && CandleSticksBuffer[0][0].GetClose() <= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(3, 0)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }  
            
      // Continuation On the D1 Fractal Resistance
      else if(IsPriceBounceSupport(0, m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(3, 0), 0))
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "D1R Rebound");
         return true;
      }


      // Continuation H4 Invalidation
      else if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "H4R Rebound"
      && CandleSticksBuffer[0][0].GetClose() <= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(2, 0)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }
      // Continuation On the H4 Fractal Resistance
      else if(IsPriceBounceSupport(0, m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(2, 0), 0))
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "H4R Rebound");
         return true;
      }

      // Continuation H4 Invalidation
      else if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "H1R Rebound"
      && CandleSticksBuffer[0][0].GetClose() <= m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(1, 0)
      )
      {
         ResetFilterBuyFlag(Type_Continuation, Filter_2);
         ResetFilterBuyFlag(Type_Continuation, Filter_3);
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "N/A");
      }
      // Continuation On the H1 Fractal Resistance
      else if(IsPriceBounceSupport(0, m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(1, 0), 0))
      {
         Filter_Buy_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Buy_Comments(Type_Continuation, Filter_2, "H1R Rebound");
         return true;
      }   
      
   }
   
   
   // Sell Continuation Zone
   else if(Direction == BEAR_TRIGGER)
   {
      // Get the timeframe index to check on first
      if(Filter_Sell_Comment[Type_Continuation][Filter_1][0] == "Bear/-D1")
         timeframeIndex = 2;
      else if(Filter_Sell_Comment[Type_Continuation][Filter_1][0] == "Bear/-H4")
         timeframeIndex = 1;


      // Tenkan Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Sell_Comment[Type_Continuation][Filter_2][0] == "Tenkan Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) -TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0) +MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
      
      // Tenkan Line Rebound
      else if(CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 0)
      && CandleSticksBuffer[0][1].GetHigh() >= m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetHigh() < m_Indicators.GetIchimoku().GetTenkanSen(timeframeIndex, 2)
      ) 
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "Tenkan Rebound");
         return true;
      }
      
      // Kijun Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "Kijun Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0)-TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0)+MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
      
      // Kijun Line Rebound         
      else if(CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 0)
      && CandleSticksBuffer[0][1].GetHigh() >= m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetHigh() < m_Indicators.GetIchimoku().GetKijunSen(timeframeIndex, 2)
      ) 
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "Kijun Rebound");
         return true;
      }
      
      
      // Kijun Line Rebound Existed (Invalidate it if goes way too below or way too above)
      if(Filter_Buy_Comment[Type_Continuation][Filter_2][0] == "BB Mean Rebound"
      && (CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetBands().GetMain(timeframeIndex, 0) -TIGHT_STOP_LOSS_MULTIPLIER*atr
      || CandleSticksBuffer[0][0].GetClose() > m_Indicators.GetBands().GetMain(timeframeIndex, 0) +MEDIUM_STOP_LOSS_MULTIPLIER*atr)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
      
      
      // Band Mean Rebound         
      else if(CandleSticksBuffer[0][0].GetClose() < m_Indicators.GetBands().GetMain(timeframeIndex, 0)
      && CandleSticksBuffer[0][1].GetHigh() >= m_Indicators.GetBands().GetMain(timeframeIndex, 1) && CandleSticksBuffer[0][2].GetHigh() < m_Indicators.GetBands().GetMain(timeframeIndex, 2)
      ) 
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "BB Mean Rebound");
         return true;
      }       

      // Continuation D1 Invalidation
      else if(Filter_Sell_Comment[Type_Continuation][Filter_2][0] == "D1S Rebound"
      && CandleSticksBuffer[0][0].GetClose() >= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(3, 0)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
 
      // Continuation On the D1 Fractal Support
      else if(IsPriceBounceResist(0, m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(3, 0), 0))
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "D1S Rebound");
         return true;
      }

      // Continuation H4 Invalidation
      else if(Filter_Sell_Comment[Type_Continuation][Filter_2][0] == "H4S Rebound"
      && CandleSticksBuffer[0][0].GetClose() >= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(2, 0)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
      // Continuation On the H4 Fractal Support
      else if(IsPriceBounceResist(0, m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(2, 0), 0))
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "H4S Rebound");
         return true;
      }

      // Continuation H1 Invalidation
      else if(Filter_Sell_Comment[Type_Continuation][Filter_2][0] == "H1S Rebound"
      && CandleSticksBuffer[0][0].GetClose() >= m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(1, 0)
      )
      {
         ResetFilterSellFlag(Type_Continuation, Filter_2);
         ResetFilterSellFlag(Type_Continuation, Filter_3);
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "N/A");
      }
      // Continuation On the H1 Fractal Support
      else if(IsPriceBounceResist(0, m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0), 0))
      {
         Filter_Sell_Flag[Type_Continuation][Filter_2] = true;
         Shift_Filter_Sell_Comments(Type_Continuation, Filter_2, "H1S Rebound");
         return true;
      }
      
   }
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Continuation_Filter_3(int Direction)
{
   // utils
   ENUM_MARKET_CONDITION curr_market_condition = m_MarketCondition.GetEnumMarketCondition(0, 0);
   
   double curr_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 0);
   double curr_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 0);

   double prev_buy_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(0, 1);
   double prev_sell_momentum_percent = m_AdvIndicators.GetMarketMomentum().GetSellPercent(0, 1);

   double curr_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 0);
   double curr_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 0);

   double prev_ob_mean = m_AdvIndicators.GetOBOS().GetOBMean(0, 1);
   double prev_os_mean = m_AdvIndicators.GetOBOS().GetOSMean(0, 1);

   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);

   string order_zone = "";
   
   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();
   
   int curr_minute = Minute();
   datetime curtime = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0);
   
/*
   // Order Region
   if(curr_ohlc4 <= ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(B)";
   else if(curr_ohlc4 > ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(B)";
   else if(curr_ohlc4 >= ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/TGT";  
   else if(curr_ohlc4 >= ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(T)"; 
   else if(curr_ohlc4 >= ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(T)"; 
   else
   {
      LogError(__FUNCTION__, "Failed to identify Region!");  
      return false;
   }
*/

   if(Direction == BULL_TRIGGER && !Filter_Sell_Flag[Type_Trend][Filter_1] && !Filter_Buy_Flag[Type_Breakout][Filter_1]
   && curtime > Last_Buy_Order_Entry[Type_Continuation]
   )
   {
      // Market Momentum Cross
      if(curr_buy_momentum_percent > curr_sell_momentum_percent
      && prev_buy_momentum_percent < prev_sell_momentum_percent
      && m_CandleStick.GetCummBodyPercent(0, 0) < 35
      )
      {
         if(Shift_Filter_Buy_Comments(Type_Continuation, Filter_3, "MoM-CO"))
         {
            Filter_Buy_Flag[Type_Continuation][Filter_3] = true;
            return true;
         }
      }  
      
      // OBOS Mean Cross
      if(curr_ob_mean > curr_os_mean && prev_ob_mean <= prev_os_mean
      && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
      && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Buy_Comments(Type_Continuation, Filter_3, "OB Mean"))
         {
            Filter_Buy_Flag[Type_Continuation][Filter_3] = true;
            return   true;
         }
      }
           
   }
   
   else if(Direction == BEAR_TRIGGER && !Filter_Sell_Flag[Type_Breakout][Filter_1] && !Filter_Buy_Flag[Type_Trend][Filter_1]
   && curtime > Last_Sell_Order_Entry[Type_Continuation]
   )
   {   
      // Market Momentum Cross
      if(curr_buy_momentum_percent < curr_sell_momentum_percent
      && prev_buy_momentum_percent > prev_sell_momentum_percent
      && m_CandleStick.GetCummBodyPercent(0, 0) > -35
      )
      {
         if(Shift_Filter_Sell_Comments(Type_Continuation, Filter_3, "MoM-CO"))
         {
            Filter_Sell_Flag[Type_Continuation][Filter_3] = true;
            return true;
         }
      }
      
      // OBOS Mean Cross
      if(curr_ob_mean < curr_os_mean && prev_ob_mean >= prev_os_mean
      && CandleSticksBuffer[0][0].GetClose() < m_AdvIndicators.GetMiddleLine().GetUpper(0, 0)
      && CandleSticksBuffer[0][0].GetClose() > m_AdvIndicators.GetMiddleLine().GetLower(0, 0)
      )
      {
         // Check if this Trigger has been activated in the last 5 bars
         if(Shift_Filter_Sell_Comments(Type_Continuation, Filter_3, "OS Mean"))
         {
            Filter_Sell_Flag[Type_Continuation][Filter_3] = true;
            return   true;
         }
      }     
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Continuation_Filter_4(int Direction)
{
   RefreshRates();

   // utils
   double curr_zigzag_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0);
   double curr_zigzag_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
   
   double curr_high = CandleSticksBuffer[0][0].GetHigh();
   double curr_low = CandleSticksBuffer[0][0].GetLow();
   
   bool isUp = m_Indicators.GetFibonacci().IsUp(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   
   double curr_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double curr_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   
   double fractal_midpoint = NormalizeDouble(curr_fractal_support+((curr_fractal_resistance-curr_fractal_support)/2), Digits);
   double zigzag_midpoint = NormalizeDouble(curr_zigzag_low+(curr_zigzag_high-curr_zigzag_low)/2, Digits);

   // Buy Situation
   if(Direction == BULL_TRIGGER)
   {
      // Stop Trade when it's time out
      if(Stop_Buy_Flag[Type_Continuation])
         return false;
   
      // Check whether hidden profit has already been calculated before
      else if(Buy_HiddenTakeProfit[Type_Continuation] > 0)
      {
         // Skip trade if minimal profit are expected from this trade
         if(Buy_HiddenTakeProfit[Type_Continuation] - Ask < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Buy_Flag[Type_Continuation] = true;
            Stop_Buy_Comment[Type_Continuation] = ">=HP-"+DoubleToStr(Buy_HiddenTakeProfit[Type_Continuation], Digits);
            return false;
         }
       
         // Still got profit to rigged (Manages stop loss to allow maximum profit)
         Filter_Buy_Flag[Type_Continuation][Filter_4] = true;
         return true;
      }
   
      // Calculate the hidden take profit --- Check the zone of the current price 
      else if(curr_high < curr_zigzag_high && m_Indicators.GetZigZag().GetZigZagHighShift(0, 0) >= 5)
      {
        // Get the high order block
        double orderBlockLower = iLow(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, m_Indicators.GetZigZag().GetZigZagHighShift(0, 0));
        double orderBlockUpper = iHigh(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, m_Indicators.GetZigZag().GetZigZagHighShift(0, 0));
        double orderBlockSize = orderBlockUpper-orderBlockLower;
        double zigzag_size = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0)-MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
        
         // Strong Continuation (Means anticipating zigzag will continue print high)
         if(isUp)
         {
            // Fibonacci for higher return
            for(int i = 7; i < FIBONACCI_LEVELS_SIZE; i++)
            {
               double fibonacci_level = m_Indicators.GetFibonacci().GetUpFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
            
               // Max Price is below the fibonacci line at the moment + Buying at Discounted price
               if(fibonacci_level > Ask+TIGHT_STOP_LOSS_MULTIPLIER*atr
               && curr_high < fibonacci_level 
               && Ask <= fractal_midpoint
               )
               {
                  Buy_HiddenTakeProfit[Type_Continuation] = fibonacci_level;
                  Buy_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BULL_TRIGGER);
                  Filter_Buy_Flag[Type_Continuation][Filter_4] = true;
                  Shift_Filter_Buy_Comments(Type_Continuation, Filter_4, "Fib-"+string(fibonacci_level));
                  return true;
               }
            }
         }      
              
         // Retraced Continuation
         else if(!isUp)
         {         
            // ZigZag Size too big, aim as liquidity sweep
            if(orderBlockSize >= zigzag_size*0.35)
            {
               if(curr_high < orderBlockUpper
               && orderBlockUpper > Ask+TIGHT_STOP_LOSS_MULTIPLIER*atr
               && Ask <= zigzag_midpoint
               )
               {
                   Buy_HiddenTakeProfit[Type_Continuation] = orderBlockUpper;
                   Buy_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BULL_TRIGGER);
                   Filter_Buy_Flag[Type_Continuation][Filter_4] = true;
                   Shift_Filter_Buy_Comments(Type_Continuation, Filter_4, "OB(S)-"+string(orderBlockUpper));
                   return true;
               }
            }
            
            else
            {
               if(curr_high < orderBlockLower
               && orderBlockLower > Ask+TIGHT_STOP_LOSS_MULTIPLIER*atr
               && Ask <= zigzag_midpoint
               )
               {
                   Buy_HiddenTakeProfit[Type_Continuation] = orderBlockLower;
                   Buy_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BULL_TRIGGER);
                   Filter_Buy_Flag[Type_Continuation][Filter_4] = true;
                   Shift_Filter_Buy_Comments(Type_Continuation, Filter_4, "OB-"+string(orderBlockLower));
                   return true;
               }
            }
         }  
      }
   }
   
   // Sell Situation
   else if(Direction == BEAR_TRIGGER)
   {
      // Stop Trade when it's time out
      if(Stop_Sell_Flag[Type_Continuation])
         return false;
   
      // Check whether hidden profit has already been calculated before
      else if(Sell_HiddenTakeProfit[Type_Continuation] > 0)
      {
         // Skip trade if minimal profit are expected from this trade
         if(Bid - Sell_HiddenTakeProfit[Type_Continuation] < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Sell_Flag[Type_Continuation] = true;
            Stop_Sell_Comment[Type_Continuation] = "<=HP-"+DoubleToStr(Sell_HiddenTakeProfit[Type_Continuation], Digits);      // Close to hidden profit
            return false;
         }
           
         // Still got profit to rigged (Manages stop loss to allow maximum profit)
         Filter_Sell_Flag[Type_Continuation][Filter_4] = true;
         return true;
      }
   
      // Calculate the hidden take profit --- Check the zone of the current price 
      else if(curr_low > curr_zigzag_low && m_Indicators.GetZigZag().GetZigZagLowShift(0, 0) >= 5)
      {
        // Get the high order block
        double orderBlockLower = iLow(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, m_Indicators.GetZigZag().GetZigZagLowShift(0, 0));
        double orderBlockUpper = iHigh(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, m_Indicators.GetZigZag().GetZigZagLowShift(0, 0));
        double orderBlockSize = orderBlockUpper-orderBlockLower;
        double zigzag_size = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0)-MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
        
         // Strong Continuation (Means anticipating zigzag will continue print high)
         if(!isUp)
         {         
            // Fibonacci for higher return
            for(int i = 7; i < FIBONACCI_LEVELS_SIZE; i++)
            {
               double fibonacci_level = m_Indicators.GetFibonacci().GetDownFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
            
               // Max Price is below the fibonacci line at the moment + Buying at Discounted price
               if(fibonacci_level < Bid-TIGHT_STOP_LOSS_MULTIPLIER*atr
               && curr_low > fibonacci_level && Bid >= fractal_midpoint
               )
               {
                  Sell_HiddenTakeProfit[Type_Continuation] = fibonacci_level;
                  Sell_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BEAR_TRIGGER);
                  Filter_Sell_Flag[Type_Continuation][Filter_4] = true;
                  Shift_Filter_Sell_Comments(Type_Continuation, Filter_4, "Fib-"+string(fibonacci_level));
                  return true;
               }
            }
         }     
         
         // Retraced Continuation
         else if(isUp)
         {
            // ZigZag Size too big, aim as liquidity sweep
            if(orderBlockSize >= zigzag_size*0.35)
            {
               if(curr_low > orderBlockLower
               && orderBlockLower < Bid-TIGHT_STOP_LOSS_MULTIPLIER*atr
               && Bid >= zigzag_midpoint
               )
               {
                  Sell_HiddenTakeProfit[Type_Continuation] = orderBlockLower;
                  Sell_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BEAR_TRIGGER);
                  Filter_Sell_Flag[Type_Continuation][Filter_4] = true;
                  Shift_Filter_Sell_Comments(Type_Continuation, Filter_4, "OB(S)-"+DoubleToStr(orderBlockLower, Digits));
                  return true;
               }
            }
            
            else
            {
               if(curr_low > orderBlockUpper
               && orderBlockUpper < Bid-TIGHT_STOP_LOSS_MULTIPLIER*atr
               && Bid >= zigzag_midpoint
               )
               {
                  Sell_HiddenTakeProfit[Type_Continuation] = orderBlockUpper;
                  Sell_HiddenStopLoss[Type_Continuation] = GetNewStopLoss(Type_Continuation, BEAR_TRIGGER);
                  Filter_Sell_Flag[Type_Continuation][Filter_4] = true;
                  Shift_Filter_Sell_Comments(Type_Continuation, Filter_4, "OB-"+DoubleToStr(orderBlockUpper, Digits));
                  return true;
               }
            }
         }
      }
   }
   
   return false;
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Breakout_Filter_1()
{   
   ENUM_MARKET_CONDITION curr_market_condition = m_MarketCondition.GetEnumMarketCondition(0, 0);
   double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);


   if(curr_market_condition == Bull_Squeeze || curr_market_condition == Bear_Squeeze)
   {
      Filter_Buy_Flag[Type_Breakout][Filter_1] = true;
      Filter_Sell_Flag[Type_Breakout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Breakout, Filter_1, "SQ/M15");
      Shift_Filter_Sell_Comments(Type_Breakout, Filter_1, "SQ/M15"); 
   }
   
   else if(curr_market_condition == Bull_Channel || curr_market_condition == Bear_Channel)
   {
      Filter_Buy_Flag[Type_Breakout][Filter_1] = true;
      Filter_Sell_Flag[Type_Breakout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Breakout, Filter_1, "CH/M15");
      Shift_Filter_Sell_Comments(Type_Breakout, Filter_1, "CH/M15"); 
   }
/*
   else if(m_Indicators.GetBands().GetBandBias(0, 0) == FULL_QUADRANT && m_Indicators.GetIchimoku().GetKijunQuadrant(0, 0) != m_Indicators.GetIchimoku().GetTenKanQuadrant(0, 0)
   && m_Indicators.GetIchimoku().GetKijunQuadrant(0, 0) != FULL_QUADRANT
   && (fractal_support-fractal_resistance) <= m_AccountManager.GetAverageDailyPriceMovement() * 0.15
   )
   {
      Filter_Buy_Flag[Type_Breakout][Filter_1] = true;
      Filter_Sell_Flag[Type_Breakout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Breakout, Filter_1, "LOGIC/M15");
      Shift_Filter_Sell_Comments(Type_Breakout, Filter_1, "LOGIC/M15"); 
   }
*/
   // Fractal M15 == Fractal H1 && 
   else if(fractal_resistance == m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(1, 0)
   && fractal_support == m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(1, 0) 
   && (fractal_support-fractal_resistance) <= m_AccountManager.GetAverageDailyPriceMovement() * 0.15
   )
   {
      Filter_Buy_Flag[Type_Breakout][Filter_1] = true;
      Filter_Sell_Flag[Type_Breakout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Breakout, Filter_1, "FRAC=M15H1");
      Shift_Filter_Sell_Comments(Type_Breakout, Filter_1, "FRAC=M15H1"); 
   }
   
   
   else
   {
      ResetAllFilterBuyFlag(Type_Breakout);
      ResetAllFilterSellFlag(Type_Breakout);
   
      if(!Open_Buy_Flag[Type_Breakout])
      {
         ResetFilterBuyComment(Type_Breakout, Filter_1);
         ResetFilterBuyComment(Type_Breakout, Filter_2);
         ResetFilterBuyComment(Type_Breakout, Filter_3);
      }

      if(!Open_Sell_Flag[Type_Breakout])
      {
         ResetFilterSellComment(Type_Breakout, Filter_1);
         ResetFilterSellComment(Type_Breakout, Filter_2);
         ResetFilterSellComment(Type_Breakout, Filter_3);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int GuanStrategy::Breakout_Filter_2()
{
   /*
      Objective - Price Breakout of one of the S/R with 
   */
        
   // Utils
   double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);

   double fractal_AnchoredResistance = m_MarketCondition.GetAnchoredResistance(0);
   double fractal_AchoredSupport = m_MarketCondition.GetAnchoredSupport(0);

   double close_price = CandleSticksBuffer[0][0].GetClose();
   

   if(close_price > fractal_support && close_price < fractal_resistance)
   {
      if(Filter_Buy_Flag[Type_Breakout][Filter_2])
         ResetFilterBuyFlag(Type_Breakout, Filter_2);
      else if(Filter_Sell_Flag[Type_Breakout][Filter_2]) 
         ResetFilterSellFlag(Type_Breakout, Filter_2);
      return NEUTRAL;
   }
   
   // Not in a sell
   if(!Open_Sell_Flag[Type_Breakout])
   {
      // Start of breakout logics
      if(IsPriceBreakOutResist(0, fractal_AnchoredResistance, 0))
      {
         Filter_Buy_Flag[Type_Breakout][Filter_2] = true;
         Filter_Sell_Flag[Type_Breakout][Filter_2] = false;
         Shift_Filter_Buy_Comments(Type_Breakout, Filter_2, "FracR-BO");
         return BULL_TRIGGER;
      }
      else if(IsPriceBreakOutResist(0, fractal_AchoredSupport, 0))
      {
         Filter_Buy_Flag[Type_Breakout][Filter_2] = true;
         Filter_Sell_Flag[Type_Breakout][Filter_2] = false;
         Shift_Filter_Buy_Comments(Type_Breakout, Filter_2, "FracS-BO");
         return BULL_TRIGGER;
      }

   }
   
   // Not in a buy
   if(!Open_Buy_Flag[Type_Breakout])
   {
      if(IsPriceBreakDownSupport(0, fractal_AnchoredResistance, 0))
      {
         Filter_Sell_Flag[Type_Breakout][Filter_2] = true;
         Filter_Buy_Flag[Type_Breakout][Filter_2] = false;
         Shift_Filter_Sell_Comments(Type_Breakout, Filter_2, "FracR-BD");
         return BEAR_TRIGGER;
      }
      else if(IsPriceBreakDownSupport(0, fractal_AchoredSupport, 0))
      {
         Filter_Sell_Flag[Type_Breakout][Filter_2] = true;
         Filter_Buy_Flag[Type_Breakout][Filter_2] = false;
         Shift_Filter_Sell_Comments(Type_Breakout, Filter_2, "FracS-BD");
         return BEAR_TRIGGER;
      }
      
      // Sell Breakout when Squeezing && Closing of Trend
      // TBC to code...
      
   }
   
   return NEUTRAL;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Breakout_Filter_3(int Direction)
{
   // utils
   ENUM_MARKET_CONDITION curr_market_condition = m_MarketCondition.GetEnumMarketCondition(0, 0);
   double fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);

   ENUM_INDICATOR_POSITION curr_vol_position = m_AdvIndicators.GetVolatility().GetVolatilityPosition(0, 0);
   ENUM_INDICATOR_POSITION curr_ob_position = m_AdvIndicators.GetOBOS().GetOBPosition(0, 0);
   ENUM_INDICATOR_POSITION curr_os_position = m_AdvIndicators.GetOBOS().GetOSPosition(0, 0);

   // Bull Bear Index
   double bull_percent[3];
   double bear_percent[3];

   ArrayInitialize(bull_percent, 0);
   ArrayInitialize(bear_percent, 0);

   for(int i =0 ; i < 3; i++)
   {
      bull_percent[i] = m_AdvIndicators.GetBullBear().GetBullPercent(0,i);
      bear_percent[i] = m_AdvIndicators.GetBullBear().GetBearPercent(0,i);
   }

   // CS Price action
   double curr_cs_body_percent = m_CandleStick.GetCummBodyPercent(0, 0);
   double prev_cs_body_percent = m_CandleStick.GetCummBodyPercent(0, 1);
   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0, 0);
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   
   double prev_h1_cs = m_Indicators.GetBodyCSATRMinPercent(0, 1);
   double curr_h4_cs_body_percent = m_Indicators.GetBodyCSATRPercent(2, 0);
   double curr_h4_cs_hl_percent = m_Indicators.GetHighLowCSATRPercent(2, 0);

   // Get Order Zone
   string order_zone = "";
   
   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();

   // Order Region
   if(curr_ohlc4 <= ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(B)";
   else if(curr_ohlc4 > ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(B)";
   else if(curr_ohlc4 >= ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/TGT";  
   else if(curr_ohlc4 >= ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(T)"; 
   else if(curr_ohlc4 >= ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(T)";  
   else
   {
      LogError(__FUNCTION__, "Failed to identify Region!");  
      return false;
   }

   RefreshRates();

   if(Direction == BULL_TRIGGER && Ask > fractal_resistance && !Stop_Buy_Flag[Type_Breakout])
   {
      // Breakout Strong BullBear Index
      if(bull_percent[0] == 100 && bull_percent[1] == 100 && bull_percent[2] == 100)
      {
         if(Shift_Filter_Buy_Comments(Type_Breakout, Filter_3, "Bull-100%(3X)"+order_zone))
         {
            Filter_Buy_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
      
      // Breakout with strong Volatility
      else if(bull_percent[0] == 100 && curr_vol_position <= Plus_2_StdDev)
      {
         if(Shift_Filter_Buy_Comments(Type_Breakout, Filter_3, "Bull-100%(VOL)"+order_zone))
         {
            Filter_Buy_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
      
      // Breakout with strong Volatility
      else if(bull_percent[0] == 100 && curr_ob_position <= Plus_2_StdDev)
      {
         if(Shift_Filter_Buy_Comments(Type_Breakout, Filter_3, "Bull-100%(OB)"+order_zone))
         {
            Filter_Buy_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }

      // Strong CS Trigger Downwards
      if(curr_cs_body_percent > prev_cs_body_percent
      && MathAbs(curr_cs_body_percent - prev_cs_body_percent) >= 50
      && curr_cs_body_percent <= 50
      )
      {
         if(Shift_Filter_Buy_Comments(Type_Breakout, Filter_3, "CSBody-MoM(S)"+order_zone))         // S -- Strong
         {
            Filter_Buy_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
   }


   // Bear Situation
   else if(Direction == BEAR_TRIGGER && Bid < fractal_support && !Stop_Sell_Flag[Type_Breakout])
   {
      // Breakout Strong BullBear Index
      if(bear_percent[0] == 100 && bear_percent[1] == 100 && bear_percent[2] == 100)
      {
         if(Shift_Filter_Sell_Comments(Type_Breakout, Filter_3, "Bear-100%(3X)"+order_zone))
         {
            Filter_Sell_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
      
      // Breakout with strong Volatility
      else if(bear_percent[0] == 100 && curr_vol_position <= Plus_2_StdDev)
      {
         if(Shift_Filter_Sell_Comments(Type_Breakout, Filter_3, "Bear-100%(VOL)"+order_zone))
         {
            Filter_Sell_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
      
      // Breakout with strong Volatility
      else if(bear_percent[0] == 100 && curr_os_position <= Plus_2_StdDev)
      {
         if(Shift_Filter_Sell_Comments(Type_Breakout, Filter_3, "Bear-100%(OS)"+order_zone))
         {
            Filter_Sell_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
      
      // Strong CS Trigger Downwards
      if(curr_cs_body_percent < prev_cs_body_percent
      && MathAbs(curr_cs_body_percent - prev_cs_body_percent) >= 50
      && curr_cs_body_percent >= -50
      )
      {
         if(Shift_Filter_Sell_Comments(Type_Breakout, Filter_3, "CSBody-MoM(S)"+order_zone))         // S -- Strong
         {
            Filter_Sell_Flag[Type_Breakout][Filter_3] = true;
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Breakout_Filter_4(int Direction)
{
   RefreshRates();

   // Utils
   datetime curtime = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0);
   
   double curr_fractal_resistance[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double curr_fractal_support[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double atr = m_Indicators.GetATR().GetATR(0, 0);
   
   double dailyAverage = m_AccountManager.GetAverageDailyPriceMovement();
   double dailyMovement = CandleSticksBuffer[3][0].GetHLDiff();
   double daily_high = CandleSticksBuffer[3][0].GetHigh();
   double daily_low = CandleSticksBuffer[3][0].GetLow();
   
   bool isUp = m_Indicators.GetFibonacci().IsUp(0, 0);
   double hidden_StopLoss = 0, hidden_TakeProfit = 0, RR = 0;
   
   double expectedMovement = (dailyAverage-dailyMovement)/3;      // At least move one third on the trend

   ArrayInitialize(curr_fractal_resistance, 0);
   ArrayInitialize(curr_fractal_support, 0);
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      curr_fractal_resistance[i] = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(i, 0);
      curr_fractal_support[i] = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(i, 0);
   }
   
   if(Direction == BULL_TRIGGER)
   {
      // Stop Trading when its time to exit
      if(Stop_Buy_Flag[Type_Breakout])
         return false;
      
      // Check whether hidden profit has already been calculated before
      else if(Buy_HiddenTakeProfit[Type_Breakout] > 0)
      {
         // Skip trade if minimal profit are expected from this trade
         if(Buy_HiddenTakeProfit[Type_Breakout] - Ask < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Buy_Flag[Type_Breakout] = true;
            Stop_Buy_Comment[Type_Breakout] = ">=HP-"+DoubleToStr(Buy_HiddenTakeProfit[Type_Breakout], Digits);
            return false;
         }
         
         Filter_Buy_Flag[Type_Breakout][Filter_4] = true;
         return true;
         
      }

      // Breakout Logics
            
       
   }
   
   
   else if(Direction == BEAR_TRIGGER)
   {
   
   
   }
   
   return false;
   
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int GuanStrategy::Fakeout_Filter_1()
{
   RefreshRates();

   // Utils
   double zz[3];
   ArrayInitialize(zz, 0);

   for(int i =0 ; i < 3; i++)
      zz[i] = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, i); 
   

   // ZigZag length
   int zzDistance = MathAbs(m_Indicators.GetZigZag().GetZigZagHighShift(0, 1)-m_Indicators.GetZigZag().GetZigZagLowShift(0, 1));
   bool isHighFirst = m_Indicators.GetZigZag().GetZigZagPrice(0, 1) > 0 ? true : false;
   double zz_price_difference = MathAbs(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) - m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1));
   double bandstddev = m_Indicators.GetBands().GetBandStdDev(0, 1, 0);
   double ema200 = m_Indicators.GetMovingAverage().GetMoneyLineMA(0,0);
   double atr = m_Indicators.GetATR().GetATR(0,0);
   
   int curr_minute = Minute();
   
   double prev_volatility = m_AdvIndicators.GetVolatility().GetVolatilityStdDevPosition(0, 1);
   double prev_ob_pos = m_AdvIndicators.GetOBOS().GetOBStdDevPosition(0, 1);
   double prev_os_pos = m_AdvIndicators.GetOBOS().GetOSStdDevPosition(0, 1);
   
   string order_zone = "";

   double curr_ohlc4 = CandleSticksBuffer[0][0].GetOHLC4();

   // Order Region
   if(curr_ohlc4 <= ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(B)";
   else if(curr_ohlc4 > ema200-EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(B)";
   else if(curr_ohlc4 >= ema200-VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/TGT";  
   else if(curr_ohlc4 >= ema200+VERY_LOOSE_STOP_LOSS_MULTIPLIER*atr && curr_ohlc4 < ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/MID(T)"; 
   else if(curr_ohlc4 >= ema200+EXTREME_LOOSE_STOP_LOSS_MULTIPLIER*atr)
      order_zone = "/EX(T)"; 
   else
   {
      LogError(__FUNCTION__, "Failed to identify Region!");  
      return false;
   }

/*
   // Fake out to upwards
   if(zz[0] > 0 && !isHighFirst && zzDistance <= 5 && zz_price_difference > NormalizeDouble(bandstddev*3.5, Digits))
   {
      Filter_Buy_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Fakeout, Filter_1, "FO-BB3.5x"+order_zone);
      
      ResetAllFilterSellFlag(Type_Fakeout);
      ResetFilterSellFlag(Type_Fakeout, Filter_1);
      ResetFilterSellFlag(Type_Fakeout, Filter_2);
      return BULL_TRIGGER;
   }
   
   // Fake out to downwards
   if(zz[0] < 0 && isHighFirst && zzDistance <= 5 && zz_price_difference > NormalizeDouble(bandstddev*3.5, Digits))
   {
      Filter_Sell_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Sell_Comments(Type_Fakeout, Filter_1, "FO-BB3.5x"+order_zone);
      
      ResetAllFilterBuyFlag(Type_Fakeout);
      ResetFilterBuyFlag(Type_Fakeout, Filter_1);
      ResetFilterBuyFlag(Type_Fakeout, Filter_2);
      return BEAR_TRIGGER;
   }
*/

   // Fake out scenarios
   if(zz[0] > 0 && zz[1] < 0 && zz[2] > 0)
   {
      Filter_Buy_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Fakeout, Filter_1, "FAST-2CS"+order_zone);
      
      ResetAllFilterSellFlag(Type_Fakeout);
      ResetFilterSellFlag(Type_Fakeout, Filter_1);
      ResetFilterSellFlag(Type_Fakeout, Filter_2);
      return BULL_TRIGGER;
      
   }
   
   // Fake out scenarios
   else if(zz[0] > 0 && zz[1] < 0 && zz[2] > 0)
   {
      Filter_Sell_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Sell_Comments(Type_Fakeout, Filter_1, "FAST-2CS"+order_zone);
      
      ResetAllFilterBuyFlag(Type_Fakeout);
      ResetFilterBuyFlag(Type_Fakeout, Filter_1);
      ResetFilterBuyFlag(Type_Fakeout, Filter_2);
      return BEAR_TRIGGER;
   }
   
   
   
   // Another form of fakeout --- Fake Breakout then break support/resistance
   else if(curr_minute%15 > 10 && curr_minute%15 <= 14
   && zz[2] > 0 && zz[1] < 0 && prev_volatility >= 2 && prev_os_pos >= 2
   && Ask > CandleSticksBuffer[0][1].GetHigh()-CandleSticksBuffer[0][1].GetHLDiff()*(FIBONACCI_LEVELS[2])
   )
   {
      Filter_Buy_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Buy_Comments(Type_Fakeout, Filter_1, "SLOW-2CS"+order_zone);
      
      ResetAllFilterSellFlag(Type_Fakeout);
      ResetFilterSellFlag(Type_Fakeout, Filter_1);
      ResetFilterSellFlag(Type_Fakeout, Filter_2);
      return BULL_TRIGGER;
   }
   

   // Another form of fakeout --- Fake Breakout then break support/resistance
   else if(curr_minute%15 > 10 && curr_minute%15 <= 14
   && zz[2] < 0 && zz[1] > 0 && prev_volatility >= 2 && prev_ob_pos >= 2
   && Bid < CandleSticksBuffer[0][1].GetLow()+CandleSticksBuffer[0][1].GetHLDiff()*(FIBONACCI_LEVELS[2])
   )
   {
      Filter_Sell_Flag[Type_Fakeout][Filter_1] = true;
      Shift_Filter_Sell_Comments(Type_Fakeout, Filter_1, "SLOW-2CS"+order_zone);
      
      ResetAllFilterBuyFlag(Type_Fakeout);
      ResetFilterBuyFlag(Type_Fakeout, Filter_1);
      ResetFilterBuyFlag(Type_Fakeout, Filter_2);
      return BEAR_TRIGGER;
   }

   return NEUTRAL;
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Fakeout_Filter_2(int Direction)
{

   if(Direction == BULL_TRIGGER)
   {
      Filter_Buy_Flag[Type_Fakeout][Filter_2] = true;
      
      if(Shift_Filter_Buy_Comments(Type_Fakeout, Filter_2, "FO"))
         return true;
   }
   
   if(Direction == BEAR_TRIGGER)
   {
      Filter_Sell_Flag[Type_Fakeout][Filter_2] = true;

      if(Shift_Filter_Sell_Comments(Type_Fakeout, Filter_2, "FO"))
         return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Fakeout_Filter_3(int Direction)
{
   RefreshRates();

   // daily average
   double dailyAverage = m_AccountManager.GetAverageDailyPriceMovement();
   double currentHighLow = CandleSticksBuffer[3][0].GetHLDiff();
   double RR = 0;
   

   double CurrentZigZagPriceRange = 0; 

   if(Direction == BULL_TRIGGER)
   {
      if(Stop_Buy_Flag[Type_Fakeout])
         return false;
   
      double zigzag_high = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, 0) > 0 ? m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) : m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0);
      CurrentZigZagPriceRange = zigzag_high-MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
      double halfPrice = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0))+CurrentZigZagPriceRange/2;
      
      int zigzag_highShift = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, 0) > 0 ? m_Indicators.GetZigZag().GetZigZagHighShift(0, 1) : m_Indicators.GetZigZag().GetZigZagHighShift(0, 0);
      double order_block = iLow(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, zigzag_highShift);
      double orderblock_size = iHigh(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, zigzag_highShift)-order_block;
      
      // Fakeout Optimal reward is identified
      if(Buy_HiddenTakeProfit[Type_Fakeout] > 0)
      {
         // Skip trade if minimal profit are expected from this trade
         if(Buy_HiddenTakeProfit[Type_Fakeout] - Ask < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Buy_Flag[Type_Fakeout] = true;
            Stop_Buy_Comment[Type_Fakeout] = ">=HP-"+DoubleToStr(Buy_HiddenTakeProfit[Type_Fakeout], Digits);
            return false;
         }
      }
      
      // ZigZag is too big, stop range will be the middle below abit
      else if(Ask < halfPrice && CurrentZigZagPriceRange > 0.75*dailyAverage)
      {
         Buy_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(halfPrice, Digits);
         Filter_Buy_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Buy_Comments(Type_Fakeout, Filter_4, "ZZ/MidPoint-"+(string)Buy_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }
      
      // Check for order block (Based on the ZigZag Size as oppose to the size of the candle at the 
      else if(Ask < order_block && NormalizeDouble(CurrentZigZagPriceRange/3, Digits) > orderblock_size)
      {
         Buy_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(order_block, Digits);
         Filter_Buy_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Buy_Comments(Type_Fakeout, Filter_4, "OB-"+(string)Buy_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }
      
      // Aim for H1 Fractal 
      else if(Ask < m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(1, 0))
      {
         Buy_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(1, 0), Digits);
         Filter_Buy_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Buy_Comments(Type_Fakeout, Filter_4, "FracR/H1-"+(string)Buy_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }      
   }
   
   else if(Direction == BEAR_TRIGGER)
   {
      if(Stop_Sell_Flag[Type_Fakeout])
         return false;
   
      double zigzag_low = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, 0) < 0 ? MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)) : MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
      CurrentZigZagPriceRange = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0) - zigzag_low;
      double halfPrice = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0)-CurrentZigZagPriceRange/2;

      int zigzag_lowShift = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, 0) < 0 ? m_Indicators.GetZigZag().GetZigZagLowShift(0, 1) : m_Indicators.GetZigZag().GetZigZagLowShift(0, 0);
      double order_block = iHigh(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, zigzag_lowShift);
      double orderblock_size = order_block-iLow(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, zigzag_lowShift);;
      
      // Fakeout Optimal reward is identified
      if(Sell_HiddenTakeProfit[Type_Fakeout] > 0)
      {
         // Skip trade if minimal profit are expected from this trade
         if(Bid-Sell_HiddenTakeProfit[Type_Fakeout] < m_AccountManager.GetMinimumStopLossPip())
         {
            Stop_Sell_Flag[Type_Fakeout] = true;
            Stop_Sell_Comment[Type_Fakeout] = "<=HP-"+DoubleToStr(Sell_HiddenTakeProfit[Type_Fakeout], Digits);
            return false;
         }
      }
      
      // ZigZag is too big, stop range will be the middle below abit
      else if(Bid > halfPrice && CurrentZigZagPriceRange > 0.75*dailyAverage)
      {
         Sell_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(halfPrice, Digits);
         Filter_Sell_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Sell_Comments(Type_Fakeout, Filter_4, "ZZ/MidPoint-"+(string)Sell_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }
      
      // Check for order block (Based on the ZigZag Size as oppose to the size of the candle at the 
      else if(Bid > order_block && NormalizeDouble(CurrentZigZagPriceRange/3, Digits) > orderblock_size)
      {
         Sell_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(order_block, Digits);
         Filter_Sell_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Sell_Comments(Type_Fakeout, Filter_4, "OB-"+(string)Sell_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }
      
      // Aim for H1 Fractal 
      else if(Bid > m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(1, 0))
      {
         Sell_HiddenTakeProfit[Type_Fakeout] = NormalizeDouble(m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(1, 0), Digits);
         Filter_Sell_Flag[Type_Fakeout][Filter_4] = true;
         Shift_Filter_Sell_Comments(Type_Fakeout, Filter_4, "FracS/H1-"+(string)Sell_HiddenTakeProfit[Type_Fakeout]);
         return true;
      }  
   }
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Is_Close_Trade(int type_strategy, int Direction)
{
   ENUM_INDICATOR_POSITION curr_body_pos = m_CandleStick.GetCummBodyPosition(0, 0);
   
   double bull_percent = m_AdvIndicators.GetBullBear().GetBullPercent(0, 0);
   double bear_percent = m_AdvIndicators.GetBullBear().GetBearPercent(0, 0);

   double stoHist = m_Indicators.GetSTO().GetSTOHist(0, 0);

   // utils
   if(Direction == BULL_TRIGGER && Stop_Buy_Flag[type_strategy])
   {
      // Normal Close 
      if(stoHist <= 0 && bear_percent > bull_percent)
         return true;
   }
   
   
   // utils
   else if(Direction == BEAR_TRIGGER && Stop_Sell_Flag[type_strategy])
   {
      // Normal Close 
      if(stoHist >= 0 && bull_percent > bear_percent)
         return true;
   }

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double GuanStrategy::GetNewStopLoss(int strategy_type,int Direction)
{
   // utils
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   double average_low = MathMin(CandleSticksBuffer[0][1].GetLow(), CandleSticksBuffer[0][2].GetLow());
   double average_high = MathMax(CandleSticksBuffer[0][1].GetHigh(), CandleSticksBuffer[0][2].GetHigh());


   // -------------------------------------   Reversal      -------------------------------------

   // Reversal Stop Loss Maangement
   if(strategy_type == Type_Reversal)
   {
      if(Direction == BULL_TRIGGER)
      {
         return 0;         // Yet to be coded
      }
      
      else if(Direction == BEAR_TRIGGER)
      {
         return 0;         // Yet to be coded
      }
   }
   

 // -------------------------------------   Trending      -------------------------------------

   // Trending Stop Loss Maangement
   if(strategy_type == Type_Trend)
   {
      if(Direction == BULL_TRIGGER)
      {
         if(Buy_HiddenStopLoss[Type_Trend] > 0)
         {
            LogInfo("Using the Same Stop Loss: " + DoubleToStr(Buy_HiddenStopLoss[Type_Trend], Digits));
            return Buy_HiddenStopLoss[Type_Trend];
         }      
         // Dependant on what type of trade it is 
         if(Open_Buy_Flag[Type_Continuation])
            return Buy_HiddenStopLoss[Type_Continuation];
         else if(Open_Buy_Flag[Type_Reversal])
            return Buy_HiddenStopLoss[Type_Reversal];
         else
         {
            LogError(__FUNCTION__, "Failed to Retrieve Stop Loss From Reversal/Continuation For Trending...");
            return -1;
         }
      }
      
      else if(Direction == BEAR_TRIGGER)
      {
         if(Sell_HiddenStopLoss[Type_Trend] > 0)
         {
            LogInfo("Using the Same Stop Loss: " + DoubleToStr(Sell_HiddenStopLoss[Type_Trend], Digits));
            return Sell_HiddenStopLoss[Type_Trend];
         }
         
         // Dependant on what type of trade it is 
         if(Open_Sell_Flag[Type_Continuation])
            return Sell_HiddenStopLoss[Type_Continuation];
         else if(Open_Sell_Flag[Type_Reversal])
            return Sell_HiddenStopLoss[Type_Reversal];
         else
         {
            LogError(__FUNCTION__, "Failed to Retrieve Stop Loss From Reversal/Continuation For Trending...");
            return -1;
         }
      }
   }


 // -------------------------------------   Continuation      -------------------------------------

   // Trending Stop Loss Management
   if(strategy_type == Type_Continuation)
   {
      // Buy Situation
      if(Direction == BULL_TRIGGER)
      {
         // Already have Stop Loss Set Initially
         if(Buy_HiddenStopLoss[Type_Continuation] > 0)
         {
            LogInfo("Using the Same Stop Loss: " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
            return Buy_HiddenStopLoss[Type_Continuation];  
         }

         // ----------------------   Current ZigZag is Low     ----------------------
         else if(m_Indicators.GetZigZag().GetZigZagPrice(0, 0) < 0)
         {
            double halfZigZag = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0))+(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)-MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)))/2;

            // Previous ZZ to High = low shift = strong sell
            if(m_Indicators.GetZigZag().GetZigZagHighShift(0, 1)-m_Indicators.GetZigZag().GetZigZagLowShift(0, 1) <= 5)
            {
               // Check for Fib
               for(int i = 5; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetDownFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Ask < fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Ask-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr > fibonacci_level 
                  && Ask-fibonacci_level < m_AccountManager.GetMaximumStopLossPip()
                  && Ask-fibonacci_level >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits); 
                     LogInfo("Buy Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Buy_HiddenStopLoss[Type_Continuation];  
                  }
               }

               // Set Default Stop Loss
               if(Buy_HiddenStopLoss[Type_Continuation] == 0)
               {
                  Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(Ask-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits); 
                  LogInfo("Buy Continuation Stop Loss @ 2*ATR - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation]));  
                  return Buy_HiddenStopLoss[Type_Continuation];   
               }

            }
            
            // Higher Low Situation
            else if(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0)) > MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)))
            {
               // Forex Pair Situation --- Previous ZZ Low not as far
               if(Ask-m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1) < m_AccountManager.GetMaximumStopLossPip()
               && Ask-m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1) >= m_AccountManager.GetMinimumStopLossPip()
               )
               {
                  // Stop Loss at the order block
                  Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr),Digits); 
                  LogInfo("Buy Continuation Stop Loss @ ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation])); 
                  return Buy_HiddenStopLoss[Type_Continuation];  
               }

               // Take Half of the ZigZag as the SL
               else if(Ask - halfZigZag < m_AccountManager.GetMaximumStopLossPip()
               && Ask - halfZigZag >= m_AccountManager.GetMinimumStopLossPip()
               )
               {
                  Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(halfZigZag, Digits);
                  LogInfo("Buy Continuation Stop Loss @ FVG ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                  return Buy_HiddenStopLoss[Type_Continuation];
               }

               // Slightly Further to accomodate sweep
               else
               {
                  Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                  LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                  return Buy_HiddenStopLoss[Type_Continuation];
               }
            }
            
            // Lower Low Situation
            else if(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0)) < MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)))
            {
               // Check for Fib
               for(int i = 5; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetDownFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Ask < fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Ask-TIGHT_STOP_LOSS_MULTIPLIER*atr > fibonacci_level
                  && Ask-fibonacci_level < m_AccountManager.GetMaximumStopLossPip()
                  && Ask-fibonacci_level >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level-TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Buy Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Buy_HiddenStopLoss[Type_Continuation];   
                  }
                  
                  // If Still Empty, then use the default ones
                  if(Buy_HiddenStopLoss[Type_Continuation] == 0)
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits)); 
                     return Buy_HiddenStopLoss[Type_Continuation];   
                  }
               }
            }
         }
         
         //   ----------------------   Current ZigZag is High     ----------------------
         else if(m_Indicators.GetZigZag().GetZigZagPrice(0, 0) > 0)
         {
            // Previous ZZ to High = low shift = strong sell
            if(m_Indicators.GetZigZag().GetZigZagHighShift(0, 1)-m_Indicators.GetZigZag().GetZigZagLowShift(0, 1) <= 5)
            {
               double curr_zz_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
            
               // Forex Pair Situation
               if(Ask-curr_zz_low < m_AccountManager.GetMaximumStopLossPip()
               && Ask-curr_zz_low >= m_AccountManager.GetMinimumStopLossPip()
               )
               {
                  Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_low-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                  LogInfo("Buy Continuation Stop Loss @ ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                  return Buy_HiddenStopLoss[Type_Continuation];   
               }
               // Fibonacci Stop Loss
               else
               {
                  // Set the stop loss based on fibonacci
                  for(int i =FIBONACCI_LEVELS_SIZE-1; i >= 0; i--)
                  {
                     double fibonacci_level = m_Indicators.GetFibonacci().GetUpFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
                  
                     // Skip the ones that are on top of current price
                     if(Ask < fibonacci_level)
                        continue;
                  
                     // Fibonacci level below the current price
                     if(Ask-TIGHT_STOP_LOSS_MULTIPLIER*atr > fibonacci_level
                     && Ask-fibonacci_level < m_AccountManager.GetMaximumStopLossPip()
                     && Ask-fibonacci_level >= m_AccountManager.GetMinimumStopLossPip()
                     )
                     {
                        Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                        LogInfo("Buy Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                        return Buy_HiddenStopLoss[Type_Continuation];   
                     }
                  }  

                  // Still cant find Stop loss
                  if(Buy_HiddenStopLoss[Type_Continuation] == 0)
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];          
                  }
               }
            }
         
            
            // Higher High Situation
            else if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) < m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0))
            {
               // Set the stop loss based on fibonacci
               for(int i = 3; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetUpFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Ask < fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Ask-TIGHT_STOP_LOSS_MULTIPLIER*atr > fibonacci_level
                  && Ask-fibonacci_level < m_AccountManager.GetMaximumStopLossPip()
                  && Ask-fibonacci_level >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level-VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);    
                     LogInfo("Buy Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Buy_HiddenStopLoss[Type_Continuation];                     
                  }               
               }
            
               // if still don't have 
               if(Buy_HiddenStopLoss[Type_Continuation] == 0)
               {
                   Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);      
                   LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits)); 
                   return Buy_HiddenStopLoss[Type_Continuation];
               }
            }
            
            // Higher Low Situation
            else if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) > m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0))
            {
               // Get the zigzag Low 
               double curr_zz_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
               double curr_zz_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1);

               double halfZigZag = curr_zz_low+(curr_zz_high-curr_zz_low)/2;

               // Liquidity Accumulation Situation
               if(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)) > MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 2)))
               {
                  curr_zz_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 2))-TIGHT_STOP_LOSS_MULTIPLIER*atr;
                  halfZigZag = curr_zz_high-(curr_zz_high-curr_zz_low)/2;
                  
                  // Forex Pair Situation
                  if(Ask-curr_zz_low < m_AccountManager.GetMaximumStopLossPip()
                  && Ask-curr_zz_low >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_low, Digits);
                     LogInfo("Buy Continuation Stop Loss @ ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];
                  }
                  
                  // Take Half of the ZigZag as the SL
                  else if(Ask - halfZigZag < m_AccountManager.GetMaximumStopLossPip()
                  && Ask - halfZigZag >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(halfZigZag, Digits);
                     LogInfo("Buy Continuation Stop Loss @ FVG ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];
                  }

                  // Slightly Further to accomodate sweep
                  else
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];
                  }
               }

               // Liquidity Swept situation
               else
               {
                  // Forex Pair Situation
                  if(Ask-curr_zz_low < m_AccountManager.GetMaximumStopLossPip()
                  && Ask-curr_zz_low >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_low, Digits);
                     LogInfo("Buy Continuation Stop Loss @ ZigZag Low - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];
                  }

                  // Slightly Further to accomodate sweep
                  else
                  {
                     Buy_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_low-LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Buy Continuation Stop Loss @ Default SL - " + DoubleToStr(Buy_HiddenStopLoss[Type_Continuation], Digits));
                     return Buy_HiddenStopLoss[Type_Continuation];
                  }
               }
            }
         } 
      }
      
      // Sell Situation
      else if(Direction == BEAR_TRIGGER)
      {
         // Already have Stop Loss Set Initially
         if(Sell_HiddenStopLoss[Type_Continuation] > 0)
         {
            LogInfo("Using the Same Stop Loss: " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
            return Sell_HiddenStopLoss[Type_Continuation];  
         }

         // ----------------------  Current ZigZag is High  ----------------------
         else if(m_Indicators.GetZigZag().GetZigZagPrice(0, 0) > 0)
         {
            double halfZigZag = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)-(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)-MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)))/2;
         
            // Previous ZZ to High = low shift = strong Buy Situation
            if(m_Indicators.GetZigZag().GetZigZagHighShift(0, 1)-m_Indicators.GetZigZag().GetZigZagLowShift(0, 1) <= 5)
            {
               // Check for Fib
               for(int i = 5; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetUpFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Bid > fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Bid+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr < fibonacci_level
                  && fibonacci_level-Bid < m_AccountManager.GetMaximumStopLossPip()
                  && fibonacci_level-Bid >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
               }
               
               // Set Default Stop Loss
               if(Sell_HiddenStopLoss[Type_Continuation] == 0)
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(Bid+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                  LogInfo("Sell Continuation Stop Loss @ 2*ATR - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
               
            }
         
            
            // Lower High Situation
            else if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0) < m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1))
            {
               // Forex Pair Situation --- Previous ZZ Low not as far
               if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)-Bid < m_AccountManager.GetMaximumStopLossPip()
               && m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)-Bid >= m_AccountManager.GetMinimumStopLossPip()
               ) 
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr,Digits);
                  LogInfo("Sell Continuation Stop Loss @ ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
               
               // Take Half of the ZigZag as SL
               else if(Bid-halfZigZag < m_AccountManager.GetMaximumStopLossPip()
               && Bid-halfZigZag >= m_AccountManager.GetMinimumStopLossPip()
               )
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(halfZigZag,Digits);
                  LogInfo("Sell Continuation Stop Loss @ FVG ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
               
               // Long ZigZag Range towards the zigzag low 
               else
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);     
                  LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
            }
            
            // Higher High Situation
            else if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0) > m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1))
            {
               // Check for Fib
               for(int i = 5; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetUpFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Bid > fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Bid+TIGHT_STOP_LOSS_MULTIPLIER*atr < fibonacci_level
                  && fibonacci_level-Bid < m_AccountManager.GetMaximumStopLossPip()
                  && fibonacci_level-Bid >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
                  
                  // If Still Empty, then use the default ones
                  if(Sell_HiddenStopLoss[Type_Continuation] == 0)
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
               }
            }
         }
         
         // ----------------------  Current ZigZag is Low   ----------------------
         else if(m_Indicators.GetZigZag().GetZigZagPrice(0, 0) < 0)
         {
            // Previous ZZ to High = low shift = strong sell
            if(m_Indicators.GetZigZag().GetZigZagHighShift(0, 1)-m_Indicators.GetZigZag().GetZigZagLowShift(0, 1) <= 5)
            {
               double curr_zz_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0);
            
               // Forex Pair Situation
               if(curr_zz_high-Bid < m_AccountManager.GetMaximumStopLossPip()
               && curr_zz_high-Bid >= m_AccountManager.GetMinimumStopLossPip()
               )
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_high+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                  LogInfo("Sell Continuation Stop Loss @ ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
               
               // Fibonacci Stop Loss
               else
               {
                  // Set the stop loss based on fibonacci
                  for(int i = FIBONACCI_LEVELS_SIZE-1 ; i >= 0; i--)
                  {
                     double fibonacci_level = m_Indicators.GetFibonacci().GetDownFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
                  
                     // Skip the ones that are on top of current price
                     if(Bid > fibonacci_level)
                        continue;
                  
                     // Fibonacci level below the current price
                     if(Bid+TIGHT_STOP_LOSS_MULTIPLIER*atr < fibonacci_level
                     && fibonacci_level-Bid < m_AccountManager.GetMaximumStopLossPip()
                     && fibonacci_level-Bid >= m_AccountManager.GetMinimumStopLossPip()
                     )
                     {
                        Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                        LogInfo("Sell Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                        return Sell_HiddenStopLoss[Type_Continuation]; 
                     }
                  }  

                  // Still cant find Stop loss
                  if(Sell_HiddenStopLoss[Type_Continuation] == 0)
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation]; 
                  }
               }
            }
         
            
            // Lower Low Situation
            else if(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)) > MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0)))
            {
               // Set the stop loss based on fibonacci
               for(int i =3 ; i < FIBONACCI_LEVELS_SIZE; i++)
               {
                  double fibonacci_level = m_Indicators.GetFibonacci().GetDownFibonacci(0, 0, FIBONACCI_LEVELS[i]*100);
               
                  // Skip the ones that are on top of current price
                  if(Bid > fibonacci_level)
                     continue;
               
                  // Fibonacci level below the current price
                  if(Bid+TIGHT_STOP_LOSS_MULTIPLIER*atr < fibonacci_level
                  && fibonacci_level-Bid < m_AccountManager.GetMaximumStopLossPip()
                  && fibonacci_level-Bid >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(fibonacci_level+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Fib - " + DoubleToStr(FIBONACCI_LEVELS[i]*100, 3));
                     return Sell_HiddenStopLoss[Type_Continuation]; 
                  }
               }
            
               // if still don't have 
               if(Sell_HiddenStopLoss[Type_Continuation] == 0)
               {
                  Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                  LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                  return Sell_HiddenStopLoss[Type_Continuation];
               }
            }
            
            // Higher Low Situation
            else if(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1)) < MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0)))
            {
               // Get the zigzag high 
               double curr_zz_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1)+VERY_TIGHT_STOP_LOSS_MULTIPLIER*atr;
               double curr_zz_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1));
               
               double halfZigZag = curr_zz_high-(curr_zz_high-curr_zz_low)/2;       
                           
               // Liquidity Accumulation Situation
               if(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) < m_Indicators.GetZigZag().GetZigZagHighPrice(0, 2))
               {
                  curr_zz_high = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 2)-TIGHT_STOP_LOSS_MULTIPLIER*atr;
                  halfZigZag = curr_zz_high-(curr_zz_high-curr_zz_low)/2;
               
                  // Forex Pair Situation
                  if(curr_zz_high-Bid < m_AccountManager.GetMaximumStopLossPip()
                  && curr_zz_high-Bid >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_high, Digits);
                     LogInfo("Sell Continuation Stop Loss @ ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
                  
                  // Take Half of the ZigZag as the SL
                  else if(halfZigZag-Bid < m_AccountManager.GetMaximumStopLossPip()
                  && halfZigZag-Bid >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(halfZigZag, Digits);
                     LogInfo("Sell Continuation Stop Loss @ FVG ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
                  
                  // Set Further to accomodate sweep
                  else
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
               }
               
               
               // Liquidity Swept Situation
               else
               {
                  // Forex Pair Situation
                  if(curr_zz_high-Ask < m_AccountManager.GetMaximumStopLossPip()
                  && curr_zz_high-Ask >= m_AccountManager.GetMinimumStopLossPip()
                  )
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(curr_zz_high, Digits);
                     LogInfo("Sell Continuation Stop Loss @ ZigZag High - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
      
                  // Slightly Further to accomodate sweep
                  else
                  {
                     Sell_HiddenStopLoss[Type_Continuation] = NormalizeDouble(average_high+LOOSE_STOP_LOSS_MULTIPLIER*atr, Digits);
                     LogInfo("Sell Continuation Stop Loss @ Default SL - " + DoubleToStr(Sell_HiddenStopLoss[Type_Continuation], Digits));
                     return Sell_HiddenStopLoss[Type_Continuation];
                  }
               }
            }
         }
      }
   }

 // -------------------------------------   Breakout      -------------------------------------

   // Trending Stop Loss Maangement
   if(strategy_type == Type_Breakout)
   {
      if(Direction == BULL_TRIGGER)
         return m_Indicators.GetFractal().GetFractalSupportBarShiftLowerPrice(0, 0);

      else if(Direction == BEAR_TRIGGER)
         return m_Indicators.GetFractal().GetFractalResistanceBarShiftUpperPrice(0, 0);
   }

 // -------------------------------------   Fakeout      -------------------------------------

   // Trending Stop Loss Maangement
   if(strategy_type == Type_Fakeout)
   {
      if(Direction == BULL_TRIGGER)
         return NormalizeDouble(MathMin(CandleSticksBuffer[0][0].GetLow(), CandleSticksBuffer[0][1].GetLow()), Digits);
      else if(Direction == BEAR_TRIGGER)
         return NormalizeDouble(MathMin(CandleSticksBuffer[0][0].GetHigh(), CandleSticksBuffer[0][1].GetHigh()), Digits);
   }

   LogError(__FUNCTION__, "Failed to Find Optimal Stop Loss Due to Uncovered Possibilities. ");
   return -1;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::BuyOrderManagement(Order *order)
{
   RefreshRates();

   // Order utils
   int order_ticket = order.GetTicket();
   int orderMagicNumber = order.GetMagicNumber();
   double order_openprice = order.GetOpenPrice();
   double order_stoploss = order.GetStopLoss(), new_stoploss = 0;
   double order_breakeven = order.GetBreakEvenPrice();
   datetime curtime = TimeCurrent();
   datetime order_last_update_time = order.GetLastUpdateDateTime();
   string order_comment = order.GetComment(), stop_loss_comment = "";
   double order_lockedprofit = order.GetLockedProfitInPercentage();
   
   double hidden_takeprofit = 0;

   double curr_close = CandleSticksBuffer[0][0].GetClose();
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   double curr_OHLC4 = CandleSticksBuffer[0][0].GetOHLC4();
   double curr_low = CandleSticksBuffer[0][0].GetLow();

   double curr_volatility_pos = m_AdvIndicators.GetVolatility().GetVolatilityStdDevPosition(0, 0);
   double curr_ob_pos = m_AdvIndicators.GetOBOS().GetOBStdDevPosition(0, 0);


   double curr_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double curr_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   
   double ZigZagPriceDifference = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 1) - MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0));
   double midpoint = NormalizeDouble(MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 0)) + (ZigZagPriceDifference/2), Digits);
   
   int strategy_type = -1;

   if(orderMagicNumber == GUAN_REVERSAL_BUY_STRATEGY)
   {
      strategy_type = Type_Reversal;
      hidden_takeprofit = Buy_HiddenTakeProfit[Type_Reversal];
   }
   
   else if(orderMagicNumber == GUAN_TRENDING_BUY_STRATEGY)
   {
      strategy_type = Type_Trend;
      hidden_takeprofit = Buy_HiddenTakeProfit[Type_Trend];
   }
   
   else if(orderMagicNumber == GUAN_CONTINUATION_BUY_STRATEGY)
   {
      strategy_type = Type_Continuation;
      hidden_takeprofit = Buy_HiddenTakeProfit[Type_Continuation];
   }
   else if(orderMagicNumber == GUAN_BREAKOUT_BUY_STRATEGY)
   {
      strategy_type = Type_Breakout;
      hidden_takeprofit = Buy_HiddenTakeProfit[Type_Breakout];
   }
   else if(orderMagicNumber == GUAN_FAKEOUT_BUY_STRATEGY)
   {
      strategy_type = Type_Fakeout;
      hidden_takeprofit = Buy_HiddenTakeProfit[Type_Fakeout];
   }

   // -------------  Close Order Modification based on event   -------------- 
     
   // Close off Breakout if Fakeout happens
   if(strategy_type == Type_Breakout && Open_Sell_Flag[Type_Fakeout])
   {
      m_AccountManager.CloseBuyOrder(order_ticket);
      LogInfo("Fakeout Happens, Close Buy Breakout Order: " + (string)order_ticket + ", Reason: " + Open_Sell_Comment[Type_Fakeout][0]);
      return;
   }

   // Close Reversal Order Based on Hidden TakeProfit
   if(strategy_type == Type_Reversal 
   && (Close_Buy_Flag[Type_Reversal] || (hidden_takeprofit > 0 && Bid >= hidden_takeprofit))
   )
   {
      if(!Close_Buy_Flag[Type_Reversal])
      {
         Close_Buy_Flag[Type_Reversal] = true;
         Close_Buy_Comment[Type_Reversal] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Reversal];
         
         Close_Buy_Flag[Type_Trend] = true;
         Close_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];
         
         Stop_Buy_Flag[Type_Reversal] = true;
         Stop_Buy_Comment[Type_Reversal] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Reversal];
         
         Stop_Buy_Flag[Type_Trend] = true;
         Stop_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];
      }

      if(Is_Close_Trade(Type_Reversal, BULL_TRIGGER))
      {
         m_AccountManager.CloseAllBuyOrdersByMagicNumber(GUAN_REVERSAL_BUY_STRATEGY, GUAN_TRENDING_BUY_STRATEGY);
         LogInfo("Close All Buy Order With Reason: " + Close_Buy_Comment[Type_Reversal]);
         return;
      }
   }
   
   
   // Close Continuation Order Based on Hidden TakeProfit
   else if(strategy_type == Type_Continuation 
   && (Close_Buy_Flag[Type_Continuation] || (hidden_takeprofit > 0 && Bid >= hidden_takeprofit))
   )
   {
      if(!Close_Buy_Flag[Type_Continuation])
      {
         Close_Buy_Flag[Type_Continuation] = true;
         Close_Buy_Comment[Type_Continuation] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Continuation];
         
         Close_Buy_Flag[Type_Trend] = true;
         Close_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];
         
         Stop_Buy_Flag[Type_Continuation] = true;
         Stop_Buy_Comment[Type_Continuation] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Continuation];
         
         Stop_Buy_Flag[Type_Trend] = true;
         Stop_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];
         
      }

      if(Is_Close_Trade(Type_Continuation, BULL_TRIGGER))
      {
         m_AccountManager.CloseAllBuyOrdersByMagicNumber(GUAN_TRENDING_BUY_STRATEGY, GUAN_CONTINUATION_BUY_STRATEGY);
         LogInfo("Close All Buy Order With Reason: " + Close_Buy_Comment[Type_Continuation]);
         return;
      }
   }
   
   
   // Close Continuation Order Based on Hidden TakeProfit
   else if(strategy_type == Type_Trend 
   && (Close_Buy_Flag[Type_Trend] || (hidden_takeprofit > 0 && Bid >= hidden_takeprofit))
   )
   {
      if(!Close_Buy_Flag[Type_Trend])
      {
         Close_Buy_Flag[Type_Trend] = true;
         Close_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];

         Stop_Buy_Flag[Type_Trend] = true;
         Stop_Buy_Comment[Type_Trend] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Trend];

         // Reversal
         if(Open_Buy_Flag[Type_Reversal])
         {
            Close_Buy_Flag[Type_Reversal] = true;
            Close_Buy_Comment[Type_Reversal] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Reversal];
            
            Stop_Buy_Flag[Type_Reversal] = true;
            Stop_Buy_Comment[Type_Reversal] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Reversal];
         }
         
         // Continuation
         if(Open_Buy_Flag[Type_Continuation])
         {
            Close_Buy_Flag[Type_Continuation] = true;
            Close_Buy_Comment[Type_Continuation] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Continuation];
            
            Stop_Buy_Flag[Type_Continuation] = true;
            Stop_Buy_Comment[Type_Continuation] = "Bid>=TP-"+(string)Buy_HiddenTakeProfit[Type_Continuation];
         }
         
      }

      if(Is_Close_Trade(Type_Trend, BULL_TRIGGER))
      {
         m_AccountManager.CloseAllBuyOrdersByMagicNumber(GUAN_REVERSAL_BUY_STRATEGY, GUAN_CONTINUATION_BUY_STRATEGY);
         LogInfo("Close All Buy Order With Reason: " + Close_Buy_Comment[Type_Trend]);
         return;
      }
   }
   
 
   // -------------  Stop Loss Modification based on event   -------------- 
   // Squeezing, do not modify stop loss as giving breathing areas for fakeout/breakouts
   if(Filter_Buy_Flag[Type_Breakout][Filter_1])
      return;

   // Modify New Stop Loss
   if((order_stoploss == 0 || (new_stoploss > 0 && new_stoploss > order_stoploss))
   && new_stoploss < Bid
   )
   {
      if(!order.ModifyStopLoss(new_stoploss, "Modified Buy StopLoss --- " + stop_loss_comment))
         LogError(__FUNCTION__, "Failed to Update Buy Stop Loss --- " + stop_loss_comment);
         
      else
         Shift_Modify_Buy_Comments(strategy_type, stop_loss_comment);

      // update new update date time
      if(curtime != order_last_update_time)
         order.SetLastUpdateDateTime(curtime);     
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::SellOrderManagement(Order *order)
{
   RefreshRates();

   // Order utils
   int order_ticket = order.GetTicket();
   int orderMagicNumber = order.GetMagicNumber();
   double order_openprice = order.GetOpenPrice();
   double order_stoploss = order.GetStopLoss(), new_stoploss = 0;
   double order_breakeven = order.GetBreakEvenPrice();
   datetime curtime = TimeCurrent();
   datetime order_last_update_time = order.GetLastUpdateDateTime();
   string order_comment = order.GetComment(), stop_loss_comment = "";
   double order_lockedprofit = order.GetLockedProfitInPercentage();
   
   double hidden_takeprofit = 0;
   

   double curr_close = CandleSticksBuffer[0][0].GetClose();
   double atr = m_Indicators.GetATR().GetATR(0, 0);
   double curr_OHLC4 = CandleSticksBuffer[0][0].GetOHLC4();
   double curr_high = CandleSticksBuffer[0][0].GetHigh();
   
   double curr_volatility_pos = m_AdvIndicators.GetVolatility().GetVolatilityStdDevPosition(0, 0);
   double curr_os_pos = m_AdvIndicators.GetOBOS().GetOSStdDevPosition(0, 0);

   double curr_fractal_resistance = m_Indicators.GetFractal().GetFractalResistanceBarShiftPrice(0, 0);
   double curr_fractal_support = m_Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 0);
   
   double ZigZagPriceDifference = m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0) - MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(0, 1));
   double midpoint = NormalizeDouble(MathAbs(m_Indicators.GetZigZag().GetZigZagHighPrice(0, 0)) - (ZigZagPriceDifference/2), Digits);
   
   int strategy_type = -1;

   if(orderMagicNumber == GUAN_REVERSAL_SELL_STRATEGY)
   {
      strategy_type = Type_Reversal;
      hidden_takeprofit = Sell_HiddenTakeProfit[Type_Reversal];
   }
   else if(orderMagicNumber == GUAN_TRENDING_SELL_STRATEGY)
   {
      strategy_type = Type_Trend;
      hidden_takeprofit = Sell_HiddenTakeProfit[Type_Trend];
   }
   else if(orderMagicNumber == GUAN_CONTINUATION_SELL_STRATEGY)
   {
      strategy_type = Type_Continuation;
      hidden_takeprofit = Sell_HiddenTakeProfit[Type_Continuation];
   }
   else if(orderMagicNumber == GUAN_BREAKOUT_SELL_STRATEGY)
   {
      strategy_type = Type_Breakout;
      hidden_takeprofit = Sell_HiddenTakeProfit[Type_Breakout];
   }
   else if(orderMagicNumber == GUAN_FAKEOUT_SELL_STRATEGY)
   {
      strategy_type = Type_Fakeout;
      hidden_takeprofit = Sell_HiddenTakeProfit[Type_Fakeout];
   }

   // -------------  Close Order Modification based on event   -------------- 
   
   // Close off Breakout if Fakeout happens
   if(strategy_type == Type_Breakout && Open_Buy_Flag[Type_Fakeout])
   {
      m_AccountManager.CloseSellOrder(order_ticket);
      LogInfo("Fakeout Happens, Close Sell Breakout Order: " + (string)order_ticket + ", Reason: " + Open_Buy_Comment[Type_Fakeout][0]);
      return;
   }
   
   // Close Reversal Order Based on Hidden TakeProfit
   if(strategy_type == Type_Reversal 
   && (Close_Sell_Flag[Type_Reversal] || (hidden_takeprofit > 0 && Ask <= hidden_takeprofit))
   )
   {
      if(!Close_Sell_Flag[Type_Reversal])
      {
         Close_Sell_Flag[Type_Reversal] = true;
         Close_Sell_Comment[Type_Reversal] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Reversal];
         
         Close_Sell_Flag[Type_Trend] = true;
         Close_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
         Stop_Sell_Flag[Type_Reversal] = true;
         Stop_Sell_Comment[Type_Reversal] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Reversal];
         
         Stop_Sell_Flag[Type_Trend] = true;
         Stop_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
      }

      if(Is_Close_Trade(Type_Reversal, BEAR_TRIGGER))
      {
         m_AccountManager.CloseAllSellOrdersByMagicNumber(GUAN_REVERSAL_SELL_STRATEGY, GUAN_TRENDING_SELL_STRATEGY);
         LogInfo("Close All Sell Order With Reason: " + Close_Sell_Comment[Type_Reversal]);
         return;
      }
   }
   
   
   // Close Continuation Order Based on Hidden TakeProfit
   else if(strategy_type == Type_Continuation 
   && (Close_Sell_Flag[Type_Continuation] || (hidden_takeprofit > 0 && Ask <= hidden_takeprofit))
   )
   {
      if(!Close_Sell_Flag[Type_Continuation])
      {
         Close_Sell_Flag[Type_Continuation] = true;
         Close_Sell_Comment[Type_Continuation] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Continuation];
         
         Close_Sell_Flag[Type_Trend] = true;
         Close_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
         Stop_Sell_Flag[Type_Continuation] = true;
         Stop_Sell_Comment[Type_Continuation] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Continuation];
         
         Stop_Sell_Flag[Type_Trend] = true;
         Stop_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
      }

      if(Is_Close_Trade(Type_Continuation, BEAR_TRIGGER))
      {
         m_AccountManager.CloseAllSellOrdersByMagicNumber(GUAN_TRENDING_SELL_STRATEGY, GUAN_CONTINUATION_SELL_STRATEGY);
         LogInfo("Close All Sell Order With Reason: " + Close_Sell_Comment[Type_Continuation]);
         return;
      }
   }
   
   
   // Close Continuation Order Based on Hidden TakeProfit
   else if(strategy_type == Type_Trend 
   && (Close_Sell_Flag[Type_Trend] || (hidden_takeprofit > 0 && Ask <= hidden_takeprofit))
   )
   {
      if(!Close_Sell_Flag[Type_Trend])
      {
         Close_Sell_Flag[Type_Trend] = true;
         Close_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
         Stop_Sell_Flag[Type_Trend] = true;
         Stop_Sell_Comment[Type_Trend] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Trend];
         
         // Reversal
         if(Open_Sell_Flag[Type_Reversal])
         {
            Close_Sell_Flag[Type_Reversal] = true;
            Close_Sell_Comment[Type_Reversal] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Reversal];
            
            Stop_Sell_Flag[Type_Reversal] = true;
            Stop_Sell_Comment[Type_Reversal] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Reversal];
         }
         
         // Continuation
         if(Open_Sell_Flag[Type_Continuation])
         {
            Close_Sell_Flag[Type_Continuation] = true;
            Close_Sell_Comment[Type_Continuation] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Continuation];
            
            Stop_Sell_Flag[Type_Continuation] = true;
            Stop_Sell_Comment[Type_Continuation] = "Ask<=TP-"+(string)Sell_HiddenTakeProfit[Type_Continuation];
         }  
      }

      if(Is_Close_Trade(Type_Trend, BEAR_TRIGGER))
      {
         m_AccountManager.CloseAllSellOrdersByMagicNumber(GUAN_REVERSAL_SELL_STRATEGY, GUAN_CONTINUATION_SELL_STRATEGY);
         LogInfo("Close All Sell Order With Reason: " + Close_Sell_Comment[Type_Trend]);
         return;
      }
   }
   
  

   // -------------  Stop Loss Modification based on event   -------------- 

   // Squeezing, do not modify stop loss as giving breathing areas for fakeout/breakouts
   if(Filter_Sell_Flag[Type_Breakout][Filter_1])
      return;

   
   // Semi Close if it hits the Order Block of the SL 

   
   // Modify New Stop Loss
   if((order_stoploss == 0 || (new_stoploss > 0 && new_stoploss < order_stoploss))
   && new_stoploss > Ask
   )
   {
      if(!order.ModifyStopLoss(new_stoploss, "Modified Sell StopLoss --- " + stop_loss_comment))
         LogError(__FUNCTION__, "Failed to Update Sell Stop Loss --- " + stop_loss_comment);
         
      else
         Shift_Modify_Sell_Comments(strategy_type, stop_loss_comment);
         
      // update new update date time
      if(curtime != order_last_update_time)
         order.SetLastUpdateDateTime(curtime);     
   }
   
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string GuanStrategy::GetOrderZone(string order_comment)
{
   if(order_comment == "")
   {
      LogError(__FUNCTION__, "Order Comment is invalid");
      return "";
   }
   
   string results[];
   StringSplit(order_comment, '/', results);

   return results[ArraySize(results)-1];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GuanStrategy::ResetFilterBuyFlag(int type_strategy,int filter_number)
{
   Filter_Buy_Flag[type_strategy][filter_number] = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetFilterSellFlag(int type_strategy,int filter_number)
{
   Filter_Sell_Flag[type_strategy][filter_number] = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetFilterBuyComment(int type_strategy,int filter_number)
{
   Shift_Filter_Buy_Comments(type_strategy, filter_number, "----");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetFilterSellComment(int type_strategy,int filter_number)
{
   Shift_Filter_Sell_Comments(type_strategy, filter_number, "----");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetBuyOrder(int type_strategy)
{
   Open_Buy_Flag[type_strategy] = false;
   Shift_Open_Buy_Comments(type_strategy, "----");
   Close_Buy_Flag[type_strategy] = false;
   Shift_Close_Buy_Comments(type_strategy, "----");
   Shift_Modify_Buy_Comments(type_strategy, "----");
   
   Buy_HiddenTakeProfit[type_strategy] = 0;        // Reset Buy Hidden Order 
   Buy_HiddenStopLoss[type_strategy] = 0;
   Stop_Buy_Flag[type_strategy] = false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetSellOrder(int type_strategy)
{
   Open_Sell_Flag[type_strategy] = false;
   Shift_Open_Sell_Comments(type_strategy, "----");
   Close_Sell_Flag[type_strategy] = false;
   Shift_Close_Sell_Comments(type_strategy, "----");
   Shift_Modify_Sell_Comments(type_strategy, "----");
   
   Sell_HiddenTakeProfit[type_strategy] = 0;        // Reset Buy Hidden Order 
   Sell_HiddenStopLoss[type_strategy] = 0;          
   Stop_Sell_Flag[type_strategy] = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetStopBuyOrder(int type_strategy)
{
   Stop_Buy_Flag[type_strategy] = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetStopBuyOrderComment(int type_strategy)
{
   Stop_Buy_Comment[type_strategy] = "----";
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetStopSellOrder(int type_strategy)
{
   Stop_Sell_Flag[type_strategy] = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::ResetStopSellOrderComment(int type_strategy)
{
   Stop_Sell_Comment[type_strategy] = "----";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Shift_Filter_Buy_Comments(int type_strategy, int filter_number, string order_comments)
{
   // N/A Means push the previous to the front
   if(order_comments == "N/A")
   {  
      // Push the Previous ones to front
      for(int i = 1; i < Shift_Look_Back-1; i++)
         Filter_Buy_Comment[type_strategy][filter_number][i-1] = Filter_Buy_Comment[type_strategy][filter_number][i];
   
      // Set the last one as nothing 
      Filter_Buy_Comment[type_strategy][filter_number][Shift_Look_Back-1] = "----";
      return true;
   }

   // If Order_Comments == --- Means just shift by 1 as narrative changes
   else if(order_comments == "----")
   {
      if(Filter_Buy_Comment[type_strategy][filter_number][0] == "----")
         return true;
      else if(Filter_Buy_Comment[type_strategy][filter_number][0] == "N/A")
      {
         Filter_Buy_Comment[type_strategy][filter_number][0] = "----";
         return true;
      }

      for(int i = Shift_Look_Back-1 ; i > 0; i--)
         Filter_Buy_Comment[type_strategy][filter_number][i] = Filter_Buy_Comment[type_strategy][filter_number][i-1];
      
      Filter_Buy_Comment[type_strategy][filter_number][0] = "----";
      return true;
   }
   
   // Make sure to only shift if the same strategy does not appear in last 5 M15 bars
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      if(Filter_Buy_Comment[type_strategy][filter_number][i] == "----")
         break;
      // Filter type already appeared in last Shifts
      if(order_comments == Filter_Buy_Comment[type_strategy][filter_number][i])
         return false;
   }
 
   // Passed the test
   if(Filter_Buy_Comment[type_strategy][filter_number][0] == "----")
      Filter_Buy_Comment[type_strategy][filter_number][0] = order_comments;
   else
   {
      // Passed the test
      for(int i = Shift_Look_Back-1; i > 0; i--)
         Filter_Buy_Comment[type_strategy][filter_number][i] = Filter_Buy_Comment[type_strategy][filter_number][i-1];
   
      Filter_Buy_Comment[type_strategy][filter_number][0] = order_comments;
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Shift_Filter_Sell_Comments(int type_strategy, int filter_number, string order_comments)
{

   // N/A Means push the previous to the front
   if(order_comments == "N/A")
   {  
      // Push the Previous ones to front
      for(int i = 1; i < Shift_Look_Back-1; i++)
         Filter_Sell_Comment[type_strategy][filter_number][i-1] = Filter_Sell_Comment[type_strategy][filter_number][i];
   
      // Set the last one as nothing 
      Filter_Sell_Comment[type_strategy][filter_number][Shift_Look_Back-1] = "----";
      return true;
   }

   // If Order_Comments == --- Means just shift by 1 as narrative changes
   else if(order_comments == "----")
   {
      if(Filter_Sell_Comment[type_strategy][filter_number][0] == "----")
         return true;
      else if(Filter_Sell_Comment[type_strategy][filter_number][0] == "N/A")
      {
         Filter_Sell_Comment[type_strategy][filter_number][0] = "----";
         return true;
      }
   
      for(int i = Shift_Look_Back-1 ; i > 0; i--)
      {
         Filter_Sell_Comment[type_strategy][filter_number][i] = Filter_Sell_Comment[type_strategy][filter_number][i-1];
      }
      
      Filter_Sell_Comment[type_strategy][filter_number][0] = "----";
      return true;
   }


   // Make sure to only shift if the same strategy does not appear in last 5 M15 bars   
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      if(Filter_Sell_Comment[type_strategy][filter_number][i] == "----")
         break;
      // Filter type already appeared in last Shifts
      if(order_comments == Filter_Sell_Comment[type_strategy][filter_number][i])
         return false;
   }
   
   // Passed the test
   if(Filter_Sell_Comment[type_strategy][filter_number][0] == "----")
      Filter_Sell_Comment[type_strategy][filter_number][0] = order_comments;
   else
   {
      // Passed the test
      for(int i = Shift_Look_Back-1; i > 0; i--)
         Filter_Sell_Comment[type_strategy][filter_number][i] = Filter_Sell_Comment[type_strategy][filter_number][i-1];
   
      Filter_Sell_Comment[type_strategy][filter_number][0] = order_comments;
   }

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Shift_Open_Buy_Comments(int type_strategy, string order_comments)
{
   // If Order_Comments == --- Means just shift by 1 as narrative changes
   if(order_comments == "----")
   {
      if(Open_Buy_Comment[type_strategy][0] == "----")
         return;
   
      for(int i = Shift_Look_Back-1 ; i > 0; i--)
      {
         Open_Buy_Comment[type_strategy][i] = Open_Buy_Comment[type_strategy][i-1];
      }
      
      Open_Buy_Comment[type_strategy][0] = "----";
   }

   if(Open_Buy_Comment[type_strategy][0] != order_comments)
   {
      for(int i = Shift_Look_Back-1; i > 0; i--)
      {
         Open_Buy_Comment[type_strategy][i] = Open_Buy_Comment[type_strategy][i-1];
      }
   }
   Open_Buy_Comment[type_strategy][0] = order_comments;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Shift_Open_Sell_Comments(int type_strategy, string order_comments)
{
   // If Order_Comments == --- Means just shift by 1 as narrative changes
   if(order_comments == "----")
   {
      if(Open_Sell_Comment[type_strategy][0] == "----")
         return;
   
      for(int i = Shift_Look_Back-1 ; i > 0; i--)
      {
         Open_Sell_Comment[type_strategy][i] = Open_Sell_Comment[type_strategy][i-1];
      }
      
      Open_Sell_Comment[type_strategy][0] = "----";
   }

   if(Open_Sell_Comment[type_strategy][0] != order_comments)
   {
      for(int i = Shift_Look_Back-1; i > 0; i--)
      {
         Open_Sell_Comment[type_strategy][i] = Open_Sell_Comment[type_strategy][i-1];
      }
   }
   Open_Sell_Comment[type_strategy][0] = order_comments;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Shift_Close_Buy_Comments(int type_strategy,string order_comments)
{
   if(order_comments == "")
      return false;

   Close_Buy_Comment[type_strategy] = order_comments;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GuanStrategy::Shift_Close_Sell_Comments(int type_strategy, string order_comments)
{
   if(order_comments == "")
      return false;

   Close_Sell_Comment[type_strategy] = order_comments;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Shift_Modify_Buy_Comments(int type_strategy, string order_comments)
{
   if(order_comments == "")
      return;

   Modify_Buy_Comment[type_strategy] = order_comments;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void GuanStrategy::Shift_Modify_Sell_Comments(int type_strategy, string order_comments)
{
   if(order_comments == "")
      return;

   Modify_Sell_Comment[type_strategy] = order_comments;
}

//+------------------------------------------------------------------+