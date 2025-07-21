//+------------------------------------------------------------------+
//|                                                       ZigZag.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ZigZag:public BaseIndicator
  {
private:
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
   int               m_Depth;
   int               m_Deviation;
   int               m_Backstep;
   
   
   
   struct ZigZagPoints
     {
         datetime zzDateTime;
         double   zzPrice;
         int      zzShift;
     };
   
   ZigZagPoints      m_ZigZag[ENUM_TIMEFRAMES_ARRAY_SIZE][ZIGZAG_BUFFER_SIZE];
     
public:
                     ZigZag();
                    ~ZigZag();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   // Get ZZ shift points
   
   datetime          GetZigZagDateTime(int TimeFrameIndex,int Shift){return m_ZigZag[TimeFrameIndex][Shift].zzDateTime;};
   double            GetZigZagPrice(int TimeFrameIndex,int Shift){return Normalize(m_ZigZag[TimeFrameIndex][Shift].zzPrice);};
   int               GetZigZagShift(int TimeFrameIndex, int Shift){return m_ZigZag[TimeFrameIndex][Shift].zzShift;};
   
   // Returns the nearest zz shift based on barshift... 
   
   int               GetNearestZigZagShiftFromBarShift(int TimeFrameIndex, int BarShift);
   
   //    Getting price and shift from barshift
   
   double            GetZigZagPriceFromBarShift(int TimeFrameIndex, int BarShift);   
   int               GetZigZagShiftFromBarShift(int TimeFrameIndex, int BarShift);
   
   //    Get ZZ HighPrices based on only high price shifts.... e.g. Shift high 0 == Zz point shift 0 && Shift high 1 == Zz point shift 2
   
   double            GetZigZagHighPrice(int TimeFrameIndex,int Shift);
   double            GetZigZagLowPrice(int TimeFrameIndex,int Shift);
   
   int               GetZigZagHighShift(int TimeFrameIndex,int Shift);
   int               GetZigZagLowShift(int TimeFrameIndex, int Shift);
   
   
   
   // Get Where is the price at 
   int               GetCurrentPriceStatus(int TimeFrameIndex, int Shift);
   
   
   // Getter for handlers
   int               GetZigZagHandlers(int TimeFrameIndex){return m_Handlers[TimeFrameIndex];};
   
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZigZag::ZigZag():BaseIndicator("ZigZag")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ZigZag::~ZigZag()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ZigZag::Init()
  {
   m_Depth=ZIGZAG_DEPTH;
   m_Deviation=ZIGZAG_DEVIATION;
   m_Backstep=ZIGZAG_BACKSTEP;

   string symbol = Symbol();

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
      ENUM_TIMEFRAMES timeFrameEnum=GetTimeFrameENUM(i);
      
      m_Handlers[i] = iCustom(symbol, timeFrameEnum, "Examples\\ZigZag", m_Depth, m_Deviation, m_Backstep);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize ZigZag handlers.");
         return false;
      }
      
      int shift=0;
      int j = 0;
      while(j<ZIGZAG_BUFFER_SIZE)
      {
         double ZZ_Value=GetZigZag(m_Handlers[i],0,shift);
         if(ZZ_Value>0)
         {
            m_ZigZag[i][j].zzPrice = GetZigZag(m_Handlers[i],1,shift) > 0 ? ZZ_Value : -ZZ_Value;
            m_ZigZag[i][j].zzDateTime = iTime(Symbol(), timeFrameEnum, shift);
            m_ZigZag[i][j].zzShift = shift;
                 
            j++;
         }
         else if(ZZ_Value == EMPTY_VALUE)
         {
            m_ZigZag[i][j].zzPrice = EMPTY_VALUE;
            m_ZigZag[i][j].zzDateTime = NULL;
            m_ZigZag[i][j].zzShift = NULL;
            
            j++;
         }
         
         shift++;
      } // while loop
        
     }   // i loop

   return true;

  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void  ZigZag::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
  
   ENUM_TIMEFRAMES timeFrameEnum=GetTimeFrameENUM(TimeFrameIndex); 
      
   int i=0,counter=0;   
   
   while(i < ZIGZAG_BUFFER_SIZE)
   {
      double zz = GetZigZag(m_Handlers[TimeFrameIndex],0,counter);
      
      if(zz > 0)
      {
         // update zz shift (i)
         m_ZigZag[TimeFrameIndex][i].zzPrice = GetZigZag(m_Handlers[TimeFrameIndex],1,counter) > 0 ? zz : -zz;
         m_ZigZag[TimeFrameIndex][i].zzDateTime = iTime(Symbol(), timeFrameEnum, counter);
         m_ZigZag[TimeFrameIndex][i].zzShift = counter;
         
         i++;
         
      }
      
      else if(zz == EMPTY_VALUE)
      {
         m_ZigZag[TimeFrameIndex][i].zzPrice = EMPTY_VALUE;
         m_ZigZag[TimeFrameIndex][i].zzDateTime = NULL;
         m_ZigZag[TimeFrameIndex][i].zzShift = NULL;
            
         i++;
      }
      
      counter++;
      
   }
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ZigZag::GetZigZagHighPrice(int TimeFrameIndex,int Shift)
{
   if(Shift < 0 || Shift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   return m_ZigZag[TimeFrameIndex][Shift].zzPrice > 0 ? m_ZigZag[TimeFrameIndex][Shift].zzPrice : m_ZigZag[TimeFrameIndex][Shift+1].zzPrice;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ZigZag::GetZigZagLowPrice(int TimeFrameIndex,int Shift)
{
   if(Shift < 0 || Shift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   return m_ZigZag[TimeFrameIndex][Shift].zzPrice < 0 ? m_ZigZag[TimeFrameIndex][Shift].zzPrice : m_ZigZag[TimeFrameIndex][Shift+1].zzPrice;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ZigZag::GetZigZagHighShift(int TimeFrameIndex,int Shift)
{
   if(Shift < 0 || Shift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   return m_ZigZag[TimeFrameIndex][Shift].zzPrice > 0 ? m_ZigZag[TimeFrameIndex][Shift].zzShift : m_ZigZag[TimeFrameIndex][Shift+1].zzShift;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ZigZag::GetZigZagLowShift(int TimeFrameIndex,int Shift)
{
   if(Shift < 0 || Shift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   return m_ZigZag[TimeFrameIndex][Shift].zzPrice < 0 ? m_ZigZag[TimeFrameIndex][Shift].zzShift : m_ZigZag[TimeFrameIndex][Shift+1].zzShift;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ZigZag::GetNearestZigZagShiftFromBarShift(int TimeFrameIndex,int BarShift)
{
   if(BarShift < 0 || BarShift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return -1;
   }
   
   datetime curTime = iTime(Symbol(), GetTimeFrameENUM(TimeFrameIndex), BarShift);
   
   for(int i = 0; i < ZIGZAG_BUFFER_SIZE; i++)
   {
      if(curTime >= m_ZigZag[TimeFrameIndex][i].zzDateTime)
         return i;
   }

   return -1;        // not found

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ZigZag::GetZigZagShiftFromBarShift(int TimeFrameIndex, int BarShift)
{
   if(BarShift < 0 || BarShift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   datetime curTime = iTime(Symbol(), GetTimeFrameENUM(TimeFrameIndex), BarShift);
   
   for(int i = 0; i < ZIGZAG_BUFFER_SIZE; i++)
   {
      if(m_ZigZag[TimeFrameIndex][i].zzDateTime == curTime)
         return GetZigZagShift(TimeFrameIndex, i);
         
      else if(m_ZigZag[TimeFrameIndex][i].zzDateTime < curTime)
         return -1;   
   }

   return -1;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ZigZag::GetZigZagPriceFromBarShift(int TimeFrameIndex, int BarShift)
{
   if(BarShift < 0 || BarShift >= ZIGZAG_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      LogError(__FUNCTION__, "ZigZag Shift or TimeFrameIndex out of range. ");
      return 0;
   }
   
   datetime curTime = iTime(Symbol(), GetTimeFrameENUM(TimeFrameIndex), BarShift);
   
   for(int i = 0; i < ZIGZAG_BUFFER_SIZE; i++)
   {
      if(m_ZigZag[TimeFrameIndex][i].zzDateTime == curTime)
         return m_ZigZag[TimeFrameIndex][i].zzPrice;
         
      else if(m_ZigZag[TimeFrameIndex][i].zzDateTime < curTime)
         return 0;   
   }

   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ZigZag::GetCurrentPriceStatus(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE
   || Shift < 0 || Shift >= ZIGZAG_BUFFER_SIZE
   )
   {
      LogError(__FUNCTION__, "Price Status ZigZag TimeFrameIndex/Shift Invalid.");
      return NEUTRAL;
   }

   // Skip the last ones
   if(Shift+1 > ZIGZAG_BUFFER_SIZE)
      return NEUTRAL;
      
   int current_zigzag_shift = GetNearestZigZagShiftFromBarShift(TimeFrameIndex, Shift);
   int previous_zigzag_shift = current_zigzag_shift+1;
   
   double price_difference = MathAbs(m_ZigZag[TimeFrameIndex][current_zigzag_shift].zzPrice-m_ZigZag[TimeFrameIndex][previous_zigzag_shift].zzPrice);
   
   double upper = MathMax(m_ZigZag[TimeFrameIndex][current_zigzag_shift].zzPrice, m_ZigZag[TimeFrameIndex][previous_zigzag_shift].zzPrice);
   double midpoint = upper-(price_difference/2);
   
   // Discounted Pricing 
   if(CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() < midpoint)
      return BULL_TRIGGER;
   
   // Premium Pricing 
   if(CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() > midpoint)
      return BEAR_TRIGGER;
      
   return NEUTRAL;
    
}

//+------------------------------------------------------------------+
