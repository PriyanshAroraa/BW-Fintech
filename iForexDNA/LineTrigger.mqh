//+------------------------------------------------------------------+
//|                                                  LineTrigger.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BullBearIndex.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandlestickArray.mqh"


class LineTrigger:public BaseIndicator{
      IndicatorsHelper              *m_Indicators;
      
      int                           m_TotalLineAboveCurPrice[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      int                           m_TotalLineBelowCurPrice[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      
      double                        m_BuyPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];    
      
      double                        m_BuyMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];

      double                        m_BuyStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_SellStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
    

      
      string                        CalculateLineTrigger(int TimeFrameIndex, int Shift);
      void                          OnUpdateLineTriggerStdDev(int TimeFrameIndex);
        

      ENUM_PRICE_POSITION           LinePositionChecker(double curPrice, double LineValue);
      void                          ResetTotalLineOnCurPrice(int TimeFrameIndex, int Shift);   



   public:
                                    LineTrigger(IndicatorsHelper *pIndicators);
                                    ~LineTrigger();

      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
      

      double                        GetBuyPercent(int TimeFrameIndex, int Shift){return m_BuyPercent[TimeFrameIndex][Shift];};
      double                        GetSellPercent(int TimeFrameIndex, int Shift){return m_SellPercent[TimeFrameIndex][Shift];};
   
      double                        GetBuyMean(int TimeFrameIndex, int Shift){return m_BuyMean[TimeFrameIndex][Shift];};
      double                        GetSellMean(int TimeFrameIndex, int Shift){return m_SellMean[TimeFrameIndex][Shift];};
      
      double                        GetBuyStdDev(int TimeFrameIndex, int Shift){return m_BuyStdDev[TimeFrameIndex][Shift];};
      double                        GetSellStdDev(int TimeFrameIndex, int Shift){return m_SellStdDev[TimeFrameIndex][Shift];};
               
      double                        GetUpperBuyStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_BuyMean[TimeFrameIndex][Shift]+Multiplier*m_BuyStdDev[TimeFrameIndex][Shift];};
      double                        GetUpperSellStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_SellMean[TimeFrameIndex][Shift]+Multiplier*m_SellStdDev[TimeFrameIndex][Shift];};        
               
      double                        GetBuyStdDevPosition(int TimeFrameIndex, int Shift);
      double                        GetSellStdDevPosition(int TimeFrameIndex, int Shift);
      
      //    still under R&D and may or may not need it
      
      int                           GetTotalLineAbovePrice(int TimeFrameIndex, int Shift){return m_TotalLineAboveCurPrice[TimeFrameIndex][Shift];};
      int                           GetTotalLineBelowPrice(int TimeFrameIndex, int Shift){return m_TotalLineBelowCurPrice[TimeFrameIndex][Shift];};
      
      
      bool                          GetIsBuyCrossOver(int TimeFrameIndex, int Shift);
      bool                          GetIsSellCrossOver(int TimeFrameIndex, int Shift);

      ENUM_INDICATOR_POSITION       GetBuyPosition(int TimeFrameIndex,int Shift);
      ENUM_INDICATOR_POSITION       GetSellPosition(int TimeFrameIndex,int Shift);
      

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

