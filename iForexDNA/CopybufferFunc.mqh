//+------------------------------------------------------------------+
//|                                               CopybufferFunc.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include "..\iForexDNA\MiscFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMovingAverage(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create MA handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetADX(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create ADX handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAD(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create AD handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetBands(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create Bands handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double GetATR(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create ATR handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetBullPower(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create BullPower handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetBearPower(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create BearPower handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetCCI(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create CCI handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];


    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetForceIndex(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create ForceIndex handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];

    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIchimoku(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create Ichimoku handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(Shift < 0)
    {
      if(CopyBuffer(handler, mode, Shift, 1, arr) <= 0)
      {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
      }
    }
    
    else if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
       LogError(__FUNCTION__, "Failed to retrieve data from handle...");
       return -1;
    }
    
    ArrayReverse(arr);

    return Shift > 0 ? NormalizeDouble(arr[Shift], _Digits) : NormalizeDouble(arr[0], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMACD(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create MACD handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
    
    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMomentum(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create MoM handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMFI(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create MFI handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetOBV(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create OBV handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);
   
    return NormalizeDouble(arr[Shift], 0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetRSI(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create RSI handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    

    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetRVI(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create RVI handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPSAR(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create PSAR handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }
    
    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSTO(int handler, int mode, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create Stochastic handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];

    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVolume(int handler, int Shift)
{
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create Volume handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, 0, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);
    return NormalizeDouble(arr[Shift], 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double GetZigZag(int handler, int mode, int Shift)
{
    //int handler = iCustom(symbol, timeFrameENUM, "Examples\\ZigZag", depth, deviation, backstep);
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create Zigzag handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);
    return Shift < ArraySize(arr) ? NormalizeDouble(arr[Shift], _Digits) : EMPTY_VALUE;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double GetMTFLine(int handler, int mode, int Shift)
{
    //int handler = iCustom(symbol, timeFrameENUM, "Examples\\Support_and_Resistance", nativeAlert, emailAlert, pushAlert, candle);         // candle = 0 - Current, 1 = Previous
    int buffersize = Shift+1;
    
    // Logging error (Handler issue)
    if(handler == INVALID_HANDLE)
    {
        LogError(__FUNCTION__, "Failed to create S&R handle for timeframe ");
        return -1;
    }
    
    // arr for calculation
    double arr[];
    
    if(CopyBuffer(handler, mode, 0, buffersize, arr) <= 0)
    {
         LogError(__FUNCTION__, "Failed to retrieve data from handle...");
         return -1;
    }

    ArrayReverse(arr);

    return NormalizeDouble(arr[Shift], _Digits);
}
//+------------------------------------------------------------------+
