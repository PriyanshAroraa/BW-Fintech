//+------------------------------------------------------------------+
//|                                                    Fibonacci.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\ZigZag.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Fibonacci:public BaseIndicator
  {
private:
   ZigZag            *m_ZigZag;
   
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_FibonacciUp[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][FIBONACCI_LEVELS_SIZE][FIBOACCI_PRICE_LEVELS_SIZE];
   double            m_FibonacciDown[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][FIBONACCI_LEVELS_SIZE][FIBOACCI_PRICE_LEVELS_SIZE];
   
public:
                     Fibonacci(ZigZag *pZigZag);
                    ~Fibonacci();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetUpFibonacci(int TimeFrameIndex,int Shift,double FibonacciLevel);
   double            GetDownFibonacci(int TimeFrameIndex,int Shift,double FibonacciLevel);
   
   double            GetUpFibonacciLimit(int TimeFrameIndex, int Shift, int FibonacciLevelShift, bool isUpperLimit);
   double            GetDownFibonacciLimit(int TimeFrameIndex, int Shift, int FibonacciLevelShift, bool isUpperLimit);


   bool              IsUp(int TimeFrameIndex,int Shift);
   double            IndexToLevel(int LevelIndex);
   double            LevelInDecimalToIndex(int Level);
   
private:
   double            CalculateFibonacciLevel(int TimeFrameIndex,int Shift,bool IsUp,int Level);
   void              CalculateFibonacciUpperLowerLimit(int TimeFrameIndex, int Shift, int FibonacciLevel);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Fibonacci::Fibonacci(ZigZag *pZigZag):BaseIndicator("Fibonacci")
  {
   m_ZigZag = NULL;

   if(pZigZag==NULL)
      LogError(__FUNCTION__,"ZigZag pointer is NULL");
   else
      m_ZigZag=pZigZag;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Fibonacci::~Fibonacci()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fibonacci::Init()
  {

   if(FIBONACCI_LEVELS_SIZE!=ArraySize(FIBONACCI_LEVELS))
     {
      LogError(__FUNCTION__,"Fibonacci levels array out of sync");
      return false;
     }

   for(int t=0; t<ENUM_TIMEFRAMES_ARRAY_SIZE; t++)
     {
      m_Handlers[t] = m_ZigZag.GetZigZagHandlers(t);
     
      for(int i=0; i<DEFAULT_BUFFER_SIZE;i++)
        {
         for(int j=0; j<FIBONACCI_LEVELS_SIZE; j++)
           {
            m_FibonacciUp[t][i][j][0]=CalculateFibonacciLevel(t,i,true,j);
            m_FibonacciDown[t][i][j][0]=CalculateFibonacciLevel(t,i,false,j);

            CalculateFibonacciUpperLowerLimit(t, i, j);
            
           }
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fibonacci::OnUpdate(int TimeFrameIndex,bool IsNewBar)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar)
     {
      for(int i=DEFAULT_BUFFER_SIZE-1; i>0; i--)
        {
         for(int j=0; j<FIBONACCI_LEVELS_SIZE;j++)
           {
            for(int k = 0; k < FIBOACCI_PRICE_LEVELS_SIZE; k++)
            {
               m_FibonacciUp[TimeFrameIndex][i][j][k]=m_FibonacciUp[TimeFrameIndex][i-1][j][k];
               m_FibonacciDown[TimeFrameIndex][i][j][k]=m_FibonacciDown[TimeFrameIndex][i-1][j][k];
            }
           }
        }
     }

   for(int i=0; i<FIBONACCI_LEVELS_SIZE; i++)
     {
      m_FibonacciUp[TimeFrameIndex][0][i][0]=CalculateFibonacciLevel(TimeFrameIndex,0,true,i);
      m_FibonacciDown[TimeFrameIndex][0][i][0]=CalculateFibonacciLevel(TimeFrameIndex,0,false,i);
      
      CalculateFibonacciUpperLowerLimit(TimeFrameIndex, 0, i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::GetUpFibonacci(int TimeFrameIndex,int Shift,double FibonacciLevel)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("TimeFrameIndex = "+(string) TimeFrameIndex+" - Shift = "+(string)Shift+" - FibonacciLevel = "+(string)FibonacciLevel);
      return-1;
     }

   for(int i=0; i<FIBONACCI_LEVELS_SIZE; i++)
     {
      if(Normalize(FibonacciLevel)==Normalize((FIBONACCI_LEVELS[i]*100)))
        {
         return Normalize(m_FibonacciUp[TimeFrameIndex][Shift][i][0]);
        }
     }

   LogError(__FUNCTION__,"Invalid Fibonacci Level.");
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::GetDownFibonacci(int TimeFrameIndex,int Shift,double FibonacciLevel)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("TimeFrameIndex = "+(string) TimeFrameIndex+" - Shift = "+(string)Shift+" - FibonacciLevel = "+(string)FibonacciLevel);
      return-1;
     }

   for(int i=0; i<FIBONACCI_LEVELS_SIZE; i++)
     {
      if(Normalize(FibonacciLevel)==Normalize((FIBONACCI_LEVELS[i]*100)))
        {
         return Normalize(m_FibonacciDown[TimeFrameIndex][Shift][i][0]);
        }
     }

   LogError(__FUNCTION__,"Invalid Fibonacci Level.");
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::GetUpFibonacciLimit(int TimeFrameIndex,int Shift,int FibonacciLevelShift, bool isUpperLimit)
{
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>DEFAULT_BUFFER_SIZE || FibonacciLevelShift < 0 || FibonacciLevelShift >= FIBONACCI_LEVELS_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("TimeFrameIndex = "+(string) TimeFrameIndex+" - Shift = "+(string)Shift+" - FibonacciLevel = "+(string)FibonacciLevelShift);
      return-1;
     }
     
     return isUpperLimit ? m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevelShift][1] : m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevelShift][2];
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::GetDownFibonacciLimit(int TimeFrameIndex,int Shift,int FibonacciLevelShift, bool isUpperLimit)
{
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>DEFAULT_BUFFER_SIZE || FibonacciLevelShift < 0 || FibonacciLevelShift >= FIBONACCI_LEVELS_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("TimeFrameIndex = "+(string) TimeFrameIndex+" - Shift = "+(string)Shift+" - FibonacciLevel = "+(string)FibonacciLevelShift);
      return-1;
     }
     
     return isUpperLimit ? m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevelShift][1] : m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevelShift][2];
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fibonacci::IsUp(int TimeFrameIndex,int Shift)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      printf("TimeFrameIndex = "+(string) TimeFrameIndex+" - Shift = "+(string)Shift);
      return false;
     }

   ENUM_TIMEFRAMES timeFrameEnum=GetTimeFrameENUM(TimeFrameIndex);

   int n=0;
   int i=Shift;
   double highest=0;
   int highestIndex=0;
   double lowest=INT_MAX;
   int lowestIndex=0;
   bool firstVal=true;

   while(n<2)
     {
      double temp=GetZigZag(m_Handlers[TimeFrameIndex], 0, i);
      if(temp>0)
        {
         if(firstVal)
           {
            firstVal=false;
            i++;
            continue;
           }
         if(temp>highest)
           {
            highest=temp;
            highestIndex=n;
           }
         if(temp<lowest)
           {
            lowest=temp;
            lowestIndex=n;
           }
         n+=1;
        }
      i++;
     }

   return highestIndex>lowestIndex;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::IndexToLevel(int LevelIndex)
  {
   if(LevelIndex<0 || LevelIndex>=FIBONACCI_LEVELS_SIZE)
     {
      LogError(__FUNCTION__,"Invalid Fibo Level Index.");
      return -1;
     }

   return FIBONACCI_LEVELS[LevelIndex]*100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::LevelInDecimalToIndex(int Level)
{
   if(Level < FIBONACCI_LEVELS[0] && Level > FIBONACCI_LEVELS[FIBONACCI_LEVELS_SIZE-1])
   {
      LogError(__FUNCTION__, "Fibonacci Price Level is not supported.");
      return -1;
   }
   
   
   for(int i = 0; i < FIBONACCI_LEVELS_SIZE; i++)
   {
      if(FIBONACCI_LEVELS[i] == Level)
         return i;
   }
   
   LogError(__FUNCTION__, "Fibonacci Price Level may not be supported.");
   return -1;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fibonacci::CalculateFibonacciLevel(int TimeFrameIndex,int Shift,bool IsUp,int Level)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || Level<0 || Level>=FIBONACCI_LEVELS_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      return -1;
     }

   ENUM_TIMEFRAMES timeFrameEnum=GetTimeFrameENUM(TimeFrameIndex);

   int n=0;
   int i=Shift;
   double highest=0;
   int highestIndex=0;
   double lowest=INT_MAX;
   int lowestIndex=0;
   bool firstVal = true;

   while(n<2)
     {
      double temp=GetZigZag(m_Handlers[TimeFrameIndex], 0, i);
            
      if(temp>0)
        {
         if(firstVal)
         {
            firstVal=false;
            i++;
            continue;
         }
        
        
         if(temp>highest)
           {
            highest=temp;
            highestIndex=n;
           }
         if(temp<lowest)
           {
            lowest=temp;
            lowestIndex=n;
           }
         n+=1;
        }
      i++;
     }

   double price1=IsUp?highest:lowest;
   double price2=IsUp?lowest:highest;
   double diff=price2-price1;

   return price2-diff*FIBONACCI_LEVELS[Level];
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Fibonacci::CalculateFibonacciUpperLowerLimit(int TimeFrameIndex, int Shift, int FibonacciLevel)
{
   if(TimeFrameIndex<0 || TimeFrameIndex>ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || FibonacciLevel<0 || FibonacciLevel>=FIBONACCI_LEVELS_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      return;
     }
     
    double range = 0;
    
   if(FibonacciLevel > 0)
   {
       // ~ 0.25% Upper and Lower limit from the above
      range = MathAbs(m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][0] - m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel-1][0]) * 0.1;
       
      m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][1] = m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][0] + range;
      m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][2] = m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][0] - range;
   
       
      range = MathAbs(m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][0] - m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel-1][0]) * 0.1;
       
      m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][1] = m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][0] + range;
      m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][2] = m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][0] - range;
   }
   
   else
   {
      m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][1] = 0;
      m_FibonacciUp[TimeFrameIndex][Shift][FibonacciLevel][2] = 0;
   
      m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][1] = 0;
      m_FibonacciDown[TimeFrameIndex][Shift][FibonacciLevel][2] = 0;
   }

} 

//+------------------------------------------------------------------+
