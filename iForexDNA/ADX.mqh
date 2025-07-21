//+------------------------------------------------------------------+
//|                                                          ADX.mqh |
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
#include "..\iForexDNA\MathFunc.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ADX:public BaseIndicator
  {
private:
   int               m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int               m_Shift;
   int               m_Period;
   int               m_AppliedPrice;
   ENUM_MA_METHOD    m_MAMethod;
   
   
   
   double            m_DMI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_DMIMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];            
   double            m_DMIStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


   double            m_PlusDI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_MinusDI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   
   double            m_DIHist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_MeanDIHist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_StdDevDIHist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   
public:
                     ADX();
                    ~ADX();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetDMI(int TimeFrameIndex,int Shift){return m_DMI[TimeFrameIndex][Shift];};
   double            GetDMIMean(int TimeFrameIndex, int Shift){return m_DMIMean[TimeFrameIndex][Shift];};
   double            GetDMIStdDev(int TimeFrameIndex, int Shift){return m_DMIStdDev[TimeFrameIndex][Shift];};
   double            GetDMIStdDevPosition(int TimeFrameIndex, int Shift);
   
   double            GetPlusDI(int TimeFrameIndex,int Shift);
   double            GetMinusDI(int TimeFrameIndex,int Shift);
   double            GetDIHist(int TimeFrameIndex, int Shift);
   double            GetDIMean(int TimeFrameIndex, int Shift){return m_MeanDIHist[TimeFrameIndex][Shift];};
   double            GetDIStdDev(int TimeFrameIndex, int Shift){return m_StdDevDIHist[TimeFrameIndex][Shift];};
   double            GetDIStdDevPosition(int TimeFrameIndex, int Shift);

   bool              GetPlusDICross(int TimeFrameIndex, int Shift);
   bool              GetMinusDICross(int TimeFrameIndex, int Shift);


   double            CalculateDMI(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateDIHist(ENUM_TIMEFRAMES timeFrameENUM, int Shift);

  
private:
   bool              SetShift(int Shift);
   bool              SetPeriod(int ADXPeriod);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
   bool              SetMAPeriod(int MAPeriod);
   bool              SetMAMethod(ENUM_MA_METHOD MAMethod);

   
   void              OnUpdateMeanStdDev(int TimeFrameIndex);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ADX::ADX():BaseIndicator("ADX")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ADX::~ADX()
  {
      ArrayRemove(m_DMI,0);
      ArrayRemove(m_PlusDI,0);
      ArrayRemove(m_MinusDI,0);
      ArrayRemove(m_DMIMean,0);
      ArrayRemove(m_DMIStdDev,0);
      ArrayRemove(m_DIHist,0);
      ArrayRemove(m_MeanDIHist,0);
      ArrayRemove(m_StdDevDIHist,0);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ADX::Init(){
   m_Shift=-1;
   m_Period=-1;
   m_AppliedPrice=-1;

   if(
      !SetShift(DEFAULT_SHIFT)
      || !SetPeriod(ADX_PERIOD)
      || !SetAppliedPrice(APPLIED_PRICE)
      )
      return false;
    

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
   
      // Initializing handlers
      m_Handler[i] = iADX(Symbol(), timeFrameENUM, m_Period);
      
      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize ADX handlers.");
         return false;
      }
      
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      double tempDIHist[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++)
      {
         if(j < DEFAULT_BUFFER_SIZE){
            m_DMI[i][j]=GetADX(m_Handler[i], MODE_MAIN, m_Shift+j);
            m_PlusDI[i][j]=GetADX(m_Handler[i], MODE_PLUSDI, m_Shift+j);
            m_MinusDI[i][j]=GetADX(m_Handler[i], MODE_MINUSDI, m_Shift+j);
            m_DIHist[i][j]=NormalizeDouble(m_PlusDI[i][j]-m_MinusDI[i][j], 2);
                        
            tempArray[j] = m_DMI[i][j];
            tempDIHist[j] = m_DIHist[i][j];
            continue;         
         }
         
         tempArray[j] = GetADX(m_Handler[i], MODE_MAIN, m_Shift+j);
         tempDIHist[j] = NormalizeDouble(GetADX(m_Handler[i], MODE_PLUSDI, m_Shift+j) - GetADX(m_Handler[i], MODE_MINUSDI, m_Shift+j), 2);   
         
      }   
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_DMIMean[i][x]=MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD);
         m_MeanDIHist[i][x]=MathMean(tempDIHist, x, DEFAULT_INDICATOR_PERIOD); 
 
         m_DMIStdDev[i][x]=MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD);
         m_StdDevDIHist[i][x]=MathStandardDeviation(tempDIHist, x, DEFAULT_INDICATOR_PERIOD);
      }
   
   }
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ADX::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar)
   {
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--){
         m_DMI[TimeFrameIndex][j]=m_DMI[TimeFrameIndex][j-1];
         m_DMIMean[TimeFrameIndex][j]=m_DMIMean[TimeFrameIndex][j-1];
         m_DMIStdDev[TimeFrameIndex][j]=m_DMIStdDev[TimeFrameIndex][j-1];
         
         m_PlusDI[TimeFrameIndex][j]=m_PlusDI[TimeFrameIndex][j-1];
         m_MinusDI[TimeFrameIndex][j]=m_MinusDI[TimeFrameIndex][j-1];
         m_DIHist[TimeFrameIndex][j]=m_DIHist[TimeFrameIndex][j-1];
         m_MeanDIHist[TimeFrameIndex][j]=m_MeanDIHist[TimeFrameIndex][j-1];
         m_StdDevDIHist[TimeFrameIndex][j]=m_StdDevDIHist[TimeFrameIndex][j-1];

      }
   }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_DMI[TimeFrameIndex][0]=GetADX(m_Handler[TimeFrameIndex], MODE_MAIN, 0);
   m_PlusDI[TimeFrameIndex][0]=GetADX(m_Handler[TimeFrameIndex], MODE_PLUSDI, 0);
   m_MinusDI[TimeFrameIndex][0]=GetADX(m_Handler[TimeFrameIndex], MODE_MINUSDI, 0);
   m_DIHist[TimeFrameIndex][0]=m_PlusDI[TimeFrameIndex][0]-m_MinusDI[TimeFrameIndex][0];
  
   OnUpdateMeanStdDev(TimeFrameIndex);
   
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ADX::GetPlusDICross(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift+1>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      ASSERT("Invalid function input",__FUNCTION__);
      return false;
   }
   
   if(m_PlusDI[TimeFrameIndex][Shift] > m_MinusDI[TimeFrameIndex][Shift]
   && m_PlusDI[TimeFrameIndex][Shift+1] <= m_MinusDI[TimeFrameIndex][Shift+1]
   )
      return true;
   
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  
bool ADX::GetMinusDICross(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift+1>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      ASSERT("Invalid function input",__FUNCTION__);
      return false;
   }
   
   if(m_PlusDI[TimeFrameIndex][Shift] < m_MinusDI[TimeFrameIndex][Shift]
   && m_PlusDI[TimeFrameIndex][Shift+1] >= m_MinusDI[TimeFrameIndex][Shift+1]
   )
      return true;
   
   
   return false;
   
} 
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ADX::SetShift(int Shift)
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

