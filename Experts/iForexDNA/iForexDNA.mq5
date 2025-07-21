//+------------------------------------------------------------------+
//|                                                    iForexDNA.mq5 |
//|                                          Copyright 2016, iPayDNA |
//|                                               http://ipaydna.biz |
//+------------------------------------------------------------------+

#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict

//#include <stderror.mqh>
#include <StdLibErr.mqh>
#include <stdlib.mq5>
//#include <WinUser32.mqh>
//#import "user32.dll";
int GetAncestor(int,int);

// Helper functions for testing/visual mode
bool IsTesting() { return MQLInfoInteger(MQL_TESTER); }
bool IsVisualMode() { return MQLInfoInteger(MQL_VISUAL_MODE); }

/*
#include    "..\..\iForexDNA\Graphics.mqh"
#include    "..\..\iForexDNA\EventHandler.mqh"
#include    "..\iForexDNA\ZigZagPauser.mqh"
*/
#include    "..\..\iForexDNA\Graphics.mqh"
#include    "..\..\iForexDNA\ExternVariables.mqh"
#include    "..\..\iForexDNA\Enums.mqh"
#include    "..\..\iForexDNA\CandleStick\CandleStick.mqh"
#include    "..\..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include    "..\..\iForexDNA\IndicatorsHelper.mqh"

#include    "..\..\iForexDNA\IndicatorsHelper.mqh"
#include    "..\..\iForexDNA\AdvanceIndicator.mqh"
#include    "..\..\iForexDNA\MarketCondition.mqh"
#include    "..\..\iForexDNA\Probability.mqh"

#include    "..\..\iForexDNA\AccountManager.mqh"

#include    "..\..\iForexDNA\Orderblocks.mqh"
#include    "..\..\iForexDNA\OpenPosition.mqh"
#include    "..\..\iForexDNA\ManagePosition.mqh"

//#include    "..\iForexDNA\Analysis\Analysis.mqh"
//#include    "..\iForexDNA\Analysis\Evaluation.mqh"

//#include    "..\Telegram\TelegramBot.mqh"


CandleStickArray     CSAnalysis;
IndicatorsHelper     Indicators;
OrderBlockFinder     orderblock(&CSAnalysis, &Indicators);

AccountManager       accountManager;
AdvanceIndicator     AdvIndicators(&Indicators);

MarketCondition      marketcondition(&CSAnalysis, &Indicators, &AdvIndicators);
Probability          probablity(&CSAnalysis, &Indicators, &AdvIndicators);

OpenPosition         openposition(&Indicators, &accountManager, &AdvIndicators, &CSAnalysis, &marketcondition, &probablity);
ManagePosition       manageposition(&CSAnalysis,&accountManager,&Indicators, &AdvIndicators, &marketcondition, &openposition);
Graphics             graphics(&CSAnalysis, &Indicators, &AdvIndicators,&marketcondition);

/* 
TelegramBot          telegramBot(&accountManager);
int                  telegram_result;

Graphics             graphics(&CSAnalysis,&accountManager, &Indicators, &AdvIndicators, &openposition, &marketcondition, &probablity);
Analysis             analysis(&Indicators, &AdvIndicators, &CSAnalysis, &probablity);
Evaluation           evaluation(IsTesting());
*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
   
   ObjectsDeleteAll(0);   
   TesterHideIndicators(true);

   MQLInfoInteger(MQL_TRADE_ALLOWED);
   MQLInfoInteger(MQL_DLLS_ALLOWED);


   // Check Daylight savings
   
   CheckLondonDayLightSaving();
   CheckNYDayLightSaving();
   
      
   if(!CSAnalysis.Init())
   {
      printf("CSAnalysis.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!Indicators.Init())
   {
      printf("Indicators.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!AdvIndicators.Init())
   {
      printf("Indicators.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!marketcondition.Init())
   {
      printf("MarketCondition.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!probablity.Init())
   {
      printf("Probability.Init() Failed");
      return(REASON_INITFAILED);
   }


   if(!accountManager.Init())
   {
      printf("accountManager.Init() Failed");
      return(REASON_INITFAILED);
   }
   
/*
   if(!openposition.Init())
   {
      printf("openPosition.Init() Failed");
      return(REASON_INITFAILED);
   }


   if(!manageposition.Init())
   {
      printf("ManagePosition.Init() Failed");
      return(REASON_INITFAILED);
   }
*/

   // Initialize Orderblock
   orderblock.RunOncePerDay();
   if(!graphics.Init()) 
   {
      printf("graphics.Init() Failed");
      return(REASON_INITFAILED);
   }
   
   /*if(DO_ANALYSIS && !analysis.Init())
   {
      printf("analysis.Init() Failed");
      return(REASON_INITFAILED);
   }*/
