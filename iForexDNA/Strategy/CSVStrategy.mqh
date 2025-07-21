//+------------------------------------------------------------------+
//|                                                  CSVStrategy.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property tester_file   "Entry-2016.csv"

#include "..\ExternVariables.mqh"
#include "..\hash.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"
#include "..\AccountManager.mqh"
#include "..\IndicatorsHelper.mqh"
#include "..\AdvanceIndicator.mqh"
#include "..\MarketCondition.mqh"

#include <Trade\Trade.mqh>


// Structure to hold signal data
struct SignalData
{
    datetime signalTime;
    int predictionResult;        // 1 = BUY, -1 = SELL
    string reversalDirection;
    double entryZoneLower;
    double entryZoneUpper;
    string patternType;          // "SPOT" or "ZONE"
    bool executed;
    datetime expiryTime;
};

struct DivergenceType
{
   int m15;
   int h1;
   int h4;
   int d1;
};

struct Candlestick
{
   double open;
   double high;
   double low;
   double close;
};

struct MarketData
{
   double atr;
   double std_dev;
   double current_price;
   double current_band;
   double current_tenkan;
   double current_kijun;
};

struct FibonacciLevels
{
   double m15[9];
   double h1[9];
   double h4[9];
   double d1[9];
};

#import "takeprofit.dll"
   bool check_buy_takeprofit(double k_current, double d_current, double k_prev, double d_prev, double bid, double upper, string symbol, double order_open_price);
   bool check_sell_takeprofit(double k_current, double d_current, double k_prev, double d_prev, double ask, double lower, string symbol, double order_open_price);
#import

