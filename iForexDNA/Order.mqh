//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#include "..\iForexDNA\MiscFunc.mqh"


#include <Trade\PositionInfo.mqh>
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
private:
   int               m_Ticket;
   int               m_Type;
   double            m_OpenPrice;
   double            m_OpenBidPrice;
   double            m_OpenAskPrice;
   double            m_StopLoss;
   double            m_TakeProfit;
   double            m_HiddenTakeProfit;
   double            m_Lots;
   int               m_MagicNumber;
   string            m_Comment;
   datetime          m_OpenDateTime;
   datetime          m_OpenOrderDateTime;
   datetime          m_ExpirationDateTime;
   datetime          m_LastUpdateDateTime;
   string            m_Symbol;
   ENUM_TIMEFRAMES   m_TimeFrame;
   int               m_LastOrderError;
   
   double            m_MaxProfit;
   double            m_MinProfit;
   
   double            m_BreakEvenPrice;   
   double            m_TriggerPrice;

   double            m_Commission;
   double            m_Swap;
   double            m_PricePerPip;   
   
   bool              m_IsPartialClosed;

public:
                     Order(
                                             int      ticket,              // ticket number
                                             string   symbol,              // symbol 
                                             int      cmd,                 // operation 
                                             double   volume,              // volume 
                                             double   price,               // price 
                                             int      slippage,            // slippage 
                                             double   stoploss,            // stop loss 
                                             double   takeprofit,          // take profit
                                             datetime opendatetime,        // open order time 
                                             string   comment,             // comment                                              
                                             int      magicnumber,       // magic number 
                                             datetime expiration=0,        // pending order expiration 
                                             color    arrow_color=clrNONE  // color 
                                             );
                    ~Order();

   void              OnUpdate();

   bool              ModifyStopLoss(double NewStopLoss, string StopLossComment);
   bool              ModifyTakeProfit(double NewTakeProfit);
   bool              ModifyTriggerPrice(double TriggerPrice);
   bool              ModifyOpenPrice(double NewOpenPrice);
   double            GetProfit();
   double            GetLockedProfit();
   double            GetLockedProfitInPercentage();
   double            GetMaxProfit(){return m_MaxProfit;};
   double            GetMinProfit(){return m_MinProfit;};
   
   int               GetTicket(){return m_Ticket;};
   int               GetType(){return m_Type;};
   double            GetOpenPrice(){return m_OpenPrice;};
   double            GetOpenBidPrice(){return m_OpenBidPrice;};
   double            GetOpenAskPrice(){return m_OpenAskPrice;};
   
   double            GetStopLoss(){return m_StopLoss;};
   double            GetTakeProfit(){return m_TakeProfit;};
   double            GetHiddenTakeProfit(){return m_HiddenTakeProfit;};
   double            GetLots(){return m_Lots;};
   int               GetMagicNumber(){return m_MagicNumber;};
   string            GetComment(){return m_Comment;};
   datetime          GetOpenDateTime(){return m_OpenDateTime;};
   datetime          GetOpenOrderDateTime(){return m_OpenOrderDateTime;};
   datetime          GetLastUpdateDateTime(){return m_LastUpdateDateTime;};
   datetime          GetExpirationDateTime(){return m_ExpirationDateTime;};
   string            GetSymbol(){return m_Symbol;};
   ENUM_TIMEFRAMES   GetTimeFrame(){return m_TimeFrame;};
   double            GetCommission(){return m_Commission;};
   double            GetSwap(){return m_Swap;};
   double            GetBreakEvenPrice(){return m_BreakEvenPrice;};
   double            GetTriggerPrice(){return m_TriggerPrice;};
   
   bool              GetIsPartialClosed(){return m_IsPartialClosed;};



   // shared Setter method
   void              SetFrenzyStopLoss(double StopLoss);
   void              SetMagicNumber(int MagicNumber);
   void              SetLastUpdateDateTime(datetime DateTime);
   void              SetIsPartialClosed(bool PartialClosed){m_IsPartialClosed=PartialClosed;};


