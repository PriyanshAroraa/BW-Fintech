//+------------------------------------------------------------------+
//|                                               KeltnerChannel.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class KeltnerChannel: public BaseIndicator{

   private:      
      int                  m_Shift;
      int                  m_Period;
      int                  m_ATRPeriod;
      int                  m_MAPeriod;
      ENUM_MA_METHOD       m_MAMethod;
      ENUM_APPLIED_PRICE   m_AppliedPrice;
      
      int                  m_ATRHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                  m_MAHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];

   
      double            m_Main[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double            m_Upper[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];    
      double            m_Lower[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];    



   public:
                        KeltnerChannel();
                        ~KeltnerChannel();
      
      bool              Init();
      void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

      double            GetMain(int TimeFrameIndex, int Shift);
      double            GetUpper(int TimeFrameIndex, int Shift);
      double            GetLower(int TimeFrameIndex, int Shift);

      int               GetPricePosition(int TimeFrameIndex, int Shift);
      double            GetKeltnerSize(int TimeFrameIndex, int Shift);
      double            GetKeltnerMASize(int TimeFrameIndex, int Shift);


      void              CalculateKeltner(ENUM_TIMEFRAMES timeFrameENUM, int Shift, double &returnArray[]);          // (keltner main, keltner stdDev)
      
      
   private:
      bool        SetShift(int Shift);
      bool        SetPeriod(int Period);
      bool        SetATRPeriod(int ATRPeriod);
      bool        SetMAPeriod(int MAPeriod);
      bool        SetMAMethod(ENUM_MA_METHOD MAMethod);
      bool        SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

KeltnerChannel::KeltnerChannel():BaseIndicator("Keltner")
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

KeltnerChannel::~KeltnerChannel()
{
    ArrayRemove(m_Main, 0);
    ArrayRemove(m_Upper, 0);
    ArrayRemove(m_Lower, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::Init(){
   m_Shift=-1;
   m_Period=-1;
   m_ATRPeriod=-1;
   m_MAPeriod=-1;
   m_MAMethod=-1;
   m_AppliedPrice = -1;

   if(!SetShift(DEFAULT_SHIFT) 
      || !SetPeriod(KELTNER_PERIOD) 
      || !SetATRPeriod(KELTNER_ATR_PERIOD) 
      || !SetMAPeriod(KELTNER_MA_PERIOD) 
      || !SetMAMethod(KELTNER_MA_METHOD)
      || !SetAppliedPrice(APPLIED_PRICE))
   {
      return false;
   }

   ArrayInitialize(m_Main, -1);
   ArrayInitialize(m_Upper, -1);
   ArrayInitialize(m_Lower, -1);

   string symbol = Symbol();

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      // get the checking timeframe only
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_ATRHandler[i] = iATR(Symbol(), timeFrameENUM, m_Period);
      m_MAHandler[i] = iMA(Symbol(), timeFrameENUM, m_Period, m_Shift, m_MAMethod, m_AppliedPrice);

      if(m_ATRHandler[i] == INVALID_HANDLE || m_MAHandler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Keltner handlers.");
         return false;
      }

      for(int j=0; j < DEFAULT_BUFFER_SIZE; j++)
      {
         double atr = GetATR(m_ATRHandler[i], j);
         
         m_Main[i][j] = GetMovingAverage(m_MAHandler[i], j);
         m_Upper[i][j] = m_Main[i][j]+KELTNER_MULTIPLIER*atr;
         m_Lower[i][j] = m_Main[i][j]-KELTNER_MULTIPLIER*atr;
      }   
   }

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void KeltnerChannel::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid Timeframe Input.", __FUNCTION__);
      return;
   }

   if(IsNewBar){
      // updating bar
      for(int i = DEFAULT_BUFFER_SIZE - 1; i > 0; i--){
         m_Main[TimeFrameIndex][i] = m_Main[TimeFrameIndex][i-1];
         m_Upper[TimeFrameIndex][i] = m_Upper[TimeFrameIndex][i-1];
         m_Lower[TimeFrameIndex][i] = m_Lower[TimeFrameIndex][i-1];
      }
   }

   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   m_Main[TimeFrameIndex][0] = GetMovingAverage(m_MAHandler[TimeFrameIndex], 0);

   // get ATR 
   double atr_value = GetATR(m_ATRHandler[TimeFrameIndex], 0);

   // update upper and lower channel
   m_Upper[TimeFrameIndex][0] = (m_Main[TimeFrameIndex][0]) + (KELTNER_MULTIPLIER * atr_value);
   m_Lower[TimeFrameIndex][0] = (m_Main[TimeFrameIndex][0]) - (KELTNER_MULTIPLIER * atr_value);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void KeltnerChannel::CalculateKeltner(ENUM_TIMEFRAMES timeFrameENUM,int Shift,double &returnArray[])
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   returnArray[0] = GetMovingAverage(m_MAHandler[TimeFrameIndex], Shift);
   returnArray[1] = GetATR(m_ATRHandler[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double KeltnerChannel::GetMain(int TimeFrameIndex,int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
   }

   double res=m_Main[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double KeltnerChannel::GetUpper(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
   }

   if(m_Upper[TimeFrameIndex][Shift]<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return m_Upper[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double KeltnerChannel::GetLower(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
   }

   if(m_Lower[TimeFrameIndex][Shift]<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return m_Lower[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                           Setter                                 |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetShift(int Shift){
   if(Shift < 0){
      LogError(__FUNCTION__, "Invalid Shift Input.");
      m_Shift = -1;
      return false;
   }

   m_Shift = Shift;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetPeriod(int period){
   if(period <= 0){
      LogError(__FUNCTION__, "Invalid Period Input.");
      m_Period = -1;
      return false;
   }

   m_Period = period;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetATRPeriod(int ATRPeriod){
   if(ATRPeriod <= 0){
      LogError(__FUNCTION__, "Invalid ATR Period Input.");
      m_ATRPeriod = -1;
      return false;
   }

   m_ATRPeriod = ATRPeriod;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice){
   if(AppliedPrice < 0 || AppliedPrice > 6){
      LogError(__FUNCTION__, "Invalid Applied Price.");
      m_AppliedPrice = -1;
      return false;
   }

   m_AppliedPrice = AppliedPrice;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetMAPeriod(int MAPeriod){
   if(MAPeriod <= 0){
      LogError(__FUNCTION__, "Invalid MAPeriod Input.");
      m_MAPeriod = -1;
      return false;
   }

   m_MAPeriod = MAPeriod;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool KeltnerChannel::SetMAMethod(ENUM_MA_METHOD MAMethod){
   if(MAMethod < 0 || MAMethod > 3){
      LogError(__FUNCTION__, "Invalid MAMethod input.");
      m_MAMethod = -1;
      return false;
   }

   m_MAMethod = MAMethod;
   return true;
}

//+------------------------------------------------------------------+

int KeltnerChannel::GetPricePosition(int TimeFrameIndex, int Shift){
   /*
      Outside of Upper Band = 0
      Between Upper Band and MA = 1
      Between Lower Band and MA = 2
      Outside of Lower Band = 3
      On MA = 4
   */

   double kcUpper = GetUpper(TimeFrameIndex, Shift);
   double kcMain = GetMain(TimeFrameIndex, Shift);
   double kcLower = GetLower(TimeFrameIndex, Shift);

   //ResetLastError();

   // get close price 
   double CurrPrice = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift);
   
   if(CurrPrice == 0){
      LogError(__FUNCTION__, "Shift Price invalid. ");
      return 0;
   }

   int position = 0;
   

   // Outside of Upper Band
   if(CurrPrice > kcUpper){
      position = 2;
   }

   // Between Upper & MA
   else if(kcUpper >= CurrPrice && CurrPrice <= kcMain){
      position = 1;
   }

   // Between Lower Band & MA
   else if(kcMain >= CurrPrice && CurrPrice >= kcLower){
      position = -1;
   }

   // Outside of Lower Band
   else if(kcLower > CurrPrice){
      position = -2;
   }


   // to check if it gets the position
   if(position == 0){
     LogError(__FUNCTION__,"Invalid Price position.");
     return 0;
   }


   return position;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double KeltnerChannel::GetKeltnerSize(int TimeFrameIndex, int Shift){
   if(Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid Buffer/Timeframe input." , __FUNCTION__);
      return -1;
   }

   return GetUpper(TimeFrameIndex, Shift) - GetLower(TimeFrameIndex, Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double KeltnerChannel::GetKeltnerMASize(int TimeFrameIndex, int Shift){
   if(Shift < 0 || Shift >=DEFAULT_BUFFER_SIZE || TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid Buffer/Timeframe input." , __FUNCTION__);
      return -1;
   }

   return GetUpper(TimeFrameIndex, Shift) - GetMain(TimeFrameIndex, Shift);
}

//+------------------------------------------------------------------+
