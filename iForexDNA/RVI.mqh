//+------------------------------------------------------------------+
//|                                                          RVI.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class RVI:public BaseIndicator{
    private:
        int                     m_Shift;
        int                     m_Period;
        int                     m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];


        double                  m_RVIMain[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_RVISignal[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_RVIHist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


        double                  m_RVIMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_RVIStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_RVIHistMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_RVIHistStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


    public:
                                RVI();
                                ~RVI();


        bool                    Init();
        void                    OnUpdate(int TimeFrameIndex, bool IsNewBar);



        double                  GetRVIMain(int TimeFrameIndex, int Shift);
        double                  GetRVISignal(int TimeFrameIndex, int Shift);
        double                  GetRVIHist(int TimeFrameIndex, int Shift);

        double                  GetRVIMean(int TimeFrameIndex, int Shift);
        double                  GetRVIStdDev(int TimeFrameIndex, int Shift);
        
        double                  GetRVIHistMean(int TimeFrameIndex, int Shift);
        double                  GetRVIHistStdDev(int TimeFrameIndex, int Shift);


        double                  CalculateRVISignal(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
        double                  CalculateRVIHist(ENUM_TIMEFRAMES timeFrameENUM, int Shift);

    private:
        bool                    SetShift(int Shift);
        bool                    SetPeriod(int RVIPeriod);

        void                    OnUpdateRVIHistStdDev(int TimeFrameIndex);


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

RVI::RVI():BaseIndicator("RVI"){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

RVI::~RVI(){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool RVI::Init(){
    m_Shift = -1;
    m_Period = -1;


    if(!SetShift(DEFAULT_SHIFT)
    || !SetPeriod(RVI_PERIOD))
        return false;
    


   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++){      
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      double tempMainArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      // Get Handlers
      m_Handler[i] = iRVI(Symbol(), timeFrameENUM, m_Period);

      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize RVI handlers.");
         return false;
      }

      for(int j=0; j<DEFAULT_BUFFER_SIZE*2; j++)
        {
         if(j < DEFAULT_BUFFER_SIZE){
            m_RVIMain[i][j]=GetRVI(m_Handler[i], MODE_MAIN, m_Shift+j);
            m_RVISignal[i][j]=GetRVI(m_Handler[i], MODE_SIGNAL, m_Shift+j);
            m_RVIHist[i][j]=m_RVIMain[i][j] - m_RVISignal[i][j];
            tempArray[j] = m_RVIHist[i][j];
            tempMainArray[j] = m_RVISignal[i][j];
            continue;
         }
         
         double tempMain = GetRVI(m_Handler[i], MODE_MAIN, m_Shift+j);
         double tempSignal =GetRVI(m_Handler[i], MODE_SIGNAL, m_Shift+j);
         tempArray[j]=tempMain-tempSignal;
         tempMainArray[j] = tempSignal;

        }
        
        
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_RVIMean[i][x]=NormalizeDouble(MathMean(tempMainArray, x, DEFAULT_INDICATOR_PERIOD), 2);     
         m_RVIStdDev[i][x]=NormalizeDouble(MathStandardDeviation(tempMainArray, x, DEFAULT_INDICATOR_PERIOD), 2);     
        
         m_RVIHistMean[i][x]= NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);          
         m_RVIHistStdDev[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);  
      }
      
    }
     
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void RVI::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_RVIMain[TimeFrameIndex][j]=m_RVIMain[TimeFrameIndex][j-1];
         m_RVISignal[TimeFrameIndex][j]=m_RVISignal[TimeFrameIndex][j-1];
         m_RVIMean[TimeFrameIndex][j]=m_RVIMean[TimeFrameIndex][j-1];
         m_RVIStdDev[TimeFrameIndex][j]=m_RVIStdDev[TimeFrameIndex][j-1];
         
         m_RVIHist[TimeFrameIndex][j]=m_RVIHist[TimeFrameIndex][j-1];
         m_RVIHistMean[TimeFrameIndex][j]=m_RVIHistMean[TimeFrameIndex][j-1];
         m_RVIHistStdDev[TimeFrameIndex][j]=m_RVIHistStdDev[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_RVIMain[TimeFrameIndex][0]=GetRVI(m_Handler[TimeFrameIndex], MODE_MAIN, m_Shift);
   m_RVISignal[TimeFrameIndex][0]=GetRVI(m_Handler[TimeFrameIndex], MODE_SIGNAL, m_Shift);
   m_RVIHist[TimeFrameIndex][0]= m_RVIMain[TimeFrameIndex][0] - m_RVISignal[TimeFrameIndex][0];
   
   OnUpdateRVIHistStdDev(TimeFrameIndex);
   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RVI::GetRVIMain(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_RVIMain[TimeFrameIndex][Shift];
  }  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVISignal(int TimeFrameIndex, int Shift)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_RVISignal[TimeFrameIndex][Shift];
  }  

//+------------------------------------------------------------------+, 
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVIMean(int TimeFrameIndex, int Shift)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_RVIMean[TimeFrameIndex][Shift];
  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVIStdDev(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE){
      ASSERT("Invalid Function Input...", __FUNCTION__);
      return -1;
   }
   
   return m_RVIStdDev[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVIHist(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE){
      ASSERT("Invalid Function Input...", __FUNCTION__);
      return -1;
   }
   
   return m_RVIHist[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+, 
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVIHistMean(int TimeFrameIndex, int Shift)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_RVIHistMean[TimeFrameIndex][Shift];
  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::GetRVIHistStdDev(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE){
      ASSERT("Invalid Function Input...", __FUNCTION__);
      return -1;
   }
   
   return m_RVIHistStdDev[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void RVI::OnUpdateRVIHistStdDev(int TimeFrameIndex)
{   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   double tempHistArray[DEFAULT_INDICATOR_PERIOD];

   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
   {
      tempArray[i]=m_RVISignal[TimeFrameIndex][i];
      tempHistArray[i]=m_RVIHist[TimeFrameIndex][i];
   }

   m_RVIMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2); 
   m_RVIHistMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD), 2); 
 
   m_RVIStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2); 
   m_RVIHistStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD), 2); 

}

//+------------------------------------------------------------------+, 
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::CalculateRVISignal(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetRVI(m_Handler[TimeFrameIndex], MODE_SIGNAL, Shift);
}

//+------------------------------------------------------------------+ 
//|                                                                  |
//+------------------------------------------------------------------+

double RVI::CalculateRVIHist(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   
   return GetRVI(m_Handler[TimeFrameIndex], MODE_MAIN, Shift) - GetRVI(m_Handler[TimeFrameIndex], MODE_SIGNAL, Shift);
}

//+------------------------------------------------------------------+ 
//|                                                                  |
//+------------------------------------------------------------------+

bool RVI::SetShift(int Shift)
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
bool RVI::SetPeriod(int RVIPeriod)
  {
   if(RVIPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=RVIPeriod;
   return true;
  }
//+------------------------------------------------------------------+