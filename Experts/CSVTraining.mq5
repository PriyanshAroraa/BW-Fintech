//+------------------------------------------------------------------+
//|                                                  CSVTraining.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include    "..\iForexDNA\ExternVariables.mqh"
#include    "..\iForexDNA\hash.mqh"
#include    "..\iForexDNA\MiscFunc.mqh"
#include    "..\iForexDNA\Enums.mqh"
#include    "..\iForexDNA\CandleStick\CandleStick.mqh"
#include    "..\iForexDNA\CandleStick\CandleStickArray.mqh"

#include    "..\iForexDNA\IndicatorsHelper.mqh"
#include    "..\iForexDNA\AdvanceIndicator.mqh"
#include    "..\iForexDNA\ReversalProbability.mqh"
#include    "..\iForexDNA\MarketCondition.mqh"

#include <..\Include\MarketopenHours.mqh>
#include <..\Include\Generic\HashMap.mqh>

CandleStickArray     CSAnalysis;
IndicatorsHelper     Indicators;
AdvanceIndicator     AdvIndicators(&Indicators);
ReversalProbability  reversalprob(&CSAnalysis, &Indicators, &AdvIndicators);
MarketCondition      marketcondition(&CSAnalysis, &Indicators, &AdvIndicators);

string current_symbol = Symbol();

class datas
{
   private:
      int      Direction;
      double   Price;
      
   public:
      datas(double price, int direction)
      {
         this.Direction = direction;
         this.Price = price;
      };  
      
      int    GetDirection(){return Direction;};
      double GetPrice(){return Price;};
};


CHashMap<string, datas*> M15DataMap;     
CHashMap<string, datas*> H1DataMap; 
CHashMap<string, datas*> H4DataMap; 
CHashMap<string, datas*> D1DataMap; 


//--- Indicators Handlers
int AdvHandler = INVALID_HANDLE;

bool  isFoundM15Zigzag = false;
datetime isFoundM15Datetime = 0;
int   m15counter = 0;

bool  isFoundH1Zigzag = false;
datetime isFoundH1Datetime = 0;
int   h1counter = 0;

bool  isFoundH4Zigzag = false;
datetime isFoundH4Datetime = 0;
int   h4counter = 0;

bool  isFoundD1Zigzag = false;
datetime isFoundD1Datetime = 0;
int   d1counter = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(60);

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
   
   
   // Read the CSV files
   LoadCSVToHashMap(M15DataMap, "M15-EURUSD-ZZ.csv");
   LoadCSVToHashMap(H1DataMap, "H1-EURUSD-ZZ.csv");
   LoadCSVToHashMap(H4DataMap, "H4-EURUSD-ZZ.csv");
   LoadCSVToHashMap(D1DataMap, "D1-EURUSD-ZZ.csv");

   string filename = current_symbol + "-"+"ADV.csv";
   AdvHandler = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV);
   
   WriteHeader();
   

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   EventKillTimer();
   FileClose(AdvHandler);  
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if(MarketOpenHours(current_symbol))
   {
      for(int i = 0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      {
         ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
         bool isnewbar = CheckIsNewBar(timeFrameENUM);
         
         CSAnalysis.OnUpdate(i, isnewbar);
         Indicators.OnUpdate(i, isnewbar);
         AdvIndicators.OnUpdate(i, isnewbar);
         reversalprob.OnUpdate(i, isnewbar);
         marketcondition.OnUpdate(i, isnewbar);
      }
      
      WriteAdvanceIndicators();
   }
}
  