bool ADX::SetPeriod(int ADXPeriod)
  {
   if(ADXPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=ADXPeriod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ADX::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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
double ADX::GetPlusDI(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_PlusDI[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ADX::GetMinusDI(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_MinusDI[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ADX::GetDIHist(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_DIHist[TimeFrameIndex][Shift];

   return res;
  
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ADX::GetDMIStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_DMIStdDev[TimeFrameIndex][Shift] != 0 ? (m_DMI[TimeFrameIndex][Shift] - m_DMIMean[TimeFrameIndex][Shift])/m_DMIStdDev[TimeFrameIndex][Shift] : 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ADX::GetDIStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevDIHist[TimeFrameIndex][Shift] != 0 ? (m_DIHist[TimeFrameIndex][Shift] - m_MeanDIHist[TimeFrameIndex][Shift])/m_StdDevDIHist[TimeFrameIndex][Shift] : 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ADX::OnUpdateMeanStdDev(int TimeFrameIndex)
{
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   double tempHistArray[DEFAULT_INDICATOR_PERIOD];

   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
   {
      tempArray[i]=m_DMI[TimeFrameIndex][i];
      tempHistArray[i]=m_DIHist[TimeFrameIndex][i];
   }

   m_DMIMean[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);
   m_MeanDIHist[TimeFrameIndex][0]=MathMean(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD); 
 
   m_DMIStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD);
   m_StdDevDIHist[TimeFrameIndex][0]=MathStandardDeviation(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ADX::CalculateDIHist(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return (GetADX(m_Handler[TimeFrameIndex], MODE_PLUSDI, Shift) - GetADX(m_Handler[TimeFrameIndex], MODE_MINUSDI, Shift));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ADX::CalculateDMI(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return GetADX(m_Handler[TimeFrameIndex], MODE_MAIN, Shift);

}

//+------------------------------------------------------------------+
