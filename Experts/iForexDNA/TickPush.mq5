//+------------------------------------------------------------------+
//|                                                  DataRequest.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include    "..\..\iForexDNA\ExternVariables.mqh"
#include    "..\..\iForexDNA\hash.mqh"
#include    "..\..\iForexDNA\MiscFunc.mqh"
#include    "..\..\iForexDNA\Enums.mqh"
#include    "..\..\iForexDNA\CandleStick\CandleStick.mqh"
#include    "..\..\iForexDNA\CandleStick\CandleStickArray.mqh"

#include    "..\..\iForexDNA\IndicatorsHelper.mqh"
#include    "..\..\iForexDNA\AdvanceIndicator.mqh"
#include    "..\..\iForexDNA\ReversalProbability.mqh"
#include    "..\..\iForexDNA\MarketCondition.mqh"
#include    "..\..\iForexDNA\Orderblocks.mqh"

input string TICK_SERVER_URL = "http://127.0.0.1:5000";
input string PREDICTION_SERVICE_URL = "http://127.0.0.1:5555";
input string ORDERBLOCK_SERVICE_URL = "http://127.0.0.1:6000";
input bool LOG_ACTIVITY = true;

datetime last_error_report;

int count = 5;
string current_symbol = Symbol();
datetime m_LastCheckMinute = 0;
datetime m_LastCheckDay = 0;

CandleStickArray     CSAnalysis;
IndicatorsHelper     Indicators;
AdvanceIndicator     AdvIndicators(&Indicators);
MarketCondition      marketcondition(&CSAnalysis, &Indicators, &AdvIndicators);
ReversalProbability  reversalprob(&CSAnalysis, &Indicators, &AdvIndicators);
OrderBlockFinder     orderblock(&CSAnalysis, &Indicators);

// Define all column names in an array
string feature_columns[] = {
   "DivergenceType", "DivergenceCode", "DivergencePercent", "ZigzagPoint",
   "Resistance", "Support", "BullPercent", "BullPosition", "BearPercent", 
   "BearPosition", "OverboughtPercent", "OverboughtPosition", "OversoldPercent",
   "OversoldPosition", "VolatilityPercent", "VolatilityPosition", 
   "BuyMomentumPercent", "BuyMomentumMean", "SellMomentumPercent", "SellMomentumMean",
   "BuyTrendPercent", "BuyTrendMean", "SellTrendPercent", "SellTrendMean",
   "CSBodyPercent", "CSBodyPosition", "CSTopPercent", "CSTopPosition",
   "CSBotPercent", "CSBotPosition", "BuyIndicatorTriggerPosition", 
   "SellIndicatorTriggerPosition", "BuyLineTriggerPosition", "SellLineTriggerPosition",
   "BuyReversalProbability", "SellReversalProbability", "ChikouPosition", "MarketCondition",
   "BandQuadrant", "TenkanQuadrant", "KijunQuadrant", 
   "FibonacciLevel"
};

