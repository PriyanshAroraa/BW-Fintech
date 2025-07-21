//+------------------------------------------------------------------+
//|                                                     MiscFunc.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#include <WinUser32.mqh>
#import "user32.dll"
int GetAncestor(int,int);
#import

#include <stderror.mqh>
#include <stdlib.mqh>
#include "..\iForexDNA\hash.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\AccountManager.mqh"
#include "..\iForexDNA\Graphics.mqh"



#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property strict


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
{
      
      

      if(id == CHARTEVENT_CHART_CHANGE)
      {
         
         graphics.Init();
         ChartRedraw();
      }
      
      if(id == CHARTEVENT_OBJECT_ENDEDIT)
      {
      
         if(sparam == "AspectRatioEdit")
         {
            string   AspectRatio, NewStrVal; 
            double   NewVal;

            EditTextGet(AspectRatio, 0, sparam);
            NewVal = StringToDouble(AspectRatio);
            
            if(NewVal < 1 || NewVal > 2)
            {
               Alert("Aspect Ratio  "+(string)NewVal+" is not a Number or within parameters = "+"1-2");
               EditTextChange(0, sparam, (string) NormalizeDouble((double) DoubleToString(ASPECT_RATIO), 2));
               
            }
            else
            {         
               EditTextGet(NewStrVal,0,sparam);
               ASPECT_RATIO = NormalizeDouble(StringToDouble(NewStrVal), 2);
               Alert("Aspect Ratio Changed to = "+(string)ASPECT_RATIO);
               graphics.Init();
               ChartRedraw();
            }   
         }
         
         // MODIFY BUY ORDERS
         else if(sparam == "ModifyBuySLEdit")
         {
            string   newStopLoss, NewStrVal; 
            double   NewVal;

            EditTextGet(newStopLoss, 0, sparam);
            NewVal = StringToDouble(newStopLoss);
            
            if(NewVal <= 0 || NewVal >= MarketInfo(Symbol(), MODE_BID) || accountManager.GetTotalNumberOfOpenBuyOrders() <= 0)
            {
               Alert("Stop Loss:  "+(string)NewVal+" is invalid.");
               EditTextChange(0, sparam, "0");
               
            }
            else
            {  
               EditTextGet(NewStrVal,0,sparam);
               accountManager.ModifyAllStopLoss(Symbol(), StringToDouble(NewStrVal), OP_BUY);
            
            }   
         }
         
         // MODIFY SELL ORDERS
         else if(sparam == "ModifySellSLEdit")
         {
            string   newStopLoss, NewStrVal; 
            double   NewVal;

            EditTextGet(newStopLoss, 0, sparam);
            NewVal = StringToDouble(newStopLoss);
            
            if(NewVal <= 0 || NewVal <= MarketInfo(Symbol(), MODE_ASK) || accountManager.GetTotalNumberOfOpenSellOrders() <= 0)
            {
               Alert("Stop Loss:  "+(string)NewVal+" is invalid.");
               EditTextChange(0, sparam, "0");
               
               
            }
            else
            {
               EditTextGet(NewStrVal,0,sparam);
               accountManager.ModifyAllStopLoss(Symbol(), StringToDouble(NewStrVal), OP_SELL);    
            }   
         }
         
         
         // TRAILING STOP WITH (PIP)
         else if(sparam == "PipTrailingEdit")
         {
            string   pipStopLoss, NewStrVal; 
            double   NewVal;

            EditTextGet(pipStopLoss, 0, sparam);
            NewVal = StringToDouble(pipStopLoss);
            
            if((NewVal > 0 && NewVal < 50) && TRAILINGPIP_ENABLE && !TRAILINGATR_ENABLE){
               EditTextGet(NewStrVal,0,sparam);
               Trailing_PIP = StringToDouble(NewStrVal);  
               accountManager.SetTrailingStopByATR(Trailing_PIP); 
            }
            
            else
            {
               Alert("Invalid Button Usage. Please ensure Button is activated and value is in between 1-49.");
               EditTextChange(0, sparam, "0");
            }   
         }


         // TRAILING STOP WITH (ATR)
         else if(sparam == "ATRTrailingEdit")
         {
            string   ATRStopLoss, NewStrVal; 
            double   NewVal;

            EditTextGet(ATRStopLoss, 0, sparam);
            NewVal = StringToDouble(ATRStopLoss);
            
            if((NewVal >= 0.5 && NewVal <= 3) && TRAILINGATR_ENABLE && !TRAILINGPIP_ENABLE){            
               EditTextGet(NewStrVal,0,sparam);
               Trailing_ATR = StringToDouble(NewStrVal);   
               accountManager.SetTrailingStopByATR(Trailing_ATR);
            }
            
            else
            {
               Alert("Invalid Button Usage. Please ensure Button is activated and value is in between 0.5 - 3.");
               EditTextChange(0, sparam, "0");
            }   
         }

      }
      
      
      if(id == CHARTEVENT_OBJECT_CLICK)
      {
      ////////////////////////      GENERAL FUNCTION BUTTONS      /////////////////////////////////////
      
         if(sparam == "ResetEA")
         {
            OnInit();
         }
         
         
         else if(sparam == "CloseAllOrders")
         {
            Alert("Closing All Orders");
            accountManager.CloseAllOrders();
         }
         
         
         else if(sparam == "CloseAllBuyOrdersBySymbol")
         {
            Alert("Closing All Buy Orders By Symbol");
            accountManager.CloseAllBuyOrdersByChartSymbol();
         }
         
         
         else if(sparam == "CloseAllSellOrdersBySymbol")
         {
            Alert("Closing All Sell Orders By Symbol");
            accountManager.CloseAllSellOrdersByChartSymbol();
         }
      
      
      
         // Trailing Stop by Pip / %ATR
         else if(sparam == "PipTrailingStop")
         {
            if(TRAILINGPIP_ENABLE == false){
               TRAILINGPIP_ENABLE = true;               
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
                        
            }
            
            
            else{
               Trailing_PIP = 0;
               TRAILINGPIP_ENABLE = false;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
               Alert("Automatic PIP Trailing Stop is turned off.");
            }
         
         }
         
         // ATR
         else if(sparam == "ATRTrailingStop")
         {
            if(TRAILINGATR_ENABLE == false){          
               TRAILINGATR_ENABLE = true;               
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            }      
            
            
            
            else{
               Trailing_ATR = 0;
               TRAILINGATR_ENABLE = false;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
               Alert("Automatic ATR Trailing Stop is turned off.");
            }
         
         }
      
      
      
      ////////////////////////      FIBFONASSI BUTTONS      /////////////////////////////////////
      
      
      // Press Main Fib Button
      
         else if(sparam == "Fibonassi")
         {
            if(SHOW_FIB_ALL == true)
            {
               SHOW_FIB_ALL = false;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
            }
            else
            {
               SHOW_FIB_ALL = true;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            }
            for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
            {
               SHOW_FIB_ON_CHART[i] = SHOW_FIB_ALL;
               
               if(SHOW_FIB_ON_CHART[i])
               {
                  ObjectSetInteger(0,"FibonassiM15",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"FibonassiH1",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"FibonassiH4",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"FibonassiD1",OBJPROP_BGCOLOR,BUTTON_ON);
               }
               else
               {
                  ObjectSetInteger(0,"FibonassiM15",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"FibonassiH1",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"FibonassiH4",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"FibonassiD1",OBJPROP_BGCOLOR,BUTTON_OFF);
               }
            }
            
         }
      
      
          // M15
         else if(sparam == "FibonassiM15")
         {
            SHOW_FIB_ON_CHART[0] = !SHOW_FIB_ON_CHART[0];
            if(SHOW_FIB_ON_CHART[0])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }

         // H1
         else if(sparam == "FibonassiH1")
         {
            SHOW_FIB_ON_CHART[1] = !SHOW_FIB_ON_CHART[1];
            if(SHOW_FIB_ON_CHART[1])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
         
         // H4
         else if(sparam == "FibonassiH4")
         {
            SHOW_FIB_ON_CHART[2] = !SHOW_FIB_ON_CHART[2];
            if(SHOW_FIB_ON_CHART[2])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
         
         // D1
         else if(sparam == "FibonassiD1")
         {
            SHOW_FIB_ON_CHART[3] = !SHOW_FIB_ON_CHART[3];
            if(SHOW_FIB_ON_CHART[3])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
         
         ////////////////////////      MTF BUTTONS      /////////////////////////////////////
      
      
      // Press Main MTF Button
      
         else if(sparam == "MTF")
         {
            if(SHOW_FRACTAL_ALL == true)
            {
               SHOW_FRACTAL_ALL = false;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
            }
            else
            {
               SHOW_FRACTAL_ALL = true;
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            }
            for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
            {
               SHOW_FRACTAL_ON_CHART[i] = SHOW_FRACTAL_ALL;
               
               if(SHOW_FRACTAL_ON_CHART[i])
               {
                  ObjectSetInteger(0,"MTFM15",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"MTFH1",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"MTFH4",OBJPROP_BGCOLOR,BUTTON_ON);
                  ObjectSetInteger(0,"MTFD1",OBJPROP_BGCOLOR,BUTTON_ON);
               }
               else
               {
                  ObjectSetInteger(0,"MTFM15",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"MTFH1",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"MTFH4",OBJPROP_BGCOLOR,BUTTON_OFF);
                  ObjectSetInteger(0,"MTFD1",OBJPROP_BGCOLOR,BUTTON_OFF);
               }
            }
         }
      
      
          // M15
         else if(sparam == "MTFM15")
         {
            SHOW_FRACTAL_ON_CHART[0] = !SHOW_FRACTAL_ON_CHART[0];
            if(SHOW_FRACTAL_ON_CHART[0])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }

         // H1
         else if(sparam == "MTFH1")
         {
            SHOW_FRACTAL_ON_CHART[1] = !SHOW_FRACTAL_ON_CHART[1];
            if(SHOW_FRACTAL_ON_CHART[1])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
         
         // H4
         else if(sparam == "MTFH4")
         {
            SHOW_FRACTAL_ON_CHART[2] = !SHOW_FRACTAL_ON_CHART[2];
            if(SHOW_FRACTAL_ON_CHART[2])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
         
         // D1
         else if(sparam == "MTFD1")
         {
            SHOW_FRACTAL_ON_CHART[3] = !SHOW_FRACTAL_ON_CHART[3];
            if(SHOW_FRACTAL_ON_CHART[3])
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_ON);
            else
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,BUTTON_OFF);
         }
               
   }  
      
}