//+------------------------------------------------------------------+
//| Write header row to CSV file                                     |
//+------------------------------------------------------------------+
void WriteHeader()
{
   // Create a string to hold the entire header row
   string header = "Datetime"; // First column

   header+=StringFormat(",%s", "Open");
   header+=StringFormat(",%s", "High");
   header+=StringFormat(",%s", "Low");
   header+=StringFormat(",%s", "Close");

   for (int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      string tf = GetTimeFrameString(i);

      // Append each column name to the header string with commas
      header += StringFormat(",%s%s", tf, "DivergenceType");
      header += StringFormat(",%s%s", tf, "DivergenceCode");
      header += StringFormat(",%s%s", tf, "DivergencePercent");
      
      header += StringFormat(",%s%s", tf, "ZigzagPoint");
      
      header += StringFormat(",%s%s", tf, "Resistance");
      header += StringFormat(",%s%s", tf, "Support");
      
      header += StringFormat(",%s%s", tf, "BullPercent");
      header += StringFormat(",%s%s", tf, "BullPosition");
      header += StringFormat(",%s%s", tf, "BearPercent");
      header += StringFormat(",%s%s", tf, "BearPosition");
      
      header += StringFormat(",%s%s", tf, "OverboughtPercent");
      header += StringFormat(",%s%s", tf, "OverboughtPosition");
      header += StringFormat(",%s%s", tf, "OversoldPercent");
      header += StringFormat(",%s%s", tf, "OversoldPosition");
      
      header += StringFormat(",%s%s", tf, "VolatilityPercent");
      header += StringFormat(",%s%s", tf, "VolatilityPosition");
      
      header += StringFormat(",%s%s", tf, "BuyMomentumPercent");
      header += StringFormat(",%s%s", tf, "BuyMomentumMean");
      header += StringFormat(",%s%s", tf, "SellMomentumPercent");
      header += StringFormat(",%s%s", tf, "SellMomentumMean");
      
      header += StringFormat(",%s%s", tf, "BuyTrendPercent");
      header += StringFormat(",%s%s", tf, "BuyTrendMean");
      header += StringFormat(",%s%s", tf, "SellTrendPercent");
      header += StringFormat(",%s%s", tf, "SellTrendMean");

      header += StringFormat(",%s%s", tf, "CSBodyPercent");
      header += StringFormat(",%s%s", tf, "CSBodyPosition");
      header += StringFormat(",%s%s", tf, "CSTopPercent");
      header += StringFormat(",%s%s", tf, "CSTopPosition");
      header += StringFormat(",%s%s", tf, "CSBotPercent");
      header += StringFormat(",%s%s", tf, "CSBotPosition");  

      header += StringFormat(",%s%s", tf, "BuyIndicatorTriggerPosition");
      header += StringFormat(",%s%s", tf, "SellIndicatorTriggerPosition");

      header += StringFormat(",%s%s", tf, "BuyLineTriggerPosition");
      header += StringFormat(",%s%s", tf, "SellLineTriggerPosition");

      header += StringFormat(",%s%s", tf, "BuyReversalProbability");
      header += StringFormat(",%s%s", tf, "SellReversalProbability");
      
      header += StringFormat(",%s%s", tf, "ChikouPosition");
      
      header += StringFormat(",%s%s", tf, "BandQuadrant");
      header += StringFormat(",%s%s", tf, "TenkanQuadrant");
      header += StringFormat(",%s%s", tf, "KijunQuadrant");
      
      header += StringFormat(",%s%s", tf, "FibonacciLevel");

   }
  
   // ZigZag Existance
   header += StringFormat(",%s", "M15Zigzag");
   header += StringFormat(",%s", "H1Zigzag");  
   header += StringFormat(",%s", "H4Zigzag");
   header += StringFormat(",%s", "D1Zigzag");  

   // Write the entire header as a single string
   FileWriteString(AdvHandler, header + "\n");
   FileFlush(AdvHandler);
}  