datetime current_m1_time = iTime(current_symbol, PERIOD_M1, 0);
long tickvolume = iVolume(current_symbol, PERIOD_M1, 0);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

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
   
   if(!reversalprob.Init())
   {
      printf("ReversalProbability.Init() Failed");
      return(REASON_INITFAILED);
   }
   
   if(!marketcondition.Init())
   {
      printf("ReversalProbability.Init() Failed");
      return(REASON_INITFAILED);
   }   
   
   orderblock.RunOncePerDay();
   
   if(LOG_ACTIVITY) Print("TickSender initialized");

   SendOrderblockData();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    if(LOG_ACTIVITY) Print("TickSender deinitialized");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static MqlTick prev_tick;
   MqlTick last_tick;
   datetime current_minute = iTime(_Symbol, PERIOD_M1, 0);
   datetime current_day = iTime(_Symbol, PERIOD_D1, 0);
      
   //--- Send Minute data
   if(current_m1_time > m_LastCheckMinute)
   {
      for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      {
         // Get TimeFrame ENUM
         ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
         bool newbar = CheckIsNewBar(timeFrameENUM);
         
         // On Update all the indicators
         CSAnalysis.OnUpdate(i, newbar);
         Indicators.OnUpdate(i, newbar);
         AdvIndicators.OnUpdate(i, newbar);
         reversalprob.OnUpdate(i, newbar);
      }
      
      // Send New JSON 
      if(SendMinuteData())
         m_LastCheckMinute = current_m1_time;    //  Update last check minute if advindicator is pushed
   }
   
   // Sending Order block
   if(current_day > m_LastCheckDay)
   {      
      orderblock.RunOncePerDay();
      
      if(SendOrderblockData())
         m_LastCheckDay = current_day;       // Update last check day if order block is pushed
   }
     
     
   // Sending the tick data format
   if (!SymbolInfoTick(current_symbol, last_tick))
      return;
   
   // Optional: Skip duplicate ticks to reduce traffic
   if(last_tick.time == prev_tick.time && 
      last_tick.bid == prev_tick.bid && 
      last_tick.ask == prev_tick.ask)
      return;
      
   prev_tick = last_tick;
   
   // Send tick data with minimal formatting
   SendTickData(last_tick);
     
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SendTickData(MqlTick &tick)
{
    MqlDateTime dt;
    datetime currentTime = TimeCurrent();
    datetime m1time = iTime(current_symbol, PERIOD_M1, 0);
    ulong currentMilliseconds = GetTickCount64();
    
    TimeToStruct(currentTime, dt);

   // Minimal JSON format
   char post_data[];

   string headers = "Content-Type: application/json";
   char result[];
   int timeout = 100; // Ultra short timeout for speed
   
   long current_volume = iVolume(Symbol(), PERIOD_M1, 0);
   long push_volume = 0;
   
   // reset tick volume (Update if its new bar)
   if(m1time != current_m1_time)
   {
      current_m1_time = m1time;
      push_volume = current_volume;
      tickvolume = push_volume;
   }
   
   // Check for tick volume
   else
   {
      push_volume = current_volume-tickvolume;
      tickvolume = push_volume;
   }
   

   // Pre-allocate approximate JSON size
   string json = "{\"datetime\":\"" + StringFormat("%02d-%02d-%04d %02d:%02d:%02d.%03d", 
              dt.day, dt.mon, dt.year, dt.hour, dt.min, dt.sec, 
              (int)(currentMilliseconds % 1000)) + 
              "\",\"symbol\":\"" + Symbol() + 
              "\",\"ask\":" + DoubleToString(tick.ask, _Digits) + 
              ",\"bid\":" + DoubleToString(tick.bid, _Digits) + 
              ",\"volume\":" + IntegerToString(push_volume) + 
              "}";

   // Convert JSON string to char array for WebRequest
   StringToCharArray(json, post_data);

   // Make the request
   int res = WebRequest("POST", TICK_SERVER_URL+"/tick_data_raw", headers, timeout, post_data, result, headers);

   if (res == -1)    
   {
      int error_code = GetLastError();
         
      // Limit error reporting to once per minute
      if(TimeCurrent() - last_error_report > 60)
      {
         if(LOG_ACTIVITY)
         {
            Print("TickPush WebRequest failed. Error: ", error_code);
            last_error_report = TimeCurrent();
         }  
      }
      
    }
    
    // set the latest volume
    
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool SendMinuteData()
{
   // Minimal JSON format
   char post_data[];

   string headers = "Content-Type: application/json";
   char result[];
   int timeout = 100; // Ultra short timeout for speed

   datetime curtime = TimeCurrent();
   
   MqlDateTime t;
   TimeToStruct(curtime, t);
   
   string formatted_time = StringFormat("%02d-%02d-%04d %02d:%02d",
                                   t.day, t.mon, t.year,
                                   t.hour, t.min);

   // Pre-allocate approximate JSON size
   string json = "{\"Datetime\":\"" + formatted_time + 
              "\",\"Symbol\":\"" +  current_symbol + 
              "\",\"Open\":" + DoubleToString(iOpen(current_symbol, PERIOD_M1, 0), _Digits) + 
              ",\"High\":" +  DoubleToString(iHigh(current_symbol, PERIOD_M1, 0), _Digits) + 
              ",\"Low\":" +  DoubleToString(iLow(current_symbol, PERIOD_M1, 0), _Digits) + 
              ",\"Close\":" +  DoubleToString(iClose(current_symbol, PERIOD_M1, 0), _Digits)+",";

   // Concatenate it into all timeframes
   for(int i =0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      string timeFrameStr = GetTimeFrameString(i);
      
      // Get dynamic values for this timeframe
      string columnValues[];
      GetColumnValues(i, columnValues);
   
      // Loop through all columns
      for(int j = 0; j < ArraySize(feature_columns); j++)
      {
         json += "\"" + timeFrameStr + feature_columns[j] + "\":" + columnValues[j];
         
         if(j == ArraySize(feature_columns) - 1 && i == ENUM_TIMEFRAMES_ARRAY_SIZE - 1)
            break;
         
         // Add comma if not the last column or not the last timeframe
         json += ",";
      }
      
   }   
   
   // End the prefix
   json+= "}";

   // Convert JSON string to char array for WebRequest
   StringToCharArray(json, post_data);

   // Make the request
   int res = WebRequest("POST", PREDICTION_SERVICE_URL+"/predict_minute", headers, timeout, post_data, result, headers);


   if (res == -1)    
   {
      int error_code = GetLastError();
         
      // Limit error reporting to once per minute
      if(TimeCurrent() - last_error_report > 60)
      {
         if(LOG_ACTIVITY)
         {
            Print("MinutePush WebRequest failed. Error: ", error_code);
            last_error_report = TimeCurrent();
         }  
      }
      
      return false;
      
    }
     
    return true; 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool SendOrderblockData()
{
   char result[];
   char post_data[];
   string headers = "Content-Type: application/json";
   int timeout = 5000;

   datetime curtime = TimeCurrent();
   
   MqlDateTime t;
   TimeToStruct(curtime, t);
   
   string formatted_time = StringFormat("%02d-%02d-%04d %02d:%02d",
                                   t.day, t.mon, t.year,
                                   t.hour, t.min);

   string json = "{";

   json += "\"symbol\":\"" + current_symbol + "\",";
   json += "\"datetime\":\"" + formatted_time + "\",";

   // Build Support array
   json += "\"resistance\":[";
   for(int i = 0; i < orderblock.GetSupplyCount(); i++)
   {
      OrderBlock *ob = orderblock.GetSupplyAt(i);
   
      // format the time
      MqlDateTime time;
      TimeToStruct(ob.time, time);
      string format_time = StringFormat("%02d-%02d-%04d %02d:%02d",
                                   t.day, t.mon, t.year,
                                   t.hour, t.min);
      
      json += "{";
      json += "\"upper\":" + DoubleToString(ob.upper, _Digits) + ",";
      json += "\"lower\":" + DoubleToString(ob.lower, _Digits) + ",";
      json += "\"violated\":" + IntegerToString(ob.violated) + ",";
      json += "\"withheld\":" + IntegerToString(ob.withheld);
      json += "}";
      if(i != orderblock.GetSupplyCount()-1)
         json += ",";
   }
   json += "],";

   // Build Resistance array
   json += "\"support\":[";
   for(int i = 0; i < orderblock.GetDemandCount(); i++)
   {
      OrderBlock *ob = orderblock.GetDemandAt(i);
   
      // format the time
      MqlDateTime time;
      TimeToStruct(ob.time, time);
      string format_time = StringFormat("%02d-%02d-%04d %02d:%02d",
                                   t.day, t.mon, t.year,
                                   t.hour, t.min);
      
      json += "{";
      json += "\"upper\":" + DoubleToString(ob.upper, _Digits) + ",";
      json += "\"lower\":" + DoubleToString(ob.lower, _Digits) + ",";
      json += "\"violated\":" + IntegerToString(ob.violated) + ",";
      json += "\"withheld\":" + IntegerToString(ob.withheld);
      json += "}";
      if(i != orderblock.GetDemandCount()-1)
         json += ",";
   }
   json += "]";

   json += "}";

   StringToCharArray(json, post_data);

   // Replace with your actual URL
   string url = ORDERBLOCK_SERVICE_URL+"/reversal_zone_raw";
   int res = WebRequest("POST", url, headers, timeout, post_data, result, headers);

   if(res == -1)
   {
      int error_code = GetLastError();
      Print("WebRequest failed. Error: ", error_code);
      return false;
   }
   
   return true;
 
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to get column values dynamically
void GetColumnValues(int TimeFrameIndex, string &values[])
{
   // Create format string with _Digits precision for 9 variables
   string digits_str = IntegerToString(_Digits);
   string format_str = "\"%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f;%" + digits_str + "f\"";

   string combined_string = "";

   if(Indicators.GetFibonacci().IsUp(TimeFrameIndex, 0))
      combined_string = StringFormat(format_str, Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[1]*100)), 
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[2]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[3]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[4]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[5]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[6]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[7]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[8]*100)),
      Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[9]*100)));
   else
       combined_string = StringFormat(format_str, Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[1]*100)), 
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[2]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[3]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[4]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[5]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[6]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[7]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[8]*100)),
      Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, 0, (FIBONACCI_LEVELS[9]*100)));
   

   ArrayResize(values, ArraySize(feature_columns));
   
   // Assign values by calling respective class functions
   values[0] = "\"" + GetTrend(AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(TimeFrameIndex, 0)) + "\"";
   values[1] = "\"" + AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(TimeFrameIndex, 0) + "\"";
   values[2] = DoubleToString(AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(TimeFrameIndex, 0), 2);
   values[3] = DoubleToString(AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(TimeFrameIndex), 0), _Digits);
   values[4] = DoubleToString(Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(TimeFrameIndex, 0), _Digits);
   values[5] = DoubleToString(Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(TimeFrameIndex, 0), _Digits);
   values[6] = DoubleToString(AdvIndicators.GetBullBear().GetReactiveBullPercent(TimeFrameIndex, 0), 2);
   values[7] = "\"" + GetIndicatorPositionString(AdvIndicators.GetBullBear().GetReactiveBullPosition(TimeFrameIndex, 0)) + "\"";
   values[8] = DoubleToString(AdvIndicators.GetBullBear().GetReactiveBearPercent(TimeFrameIndex, 0), 2);
   values[9] = "\"" + GetIndicatorPositionString(AdvIndicators.GetBullBear().GetReactiveBearPosition(TimeFrameIndex, 0)) + "\"";
   values[10] = DoubleToString(AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, 0), 2);
   values[11] = "\"" + GetIndicatorPositionString(AdvIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, 0)) + "\"";
   values[12] = DoubleToString(AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, 0), 2);
   values[13] = "\"" + GetIndicatorPositionString(AdvIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, 0)) + "\"";
   values[14] = DoubleToString(AdvIndicators.GetVolatility().GetVolatilityPercent(TimeFrameIndex, 0), 2);
   values[15] = "\"" + GetIndicatorPositionString(AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, 0)) + "\"";
   values[16] = DoubleToString(AdvIndicators.GetMarketMomentum().GetBuyPercent(TimeFrameIndex, 0), 2);
   values[17] = DoubleToString(AdvIndicators.GetMarketMomentum().GetBuyMean(TimeFrameIndex, 0), 2);
   values[18] = DoubleToString(AdvIndicators.GetMarketMomentum().GetSellPercent(TimeFrameIndex, 0), 2);
   values[19] = DoubleToString(AdvIndicators.GetMarketMomentum().GetSellMean(TimeFrameIndex, 0), 2);
   values[20] = DoubleToString(AdvIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, 0), 2);
   values[21] = DoubleToString(AdvIndicators.GetTrendIndexes().GetBuyIndexesMean(TimeFrameIndex, 0), 2);
   values[22] = DoubleToString(AdvIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, 0), 2);
   values[23] = DoubleToString(AdvIndicators.GetTrendIndexes().GetSellIndexesMean(TimeFrameIndex, 0), 2);
   values[24] = DoubleToString(CSAnalysis.GetCummBodyPercent(TimeFrameIndex, 0), 2);
   values[25] = "\"" + GetIndicatorPositionString(CSAnalysis.GetCummBodyPosition(TimeFrameIndex, 0)) + "\"";
   values[26] = DoubleToString(CSAnalysis.GetCummTopWickPercent(TimeFrameIndex, 0), 2);
   values[27] = "\"" + GetIndicatorPositionString(CSAnalysis.GetCummTopPosition(TimeFrameIndex, 0)) + "\"";
   values[28] = DoubleToString(CSAnalysis.GetCummBotWickPercent(TimeFrameIndex, 0), 2);
   values[29] = "\"" + GetIndicatorPositionString(CSAnalysis.GetCummBotPosition(TimeFrameIndex, 0)) + "\"";
   values[30] = "\"" + GetIndicatorPositionString(AdvIndicators.GetIndicatorsTrigger().GetBuyPosition(TimeFrameIndex, 0)) + "\"";
   values[31] = "\"" + GetIndicatorPositionString(AdvIndicators.GetIndicatorsTrigger().GetSellPosition(TimeFrameIndex, 0)) + "\"";
   values[32] = "\"" + GetIndicatorPositionString(AdvIndicators.GetLineTrigger().GetBuyPosition(TimeFrameIndex, 0)) + "\"";
   values[33] = "\"" + GetIndicatorPositionString(AdvIndicators.GetLineTrigger().GetSellPosition(TimeFrameIndex, 0)) + "\"";
   values[34] = DoubleToString(reversalprob.GetBuyReversalProbability(TimeFrameIndex, 0), 2);
   values[35] = DoubleToString(reversalprob.GetSellReversalProbability(TimeFrameIndex, 0), 2);
   values[36] = "\"" + GetTrend(Indicators.GetIchimoku().GetChikouPosition(TimeFrameIndex, 0)) + "\"";
   values[37] = "\"" + GetEnumMarketConditionString(marketcondition.GetEnumMarketCondition(TimeFrameIndex, 0)) + "\"";
   values[38] = "\"" + GetEnumQuadrantString(Indicators.GetBands().GetBandBias(TimeFrameIndex, 0)) + "\"";
   values[39] = "\"" + GetEnumQuadrantString(Indicators.GetIchimoku().GetTenKanQuadrant(TimeFrameIndex, 0)) + "\"";
   values[40] = "\"" + GetEnumQuadrantString(Indicators.GetIchimoku().GetKijunQuadrant(TimeFrameIndex, 0)) + "\"";
   values[41] = combined_string;
   
   
   //+ "\"";
  
}


//+------------------------------------------------------------------+
