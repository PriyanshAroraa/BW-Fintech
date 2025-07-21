//+------------------------------------------------------------------+
//|                                                 ZigZagPauser.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ZigZagPauser{
   private:
      string               m_FileName[3];
      int                  m_FileHandle[3];
      
      datetime             m_PauseDate[3];
      
      
      void                 DiscardHeader();
      void                 ReadNextDayPauseDate();
      void                 ReadNextHourPauseDate();
      void                 ReadNext4HPauseDate();

 
   public:
                           ZigZagPauser();
                           ~ZigZagPauser();
                           
                          
                          
      bool                 Init();                     
      void                 OnUpdate(bool IsNewBar);



};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZigZagPauser::ZigZagPauser(){
   for(int i = 0; i < ArraySize(m_FileHandle); i++){
      m_FileName[i] = ZIGZAG_FILENAME[i];
      m_PauseDate[i] = NULL;
   
   }
         
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZigZagPauser::~ZigZagPauser(){
   for(int i = 0; i < ArraySize(m_FileHandle); i++){
      FileClose(m_FileHandle[i]);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ZigZagPauser::Init(){
   for(int i = 0; i < ArraySize(m_FileName); i++){
      // open file
      m_FileHandle[i] = FileOpen(m_FileName[i], FILE_READ|FILE_CSV, ',');
      
      
      // file existence
      if(m_FileHandle[i] == -1){
         LogError(__FUNCTION__, "File not Found. ");
         return false;
      }
   }
   
   
   Print("File read successfullly. ");
   
   // read first date first
   DiscardHeader();
   ReadNextHourPauseDate();
   ReadNext4HPauseDate();
   ReadNextDayPauseDate();
   
   
   // update latest for 15m x hour
   datetime curTime = TimeCurrent();
   
   while(curTime > m_PauseDate[0])
      ReadNextHourPauseDate();
   
   while(curTime > m_PauseDate[1])
      ReadNext4HPauseDate();
   
   while(curTime > m_PauseDate[2])
      ReadNextDayPauseDate();
      
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagPauser::OnUpdate(bool IsNewBar){
   if(IsNewBar){
      datetime dt = TimeCurrent();
      
      

      
      // 1H Matched
      if(dt == m_PauseDate[0] && dt != m_PauseDate[1] && dt != m_PauseDate[2]){
         Print("1H ZZ Pause Date: " + TimeToString(dt));
         ReadNextHourPauseDate();
         PauseTest();      
      }
      
      
      // 4H Matched
      else if(dt == m_PauseDate[1] && dt == m_PauseDate[0] && dt != m_PauseDate[2]){
         Print("4H ZZ Pause Date: " + TimeToString(dt));
         ReadNextHourPauseDate();
         ReadNext4HPauseDate();
         PauseTest();      
      }
      
      
      // Daily Matched
      else if(dt == m_PauseDate[1] && dt == m_PauseDate[0] && dt == m_PauseDate[2]){
         Print("1D ZZ Pause Date: " + TimeToString(dt));
         ReadNextHourPauseDate();
         ReadNext4HPauseDate();
         ReadNextDayPauseDate();
         PauseTest();      
      }        
   
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagPauser::ReadNextHourPauseDate(){
   if(!FileIsEnding(m_FileHandle[0])){
      m_PauseDate[0] = StringToTime(FileReadString(m_FileHandle[0]));
      
      
      // read off the price and mode as not needed
      FileReadString(m_FileHandle[0]);
      FileReadString(m_FileHandle[0]);
   
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagPauser::ReadNext4HPauseDate(){
   if(!FileIsEnding(m_FileHandle[1])){
      m_PauseDate[1] = StringToTime(FileReadString(m_FileHandle[1]));
      
      
      // read off the price and mode as not needed
      FileReadString(m_FileHandle[1]);
      FileReadString(m_FileHandle[1]);
   
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagPauser::ReadNextDayPauseDate(){
   if(!FileIsEnding(m_FileHandle[2])){
      m_PauseDate[2] = StringToTime(FileReadString(m_FileHandle[2]));
      
      
      // read off the price and mode as not needed
      FileReadString(m_FileHandle[2]);
      FileReadString(m_FileHandle[2]);
   
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagPauser::DiscardHeader(){
   for(int i = 0; i < ArraySize(m_FileHandle); i++){
      if(!FileIsEnding(m_FileHandle[i])){
         // read off the header
      
         FileReadString(m_FileHandle[i]);
         FileReadString(m_FileHandle[i]);
         FileReadString(m_FileHandle[i]);
     
      }
   }
   
}

//+------------------------------------------------------------------+