/*
   
   


   if(!IsTesting() && WITH_TELEGRAM)
   {
      // set up telegram bot
      if(accountManager.GetChartCurrencySymbol() == "EURUSD")
         telegramBot.Token(EURUSD_TELEGRAM_BOT_TOKEN);
      else if(accountManager.GetChartCurrencySymbol() == "XAUUSD")
         telegramBot.Token(XAUUSD_TELEGRAM_BOT_TOKEN);
      else
      {
         LogError(__FUNCTION__, "Symbol is not supported for Telegram Integration yet.");
         return(REASON_INITFAILED);
      } 
         
      telegram_result = telegramBot.GetMe();
      
      if(telegram_result!=0)
         Comment("Error: " + GetErrorDescription(telegram_result)); 
   }
   
   else
      Comment("Activate Telegram Bot in Expert Settings.");
   */
   return(INIT_SUCCEEDED);
  
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   /*if(telegram_result == 0 && !IsTesting() && WITH_TELEGRAM)
   {  
      telegramBot.GetUpdates();
      telegramBot.ProcessMessages();
   }*/
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      isNewBar[i] = false;
      isNewBar[i]=CheckIsNewBar(timeFrameENUM);
      
      // DLS (TimeZone Update)
      if(timeFrameENUM == PERIOD_D1)
      {
         CheckLondonDayLightSaving();
         CheckNYDayLightSaving();
         
         if(i == 5 && isNewBar[i])
            orderblock.RunOncePerDay();
      }

         CSAnalysis.OnUpdate(i,isNewBar[i]); 
         Indicators.OnUpdate(i,isNewBar[i]);
         AdvIndicators.OnUpdate(i, isNewBar[i]);
         marketcondition.OnUpdate(i, isNewBar[i]);
         probablity.OnUpdate(i, isNewBar[i]);
      
      // Enable dashboard update
      if(!IsTesting() || (IsTesting() && IsVisualMode()))
         graphics.OnUpdate(i,isNewBar[i]);
         
      /*
      if(IsTesting() && DO_ANALYSIS  && i ==0)
         analysis.OnUpdate(i, isNewBar[i]);
           */ 
   }     // i loop

   //accountManager.OnUpdate();
   //openposition.OnUpdate();  
   //manageposition.OnUpdate();
   
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

/*  
   
REASON_PROGRAM 0 -   Expert Advisor terminated its operation by calling the ExpertRemove() function
REASON_REMOVE 1 -    Program has been deleted from the chart
REASON_RECOMPILE 2 - Program has been recompiled
REASON_CHARTCHANGE 3 - Symbol or chart period has been changed
REASON_CHARTCLOSE 4 - Chart has been closed
REASON_PARAMETERS 5 - Input parameters have been changed by a user
REASON_ACCOUNT 6 - Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings
REASON_TEMPLATE 7 - A new template has been applied
REASON_INITFAILED 8 - This value means that OnInit() handler has returned a nonzero value
REASON_CLOSE 9 - Terminal has been closed
*/


     /* if(!IsTesting() && (reason == REASON_ACCOUNT || reason == REASON_REMOVE))
      {
         graphics.RemoveSubwindowByName(SUBWINDOW4);
         graphics.RemoveSubwindowByName(SUBWINDOW3);
         graphics.RemoveSubwindowByName(SUBWINDOW2);
         graphics.RemoveSubwindowByName(SUBWINDOW1);
   
         ObjectsDeleteAll(ChartID());
      }*/
      
      if(reason == REASON_PARAMETERS || reason == REASON_RECOMPILE)
      {
         ObjectsDeleteAll(ChartID());
         OnInit();
      }

   }
//+------------------------------------------------------------------+