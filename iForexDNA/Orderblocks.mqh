//+------------------------------------------------------------------+
//|                                                  Orderblocks.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Arrays\ArrayObj.mqh>

#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\MiscFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class OrderBlock : public CObject
{
public:
       datetime time;
       double upper;
       double lower;
       int    withheld;
       int    violated;
       
       
       OrderBlock() {} // Default constructor
       OrderBlock(datetime t, double u, double l) : time(t), upper(u), lower(l) {}
};

class OrderBlockFinder
{
   private:       
       CandleStickArray *m_CandleStick;
       IndicatorsHelper *m_Indicators;
   
       CArrayObj supplyBlocks;
       CArrayObj demandBlocks;
       CArrayObj finalSupply;
       CArrayObj finalDemand;
       
       datetime Time[];
       double Low[];
       double High[];
       double Open[];
       double Close[];
       
       int    FractalHandle;
       double UpFractal;
       double DownFractal;
      
       int     SupplyFileHandle;
       int     DemandFileHandle;
      
    
      bool           IsUpFractal(int i);
      bool           IsDownFractal(int i);
      
      bool           HasStrongMarubozu(int i, bool isBuy);
      bool           HasThreeCandles(int i, bool isBuy);
      bool           CheckBrokenSinceFractal(int i, bool isBuy, int& violated, int& withheld);
      void           LastRefinement();
      
      void           WriteIntoFile();
    
   public:
                     OrderBlockFinder(CandleStickArray *pCandleStick, IndicatorsHelper *pIndicators);
                     ~OrderBlockFinder();
                     
       void RunOncePerDay();   
    
       void FindOrderBlocks();
       void MatchFibonacci();
   
       int GetSupplyCount() const { return finalSupply.Total(); }
       int GetDemandCount() const { return finalDemand.Total(); }
   