private:  

   void              SetTicket(int Ticket);
   void              SetType(int Type);
   void              SetOpenPrice(double OpenPrice);
   void              SetOpenAskPrice(double OpenAskPrice);
   void              SetOpenBidPrice(double OpenBidPrice);
   void              SetStopLoss(double StopLoss);
   void              SetTakeProfit(double TakeProfit);
   void              SetHiddenTakeProfit(double TakeProfit);
   void              SetLots(double Lots);
   void              SetComment(string CommentStr);
   void              SetOpenDateTime(datetime OpenDateTime);
   void              SetOpenOrderDateTime(datetime OpenOrderDateTime);
   void              SetExpirationDateTime(datetime ExpirationDateTime);
   void              SetSymbol(string SymbolStr);
   void              SetTimeFrame(ENUM_TIMEFRAMES TimeFrame);
   void              SetCommission(double Commission);
   void              SetSwap(double Swap);
   void              SetBreakEvenPrice(double BreakEvenPrice);   
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(int ticket,string symbol,int cmd,double volume,double price,int slippage,double stoploss,double takeprofit,datetime opendatetime,string comment=NULL,int magic=0,datetime expiration=0,color arrow_color=clrNONE)
  {
   SetTicket(ticket);
   SetSymbol(symbol);
   SetType(cmd);
   SetLots(volume);
   SetOpenPrice(price);
   SetStopLoss(stoploss);
   SetTakeProfit(takeprofit);
   SetOpenDateTime(opendatetime);
   SetComment(comment);
   SetMagicNumber(magic);
   SetExpirationDateTime(expiration);
   m_OpenOrderDateTime = iTime(Symbol(), PERIOD_M15, 0);
   SetLastUpdateDateTime(iTime(Symbol(), PERIOD_M1, 0));
   m_MaxProfit=0;
   m_MinProfit=0;
   m_TriggerPrice = 0;
   m_IsPartialClosed = false;
   
   m_PricePerPip = GetPricePerPip(m_Symbol, m_Lots);  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::~Order()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order::OnUpdate()
  {
   OrderSelectByTicket(GetTicket());
   SetStopLoss(PositionGetDouble(POSITION_SL));
   SetTakeProfit(PositionGetDouble(POSITION_TP));
   SetOpenPrice(PositionGetDouble(POSITION_PRICE_OPEN));
      
   double currentProfit=GetProfit();
   
   if(m_MaxProfit<currentProfit)
      m_MaxProfit=currentProfit;
      
   if(m_MinProfit>currentProfit)
      m_MinProfit=currentProfit;

   SetCommission(PositionGetDouble(POSITION_COMMISSION));
   SetSwap(PositionGetDouble(POSITION_SWAP));
   if(m_Type % 2 ==0)
      m_BreakEvenPrice = NormalizeDouble(m_OpenPrice + ((m_Commission+m_Swap)/m_PricePerPip)/MathPow(10, _Digits-1), _Digits);
   else
      m_BreakEvenPrice = NormalizeDouble(m_OpenPrice - ((m_Commission+m_Swap)/m_PricePerPip)/MathPow(10, _Digits-1), _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::ModifyStopLoss(double NewStopLoss, string StopLossComment)
  {  
   ResetLastError();
  
   MqlTradeRequest trade_request;
   MqlTradeResult trade_result;
   ZeroMemory(trade_request);
   ZeroMemory(trade_result);
     
   double oldStopLoss=GetStopLoss();

   if(NewStopLoss==oldStopLoss || NewStopLoss <= 0)
      return false;
   
   ResetLastError();
   
   long stopLevel = SymbolInfoInteger(m_Symbol, SYMBOL_TRADE_STOPS_LEVEL);

   NewStopLoss = m_Type % 2 == 0 ? NewStopLoss += stopLevel*_Point : NewStopLoss -= stopLevel*_Point;
   
   if(m_Type % 2 == 0 && NewStopLoss >= SymbolInfoDouble(m_Symbol, SYMBOL_BID))
      return false;
   else if(m_Type % 2 == 1 && NewStopLoss <= SymbolInfoDouble(m_Symbol, SYMBOL_ASK))
      return false;


   //--- setting request
   trade_request.action      =TRADE_ACTION_SLTP;
   trade_request.position    =m_Ticket;
   trade_request.symbol      =Symbol();
   trade_request.sl          =NewStopLoss;
   trade_request.tp          =m_TakeProfit;
   
   if (!OrderSend(trade_request, trade_result)) {
       Print("Order modification failed: ", trade_result.comment);
       return false;
   } else {
       Print("Order modified successfully. Result code: ", trade_result.retcode);
   }
   
   return true;
      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::ModifyTakeProfit(double NewTakeProfit)
  {
   ResetLastError();

   MqlTradeRequest trade_request;
   MqlTradeResult trade_result;
   ZeroMemory(trade_request);
   ZeroMemory(trade_result);

   long stopLevel = SymbolInfoInteger(m_Symbol, SYMBOL_TRADE_STOPS_LEVEL);

   NewTakeProfit = m_Type % 2 == 0 ? NewTakeProfit += stopLevel*_Point : NewTakeProfit -= stopLevel*_Point;
   
   if(m_Type % 2 == 0 && NewTakeProfit >= SymbolInfoDouble(m_Symbol, SYMBOL_BID))
      return false;
   else if(m_Type % 2 == 1 && NewTakeProfit <= SymbolInfoDouble(m_Symbol, SYMBOL_ASK))
      return false;

   //--- setting request
   trade_request.action      =TRADE_ACTION_SLTP;
   trade_request.position    =m_Ticket;
   trade_request.symbol      =Symbol();
   trade_request.sl          =m_StopLoss;
   trade_request.tp          =NewTakeProfit;
   
   if (!OrderSend(trade_request, trade_result)) {
       Print("Order modification failed: ", trade_result.comment);
       return false;
   } else {
       Print("Order modified successfully. Result code: ", trade_result.retcode);
   }
   
   return true;
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::ModifyTriggerPrice(double Price)
{
   double triggerprice = NormalizeDouble(Price, _Digits);

   if(Price <= 0)
   {
      LogError(__FUNCTION__, "Price should not be lower than 0.");
      return false;
   }


   m_TriggerPrice = triggerprice;
   return true;
   
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::ModifyOpenPrice(double NewOpenPrice)
  {
   ResetLastError();

   MqlTradeRequest trade_request;
   MqlTradeResult trade_result;
   ZeroMemory(trade_request);
   ZeroMemory(trade_result);

   long stopLevel = SymbolInfoInteger(m_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double ask = SymbolInfoDouble(m_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(m_Symbol, SYMBOL_BID);
   
   
   if(m_Type == ORDER_TYPE_BUY || m_Type == ORDER_TYPE_SELL)
   {
      Print("Failed to modify open price of an opened order");
      return false;
   }

   // Open price cannot clog with order type
   if(m_Type == ORDER_TYPE_BUY_LIMIT && NewOpenPrice > ask)
   {
      Print("Failed to modify open price of Limit order due to wrong open price set.");
      return false;
   }
   // Open price cannot clog with order type
   else if(m_Type == ORDER_TYPE_SELL_LIMIT && NewOpenPrice < bid)
   {
      Print("Failed to modify open price of Limit order due to wrong open price set.");
      return false;
   }
   else if(m_Type == ORDER_TYPE_BUY_STOP && NewOpenPrice < ask)
   {
      Print("Failed to modify open price of Stop order due to wrong open price set.");
      return false;
   }
   // Open price cannot clog with order type
   else if(m_Type == ORDER_TYPE_SELL_STOP && NewOpenPrice > bid)
   {
      Print("Failed to modify open price of Stop order due to wrong open price set.");
      return false;
   }


   //--- setting request
   trade_request.symbol      =Symbol();
   trade_request.action      =TRADE_ACTION_MODIFY;
   trade_request.magic       =m_MagicNumber;
   trade_request.order       =m_Ticket;
   trade_request.price       = NewOpenPrice;
   trade_request.sl          = m_StopLoss;
   trade_request.tp          =m_TakeProfit;

   if (!OrderSend(trade_request, trade_result)) {
       Print("Order modification failed: ", trade_result.comment);
       return false;
   } else {
       Print("Order modified successfully. Result code: ", trade_result.retcode);
   }
   
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::GetProfit()
  {
   if(OrderSelectByTicket(m_Ticket))
      return PositionGetDouble(POSITION_PROFIT);

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::GetLockedProfit()
  {  
   double lockProfit = 0;

   if(m_StopLoss == 0)
     return -TOTAL_RISK;

    // calculation for price different
   double pipDiff=0;   
   
   // deducted swap & commission
   if(m_Type % 2 == 0)
   {
      pipDiff = m_StopLoss-m_OpenPrice;
      lockProfit = pipDiff * (MathPow(10, _Digits-1)) * GetPricePerPip(m_Symbol) * m_Lots;
      lockProfit += GetSwap() + GetCommission();
   }
    
   if(m_Type % 2 == 1)
   {
      pipDiff = m_OpenPrice-m_StopLoss;
      lockProfit = pipDiff * (MathPow(10, _Digits-1)) * GetPricePerPip(m_Symbol) * m_Lots;
      lockProfit += GetSwap() + GetCommission();
   }
   
   return NormalizeDouble(lockProfit, 2);
    
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::GetLockedProfitInPercentage()
  {  
    if(m_StopLoss == 0)
      return -TOTAL_RISK;
  
    return NormalizeDouble((GetLockedProfit()/AccountInfoDouble(ACCOUNT_BALANCE))*100, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order::SetTicket(int Ticket)
  {
   if(Ticket<0)
     {
      LogError(__FUNCTION__,"Order Ticket number is not valid, Ticket number: "+IntegerToString(Ticket));
      return;
     }

   m_Ticket=Ticket;
  }
//+------------------------------------------------------------------+
void Order::SetType(int Type)
  {
   if(Type<0 || Type>=ENUM_ORDER_TYPE_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Order Type is not valid, Order Type: "+IntegerToString(Type));
      return;
     }

   m_Type=Type;
  }
//+------------------------------------------------------------------+
void Order::SetOpenPrice(double OpenPrice)
  {
   if(OpenPrice<0)
     {
      LogError(__FUNCTION__,"Order Open Price is not valid, Order Open Price: "+DoubleToString(OpenPrice));
      return;
     }

   m_OpenPrice=OpenPrice;

   if(m_Type % 2 == 0)
   {
      SetOpenAskPrice(m_OpenPrice);
      SetOpenBidPrice(SymbolInfoDouble(m_Symbol, SYMBOL_BID));
   }
   
   else
   {
      SetOpenAskPrice(SymbolInfoDouble(m_Symbol, SYMBOL_ASK));
      SetOpenBidPrice(m_OpenPrice);
   }

  }
//+------------------------------------------------------------------+
void Order::SetOpenBidPrice(double OpenBidPrice)
  {
   if(OpenBidPrice<0)
     {
      LogError(__FUNCTION__,"Order Open Bid Price is not valid, Order Open Price: "+DoubleToString(OpenBidPrice));
      return;
     }
     
   m_OpenBidPrice=OpenBidPrice;
  }
//+------------------------------------------------------------------+
void Order::SetOpenAskPrice(double OpenAskPrice)
  {
   if(OpenAskPrice<0)
     {
      LogError(__FUNCTION__,"Order Open Ask Price is not valid, Order Open Price: "+DoubleToString(OpenAskPrice));
      return;
     }

   m_OpenAskPrice=OpenAskPrice;
  }
//+------------------------------------------------------------------+
void Order::SetStopLoss(double StopLoss)
  {
   if(StopLoss<0)
     {
      LogError(__FUNCTION__,"Order Stop Loss is not valid, Order Stop Loss: "+DoubleToString(StopLoss));
      return;
     }

   m_StopLoss=NormalizeDouble(StopLoss, _Digits);
  }
//+------------------------------------------------------------------+
void Order::SetTakeProfit(double TakeProfit)
  {
   if(TakeProfit<0)
     {
      LogError(__FUNCTION__,"Order Take Profit is not valid, Order Take Profit: "+DoubleToString(TakeProfit));
      return;
     }

   m_TakeProfit=NormalizeDouble(TakeProfit, _Digits);
  }
//+------------------------------------------------------------------+
void Order::SetHiddenTakeProfit(double HiddenTakeProfit)
  {
   if(HiddenTakeProfit<0)
     {
      LogError(__FUNCTION__,"Order Take Profit is not valid, Order Take Profit: "+DoubleToString(HiddenTakeProfit));
      return;
     }

   m_HiddenTakeProfit=NormalizeDouble(HiddenTakeProfit, _Digits);
  }
//+------------------------------------------------------------------+
void Order::SetLots(double Lots)
  {
   if(Lots<0)
     {
      LogError(__FUNCTION__,"Order Lots is not valid, Order Lots: "+DoubleToString(Lots, 2));
      return;
     }

   m_Lots=Lots;
  }
//+------------------------------------------------------------------+
void Order::SetMagicNumber(int MagicNumber)
  {
   m_MagicNumber=MagicNumber;
  }
//+------------------------------------------------------------------+
void Order::SetComment(string CommentStr)
  {
   m_Comment=CommentStr;
  }
//+------------------------------------------------------------------+
void Order::SetOpenDateTime(datetime OpenDateTime)
  {
   m_OpenDateTime=OpenDateTime;
  }
//+------------------------------------------------------------------+
void Order::SetOpenOrderDateTime(datetime OpenOrderDateTime)
  {
   m_OpenOrderDateTime=OpenOrderDateTime;
  }
//+------------------------------------------------------------------+
void Order::SetLastUpdateDateTime(datetime DateTime)
  {  
   if(m_LastUpdateDateTime >= DateTime)
   {
      LogError(__FUNCTION__, "New DateTime is earlier than Previous DateTime. ");
      return;
   }
  
   m_LastUpdateDateTime=DateTime;
   
  }
//+------------------------------------------------------------------+
void Order::SetExpirationDateTime(datetime ExpirationDateTime)
  {
   m_ExpirationDateTime=ExpirationDateTime;
  }
//+------------------------------------------------------------------+
void Order::SetSymbol(string SymbolStr)
  {
   if(SymbolStr=="")
     {
      LogError(__FUNCTION__,"Symbol string is empty");
      return;
     }

   m_Symbol=SymbolStr;
  }
//+------------------------------------------------------------------+
void Order::SetTimeFrame(ENUM_TIMEFRAMES TimeFrame)
  {
   if(!IsTimeFrameSupported(TimeFrame))
     {
      LogError(__FUNCTION__,"Time Frame Is not supported");
      return;
     }

   m_TimeFrame=TimeFrame;
  }
//+------------------------------------------------------------------+
void Order::SetBreakEvenPrice(double BreakEvenPrice)
{
   if(BreakEvenPrice < 0)
   {
      LogError(__FUNCTION__, "BE Price cannot be < 0");
      return;
   }

   m_BreakEvenPrice=NormalizeDouble(BreakEvenPrice, _Digits);
}
//+------------------------------------------------------------------+
void Order::SetCommission(double Commission)
{
   m_Commission=MathAbs(Commission);
}
//+------------------------------------------------------------------+
void Order::SetSwap(double Swap)
{
   m_Swap=MathAbs(Swap);
}