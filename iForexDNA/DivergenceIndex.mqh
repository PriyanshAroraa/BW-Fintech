//+------------------------------------------------------------------+
//|                                                   Divergence.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\Enums.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class DivergenceIndex:public BaseIndicator
{
   private:
      struct DivergencePoint 
      {
         double               percent;
         string               divergencecode;               // R-LLHL, R-HHLH, H-HLLL, H-LHHH, C-HHHH, C-LLLL
         int                  divergencetype;               // BULL_DIVERGENCE or BEAR_DIVERGENCE
         datetime             startDatetime;                // Start time of the ZZ point
         datetime             endDatetime;                  // End time of the ZZ point
      };
    
      DivergencePoint               m_BarShiftDivergence[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
   
      IndicatorsHelper              *m_Indicators;
      int                           m_TotalDivergenceIndex;
      
      bool                          CalculateDivergence(int TimeFrameIndex, int Shift);
      bool                          SetTotalDivergenceIndex(int TotalDivergenceIndex);


   public:
                                    DivergenceIndex(IndicatorsHelper *pIndicators);
                                    ~DivergenceIndex();

      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      
      // BarShift Divergence
      double                        GetBarShiftDivergencePercent(int TimeFrameIndex, int Shift){return m_BarShiftDivergence[TimeFrameIndex][Shift].percent;};
      string                        GetBarShiftDivergenceCode(int TimeFrameIndex, int Shift){return m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode;};
      int                           GetBarShiftDivergenceType(int TimeFrameIndex, int Shift){return m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype;};         
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

DivergenceIndex::DivergenceIndex(IndicatorsHelper *pIndicators):BaseIndicator("DivergenenceIndex"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

DivergenceIndex::~DivergenceIndex()
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DivergenceIndex::Init()
{
   if(!SetTotalDivergenceIndex(TOTAL_DIVERGENCE_INDEX))
      return false;

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      for(int j = 0; j < INDEXES_BUFFER_SIZE; j++)
         CalculateDivergence(i, j);
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DivergenceIndex::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{ 
   // New ZigZag Formed
   if(m_BarShiftDivergence[TimeFrameIndex][0].startDatetime != m_Indicators.GetZigZag().GetZigZagDateTime(TimeFrameIndex, 0))
   {
      for(int i=INDEXES_BUFFER_SIZE-1 ; i >= 0; i--)
         CalculateDivergence(TimeFrameIndex, i);
   }
   
   else if(IsNewBar)
   {
      for(int i=INDEXES_BUFFER_SIZE-1; i > 0; i--)
         m_BarShiftDivergence[TimeFrameIndex][i]=m_BarShiftDivergence[TimeFrameIndex][i-1];
   }
   
   // On Update calculation
   CalculateDivergence(TimeFrameIndex, 0);          
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DivergenceIndex::CalculateDivergence(int TimeFrameIndex,int Shift)
{
   string MarketStructure="";
   int startingshift=0, endingshift=0;
   double startingprice=0, endingprice=0;
   char endingtrend='0';
         

   int zzshift = m_Indicators.GetZigZag().GetNearestZigZagShiftFromBarShift(TimeFrameIndex, Shift);
       
   startingshift = m_Indicators.GetZigZag().GetZigZagShift(TimeFrameIndex, zzshift);
   endingshift = m_Indicators.GetZigZag().GetZigZagShift(TimeFrameIndex, zzshift + 2);
       
   startingprice = m_Indicators.GetZigZag().GetZigZagPrice(TimeFrameIndex, zzshift);
   endingprice = m_Indicators.GetZigZag().GetZigZagPrice(TimeFrameIndex, zzshift + 2);
      
   endingtrend = endingprice > 0 ? 'H' : 'L';
         

   if(endingtrend == 'H')
   {         
      if(startingprice>endingprice)
         MarketStructure="HH";
         
      else if(startingprice<endingprice)
         MarketStructure="LH";      
   }

   else
   {
      if(startingprice>endingprice)
         MarketStructure="HL";
         
      else if(startingprice<endingprice)
         MarketStructure="LL";
   }

   if(MarketStructure=="")
      return false;



   // Divergence utils
   ENUM_APPLIED_PRICE appliedprice = MarketStructure[1]=='H' ? PRICE_HIGH : PRICE_LOW;
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   double BullDivergence = 0, BearDivergence = 0, BullHiddenDivergence = 0, BearHiddenDivergence = 0;
   double firstIndicatorPoint=0, secondIndicatorPoint=0;


   m_BarShiftDivergence[TimeFrameIndex][Shift].startDatetime=m_Indicators.GetZigZag().GetZigZagDateTime(TimeFrameIndex, zzshift);
   m_BarShiftDivergence[TimeFrameIndex][Shift].endDatetime=m_Indicators.GetZigZag().GetZigZagDateTime(TimeFrameIndex, zzshift+2);

   // MOM
   firstIndicatorPoint = m_Indicators.GetMomentum().CalculateMomentum(timeFrameENUM, startingshift, appliedprice);
   secondIndicatorPoint = m_Indicators.GetMomentum().CalculateMomentum(timeFrameENUM, endingshift, appliedprice);

      
   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;    
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }


   // FORCE INDEX
   firstIndicatorPoint = m_Indicators.GetForceIndex().CalculateForceIndex(timeFrameENUM, startingshift, appliedprice);
   secondIndicatorPoint = m_Indicators.GetForceIndex().CalculateForceIndex(timeFrameENUM, endingshift, appliedprice);

   
   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   } 
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }


   // MFI
   firstIndicatorPoint = startingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetMoneyFlow().GetMFIValue(TimeFrameIndex, startingshift) : m_Indicators.GetMoneyFlow().CalculateMFI(timeFrameENUM, startingshift);
   secondIndicatorPoint = endingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetMoneyFlow().GetMFIValue(TimeFrameIndex, endingshift) : m_Indicators.GetMoneyFlow().CalculateMFI(timeFrameENUM, endingshift);



   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }

   // CCI
   firstIndicatorPoint = m_Indicators.GetCCI().CalculateCCI(timeFrameENUM, startingshift, appliedprice);
   secondIndicatorPoint = m_Indicators.GetCCI().CalculateCCI(timeFrameENUM, endingshift, appliedprice);

  
   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }


   // AD
   firstIndicatorPoint = startingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetAccumulation().GetADValue(TimeFrameIndex, startingshift) : m_Indicators.GetAccumulation().CalculateAD(timeFrameENUM, startingshift);
   secondIndicatorPoint = endingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetAccumulation().GetADValue(TimeFrameIndex, endingshift)  : m_Indicators.GetAccumulation().CalculateAD(timeFrameENUM, endingshift);

   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }



   // Volume
   firstIndicatorPoint = startingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetVolumeIndicator().GetVolumeValue(TimeFrameIndex, startingshift) : m_Indicators.GetVolumeIndicator().CalculateVolume(timeFrameENUM, startingshift);
   secondIndicatorPoint = endingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetVolumeIndicator().GetVolumeValue(TimeFrameIndex, endingshift) : m_Indicators.GetVolumeIndicator().CalculateVolume(timeFrameENUM, endingshift); 
  

   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }



   // RSI
   firstIndicatorPoint = m_Indicators.GetRSI().CalculateRSI(timeFrameENUM, startingshift, appliedprice);
   secondIndicatorPoint = m_Indicators.GetRSI().CalculateRSI(timeFrameENUM, endingshift, appliedprice);



   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }


   // STOCHASTIC
   firstIndicatorPoint = startingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSTO().GetSignal(TimeFrameIndex, startingshift):m_Indicators.GetSTO().CalculateSignal(timeFrameENUM, startingshift);
   secondIndicatorPoint = endingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetSTO().GetSignal(TimeFrameIndex, endingshift):m_Indicators.GetSTO().CalculateSignal(timeFrameENUM, endingshift);


   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }


   // RVI
   firstIndicatorPoint = startingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetRVI().GetRVISignal(TimeFrameIndex, startingshift) : m_Indicators.GetRVI().CalculateRVISignal(timeFrameENUM, startingshift);
   secondIndicatorPoint = endingshift < DEFAULT_BUFFER_SIZE ? m_Indicators.GetRVI().GetRVISignal(TimeFrameIndex, endingshift) : m_Indicators.GetRVI().CalculateRVISignal(timeFrameENUM, endingshift);
  
  
   if(MarketStructure == "LL" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BullDivergence++;
   }
   else if(MarketStructure == "HH" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BearDivergence++;
   }
   else if(MarketStructure == "HL" && firstIndicatorPoint < secondIndicatorPoint)
   {
      BullHiddenDivergence++;
   }
   else if(MarketStructure == "LH" && firstIndicatorPoint > secondIndicatorPoint)
   {
      BearHiddenDivergence++;
   }
   
   
   // evaluate results
   if (BullDivergence > 0) 
   {
      m_BarShiftDivergence[TimeFrameIndex][Shift].percent = NormalizeDouble((BullDivergence/(double)m_TotalDivergenceIndex)*100, 2);
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode = "R-LLHL";
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BULL_DIVERGENCE;
   }
   
   else if (BearDivergence > 0)
   {  

      m_BarShiftDivergence[TimeFrameIndex][Shift].percent = NormalizeDouble((BearDivergence/(double)m_TotalDivergenceIndex)*100, 2);
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode = "R-HHLH";
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BEAR_DIVERGENCE;

   } 
   
   else if (BullHiddenDivergence > 0)
   {
      m_BarShiftDivergence[TimeFrameIndex][Shift].percent = NormalizeDouble((BullHiddenDivergence/(double)m_TotalDivergenceIndex)*100, 2);
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode = "H-HLLL";
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BULL_DIVERGENCE;
   } 
   
   else if (BearHiddenDivergence > 0)
   {
      m_BarShiftDivergence[TimeFrameIndex][Shift].percent = NormalizeDouble((BearHiddenDivergence/(double)m_TotalDivergenceIndex)*100, 2);
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode = "H-LHHH";
      m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BEAR_DIVERGENCE;
   }
   
   else
   {
      m_BarShiftDivergence[TimeFrameIndex][Shift].percent=100;
         
      if(MarketStructure == "LL" || MarketStructure == "HL" )
      {
         m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode ="C-HHHH";
         m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BULL_DIVERGENCE;
      }   
         
      else
      {
         m_BarShiftDivergence[TimeFrameIndex][Shift].divergencecode = "C-LLLL";
         m_BarShiftDivergence[TimeFrameIndex][Shift].divergencetype = BEAR_DIVERGENCE;
      }
   }
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DivergenceIndex::SetTotalDivergenceIndex(int TotalDivergenceIndex)
{
   if(TotalDivergenceIndex<0)
     {
      LogError(__FUNCTION__,"Invalid Total Divergence Indicator Index input.");
      m_TotalDivergenceIndex=0;
      return false;
     }

   m_TotalDivergenceIndex=TotalDivergenceIndex;
   return true;
}

//+------------------------------------------------------------------+