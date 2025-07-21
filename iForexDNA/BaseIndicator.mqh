//+------------------------------------------------------------------+
//|                                                BaseIndicator.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\MiscFunc.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BaseIndicator
  {
private:
   string            m_Type;
public:
                     BaseIndicator(const string Type){SetType(Type);};
                    ~BaseIndicator(){};

   virtual bool      Init()=0;
   virtual void      OnUpdate(int TimeFrameIndex,bool IsNewBar)=0;
   
   void              SetType(string Type){if(Type==""){LogError(__FUNCTION__,"Indicator type not init.");} m_Type=Type;};
   string            GetType(){return m_Type;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
