//+------------------------------------------------------------------+
//|                                                          SAR.mqh |
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
//|                                                                  |
//+------------------------------------------------------------------+
class SAR:public BaseIndicator
  {
private:
   int               m_Shift;
   double            m_Step;
   double            m_Maximum;
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_Sar[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
public:
                     SAR();
                    ~SAR();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetSar(int TimeFrameIndex,int Shift);
   double            CalculateSar(ENUM_TIMEFRAMES timeFrameENUM, int Shift);

   int               GetSARHandler(int TimeFrameIndex){return m_Handlers[TimeFrameIndex];};

private:
   bool              SetShift(int Shift);
   bool              SetStep(double Step);
   bool              SetMaximum(double Maximum);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SAR::SAR():BaseIndicator("SAR")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SAR::~SAR()
  {
      ArrayRemove(m_Sar, 0);
  }
//+------------------------------------------------------------------+
bool SAR::Init()
  {
   m_Shift=-1;
   m_Step=-1;
   m_Maximum=-1;

   if(!SetShift(SAR_SHIFT) || !SetStep(SAR_STEP) || !SetMaximum(SAR_MAXIMUM))
      return false;

   ArrayInitialize(m_Sar,-1);

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
      
      m_Handlers[i] = iSAR(Symbol(), timeFrameENUM, m_Step, m_Maximum);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize SAR handlers.");
         return false;
      }
      
      for(int j=DEFAULT_BUFFER_SIZE-1; j>=m_Shift; j--)
         m_Sar[i][j]=GetPSAR(m_Handlers[i], j);
     }
     
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SAR::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_Sar[TimeFrameIndex][j]=m_Sar[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_Sar[TimeFrameIndex][0]=GetPSAR(m_Handlers[TimeFrameIndex], 0);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SAR::GetSar(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Sar[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double SAR::CalculateSar(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetPSAR(m_Handlers[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SAR::SetShift(int Shift)
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
bool SAR::SetStep(double Step)
  {
   if(Step<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Step=-1;
      return false;
     }

   m_Step=Step;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SAR::SetMaximum(double Maximum)
  {
   if(Maximum<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Maximum=-1;
      return false;
     }

   m_Maximum=Maximum;
   return true;
  }
//+------------------------------------------------------------------+