LineTrigger::LineTrigger(IndicatorsHelper *pIndicators):BaseIndicator("LineTrigger")
{
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

LineTrigger::~LineTrigger()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool LineTrigger::Init()
{
      
    for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
        double tempBuyArray[INDEXES_BUFFER_SIZE*2];
        double tempSellArray[INDEXES_BUFFER_SIZE*2];
        int arrsize=ArraySize(tempBuyArray);
   
        for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++){
            if(j < INDEXES_BUFFER_SIZE)
            {
               CalculateLineTrigger(i,j);
               tempBuyArray[j] = m_BuyPercent[i][j];
               tempSellArray[j] = m_SellPercent[i][j];
            }

            else
            {
               string LineTriggerArray[2];
               StringSplit(CalculateLineTrigger(i,j), '/', LineTriggerArray);
      
               tempBuyArray[j] = StringToDouble(LineTriggerArray[0]);
               tempSellArray[j] = StringToDouble(LineTriggerArray[1]);
            }

        }

      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_BuyMean[i][x] = NormalizeDouble(MathMean(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_BuyStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempBuyArray, x, ADVANCE_INDICATOR_PERIOD), 2);


         m_SellMean[i][x] = NormalizeDouble(MathMean(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_SellStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempSellArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         
      }

    }

   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void LineTrigger::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
   // not neeeded with all timeframes
   if(TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
      return;


    if(IsNewBar)
    {
        for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--){
            m_BuyPercent[TimeFrameIndex][i] = m_BuyPercent[TimeFrameIndex][i-1];
            m_SellPercent[TimeFrameIndex][i] = m_SellPercent[TimeFrameIndex][i-1];

            m_BuyMean[TimeFrameIndex][i] = m_BuyMean[TimeFrameIndex][i-1];
            m_SellMean[TimeFrameIndex][i] = m_SellMean[TimeFrameIndex][i-1];

            m_BuyStdDev[TimeFrameIndex][i] = m_BuyStdDev[TimeFrameIndex][i-1];
            m_SellStdDev[TimeFrameIndex][i] = m_SellStdDev[TimeFrameIndex][i-1];

        }

    }

    // updating the latest values
    CalculateLineTrigger(TimeFrameIndex, 0);
    OnUpdateLineTriggerStdDev(TimeFrameIndex);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string LineTrigger:: CalculateLineTrigger(int TimeFrameIndex,int Shift)
{
   if(Shift+1 >= DEFAULT_BUFFER_SIZE)
      return "0/0";


   double BuyIndex = 0, SellIndex = 0;
   double BuyPercent = 0, SellPercent = 0;
   
   double TotalLineAboveCurPrice = 0, TotalLineBelowCurPrice = 0;
   
   ResetTotalLineOnCurPrice(TimeFrameIndex, Shift);               // RESET VALUES 

   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   double curClose = Shift<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(), timeFrameENUM, Shift);
   double curOpen = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen():iOpen(Symbol(), timeFrameENUM, Shift);
   double curLow = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetLow():iLow(Symbol(), timeFrameENUM, Shift);
   double curHigh = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh():iHigh(Symbol(), timeFrameENUM, Shift);


   double prevClose = Shift+1<CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift+1].GetClose():iClose(Symbol(), timeFrameENUM, Shift+1);
   double prevLow = Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetLow():iLow(Symbol(), timeFrameENUM, Shift+1);
   double prevHigh = Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetHigh():iHigh(Symbol(), timeFrameENUM, Shift+1);

   
   // PIVOT
   for(int i = -PIVOT_LEVELS_SIZE; i <= PIVOT_LEVELS_SIZE; i++)
   {
      // skip Pivot Point
      if(i == 0)
         continue;
      
      double LineValue = m_Indicators.GetPivot().GetPivot(TimeFrameIndex, Shift, i);
      double prevLineValue = m_Indicators.GetPivot().GetPivot(TimeFrameIndex, Shift+1, i);


      if(LinePositionChecker(prevClose, prevLineValue) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
         TotalLineAboveCurPrice++;         
      else
         TotalLineBelowCurPrice++;


      // Break Upwards
      if(curClose > curOpen 
      && curClose > LineValue
      && prevHigh <= prevLineValue)
         BuyIndex++;
         
      
      // Break Downwards
      if(curClose < curOpen 
      && curClose < LineValue
      && prevLow >= prevLineValue)
         SellIndex++;
         

   }


   // FIBONACCI
   bool isUp = m_Indicators.GetFibonacci().IsUp(TimeFrameIndex, Shift);
   
   
   for(int i = 0; i < FIBONACCI_LEVELS_SIZE; i++)
   {
      double line_value = 0;
   
      // check is up
      if(isUp)
         line_value = m_Indicators.GetFibonacci().GetUpFibonacci(TimeFrameIndex, Shift, FIBONACCI_LEVELS[i]*100);
         
      else
         line_value = m_Indicators.GetFibonacci().GetDownFibonacci(TimeFrameIndex, Shift, FIBONACCI_LEVELS[i]*100);


      if(LinePositionChecker(prevClose, line_value) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
         TotalLineAboveCurPrice++;         
      else
         TotalLineBelowCurPrice++;
   
   
      // Break Upwards
      if(curClose > curOpen
       && curClose > line_value
       && prevHigh <= line_value)       
         BuyIndex++;
         
      // Break Downwards
      else if(curClose < curOpen 
      && curClose < line_value 
      && prevLow >= line_value)     
         SellIndex++;
         
   }

   // FRACTAL SUPPORT
   if(Shift+1 < INDEXES_BUFFER_SIZE)
   {
      double curr_sup = m_Indicators.GetFractal().GetFractalSupportPrice(TimeFrameIndex, Shift);
      double prev_sup = m_Indicators.GetFractal().GetFractalSupportPrice(TimeFrameIndex, Shift+1);
   
      if(LinePositionChecker(prevClose, prev_sup) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
         TotalLineAboveCurPrice++;         
      else
         TotalLineBelowCurPrice++;
   
   
      // Break Upwards
      if(curClose > curOpen
      && curClose > curr_sup
      && prevHigh <= prev_sup
      )       
          BuyIndex++;
               
      // Break Downwards
      else if(curClose < curOpen 
      && curClose < curr_sup 
      && prevLow >= prev_sup)     
          SellIndex++;
   
   
      // FRACTAL RESISTANCE
      double curr_res = m_Indicators.GetFractal().GetFractalResistancePrice(TimeFrameIndex, Shift);
      double prev_res = m_Indicators.GetFractal().GetFractalResistancePrice(TimeFrameIndex, Shift+1);
   
      if(LinePositionChecker(prevClose, prev_res) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
         TotalLineAboveCurPrice++;         
      else
         TotalLineBelowCurPrice++;
   
   
      // Break Upwards
      if(curClose > curOpen
      && curClose > curr_res
      && prevHigh <= prev_res
      )       
          BuyIndex++;
               
      // Break Downwards
      else if(curClose < curOpen 
      && curClose < curr_res 
      && prevLow >= prev_res)     
          SellIndex++;
   }


   // ICHIMOKU
   double curTenKan = m_Indicators.GetIchimoku().GetTenkanSen(TimeFrameIndex, Shift);
   double prevTenKan = m_Indicators.GetIchimoku().GetTenkanSen(TimeFrameIndex, Shift+1);
      
   if(LinePositionChecker(prevClose, prevTenKan) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   // Break Upwards
   if(curClose > curOpen 
   && curTenKan < curClose 
   && prevTenKan >= prevHigh)       
      BuyIndex++;
         
   // Break Downwards
   else if(curOpen > curClose 
   && curTenKan > curClose 
   && prevTenKan <= prevLow)      
      SellIndex++;
   
   
   // KIJUN SEN
   double curKijun = m_Indicators.GetIchimoku().GetKijunSen(TimeFrameIndex, Shift);
   double prevKijun = m_Indicators.GetIchimoku().GetKijunSen(TimeFrameIndex, Shift+1);

   if(LinePositionChecker(prevClose, prevKijun) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   if(curClose > curOpen 
   && curKijun < curClose 
   && prevKijun >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && curKijun > curClose 
   && prevKijun <= prevLow)      // Break Downwards
      SellIndex++;
      

   // SPAN A 
   double curSpanA = Shift-ICHIMOKU_NEGATIVE_SHIFT < ICHIMOKU_SENKOU_SPAN ? m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT) : m_Indicators.GetIchimoku().CalculateSenkouSpanA(timeFrameENUM, Shift);
   double prevSpanA = Shift-ICHIMOKU_NEGATIVE_SHIFT+1 < ICHIMOKU_SENKOU_SPAN ? m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT+1) : m_Indicators.GetIchimoku().CalculateSenkouSpanA(timeFrameENUM, Shift+1);

   if(LinePositionChecker(prevClose, prevSpanA) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   if(curClose > curOpen 
   && curSpanA < curClose 
   && prevSpanA >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && curSpanA > curClose 
   && prevSpanA <= prevLow)      // Break Downwards
      SellIndex++;   


   // SPAN B
   double curSpanB = Shift-ICHIMOKU_NEGATIVE_SHIFT < ICHIMOKU_SENKOU_SPAN ? m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT) : m_Indicators.GetIchimoku().CalculateSenkouSpanB(timeFrameENUM, Shift);
   double prevSpanB = Shift-ICHIMOKU_NEGATIVE_SHIFT+1 < ICHIMOKU_SENKOU_SPAN ? m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT+1) : m_Indicators.GetIchimoku().CalculateSenkouSpanB(timeFrameENUM, Shift+1);

   if(LinePositionChecker(prevClose, prevSpanB) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && curSpanB < curClose 
   && prevSpanB >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && curSpanB > curClose 
   && prevSpanB <= prevLow)      // Break Downwards
      SellIndex++;   
      

   // BOLLINGER BAND
   double BBMean = m_Indicators.GetBands().GetMain(TimeFrameIndex, Shift);
   double prevBBMean = m_Indicators.GetBands().GetMain(TimeFrameIndex, Shift+1);
   
   if(LinePositionChecker(prevClose, prevBBMean) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   if(curClose > curOpen 
   && BBMean < curClose 
   && prevBBMean >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && BBMean > curClose 
   && prevBBMean <= prevLow)      // Break Downwards
      SellIndex++;  


   // 2X UPPER
   double BBUpper2XStdDev = m_Indicators.GetBands().GetUpper(TimeFrameIndex, 2, Shift);
   double prevBBUpper2xStdDev = m_Indicators.GetBands().GetUpper(TimeFrameIndex, 2, Shift+1);

   if(LinePositionChecker(prevClose, prevBBUpper2xStdDev) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && BBUpper2XStdDev < curClose 
   && prevBBUpper2xStdDev >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && BBUpper2XStdDev > curClose 
   && prevBBUpper2xStdDev <= prevLow)      // Break Downwards
      SellIndex++;   


   // 3X UPPER
   double BBUpper3XStdDev = m_Indicators.GetBands().GetUpper(TimeFrameIndex, 3, Shift);
   double prevBBUpper3xStdDev = m_Indicators.GetBands().GetUpper(TimeFrameIndex, 3, Shift+1);
   
   if(LinePositionChecker(prevClose, prevBBUpper3xStdDev) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && BBUpper3XStdDev < curClose 
   && prevBBUpper3xStdDev >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && BBUpper3XStdDev > curClose 
   && prevBBUpper3xStdDev <= prevLow)      // Break Downwards
      SellIndex++; 


   // 2X LOWER
   double BBLower2XStdDev = m_Indicators.GetBands().GetLower(TimeFrameIndex, 2, Shift);
   double prevBBLower2XStdDev = m_Indicators.GetBands().GetLower(TimeFrameIndex, 2, Shift+1);

   if(LinePositionChecker(prevClose, prevBBLower2XStdDev) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   

   if(curClose > curOpen 
   && BBLower2XStdDev < curClose 
   && prevBBLower2XStdDev >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && BBLower2XStdDev > curClose 
   && prevBBLower2XStdDev <= prevLow)      // Break Downwards
      SellIndex++;   


   // 3X LOWER
   double BBLower3XStdDev = m_Indicators.GetBands().GetLower(TimeFrameIndex, 3, Shift);
   double prevBBLower3XStdDev = m_Indicators.GetBands().GetLower(TimeFrameIndex, 3, Shift+1);
   
   if(LinePositionChecker(prevClose, prevBBLower3XStdDev) == AbovePriceLine)         
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   

   if(curClose > curOpen 
   && BBLower3XStdDev < curClose 
   && prevBBLower3XStdDev >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && BBLower3XStdDev > curClose 
   && prevBBLower3XStdDev <= prevLow)      // Break Downwards
      SellIndex++;   


   // MOVING AVERAGES
   double ma = m_Indicators.GetMovingAverage().GetFastMA(TimeFrameIndex, Shift);    // MA 5
   double prevma = m_Indicators.GetMovingAverage().GetFastMA(TimeFrameIndex, Shift+1);

   if(LinePositionChecker(prevClose, prevma) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && ma < curClose 
   && prevma >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && ma > curClose 
   && prevma <= prevLow)      // Break Downwards
      SellIndex++;   


   ma = m_Indicators.GetMovingAverage().GetMediumMA(TimeFrameIndex, Shift);    // MA 20
   prevma = m_Indicators.GetMovingAverage().GetMediumMA(TimeFrameIndex, Shift+1);

   if(LinePositionChecker(prevClose, prevma) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && ma < curClose 
   && prevma >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && ma > curClose 
   && prevma <= prevLow)      // Break Downwards
      SellIndex++; 


   ma = m_Indicators.GetMovingAverage().GetSlowMA(TimeFrameIndex, Shift);    // MA 50
   prevma = m_Indicators.GetMovingAverage().GetSlowMA(TimeFrameIndex, Shift+1);

   if(LinePositionChecker(prevClose, prevma) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
   
   
   if(curClose > curOpen 
   && ma < curClose 
   && prevma >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && ma > curClose 
   && prevma <= prevLow)      // Break Downwards
      SellIndex++; 


   ma = m_Indicators.GetMovingAverage().GetMoneyLineMA(TimeFrameIndex, Shift);    // MA 200
   prevma = m_Indicators.GetMovingAverage().GetMoneyLineMA(TimeFrameIndex, Shift+1);

   if(LinePositionChecker(prevClose, prevma) == AbovePriceLine)          // CHECK ON WHICH POSITION IS LINE AT AS OPPOSE TO PREVIOUS PRICE
      TotalLineAboveCurPrice++;         
   else
      TotalLineBelowCurPrice++;
      
   
   if(curClose > curOpen 
   && ma < curClose 
   && prevma >= prevHigh)       // Break Upwards
      BuyIndex++;
         
   else if(curOpen > curClose 
   && ma > curClose 
   && prevma <= prevLow)      // Break Downwards
      SellIndex++; 

      
   BuyPercent = TotalLineAboveCurPrice > 0 ? NormalizeDouble((BuyIndex/TotalLineAboveCurPrice)*100, 2) : 0;
   SellPercent = TotalLineBelowCurPrice > 0 ?  NormalizeDouble((SellIndex/TotalLineBelowCurPrice)*100, 2) : 0;


   // summarize the calculation (Calculation for StdDev/ Basic Calculation)
   if(Shift < INDEXES_BUFFER_SIZE)
   {
      m_BuyPercent[TimeFrameIndex][Shift] = BuyPercent;
      m_SellPercent[TimeFrameIndex][Shift] = SellPercent;
      
      m_TotalLineAboveCurPrice[TimeFrameIndex][Shift] = (int)TotalLineAboveCurPrice;
      m_TotalLineBelowCurPrice[TimeFrameIndex][Shift] = (int)TotalLineBelowCurPrice;      
      
      return "";
   }
   
   return DoubleToString(BuyPercent, 2) + "/" + DoubleToString(SellPercent, 2);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void LineTrigger::OnUpdateLineTriggerStdDev(int TimeFrameIndex)
{

   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double tempBuyArray[ADVANCE_INDICATOR_PERIOD];
   double tempSellArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempBuyArray[i] = m_BuyPercent[TimeFrameIndex][i];
      tempSellArray[i] = m_SellPercent[TimeFrameIndex][i];
   }   

   m_BuyMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_BuyStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempBuyArray, 0, ADVANCE_INDICATOR_PERIOD), 2);


   m_SellMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_SellStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempSellArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_PRICE_POSITION LineTrigger:: LinePositionChecker(double PrevPrice, double PrevLineValue)
{
   if(PrevLineValue > PrevPrice)
      return AbovePriceLine;
      
   return BelowPriceLine;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool LineTrigger::GetIsBuyCrossOver(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   return (m_BuyPercent[TimeFrameIndex][Shift] > m_SellPercent[TimeFrameIndex][Shift] && m_BuyPercent[TimeFrameIndex][Shift+1] <= m_SellPercent[TimeFrameIndex][Shift+1]);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool LineTrigger::GetIsSellCrossOver(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return false;
   }
   
   return (m_BuyPercent[TimeFrameIndex][Shift] < m_SellPercent[TimeFrameIndex][Shift] && m_BuyPercent[TimeFrameIndex][Shift+1] >= m_SellPercent[TimeFrameIndex][Shift+1]);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double LineTrigger::GetBuyStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return 0;
   }
   
   if(m_BuyStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
   
   return (m_BuyPercent[TimeFrameIndex][Shift] - m_BuyMean[TimeFrameIndex][Shift])/m_BuyStdDev[TimeFrameIndex][Shift];
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double LineTrigger::GetSellStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift is out of range...");
      return 0;
   }
   
   if(m_SellStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
   
   return (m_SellPercent[TimeFrameIndex][Shift] - m_SellMean[TimeFrameIndex][Shift])/m_SellStdDev[TimeFrameIndex][Shift];
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION LineTrigger::GetBuyPosition(int TimeFrameIndex,int Shift)
{
   if(m_BuyPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_BuyPercent[TimeFrameIndex][Shift] > GetUpperBuyStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] > GetUpperBuyStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] > m_BuyMean[TimeFrameIndex][Shift] && m_BuyPercent[TimeFrameIndex][Shift] < GetUpperBuyStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] == m_BuyMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_BuyPercent[TimeFrameIndex][Shift] < m_BuyMean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION LineTrigger::GetSellPosition(int TimeFrameIndex,int Shift)
{
   if(m_SellPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_SellPercent[TimeFrameIndex][Shift] > GetUpperSellStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] > GetUpperSellStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] > m_SellMean[TimeFrameIndex][Shift] && m_SellPercent[TimeFrameIndex][Shift] < GetUpperSellStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] == m_SellMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_SellPercent[TimeFrameIndex][Shift] < m_SellMean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void LineTrigger::ResetTotalLineOnCurPrice(int TimeFrameIndex, int Shift)
{ 
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= INDEXES_BUFFER_SIZE)
      return;
   
   m_TotalLineAboveCurPrice[TimeFrameIndex][Shift] = 0;
   m_TotalLineBelowCurPrice[TimeFrameIndex][Shift] = 0;
   
}

//+------------------------------------------------------------------+