// Import the DLL functions
#import "order_management.dll"   
   // Function declarations
   double buy_order_management_wrapper(
      double order_open_price,
      double current_stop_loss,
      double breakeven_price,
      bool   is_current_candle,
      double &zigzag_array[],
      DivergenceType &divergence_type,
      double &fractal_resist[],
      double &fractal_support[],
      FibonacciLevels &fibonacci_levels,
      int band_quadrant,
      int tenkan_quadrant,
      int kijun_quadrant,
      Candlestick &current_candle,
      Candlestick &previous_candle,
      MarketData &market_data
   );
   // Function declarations
   double sell_order_management_wrapper(
      double order_open_price,
      double current_stop_loss,
      double breakeven_price,
      bool   is_current_candle,
      double &zigzag_array[],
      DivergenceType &divergence_type,
      double &fractal_resist[],
      double &fractal_support[],
      FibonacciLevels &fibonacci_levels,
      int band_quadrant,
      int tenkan_quadrant,
      int kijun_quadrant,
      Candlestick &current_candle,
      Candlestick &previous_candle,
      MarketData &market_data
   );
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class CSVStrategy
{
   private:
      AccountManager    *m_AccountManager;
      IndicatorsHelper  *m_Indicators;
      AdvanceIndicator  *m_AdvIndicators;  
      
      CTrade         m_CTrade;
      int            m_Handle;
      SignalData     signals[];
      
      void           RemoveHeader(int columns);
      bool           InitFileData();
      
      void           OpenOrderLogic();
      void           EnterPosition(int Direction, string Type="SPOT");
      
      double         BuyFractalRiskyStopLoss(Order *order, string& comment);
      double         BuyFractalProfitStopLoss(Order *order, string& comment);

      double         SellFractalRiskyStopLoss(Order *order, string& comment);
      double         SellFractalProfitStopLoss(Order *order, string& comment);
      
      double         BuyFibonacciStopLoss(int TimeFrameIndex, string& comment);
      double         SellFibonacciStopLoss(int TimeFrameIndex, string& comment);
   
    public:
                     CSVStrategy(IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators, AccountManager *pAccountManager);
                     ~CSVStrategy();
                     
      void           OnUpdate();
      void           BuyOrderManagement(Order *order);
      void           SellOrderManagement(Order *order);
      
      void           BuyPartialTakeProfit(Order *order);
      void           SellPartialTakeProfit(Order *order);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CSVStrategy::CSVStrategy(IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvanceIndicators, AccountManager *pAccountManager)
{
   // Initialize CTrade 
   if(pAccountManager == NULL)
   {
      LogInfo(__FUNCTION__+"- Failed to initialize account manager. ");
      return;
   }
   else
      m_AccountManager = pAccountManager;
   
   // Initialize CTrade 
   if(pIndicators == NULL)
   {
      LogInfo(__FUNCTION__+"- Failed to initialize indicators. ");
      return;
   }
   else
      m_Indicators = pIndicators;
      
   // Initialize CTrade 
   if(pAdvanceIndicators == NULL)
   {
      LogInfo(__FUNCTION__+"- Failed to initialize advance indicator. ");
      return;
   }
   else
      m_AdvIndicators = pAdvanceIndicators;

   
   // Initialize file handler
   m_Handle = FileOpen("Entry-2016.csv", FILE_READ|FILE_CSV|FILE_ANSI, ',');
   
   if(m_Handle == INVALID_HANDLE)
   {
      LogInfo(__FUNCTION__+"- Failed to Initialize handlers.");
      return;
   }
   
   RemoveHeader(6);     // datetime, prediction_result, reversal_direction, entry_zone_lower, entry_zone_upper, pattern_type
   
   if(!InitFileData())
   {
      LogInfo(__FUNCTION__+"- Failed to save datas into dict.");
      return;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CSVStrategy::~CSVStrategy()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::OnUpdate()
{
   // Check for open orders
   OpenOrderLogic();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::OpenOrderLogic()
{
    datetime currentTime = TimeCurrent();
    double bidPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double askPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    
    // Look for signals to execute
    for(int i = 0; i < ArraySize(signals) ; i++)
    {
        if(signals[i].executed) continue; // Skip already executed signals
        if(currentTime > signals[i].expiryTime) continue;   // Skip expired signals
        
        bool shouldExecute = false;
        string executionReason = "";
        
        if(currentTime == signals[i].signalTime && signals[i].patternType == "SPOT")
        {
            // For SPOT patterns, execute when current time is within tolerance of signal time
            long timeDiff = MathAbs(currentTime - signals[i].signalTime);
            if(timeDiff <= TimeToleranceMinutes * 60)
            {
                shouldExecute = true;
                executionReason = "SPOT pattern time match";
            }
        }
        else if(signals[i].patternType == "ZONE")
        {
            // For ZONE patterns, execute when price is within the entry zone
            // and current time is after signal time
            if(currentTime >= signals[i].signalTime)
            {
                bool priceInZone = false;
                
                if(signals[i].predictionResult == BULL_TRIGGER) // BUY signal
                {
                    priceInZone = (askPrice > signals[i].entryZoneLower && askPrice <= signals[i].entryZoneUpper);
                }
                else if(signals[i].predictionResult == BEAR_TRIGGER) // SELL signal
                {
                    priceInZone = (bidPrice >= signals[i].entryZoneLower && bidPrice < signals[i].entryZoneUpper);
                }
                
                if(priceInZone)
                {
                    shouldExecute = true;
                    executionReason = "ZONE pattern price in range";
                }
            }
        }
        
        if(shouldExecute)
        {
            signals[i].executed = true; 
            EnterPosition(signals[i].predictionResult, signals[i].patternType);
        }
            
    }
    
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::RemoveHeader(int column)
{
   for(int i = 0; i < column; i++)
      FileReadString(m_Handle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CSVStrategy::InitFileData()
{
   int totalSignals=0;

    // Read and parse CSV data
    while(!FileIsEnding(m_Handle)) // Limit to 1000 signals
    {
        string signal_datetime = FileReadString(m_Handle);    // Parse datetime
        Print("DEBUG: Read datetime: '", signal_datetime, "'");
        
        string signal_prediction = FileReadString(m_Handle);    // parse prediction_result
        Print("DEBUG: Read signal_prediction: '", signal_prediction, "'");

        string signal_direction = FileReadString(m_Handle);    // parse reversal_direction
        Print("DEBUG: Read signal_direction: '", signal_direction, "'");
            
        string signal_lowerzone = FileReadString(m_Handle);    // parse entry_zone_lower
            
        string signal_upperzone = FileReadString(m_Handle);    // parse entry_zone_upper
            
        string signal_pattern = FileReadString(m_Handle);    // parse pattern_type
        
        // Parse signal data according to your format:
        // ,datetime,prediction_result,reversal_direction,entry_zone_lower,entry_zone_upper,pattern_type
        SignalData signal;
        signal.signalTime = StringToTime(signal_datetime);
        signal.predictionResult = (int)StringToInteger(signal_prediction);
        signal.reversalDirection = signal_direction;
        signal.entryZoneLower = StringToDouble(signal_lowerzone);
        signal.entryZoneUpper = StringToDouble(signal_upperzone);
        signal.patternType = signal_pattern;
        signal.executed = false;
        
        // Set expiry time for ZONE patterns
        if(signal.patternType == "ZONE")
        {
            signal.expiryTime = signal.signalTime + ZoneExpiryHours * 3600;
        }
        else
        {
            signal.expiryTime = signal.signalTime;
        }
        
        // Add signal to array
        ArrayResize(signals, totalSignals + 1);
        signals[totalSignals] = signal;
        totalSignals++;
        
        Print("Loaded signal ", totalSignals, ": ", 
                TimeToString(signal.signalTime), " ",
                signal.predictionResult == 1 ? "BUY" : "SELL", " ",
                signal.patternType, " ",
                "Zone: ", DoubleToString(signal.entryZoneLower, _Digits), "-", DoubleToString(signal.entryZoneUpper, _Digits));
    }
    
    FileClose(m_Handle);
    
    if(totalSignals == 0)
    {
        Print("No valid signals found in CSV file");
        return false;
    }
    
    return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::EnterPosition(int Direction, string Type="SPOT")
{
   double stoploss = 0;
   double atr = m_Indicators.GetATR().GetATRValue(2, 0);
   datetime curm5time = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M5, 0);
   double ask = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_BID);

   if(Direction == BULL_TRIGGER)
   {
      double zz_low = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(2, 0));
   
      // Skip entering for a 5 minute gaps
      if(m_AccountManager.GetTotalNumberOfOpenBuyOrders() > 0)
      {
         // Get latest buy order index
         Order *order = m_AccountManager.GetBuyOrderByIndex(m_AccountManager.GetTotalNumberOfOpenBuyOrders()-1);
         int barshift = iBarShift(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M5, order.GetOpenDateTime());
         datetime orderm5time = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M5, barshift);
         
         if(curm5time - orderm5time >= 60*5)
         {
            // calculate stop loss
            stoploss = NormalizeDouble(zz_low - 0.5 * atr, _Digits);
            if(ask-stoploss < 0.00150)
               stoploss = NormalizeDouble(ask-0.0015, _Digits);
            else if(ask-stoploss > 0.0035)
               stoploss = NormalizeDouble(ask-0.0035, _Digits);
               
            double lots = m_AccountManager.GetBuyLots(ask, stoploss, 0.2);
         
            if(m_AccountManager.BuyMarket(m_AccountManager.GetChartCurrencySymbol(), lots, stoploss))
               LogInfo(__FUNCTION__ + "- Successfully Entered " + Type + "!");
            else
               LogInfo(__FUNCTION__+" - Failed to enter " + Type + "!");
         }
      }
      
      else
      {
            // calculate stop loss
            stoploss = NormalizeDouble(zz_low - 0.5 * atr, _Digits);
            if(ask-stoploss < 0.00150)
               stoploss = NormalizeDouble(ask-0.0015, _Digits);
            else if(ask-stoploss > 0.0035)
               stoploss = NormalizeDouble(ask-0.0035, _Digits);
               
            double lots = m_AccountManager.GetBuyLots(ask, stoploss, 0.2);
         
            if(m_AccountManager.BuyMarket(m_AccountManager.GetChartCurrencySymbol(), lots, stoploss))
               LogInfo(__FUNCTION__ + "- Successfully Entered " + Type + "!");
            else
               LogInfo(__FUNCTION__+" - Failed to enter " + Type + "!");
      }
   }
   
   else if(Direction == BEAR_TRIGGER)
   {
      double zz_high = m_Indicators.GetZigZag().GetZigZagHighPrice(2, 0);
   
      // Skip entering for a 5 minute gaps
      if(m_AccountManager.GetTotalNumberOfOpenSellOrders() > 0)
      {
         // Get latest buy order index
         Order *order = m_AccountManager.GetSellOrderByIndex(m_AccountManager.GetTotalNumberOfOpenSellOrders()-1);
         int barshift = iBarShift(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M5, order.GetOpenDateTime());
         datetime orderm5time = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M5, barshift);
         
         if(curm5time - orderm5time >= 60*5)
         {
            // calculate stop loss
            stoploss = NormalizeDouble(zz_high+0.5*atr, _Digits);
            if(stoploss-bid < 0.00150)
               stoploss = NormalizeDouble(bid+0.0015, _Digits);
            else if(stoploss-bid > 0.0035)
               stoploss = NormalizeDouble(bid+0.0035, _Digits);
            
            double lots = m_AccountManager.GetSellLots(bid, stoploss, 0.2);
         
            if(m_AccountManager.SellMarket(m_AccountManager.GetChartCurrencySymbol(), lots, stoploss))
            {
               LogInfo(__FUNCTION__ + "- Successfully Entered " + Type + "!");
            }
               
            else
               LogInfo(__FUNCTION__+" - Failed to enter " + Type + "!");
         }
      }
      
      else
      {
            // calculate stop loss
            stoploss = NormalizeDouble(zz_high+0.5*atr, _Digits);
            if(stoploss-bid < 0.00150)
               stoploss = NormalizeDouble(bid+0.0015, _Digits);
            else if(stoploss-bid > 0.0035)
               stoploss = NormalizeDouble(bid+0.0035, _Digits);
            
            double lots = m_AccountManager.GetSellLots(bid, stoploss, 0.2);
         
            if(m_AccountManager.SellMarket(m_AccountManager.GetChartCurrencySymbol(), lots, stoploss))
            {
               LogInfo(__FUNCTION__ + "- Successfully Entered " + Type + "!");
            }
               
            else
               LogInfo(__FUNCTION__+" - Failed to enter " + Type + "!");
      }
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::BuyOrderManagement(Order *order)
{
   // Initialize 
   double zigzag[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double fractal_resist[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double fractal_support[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int    divergences[4];
   DivergenceType divergence;
   
   double atr = m_Indicators.GetATR().GetATRValue(2, 0);
   double stddev = m_Indicators.GetBands().GetBandStdDev(2, 1, 0);
   double bid = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_BID);
   double current_band = m_Indicators.GetBands().GetMain(2, 0);
   double current_tenkan = m_Indicators.GetIchimoku().GetTenkanSen(2, 0);
   double current_kijun = m_Indicators.GetIchimoku().GetKijunSen(2, 0);

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      zigzag[i] = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(i), 0);
      
      if(i >= 2)
      {  
         divergences[i-2] = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(i, 0);
         fractal_resist[i-2] = m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(i, 0);
         fractal_support[i-2] = m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(i, 0);
      }
      
   }

   FibonacciLevels fib;
   for(int i =1 ; i < FIBONACCI_LEVELS_SIZE; i++)
   {
      // M15
      if(m_Indicators.GetFibonacci().IsUp(2, 0))
         fib.m15[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(2, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.m15[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(2, 0, FIBONACCI_LEVELS[i]*100);

      // H1
      if(m_Indicators.GetFibonacci().IsUp(3, 0))
         fib.h1[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(3, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.h1[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(3, 0, FIBONACCI_LEVELS[i]*100);

      // H4
      if(m_Indicators.GetFibonacci().IsUp(4, 0))
         fib.h4[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(4, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.h4[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(4, 0, FIBONACCI_LEVELS[i]*100);
      
      // D1
      if(m_Indicators.GetFibonacci().IsUp(5, 0))
         fib.d1[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(5, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.d1[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(5, 0, FIBONACCI_LEVELS[i]*100);
   }
   
   int band_quad = m_Indicators.GetBands().GetBandBias(2, 0);
   int tenkan_quad = m_Indicators.GetIchimoku().GetTenKanQuadrant(2, 0);
   int kijun_quad = m_Indicators.GetIchimoku().GetKijunQuadrant(2, 0);
   
   Candlestick curr_candle = {CandleSticksBuffer[2][0].GetOpen(), CandleSticksBuffer[2][0].GetHigh(), CandleSticksBuffer[2][0].GetLow(), CandleSticksBuffer[2][0].GetClose()};
   Candlestick prev_candle = {CandleSticksBuffer[2][1].GetOpen(), CandleSticksBuffer[2][1].GetHigh(), CandleSticksBuffer[2][1].GetLow(), CandleSticksBuffer[2][1].GetClose()};

   // get is current candle
   bool is_current_candle = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0) == order.GetOpenOrderDateTime();
   
   MarketData mktdata = {atr, stddev, bid, current_band, current_tenkan, current_kijun};
   
   double new_stoploss = buy_order_management_wrapper(order.GetOpenPrice(), 
   order.GetStopLoss(), 
   order.GetBreakEvenPrice(), 
   is_current_candle, 
   zigzag, 
   divergence, 
   fractal_resist, 
   fractal_support, 
   fib, 
   band_quad,
   tenkan_quad,
   kijun_quad, 
   curr_candle,
   prev_candle,
   mktdata
   );
  
 
   // Check for stop loss validation
   if(new_stoploss > order.GetStopLoss() && new_stoploss < bid)
   {
      m_AccountManager.ModifyAllStopLoss(m_AccountManager.GetChartCurrencySymbol(), new_stoploss, ORDER_TYPE_BUY);   
   }
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::SellOrderManagement(Order *order)
{
   // Initialize 
   double zigzag[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double fractal_resist[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double fractal_support[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int    divergences[4];
   DivergenceType divergence;
   
   double atr = m_Indicators.GetATR().GetATRValue(2, 0);
   double stddev = m_Indicators.GetBands().GetBandStdDev(2, 1, 0);
   double ask = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_ASK);
   double current_band = m_Indicators.GetBands().GetMain(2, 0);
   double current_tenkan = m_Indicators.GetIchimoku().GetTenkanSen(2, 0);
   double current_kijun = m_Indicators.GetIchimoku().GetKijunSen(2, 0);

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      zigzag[i] = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(i), 0);
      
      if(i >= 2)
      {  
         divergences[i-2] = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(i, 0);
         fractal_resist[i-2] = m_Indicators.GetFractal().GetFractalResistanceBarShiftLowerPrice(i, 0);
         fractal_support[i-2] = m_Indicators.GetFractal().GetFractalSupportBarShiftUpperPrice(i, 0);
      }
      
   }

   FibonacciLevels fib;
   for(int i =1 ; i < FIBONACCI_LEVELS_SIZE; i++)
   {
      // M15
      if(m_Indicators.GetFibonacci().IsUp(2, 0))
         fib.m15[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(2, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.m15[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(2, 0, FIBONACCI_LEVELS[i]*100);

      // H1
      if(m_Indicators.GetFibonacci().IsUp(3, 0))
         fib.h1[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(3, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.h1[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(3, 0, FIBONACCI_LEVELS[i]*100);

      // H4
      if(m_Indicators.GetFibonacci().IsUp(4, 0))
         fib.h4[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(4, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.h4[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(4, 0, FIBONACCI_LEVELS[i]*100);
      
      // D1
      if(m_Indicators.GetFibonacci().IsUp(5, 0))
         fib.d1[i-1] = m_Indicators.GetFibonacci().GetUpFibonacci(5, 0, FIBONACCI_LEVELS[i]*100);
      else
         fib.d1[i-1] = m_Indicators.GetFibonacci().GetDownFibonacci(5, 0, FIBONACCI_LEVELS[i]*100);
   }
   
   int band_quad = m_Indicators.GetBands().GetBandBias(2, 0);
   int tenkan_quad = m_Indicators.GetIchimoku().GetTenKanQuadrant(2, 0);
   int kijun_quad = m_Indicators.GetIchimoku().GetKijunQuadrant(2, 0);
   
   Candlestick curr_candle = {CandleSticksBuffer[2][0].GetOpen(), CandleSticksBuffer[2][0].GetHigh(), CandleSticksBuffer[2][0].GetLow(), CandleSticksBuffer[2][0].GetClose()};
   Candlestick prev_candle = {CandleSticksBuffer[2][1].GetOpen(), CandleSticksBuffer[2][1].GetHigh(), CandleSticksBuffer[2][1].GetLow(), CandleSticksBuffer[2][1].GetClose()};

   // get is current candle
   bool is_current_candle = iTime(m_AccountManager.GetChartCurrencySymbol(), PERIOD_M15, 0) == order.GetOpenOrderDateTime();
   
   MarketData mktdata = {atr, stddev, ask, current_band, current_tenkan, current_kijun};
   
   double new_stoploss = sell_order_management_wrapper(order.GetOpenPrice(), 
   order.GetStopLoss(), 
   order.GetBreakEvenPrice(), 
   is_current_candle, 
   zigzag, 
   divergence, 
   fractal_resist, 
   fractal_support, 
   fib, 
   band_quad,
   tenkan_quad,
   kijun_quad, 
   curr_candle,
   prev_candle,
   mktdata
   );
 
   // Check for stop loss validation
   if(new_stoploss < order.GetStopLoss() && new_stoploss > ask)
      m_AccountManager.ModifyAllStopLoss(m_AccountManager.GetChartCurrencySymbol(), new_stoploss, ORDER_TYPE_SELL);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::BuyPartialTakeProfit(Order *order)
{
   double k_current = m_Indicators.GetSTO().GetMain(1, 0);
   double d_current = m_Indicators.GetSTO().GetSignal(1, 0);
   
   double k_prev = m_Indicators.GetSTO().GetMain(1, 1);
   double d_prev = m_Indicators.GetSTO().GetSignal(1, 1);
   
   double band_upper = m_Indicators.GetBands().GetUpper(1, 1, 0);
   double band_lower = m_Indicators.GetBands().GetLower(1, 1, 0);
   
   double bid = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_BID);
   
   bool update_tp = check_buy_takeprofit(k_current, d_current, k_prev, d_prev, bid, band_upper, m_AccountManager.GetChartCurrencySymbol(), order.GetOpenPrice());
   
   // Close Partial Profit
   if(!order.GetIsPartialClosed() && update_tp)
   {
      // close partial
      if(m_CTrade.PositionClosePartial(order.GetTicket(), MathCeil(order.GetLots()/2)))
      {
         LogInfo(__FUNCTION__+"- Partial close buy successful");
         order.SetIsPartialClosed(true);
         order.ModifyStopLoss(order.GetBreakEvenPrice(), "Set order to Breakeven.");
      }
      else
         LogInfo(__FUNCTION__+"- Partial close buy failed");
   }
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CSVStrategy::SellPartialTakeProfit(Order *order)
{
   double k_current = m_Indicators.GetSTO().GetMain(1, 0);
   double d_current = m_Indicators.GetSTO().GetSignal(1, 0);
   
   double k_prev = m_Indicators.GetSTO().GetMain(1, 1);
   double d_prev = m_Indicators.GetSTO().GetSignal(1, 1);
   
   double band_upper = m_Indicators.GetBands().GetUpper(1, 1, 0);
   double band_lower = m_Indicators.GetBands().GetLower(1, 1, 0);
   
   double ask = SymbolInfoDouble(m_AccountManager.GetChartCurrencySymbol(), SYMBOL_ASK);
   
   bool update_tp = check_sell_takeprofit(k_current, d_current, k_prev, d_prev, ask, band_lower, m_AccountManager.GetChartCurrencySymbol(), order.GetOpenPrice());
   
   // Close Partial Profit
   if(!order.GetIsPartialClosed() && update_tp)
   {
      // close partial
      if(m_CTrade.PositionClosePartial(order.GetTicket(), MathCeil(order.GetLots()/2)))
      {
         LogInfo(__FUNCTION__+"- Partial close sell successful");
         order.SetIsPartialClosed(true);
         order.ModifyStopLoss(order.GetBreakEvenPrice(), "Set order to Breakeven.");
      }
      else
         LogInfo(__FUNCTION__+"- Partial close sell failed");
   }
     
}

//+------------------------------------------------------------------+