       OrderBlock *GetSupplyAt(int index) const { return (OrderBlock*)finalSupply.At(index); }
       OrderBlock *GetDemandAt(int index) const { return (OrderBlock*)finalDemand.At(index); }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OrderBlockFinder::OrderBlockFinder(CandleStickArray *pCandleStick, IndicatorsHelper *pIndicators) { 
   if(pCandleStick == NULL)
   {
      LogInfo(__FUNCTION__+"- Failed to initialize candlestick. ");
      return;
   }
   else
      m_CandleStick = pCandleStick;

 
   if(pIndicators == NULL)
   {
      LogInfo(__FUNCTION__+"- Failed to initialize indicators. ");
      return;
   }
   else
      m_Indicators = pIndicators;

    
    ArraySetAsSeries(Low,true); 
    ArraySetAsSeries(High,true); 
    ArraySetAsSeries(Open,true); 
    ArraySetAsSeries(Close,true); 

/*
   SupplyFileHandle = FileOpen("supply.csv", FILE_WRITE|FILE_CSV, ',');
   DemandFileHandle = FileOpen("demand.csv", FILE_WRITE|FILE_CSV, ',');
   
   if(SupplyFileHandle == INVALID_HANDLE || DemandFileHandle == INVALID_HANDLE)
   {
      LogInfo(__FUNCTION__+" - Failed to write orderblock file.");
      return;
   }
   
   // Write to file
   FileWrite(SupplyFileHandle, "Time", "Upper", "Lower", "Violated", "Withheld");
   FileWrite(DemandFileHandle, "Time", "Upper", "Lower", "Violated", "Witheld");

*/
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OrderBlockFinder::~OrderBlockFinder()
{
    supplyBlocks.Clear();
    demandBlocks.Clear();
    finalSupply.Clear();
    finalDemand.Clear();
    
    //FileClose(SupplyFileHandle);
    //FileClose(DemandFileHandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrderBlockFinder::RunOncePerDay()
{
    // Update OHL
    string symbol = Symbol();
    CopyLow(symbol,PERIOD_H1,0,1000,Low);
    CopyHigh(symbol,PERIOD_H1,0,1000,High);
    CopyOpen(symbol,PERIOD_H1,0,1000,Open);
    CopyOpen(symbol,PERIOD_H1,0,1000,Close);
    CopyTime(symbol, PERIOD_H1, 0, 1000, Time);

    UpFractal = 0;
    DownFractal = 0;
    supplyBlocks.Clear();
    demandBlocks.Clear();
    finalSupply.Clear();
    finalDemand.Clear();

    FindOrderBlocks();
    MatchFibonacci();
    
    
    Print("Successfully Run Orderblock Search...");
    Print("Total Supply: " + IntegerToString(supplyBlocks.Total()));
    Print("Total Demand: " + IntegerToString(demandBlocks.Total()));
    
    Print("Total Final Supply: " + IntegerToString(finalSupply.Total()));
    Print("Total Final Demand: " + IntegerToString(finalDemand.Total()));  
    
    LastRefinement();
    
    Print("Refined Supply: " + IntegerToString(finalSupply.Total()));
    Print("Refined Demand: " + IntegerToString(finalDemand.Total()));      
    
    //WriteIntoFile();
    //FileClose(SupplyFileHandle);
    //FileClose(DemandFileHandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrderBlockFinder::FindOrderBlocks()
{
    for(int i = MathMin(997, Bars(_Symbol, PERIOD_H1)); i >= 2; i--)
    {
        bool isUpFractal = IsUpFractal(i);
        bool isDownFractal = IsDownFractal(i);
    
        if(!isUpFractal && !isDownFractal) continue;
        
        // Supply
        if(isUpFractal)
        {
            if(Low[i]-High[0] < _Point*250) continue;                                             // Less than 25 pips
            if(Low[i]-High[0] < m_CandleStick.GetAverageDailyPriceMovement() * 1.3) continue;     // Too huge volatility needed, less likely
            if(!HasStrongMarubozu(i, false) && !HasThreeCandles(i, false)) continue;                          // Check for strong reaction
        }
        
        
        // Demand
        else if(isDownFractal)
        {
            if(Low[0]-High[i] < _Point*250) continue;                             // Less than 25 pips
            if(Low[0]-High[i] < m_CandleStick.GetAverageDailyPriceMovement() * 1.3) continue;     // Too huge volatility needed, less likely
            if(!HasStrongMarubozu(i, true) && !HasThreeCandles(i, true)) continue;         // Check for strong reaction 
        }
        
        // Create orderblock 
        OrderBlock *ob = new OrderBlock();
        ob.time = Time[i];
        ob.upper = High[i];
        ob.lower = Low[i];

        if(isUpFractal && ob.lower > Close[0])
        {
            bool isAdd = CheckBrokenSinceFractal(i, false, ob.violated, ob.withheld);
            if(isAdd)
               supplyBlocks.Add(ob);
        }
        else if(isDownFractal)
        {
            bool isAdd = CheckBrokenSinceFractal(i, true, ob.violated, ob.withheld);
            if(isAdd)
               demandBlocks.Add(ob);
        }   
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrderBlockFinder::MatchFibonacci()
{
    bool isup = m_Indicators.GetFibonacci().IsUp(3, 0);

   // check on supply orderblock
   for(int i =0 ; i < supplyBlocks.Total(); i++)
   {
      for(int j = 0; j < FIBONACCI_LEVELS_SIZE; j++)
      {
         double level = isup ? m_Indicators.GetFibonacci().GetUpFibonacci(3, 0, FIBONACCI_LEVELS[j]*100) : m_Indicators.GetFibonacci().GetDownFibonacci(3, 0, FIBONACCI_LEVELS[j]*100);
         
         // Skip non-supply levels
         if(Close[0] > level)
            continue;
         
         OrderBlock *ob = (OrderBlock*)supplyBlocks.At(i);
         
         if(MathAbs(ob.upper-level) < _Point*150 || MathAbs(ob.lower-level) < _Point*150)
         {
            finalSupply.Add(ob);
            Print("SUPPLY @ Time: " + TimeToString(ob.time, TIME_DATE|TIME_MINUTES) + " | Upper: " + DoubleToString(ob.upper, _Digits) + " | Lower: " + DoubleToString(ob.lower, _Digits));
            break;
         }
      }
   }

   // check on demand orderblock
   for(int i =0 ; i < demandBlocks.Total(); i++)
   {
      for(int j = 0; j < FIBONACCI_LEVELS_SIZE; j++)
      {
         double level = isup ? m_Indicators.GetFibonacci().GetUpFibonacci(3, 0, FIBONACCI_LEVELS[j]*100) : m_Indicators.GetFibonacci().GetDownFibonacci(3, 0, FIBONACCI_LEVELS[j]*100);
         
         // Skip non-supply levels
         if(Close[0] < level)
            continue;
         
         OrderBlock *ob = (OrderBlock*)demandBlocks.At(i);
         
         if(MathAbs(ob.upper-level) < _Point*150 || MathAbs(ob.lower-level) < _Point*150)
         {
            finalDemand.Add(ob);
            Print("DEMAND @ Time: " + TimeToString(ob.time, TIME_DATE|TIME_MINUTES) + " | Upper: " + DoubleToString(ob.upper, _Digits) + " | Lower: " + DoubleToString(ob.lower, _Digits));
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrderBlockFinder::LastRefinement()
{
   double levels[3] = {0.236, 0.5, 0.702};
   int supplytotal = finalSupply.Total();
   int demandtotal = finalDemand.Total();
   
   int idx = ArraySize(levels)-1;
   
   double highPrice = m_Indicators.GetZigZag().GetZigZagHighPrice(3, 0);
   double lowPrice = MathAbs(m_Indicators.GetZigZag().GetZigZagLowPrice(3, 0));
   double half = highPrice-lowPrice;

   // Supply refinement
   while(supplytotal < 3)
   {
      if(idx < 0)
         break;
   
      double level = highPrice+(levels[idx]*half);
      
      if(MathAbs(level-Close[0]) < _Point*250){idx--;continue;};                                                     // Less than 25 pips 
      double adder = Symbol() == "XAUUSD" ? (XAUUSD_MINIMUM_STOP_LOSS_PIP/2)*_Point : (EURUSD_MINIMUM_STOP_LOSS_PIP/2)*_Point*10;
      
      // Create orderblock 
      OrderBlock *ob = new OrderBlock();
      ob.time = Time[0];
      ob.upper = level+adder;
      ob.lower = level-adder;
      
      finalSupply.Add(ob);
    
      idx--;
      supplytotal++;
   }
   
   idx = ArraySize(levels)-1;
   
   
   // Demand Zone Refinement
   while(demandtotal < 3)
   {
      
      if(idx < 0)
         break;
   
      double level = lowPrice-(levels[idx]*half);
      
      if(MathAbs(level-Close[0]) < _Point*250){idx--;continue;};             // Less than 25 pips
      double adder = Symbol() == "XAUUSD" ? (XAUUSD_MINIMUM_STOP_LOSS_PIP/2)*_Point : (EURUSD_MINIMUM_STOP_LOSS_PIP/2)*_Point*10;
      
      // Create orderblock 
      OrderBlock *ob = new OrderBlock();
      ob.time = Time[0];
      ob.upper = level+adder;
      ob.lower = level-adder;
    
      finalDemand.Add(ob);
    
      idx--;
      demandtotal++;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   
bool OrderBlockFinder::HasStrongMarubozu(int i, bool isBuy)
{
    if(isBuy)
    {
       if(Open[i-1] > Close[i-1] || Open[i] < Close[i]) return false;             // 2nd candle should be bullish
       if((Close[i-1]-Open[i-1])/(High[i-1]-Low[i-1]) < 0.5
       && (Close[i-2]-Open[i-2])/(High[i-2]-Low[i-2]) < 0.5) return false;        // 2nd should be big candle
    }

    else
    {
       if(Open[i-1] < Close[i-1] || Open[i] > Close[i]) return false;             // 2nd candle should be bearish
       if((Open[i-1]-Close[i-1])/(High[i-1]-Low[i-1]) < 0.5
       && (Open[i-2]-Close[i-2])/(High[i-2]-Low[i-2]) < 0.5) return false;        // 2nd should be big candle
    }
    
    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OrderBlockFinder::HasThreeCandles(int i, bool isBuy)
{    
    if(isBuy)
    {
       if(Open[i+1] < Close[i+1] || (Open[i-1] > Close[i-1] || Open[i-2] > Close[i-2]))  return false;                                     // 1st bearish, 3rd bullish 
       if(High[i+1] < High[i]) return false;                                                                                               // 2nd candle high = mitigated
       if(MathAbs(Close[i]-Open[i])/(High[i]-Low[i]) > 0.6) return false;                                                                  // 2nd Body shouldnt be big
       if((Close[i-1] < (High[i+1]-(High[i+1]-Low[i+1])/2) && Close[i-2] < (High[i+1]-(High[i+1]-Low[i+1])/2))) return false;              // 3rd body should push higher than first candle's close
    }

    else
    {
       if(Open[i+1] > Close[i+1] ||(Open[i-1] < Close[i-1] || Open[i-2] < Close[i-2]))  return false;                                      // 1st bearish, 3rd bullish 
       if(Low[i+1] < Low[i]) return false;                                                                                                 // 2nd candle high = mitigated
       if(MathAbs(Close[i]-Open[i])/(High[i]-Low[i]) > 0.6) return false;                                                                  // 2nd Body shouldnt be big
       if((Close[i-1] > (High[i+1]-(High[i+1]-Low[i+1])/2)) && Close[i-2] > (High[i+1]-(High[i+1]-Low[i+1])/2)) return false;               // 3rd body should push higher than first candle's close
    }
    
    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OrderBlockFinder::CheckBrokenSinceFractal(int i, bool isBuy, int& violated, int& withheld)
{
   double upper = High[i];
   double lower = Low[i];

    if(isBuy)
    {
        for(int j = i-2; j >= 0; j--)
        {
            if(Low[j] <= lower && Low[j+1] > lower) violated++;
            if(Low[j] > upper && Low[j+1] <= upper && Low[j+1] > lower) withheld++;
        }
    }
    else
    {
        for(int j = i-1; j >= 0; j--)
        {
            if(High[j] >= upper && High[j+1] < upper) violated++;
            if(High[j] < lower && High[j+1] < upper && High[j+1] >= lower) withheld++;
        }
    }
    
    if(withheld > 2 || violated > 1)
      return false;
    else
      return true;
    
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


bool OrderBlockFinder::IsUpFractal(int i)
{
    return High[i] > High[i+1] && High[i] > High[i+2] && High[i] > High[i-1] && High[i] > High[i-2];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OrderBlockFinder::IsDownFractal(int i)
{
    return Low[i] < Low[i+1] && Low[i] < Low[i+2] && Low[i] < Low[i-1] && Low[i] < Low[i-2];
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrderBlockFinder::WriteIntoFile()
{
   for(int i= 0; i < finalSupply.Total(); i++)
   {
      OrderBlock *ob = (OrderBlock*)finalSupply.At(i);
      FileWrite(SupplyFileHandle, TimeToString(ob.time), DoubleToString(ob.upper, _Digits), DoubleToString(ob.lower, _Digits),
      IntegerToString(ob.violated), IntegerToString(ob.withheld)
      );
   }

   for(int i= 0; i < finalDemand.Total(); i++)
   {
      OrderBlock *ob = (OrderBlock*)finalDemand.At(i);
      FileWrite(DemandFileHandle, TimeToString(ob.time), DoubleToString(ob.upper, _Digits), DoubleToString(ob.lower, _Digits),
      IntegerToString(ob.violated), IntegerToString(ob.withheld)
      );
   }

}

//+------------------------------------------------------------------+