//+------------------------------------------------------------------+
//| Write indicator values to CSV file                               |
//+------------------------------------------------------------------+
void WriteAdvanceIndicators()
{
   datetime dt = TimeCurrent();
   datetime startTime = iTime(current_symbol, PERIOD_M1, 0);
   string timeStamp = TimeToString(startTime, TIME_DATE|TIME_MINUTES);
   
   datetime m15time = iTime(current_symbol, PERIOD_M15, 0);
   string m15timestamp = TimeToString(m15time, TIME_DATE|TIME_MINUTES);

   datetime h1time = iTime(current_symbol, PERIOD_H1, 0);
   string h1timestamp = TimeToString(h1time, TIME_DATE|TIME_MINUTES);

   datetime h4time = iTime(current_symbol, PERIOD_H4, 0);
   string h4timestamp = TimeToString(h4time, TIME_DATE|TIME_MINUTES);

   datetime d1time = iTime(current_symbol, PERIOD_D1, 0);
   string d1timestamp = TimeToString(d1time, TIME_DATE|TIME_MINUTES);

   // Start with the timestamp
   string line = timeStamp;

   double open = iOpen(current_symbol, PERIOD_M15, 0);
   double high = iHigh(current_symbol, PERIOD_M15, 0);
   double low = iLow(current_symbol, PERIOD_M15, 0);
   double close = iClose(current_symbol, PERIOD_M15, 0);

   line += StringFormat(",%s", DoubleToString(open, _Digits));
   line += StringFormat(",%s", DoubleToString(high, _Digits));
   line += StringFormat(",%s", DoubleToString(low, _Digits));
   line += StringFormat(",%s", DoubleToString(close, _Digits));

   // Add data for each timeframe
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      // Add all values for this timeframe to the string with comma separators
      line += StringFormat(",%s", GetTrend(AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(i, 0)));
      line += StringFormat(",%s", AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(i, 0));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(i, 0), 2));
      
      // ZigZag
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(timeFrameENUM, 0), _Digits));

      // Fractals
      line += StringFormat(",%s", DoubleToString(Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(i, 0), _Digits));
      line += StringFormat(",%s", DoubleToString(Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(i, 0), _Digits));

      // Bull Bear Index
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetBullBear().GetReactiveBullPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetBullBear().GetReactiveBullPosition(i, 0)));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetBullBear().GetReactiveBearPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetBullBear().GetReactiveBearPosition(i, 0)));
      
      // OBOS
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetOBOS().GetOBPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetOBOS().GetOBPosition(i, 0)));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetOBOS().GetOSPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetOBOS().GetOSPosition(i, 0)));
      
      // Volatility
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetVolatility().GetVolatilityPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetVolatility().GetVolatilityPosition(i, 0)));
      
      // market momentum
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetMarketMomentum().GetBuyPercent(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetMarketMomentum().GetBuyMean(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetMarketMomentum().GetSellPercent(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetMarketMomentum().GetSellMean(i, 0), 2));


      // market trend
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetTrendIndexes().GetBuyTrendIndexes(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetTrendIndexes().GetBuyIndexesMean(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetTrendIndexes().GetSellTrendIndexes(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(AdvIndicators.GetTrendIndexes().GetSellIndexesMean(i, 0), 2));  

      // CS Price Action
      line += StringFormat(",%s", DoubleToString(CSAnalysis.GetCummBodyPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(CSAnalysis.GetCummBodyPosition(i, 0)));

      line += StringFormat(",%s", DoubleToString(CSAnalysis.GetCummTopWickPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(CSAnalysis.GetCummTopPosition(i, 0)));

      line += StringFormat(",%s", DoubleToString(CSAnalysis.GetCummBotWickPercent(i, 0), 2));
      line += StringFormat(",%s", GetIndicatorPositionString(CSAnalysis.GetCummBotPosition(i, 0)));

      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetIndicatorsTrigger().GetBuyPosition(i, 0)));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetIndicatorsTrigger().GetSellPosition(i, 0)));

      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetLineTrigger().GetBuyPosition(i, 0)));
      line += StringFormat(",%s", GetIndicatorPositionString(AdvIndicators.GetLineTrigger().GetSellPosition(i, 0)));

      line += StringFormat(",%s", DoubleToString(reversalprob.GetBuyReversalProbability(i, 0), 2));
      line += StringFormat(",%s", DoubleToString(reversalprob.GetSellReversalProbability(i, 0), 2));
      
      line += StringFormat(",%s", GetTrend(Indicators.GetIchimoku().GetChikouPosition(i, 0)));

      line += StringFormat(",%s", GetEnumQuadrantString(Indicators.GetBands().GetBandBias(i, 0)));
      line += StringFormat(",%s", GetEnumQuadrantString(Indicators.GetIchimoku().GetTenKanQuadrant(i, 0)));
      line += StringFormat(",%s", GetEnumQuadrantString(Indicators.GetIchimoku().GetKijunQuadrant(i, 0)));
      
      
      if(Indicators.GetFibonacci().IsUp(i, 0))
         line += StringFormat(",\"%s;%s;%s;%s;%s;%s;%s;%s;%s\"", 
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[1]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[2]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[3]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[4]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[5]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[6]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[7]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[8]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetUpFibonacci(i, 0, (FIBONACCI_LEVELS[9]*100)), _Digits));
      
      else
         line += StringFormat(",\"%s;%s;%s;%s;%s;%s;%s;%s;%s\"", 
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[1]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[2]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[3]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[4]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[5]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[6]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[7]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[8]*100)), _Digits),
                       DoubleToString(Indicators.GetFibonacci().GetDownFibonacci(i, 0, (FIBONACCI_LEVELS[9]*100)), _Digits));
  
   }

   // Check if date already matches
   if(isFoundM15Datetime == m15time && !isFoundM15Zigzag)
   {
      datas *value = NULL;
      if(M15DataMap.TryGetValue(m15timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundM15Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundM15Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      }
      
      else
         line += StringFormat(",%s", "0");
   }
      
   // Find the timestamp
   else if(M15DataMap.ContainsKey(m15timestamp)
   && m15time > isFoundM15Datetime
   )
   {
      isFoundM15Datetime = m15time;
      isFoundM15Zigzag = false;
   
      datas *value = NULL;
      if(M15DataMap.TryGetValue(m15timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundM15Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundM15Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
         else
            line += StringFormat(",%s", "0");
      }
      else
         line += StringFormat(",%s", "0");
   }
   
   // Normal drawing
   else
      line += StringFormat(",%s", "0");

   // ----- H1 -------

   // Check if date already matches
   if(isFoundH1Datetime == h1time && !isFoundH1Zigzag)
   {
      datas *value = NULL;
      if(H1DataMap.TryGetValue(h1timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      }
      
      else
         line += StringFormat(",%s", "0");
   }
      
   // Find the timestamp
   else if(H1DataMap.ContainsKey(h1timestamp)
   && h1time > isFoundH1Datetime
   )
   {
      isFoundH1Datetime = h1time;
      isFoundH1Zigzag = false;
   
      datas *value = NULL;
      if(H1DataMap.TryGetValue(h1timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
         else
            line += StringFormat(",%s", "0");
      }
      else
         line += StringFormat(",%s", "0");
   }
   
   // Normal drawing
   else
      line += StringFormat(",%s", "0");

   // ----- H4 -------

   // Check if date already matches
   if(isFoundH4Datetime == h4time && !isFoundH4Zigzag)
   {
      datas *value = NULL;
      if(H4DataMap.TryGetValue(h4timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH4Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH4Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      }
      
      else
         line += StringFormat(",%s", "0");
   }
      
   // Find the timestamp
   else if(H4DataMap.ContainsKey(h4timestamp)
   && h4time > isFoundH4Datetime
   )
   {
      isFoundH4Datetime = h4time;
      isFoundH4Zigzag = false;
   
      datas *value = NULL;
      if(H4DataMap.TryGetValue(h4timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH4Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundH4Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
         else
            line += StringFormat(",%s", "0");
      }
      else
         line += StringFormat(",%s", "0");
   }
   
   // Normal drawing
   else
      line += StringFormat(",%s", "0");


   // ----- D1 -------

   // Check if date already matches
   if(isFoundD1Datetime == d1time && !isFoundD1Zigzag)
   {
      datas *value = NULL;
      if(D1DataMap.TryGetValue(d1timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundD1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundD1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      }
      
      else
         line += StringFormat(",%s", "0");
   }
      
   // Find the timestamp
   else if(D1DataMap.ContainsKey(d1timestamp)
   && d1time > isFoundD1Datetime
   )
   {
      isFoundD1Datetime = d1time;
      isFoundD1Zigzag = false;
   
      datas *value = NULL;
      if(D1DataMap.TryGetValue(d1timestamp, value) && value != NULL)
      {
         // High Direction
         if(value.GetDirection() == -1)
         {
            if(MathAbs(value.GetPrice()-high) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundD1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
      
         // Low Direction
         else if(value.GetDirection() == 1)
         {
            if(MathAbs(value.GetPrice()-low) < 1e-5)
            {
               line += StringFormat(",%s", (string)value.GetDirection());
               isFoundD1Zigzag = true;
            }
            else
               line += StringFormat(",%s", "0");
         }
         else
            line += StringFormat(",%s", "0");
      }
      else
         line += StringFormat(",%s", "0");
   }
   
   // Normal drawing
   else
      line += StringFormat(",%s", "0");

   // Write the entire line as a single string
   FileWriteString(AdvHandler, line + "\n");
   FileFlush(AdvHandler);
}

//+------------------------------------------------------------------+
//| Function to load CSV data into HashMap                           |
//+------------------------------------------------------------------+
bool LoadCSVToHashMap(CHashMap<string, datas*>& map, string filename)
{
   // Open the CSV file
   int file = FileOpen(filename, FILE_CSV|FILE_READ|FILE_ANSI, "\t");
   if(file == INVALID_HANDLE)
   {
      Print("Error opening file '", filename, "'. Error code: ", GetLastError());
      return false;
   }

   // Skip header lines if required
   SkipHeader(file);
   
   // Read data line by line
   int recordCount = 0;
   while(!FileIsEnding(file))
   {
      // Read timestamp (column 1) as key
      string timestamp = FileReadString(file);
      if(timestamp == "") break; // Break on empty row
      
      // Read column 2 and 3 values
      string value1 = FileReadString(file);
      string value2 = FileReadString(file);
      
      // Skip the rest of columns in current row
      while(!FileIsLineEnding(file) && !FileIsEnding(file))
      {
         FileReadString(file);
      }
      
      // Create new value object and store in HashMap
      int ans = 0;
      if(value2 == "High")
         ans = -1;
      else if(value2 == "Low")
         ans = 1;

      // Create datas
      map.Add(timestamp, new datas(StringToDouble(value1), ans));

      recordCount++;
   }
   
   // Close the file
   FileClose(file);
   
   Print("Successfully loaded ", recordCount, " records from '", filename, "'");
   return true;
}
//+------------------------------------------------------------------+
//| Function to clear and clean up the HashMap                       |
//+------------------------------------------------------------------+

void SkipHeader(int handler)
{
   FileReadString(handler);      // Datetime
   FileReadString(handler);      // Price
   FileReadString(handler);      // Direction
}

//+------------------------------------------------------------------+