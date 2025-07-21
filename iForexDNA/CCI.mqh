//+------------------------------------------------------------------+
//|                                                          CCI.mqh |
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

class CCI:public BaseIndicator{
    private:
        int                     m_Shift;
        int                     m_Period;
        ENUM_APPLIED_PRICE      m_AppliedPrice;
        int                     m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

        double                  m_CCI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_CCIMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_CCIStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


    public:
                                CCI();
                                ~CCI();


        bool                    Init();
        void                    OnUpdate(int TimeFrameIndex, bool IsNewBar);



        double                  GetCCIValue(int TimeFrameIndex, int Shift);
        double                  GetCCIMean(int TimeFrameIndex, int Shift);
        double                  GetCCIStdDev(int TimeFrameIndex, int Shift);
        
        
        double                  CalculateCCI(ENUM_TIMEFRAMES timeFrameENUM, int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_TYPICAL);


    private:
        bool                    SetShift(int Shift);
        bool                    SetPeriod(int CCIPeriod);
        bool                    SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);

        void                    OnUpdateCCIStdDev(int TimeFrameIndex);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CCI::CCI():BaseIndicator("CCI")
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CCI::~CCI()
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CCI::Init(){
    m_Shift = -1;
    m_Period = -1;
    m_AppliedPrice = -1;


    if(!SetShift(DEFAULT_SHIFT)
    || !SetPeriod(CCI_PERIOD)
    || !SetAppliedPrice(CCI_APPLIED_PRICE))
        return false;
    


   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++){      
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handlers[i] = iCCI(Symbol(), timeFrameENUM, m_Period, m_AppliedPrice);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize CCI handlers.");
         return false;
      }
      
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      // calculate MACD
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
        if(j < DEFAULT_BUFFER_SIZE){
            m_CCI[i][j] = GetCCI(m_Handlers[i], j+m_Shift);

            // save into temp Hist Array
            tempArray[j] = m_CCI[i][j];
            continue;
        }
         
        tempArray[j] = GetCCI(m_Handlers[i], j+m_Shift);

      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_CCIMean[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);
         m_CCIStdDev[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);           
      }
      
   }
      
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CCI::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar){
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--)
      {
         m_CCI[TimeFrameIndex][j]=m_CCI[TimeFrameIndex][j-1];
         m_CCIMean[TimeFrameIndex][j]=m_CCIMean[TimeFrameIndex][j-1];
         m_CCIStdDev[TimeFrameIndex][j]=m_CCIStdDev[TimeFrameIndex][j-1];
      }
   }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_CCI[TimeFrameIndex][0]=GetCCI(m_Handlers[TimeFrameIndex], m_Shift);

   OnUpdateCCIStdDev(TimeFrameIndex);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CCI::GetCCIValue(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_CCI[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CCI::GetCCIMean(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_CCIMean[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CCI::GetCCIStdDev(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_CCIStdDev[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CCI::OnUpdateCCIStdDev(int TimeFrameIndex)
{
   double tempArray[DEFAULT_INDICATOR_PERIOD];

   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
   {
      tempArray[i]=m_CCI[TimeFrameIndex][i];
   }
   
   m_CCIMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2);
   m_CCIStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD),2); 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CCI::CalculateCCI(ENUM_TIMEFRAMES timeFrameENUM,int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_TYPICAL)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetCCI(m_Handlers[TimeFrameIndex], Shift);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CCI::SetShift(int Shift)
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

bool CCI::SetPeriod(int CCIPeriod)
  {
   if(CCIPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=CCIPeriod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CCI::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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