//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#include "..\iForexDNA\hash.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\ExternVariables.mqh"

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property strict


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_INDICATOR_POSITION
  {
   Plus_3_StdDev,
   Plus_2_StdDev,
   Above_Mean,
   Equal_Mean,
   Below_Mean,
   Minus_2_StdDev,
   Minus_3_StdDev,
   Null
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PRICE_POSITION
  {
   AbovePriceLine,
   BelowPriceLine,
   UnknownPosition        // error
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MARKET_CONDITION
   {
      Bull_Trend_3x,
      Bull_Trend_2x,
      Bull_Channel,
      Bull_Squeeze,
      Bear_Squeeze,
      Bear_Channel,
      Bear_Trend_2x,
      Bear_Trend_3x,
      UnknownMarketCondition
   };   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MARKET_BIAS
   {
      StrongBull,
      WeakBull,
      StrongBear,
      WeakBear,
      Uncertainty
   };  
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRADE_TYPE
  {
   Continuation,
   Reversal,
   Retracement,
   NoTrade
  };
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum ENUM_QUADRANT
   {
      UPPER_QUADRANT,
      LOWER_QUADRANT,
      FULL_QUADRANT,
      UNKNOWN
   };   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string GetEnumIndicatorPositionString(ENUM_INDICATOR_POSITION Position)
  {
   if(Position<0 || Position>=ENUM_INDICATOR_POSITION_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Price Position");
      return EnumIndicatorPositionString[6];
     }

   return EnumIndicatorPositionString[Position];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetEnumPricePositionString(ENUM_PRICE_POSITION Position)
  {
   if(Position<0 || Position>=ENUM_PRICE_POSITION_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Price Position");
      return EnumPricePositionString[0];
     }

   return EnumPricePositionString[Position];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetEnumMarketConditionString(ENUM_MARKET_CONDITION MarketConditionType)
  {
   if(MarketConditionType<0 || MarketConditionType>=ENUM_MARKET_CONDITION_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Market Condition");
      return "";
     }

   return EnumMarketConditionStrings[MarketConditionType];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetEnumMarketBiasString(ENUM_MARKET_BIAS marketbias)
  {
   if(marketbias<0 || marketbias>=ENUM_MARKET_BIAS_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Market Bias");
      return NULL;
     }

   return EnumMarketBiasStrings[marketbias];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string GetEnumTradeTypeString(ENUM_TRADE_TYPE TradeType)
  {
   if(TradeType<0 || TradeType>=ENUM_TRADE_TYPE_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Trade Type");
      return NULL;
     }

   return EnumTradeTypeStrings[TradeType];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string GetEnumQuadrantString(ENUM_QUADRANT Quadrant)
  {
   if(Quadrant<0 || Quadrant>=ENUM_QUADRANT_SIZE)
     {
      LogError(__FUNCTION__,"Unknown Quadrant");
      return NULL;
     }

   return EnumQuadrantStrings[Quadrant];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
string GetTimeFramesString(const T t)
  {
   string typeOfT=typename(t);
   

   if(typeOfT=="enum ENUM_TIMEFRAMES")
     {
      switch(t)
        {  
        case PERIOD_M1:
            return EnumTimeFramesStrings[1];
            break;
        case PERIOD_M5:
            return EnumTimeFramesStrings[2];
            break;
         case PERIOD_M15:
            return EnumTimeFramesStrings[3];
            break;
         case PERIOD_H1:
            return EnumTimeFramesStrings[4];
            break;
         case PERIOD_H4:
            return EnumTimeFramesStrings[5];
            break;
         case PERIOD_D1:
            return EnumTimeFramesStrings[6];
            break;
         default:
            ASSERT("CandleStick Time frame NA",__FUNCTION__);
            return EnumTimeFramesStrings[0];
            break;
        }
     }
   else if(typeOfT=="int")
     {
      switch(t)
        {
         case 0:
            return EnumTimeFramesStrings[1];
            break;
         case 1:
            return EnumTimeFramesStrings[2];
            break;
         case 2:
            return EnumTimeFramesStrings[3];
            break;
         case 3:
            return EnumTimeFramesStrings[4];
            break;
         case 4:
            return EnumTimeFramesStrings[5];
            break;
         case 5:
            return EnumTimeFramesStrings[6];
            break;
         default:
            LogError(__FUNCTION__,"CandleStick Time frame NA");
            return EnumTimeFramesStrings[0];
            break;
        }
     }
   else
     {
      LogError(__FUNCTION__,"Type not supported");
      return EnumTimeFramesStrings[0];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
int GetTimeFrameIndex(const T t)
  {
   string typeOfT=typename(t);

   if(typeOfT=="enum ENUM_TIMEFRAMES")
     {
      switch(t)
        {
         case PERIOD_M1:
            return 0;
            break;
         case PERIOD_M5:
            return 1;
            break;
         case PERIOD_M15:
            return 2;
            break;
         case PERIOD_H1:
            return 3;
            break;
         case PERIOD_H4:
            return 4;
            break;
         case PERIOD_D1:
            return 5;
            break;
         default:
            LogError(__FUNCTION__,"Time frame NA");
            return -1;
            break;
        }
     }
   else if(typeOfT=="enum int")
     {
      switch(t)
        {
         case 1:
            return 0;
            break;
         case 5:
            return 1;
            break;
         case 15:
            return 2;
            break;
         case 16385:          // MQL5 calculation
            return 3;
            break;
         case 16388:           // MQL5 calculation
            return 4;
            break;
         case 16408:          // MQL5 calculation
            return 5;
            break;
         default:
            LogError(__FUNCTION__,"CandleStick Time frame NA");
            return -1;
            break;
        }
     }
   else
     {
      LogError(__FUNCTION__,"Type not supported");
      return -1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetTimeFrameENUM(int TimeFrameIndex)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Array out of Sync");
      return PERIOD_CURRENT;
     }

   return EnumTimeFramesArray[TimeFrameIndex];
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrameString(int TimeFrameIndex)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Array out of Sync");
      return (string) PERIOD_CURRENT;
     }

   return EnumTimeFramesStrings[TimeFrameIndex+1];
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetIndicatorPositionString(int Indicator_Position)
  {
   if(Indicator_Position<0 || Indicator_Position>=ENUM_INDICATOR_POSITION_SIZE)
     {
      LogError(__FUNCTION__,"Indicator_Position out of Sync");
      return EnumIndicatorPositionString[7];    // "NaN"
     }

   return EnumIndicatorPositionString[Indicator_Position];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetMonthString(const int month_number)
{

   return EnumMonthString[month_number];

}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetOrderTypeString(const int Type)
  {
   if(Type<0 || Type>=ENUM_ORDER_TYPE_ARRAY_SIZE)
   {
    LogError(__FUNCTION__,"Array out of Sync");
    return EnumOrderTypeArrayStrings[0];
   }
   
   return EnumOrderTypeArrayStrings[Type+1];
  }
//+------------------------------------------------------------------+
