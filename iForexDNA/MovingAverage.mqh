//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"

//+------------------------------------------------------------------+
//|       Edit by Mohan                                              |
//+------------------------------------------------------------------+

class MovingAverage:public BaseIndicator
  {

private:
   int               m_FastHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int               m_MediumHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int               m_SlowHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int               m_MoneyHandler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
   int               m_Shift;
   int               m_FastPeriod;
   int               m_MediumPeriod;
   int               m_SlowPeriod;
   int               m_MoneyLinePeriod;

   ENUM_APPLIED_PRICE m_AppliedPrice;
   ENUM_MA_METHOD    m_Method;



   double            m_MoneyLine[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Fast[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Medium[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Slow[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

   

public:
                     MovingAverage();
                    ~MovingAverage();



   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);



   double            GetFastMA(int TimeFrameIndex,int Shift);
   double            GetMediumMA(int TimeFrameIndex,int Shift);
   double            GetSlowMA(int TimeFrameIndex,int Shift);
   double            GetMoneyLineMA(int TimeFrameIndex,int Shift);



private:

   bool              SetShift(int Shift);
   bool              SetFastPeriod(int FastPeriod);
   bool              SetMediumPeriod(int MediumPeriod);
   bool              SetSlowPeriod(int SlowPeriod);
   bool              Set100MAPeriod(int MA100Period);
   bool              SetMoneyLinePeriod(int MoneyLinePeriod);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
   bool              SetMethod(ENUM_MA_METHOD Method);


  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MovingAverage::MovingAverage():BaseIndicator("MovingAverage")
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MovingAverage::~MovingAverage()
  {
      ArrayRemove(m_Fast, 0);
      ArrayRemove(m_Medium, 0);
      ArrayRemove(m_Slow, 0);
      ArrayRemove(m_MoneyLine, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::Init()
  {
   m_Shift=-1;
   m_FastPeriod=-1;
   m_MediumPeriod=-1;
   m_SlowPeriod=-1;
   m_MoneyLinePeriod=-1;
   m_AppliedPrice=-1;
   m_Method=-1;



   if(!SetShift(DEFAULT_SHIFT)
      || !SetFastPeriod(MA_FAST_PERIOD)
      || !SetMediumPeriod(MA_MEDIUM_PERIOD)
      || !SetSlowPeriod(MA_SLOW_PERIOD)
      || !SetMoneyLinePeriod(MA_MONEY_LINE_PERIOD)
      || !SetAppliedPrice(APPLIED_PRICE)
      || !SetMethod(APPLIED_PRICE_METHOD))
      return false;

   // utils
   string symbol = Symbol();

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
      
      
      m_FastHandler[i] = iMA(symbol, timeFrameENUM, m_FastPeriod, m_Shift, m_Method, m_AppliedPrice);
      m_MediumHandler[i] = iMA(symbol, timeFrameENUM, m_MediumPeriod, m_Shift, m_Method, m_AppliedPrice);
      m_SlowHandler[i] = iMA(symbol, timeFrameENUM, m_SlowPeriod, m_Shift, m_Method, m_AppliedPrice);
      m_MoneyHandler[i] = iMA(symbol, timeFrameENUM, m_MoneyLinePeriod, m_Shift, m_Method, m_AppliedPrice);

      if(m_FastHandler[i] == INVALID_HANDLE || m_MediumHandler[i] == INVALID_HANDLE
      || m_SlowHandler[i] == INVALID_HANDLE || m_MoneyHandler[i] == INVALID_HANDLE
      )
      {
         LogError(__FUNCTION__, "Failed to initialize MA handlers.");
         return false;
      }


      for(int j = 0; j < DEFAULT_BUFFER_SIZE; j++)
      {
         m_Fast[i][j]=GetMovingAverage(m_FastHandler[i],j+m_Shift);
         m_Medium[i][j]=GetMovingAverage(m_MediumHandler[i],j+m_Shift);
         m_Slow[i][j]=GetMovingAverage(m_SlowHandler[i],j+m_Shift);
         m_MoneyLine[i][j]=GetMovingAverage(m_MoneyHandler[i],j+m_Shift); 
      }
   }
   
   return true;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MovingAverage::OnUpdate(int TimeFrameIndex,bool IsNewBar)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar)
     {
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--)
        {
         m_Fast[TimeFrameIndex][j]=m_Fast[TimeFrameIndex][j-1];
         m_Medium[TimeFrameIndex][j]=m_Medium[TimeFrameIndex][j-1];
         m_Slow[TimeFrameIndex][j]=m_Slow[TimeFrameIndex][j-1];
         m_MoneyLine[TimeFrameIndex][j]=m_MoneyLine[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);


   m_Fast[TimeFrameIndex][0]=GetMovingAverage(m_FastHandler[TimeFrameIndex], 0);
   m_Medium[TimeFrameIndex][0]=GetMovingAverage(m_MediumHandler[TimeFrameIndex], 0);
   m_Slow[TimeFrameIndex][0]=GetMovingAverage(m_SlowHandler[TimeFrameIndex], 0);
   m_MoneyLine[TimeFrameIndex][0]=GetMovingAverage(m_MoneyHandler[TimeFrameIndex], 0);
   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MovingAverage::GetFastMA(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }



   double res=m_Fast[TimeFrameIndex][Shift];

   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MovingAverage::GetMediumMA(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Medium[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MovingAverage::GetSlowMA(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Slow[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MovingAverage::GetMoneyLineMA(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }



   double res=m_MoneyLine[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



bool MovingAverage::SetShift(int Shift)
  {
   if(Shift<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Shift=-1;
      return false;
     }

   m_Shift=Shift;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetFastPeriod(int FastPeriod)
  {
   if(FastPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_FastPeriod=-1;
      return false;
     }

   m_FastPeriod=FastPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetMediumPeriod(int MediumPeriod)
  {
   if(MediumPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_MediumPeriod=-1;
      return false;
     }

   m_MediumPeriod=MediumPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetSlowPeriod(int SlowPeriod)
  {
   if(SlowPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_SlowPeriod=-1;
      return false;
     }

   m_SlowPeriod=SlowPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetMoneyLinePeriod(int MoneyLinePeriod)
  {
   if(MoneyLinePeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_MoneyLinePeriod=-1;
      return false;
     }

   m_MoneyLinePeriod=MoneyLinePeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
  {
   if(AppliedPrice<0 || AppliedPrice>6)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_AppliedPrice=-1;
      return false;
     }

   m_AppliedPrice=AppliedPrice;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MovingAverage::SetMethod(ENUM_MA_METHOD Method)
  {
   if(Method<0 || Method>3)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Method=-1;
      return false;
     }


   m_Method=Method;
   return true;
  }

//+------------------------------------------------------------------+