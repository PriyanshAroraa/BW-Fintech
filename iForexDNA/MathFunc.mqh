//+------------------------------------------------------------------+
//|                                                     MathFunc.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include "..\iForexDNA\MiscFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MathMean(double &arr[], int start, int size)
{
   if(start+(size-1) >= ArraySize(arr))
   {
      LogError(__FUNCTION__, "Array Out Of Range");
      return -1;
   }
   
   double mean = 0;
   
   for(int i = start; i < start+size; i++)
      mean+=arr[i];
   
   return mean/size;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MathStandardDeviation(double &arr[], int start, int size)
{
   if(start+(size-1) >= ArraySize(arr))
   {
      LogError(__FUNCTION__, "Array Out Of Range");
      return -1;
   }
   
   //--- calculate mean
   double mean = MathMean(arr, start, size);
   
   //--- calculate standard deviation
   double sdev=0;
   for(int i=0; i<size; i++)
      sdev+=MathPow(arr[i]-mean,2);
   //--- return standard deviation
   return MathSqrt(sdev/(size-1));
}
//+------------------------------------------------------------------+

