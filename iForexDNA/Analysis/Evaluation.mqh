//+------------------------------------------------------------------+
//|                                                    TradeList.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "..\ExternVariables.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"

class Evaluation{
   private:
      bool        m_IsTesting;
      datetime    m_StartDate;
      datetime    m_EndDate;

      int         m_Month;
      int         m_File;
      double      m_StartingBalance;

      bool        GetPerformanceMetrics();


   public:
                  Evaluation(bool isTesting);
                  ~Evaluation();

      void        OnUpdate();


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Evaluation::Evaluation(bool isTesting)
{
   // set istesting results
   m_IsTesting = isTesting;
   m_StartingBalance = AccountBalance();
   m_StartDate = TimeCurrent();
   m_EndDate = NULL;
   m_File = 0;


   // live results
   m_Month = Month();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Evaluation::~Evaluation(){
   if(m_IsTesting){
      m_EndDate = TimeCurrent();    // get last datetime
      
      if(!GetPerformanceMetrics())
          LogError(__FUNCTION__, "Failed to compile trades. ");

   }

   FileClose(m_File);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Evaluation::OnUpdate(){
   // monthly trade list run 
   if(!m_IsTesting)
   {
      // normal occassion
      if(m_Month != Month()){
         m_EndDate = TimeCurrent();    // set current end time


         if(!GetPerformanceMetrics())
            LogError(__FUNCTION__, "Failed to compile trades. ");

            
         m_Month = Month();
         m_StartDate = m_EndDate;         // update date once done
         m_StartingBalance = AccountBalance();
      }
      
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Evaluation::GetPerformanceMetrics(){
   string fileName = Symbol() + "-" + TimeToString(m_StartDate, TIME_DATE) + "-" + TimeToString(m_EndDate, TIME_DATE) + ".csv";
   m_File = FileOpen(fileName, FILE_READ|FILE_WRITE|FILE_CSV, ",");        // creation of file

   if(m_File == -1){
      int error = GetLastError();
      Print("Error Opening File. ", error);
      return false;
   }

   // write informations of the trades
   FileWrite(m_File, "Open Time", "Close Time", "Type", "Size", "Magic", "Comment", "Open Price", "SL", "TP", "Profit", "Balance");


   double balance = m_IsTesting ? m_StartingBalance : AccountBalance();

   // metrics calculation
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;

      balance+=OrderProfit();


      FileWrite(m_File,
      TimeToStr(OrderOpenTime()), 
      TimeToStr(OrderCloseTime()), 
      (string)OrderType(), 
      (string)OrderLots(), 
      (string)OrderMagicNumber(),
      (string)OrderComment(),
      (string)OrderOpenPrice(), 
      (string)OrderStopLoss(), 
      (string)OrderTakeProfit(), 
      (string)OrderProfit(), 
      (string)balance);
   }


   return true;

}

//+------------------------------------------------------------------+
