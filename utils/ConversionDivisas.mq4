//+------------------------------------------------------------------+
//|                                            ConversionW.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#property show_inputs

input string FicheroIn;


// <TICKER>,<DTYYYYMMDD>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>
#define C_TICKER        0
#define C_DTYYYYMMDD    1
#define C_TIME          2
#define C_OPEN          3
#define C_HIGH          4
#define C_LOW           5
#define C_CLOSE         6
#define C_VOL           7

//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int fpin, fpout;
   string FicheroOut;
   long TimeFrame, DeltaTimeFrame;
   
   string STicker;
   string SOpen, SClose, SHigh, SLow, SVolume, SDate, STime;

   string linea, sep;
   string linea_escrita;
   unsigned u_sep;  

   string DatosLeidos[], DatosNew[];
   int NumDatosLeidos;
   
   double dOpen , dClose , dHigh , dLow;
   long Volumen;
   int Digitos; 
   
   long T_Apertura, TBarra;
   string ST_Apertura;
   
// Abrimos Ficheros

   GetFicheroSalida(FicheroIn, FicheroOut, TimeFrame);
   
//   Alert ("Entrada=",FicheroIn,"\n");   // DEBUG
//   Alert ("Salida=",FicheroOut,"\n");   // DEBUG
   
   fpin= FileOpen(FicheroIn+".txt", FILE_CSV|FILE_READ);
   fpout= FileOpen(FicheroOut+".txt", FILE_CSV|FILE_WRITE);
//   
//   //
//         
      if (fpin==0) {
         Alert("Fichero no encontrado entrada \n");
         return;
      }

      if (fpout==0) {
         Alert("Fichero de salida no abierto\n");
         return;
      }
//      
//   
// Leemos Cabecera y escribimos en los ficheros de datos
//   
      linea=FileReadString(fpin);
//   
      FileWriteString(fpout, linea+"\n");
//      
//   //-----------------------------------------------------------------   
//   // Bucle de Lectura de Info
//   // <TICKER>,<DTYYYYMMDD>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>
//   //   string STicker;
//   //   string SOpen, SClose, SHigh, SLow, SVolume, SDate, STime;
//   //   double dOpen , dClose , dHigh , dLow ;
//   //   int Volumen ; 
//   
      sep=",";
      u_sep= StringGetCharacter(sep,0);

// Inicializamos la primera barra

      linea=FileReadString(fpin); 

      NumDatosLeidos=StringSplit(linea,u_sep,DatosLeidos); 
      
//      T_Apertura=StringToInteger(DatosLeidos[C_DTYYYYMMDD]+DatosLeidos[C_TIME])/100;
      ST_Apertura=DatosLeidos[C_DTYYYYMMDD]+StringSubstr(DatosLeidos[C_TIME],0,4);
      
      T_Apertura = CalculaT_Apertura(ST_Apertura,TimeFrame);
      Calcula_StrT_Apertura(ST_Apertura, T_Apertura);
      Digitos = CalculaDigitos(DatosLeidos[C_OPEN]);
      
      Volumen=StringToInteger(DatosLeidos[C_VOL]);
      dOpen=StringToDouble(DatosLeidos[C_OPEN]);
      dClose=StringToDouble(DatosLeidos[C_CLOSE]);
      dHigh=StringToDouble(DatosLeidos[C_HIGH]);
      dLow=StringToDouble(DatosLeidos[C_LOW]);
      STicker=DatosLeidos[C_TICKER];
      
      DeltaTimeFrame=ActualizaTimeFrame(TimeFrame);

      Alert("Generando Fichero ", FicheroOut,".txt");

      do
//       for(i=1; i<30; i++)
      {
         linea=FileReadString(fpin); 
         
//         if (FileIsEnding(fpin)==True) break;      // Salgo del bucle
         
         NumDatosLeidos=StringSplit(linea,u_sep,DatosNew);
         TBarra = StringToInteger(DatosNew[C_DTYYYYMMDD]+DatosNew[C_TIME])/100;
         
//         Alert ("i=",i,"--TBarra=",TBarra,"--T_Apertura",T_Apertura,"--TimeFrame=",TimeFrame);  // DEBUG
         
         if (TBarra < T_Apertura+DeltaTimeFrame)
         {
               Volumen=Volumen+StringToInteger(DatosNew[C_VOL]);
               if (dLow > StringToDouble(DatosNew[C_LOW])) dLow=StringToDouble(DatosNew[C_LOW]);
               if (dHigh < StringToDouble(DatosNew[C_HIGH])) dHigh=StringToDouble(DatosNew[C_HIGH]);
               dClose=StringToDouble(DatosNew[C_CLOSE]);               
               
         } 
         else
         {       
               linea_escrita=STicker+","+ST_Apertura+"00,"+DoubleToString(dOpen, Digitos)+",";
               linea_escrita=linea_escrita+DoubleToString(dHigh, Digitos)+","+DoubleToString(dLow, Digitos)+",";
               linea_escrita=linea_escrita+DoubleToString(dClose, Digitos)+","+IntegerToString(Volumen);
               
               FileWrite(fpout,linea_escrita);
               
               ST_Apertura=DatosNew[C_DTYYYYMMDD]+StringSubstr(DatosNew[C_TIME],0,4);
      
               T_Apertura = CalculaT_Apertura(ST_Apertura,TimeFrame);
               Calcula_StrT_Apertura(ST_Apertura, T_Apertura);
               Digitos = CalculaDigitos(DatosNew[C_OPEN]);
                 
               Volumen=StringToInteger(DatosNew[C_VOL]);
               dOpen=StringToDouble(DatosNew[C_OPEN]);
               dClose=StringToDouble(DatosNew[C_CLOSE]);
               dHigh=StringToDouble(DatosNew[C_HIGH]);
               dLow=StringToDouble(DatosNew[C_LOW]);
               
               
               
         } 
//      } // Este es el del do
            
      } while(FileIsEnding(fpin)==false); // Eliminar el paréntesis anterior que es del for de prueba
//      

      linea_escrita=STicker+","+ST_Apertura+"00,"+DoubleToString(dOpen, Digitos)+",";
      linea_escrita=linea_escrita+DoubleToString(dHigh, Digitos)+","+DoubleToString(dLow, Digitos)+",";
      linea_escrita=linea_escrita+DoubleToString(dClose, Digitos)+","+IntegerToString(Volumen);
      
      FileWrite(fpout,linea_escrita);

 
//         
// Cerramos Ficheros 
  
      FileClose(fpin);
      FileClose(fpout);  
      
      Alert("Terminado Fichero ", FicheroOut,".txt");    
   
  }

//+----------------------------------------------------------------------------------+
// Proporciona el Nombre del fichero de Salida en funcion del parámetro de Conversion 
//
// El Nombre de entrada sera XXXXXXMnn
// XXXXXX Corresponde al cambio
// nn será de ongitud variable e incluye el TimeFrame de Entrada
//+----------------------------------------------------------------------------------+

void GetFicheroSalida(string FicheroEntrada, string& FicheroSalida, long& TimeFrameLocal)
{
   long TimeFrameTmp;
   string FicheroTmp;
   
   FicheroTmp=StringSubstr(FicheroEntrada,7,StringLen(FicheroEntrada)-1);
      
   TimeFrameTmp=StringToInteger(FicheroTmp);
   
   if (TimeFrameTmp==1)  TimeFrameLocal=5;
   if (TimeFrameTmp==5)  TimeFrameLocal=15;
   if (TimeFrameTmp==15) TimeFrameLocal=30;
   if (TimeFrameTmp==30) TimeFrameLocal=60;
   if (TimeFrameTmp==60) TimeFrameLocal=240;
   if (TimeFrameTmp==240) TimeFrameLocal=1440;

// EN LOS DOS SIGUIENTES, LA ENTRADA VA A SER 1440
// HAY QUE CONSIDERAR LA NUEVA VARIABLE.

   if (TimeFrameTmp==1440) TimeFrameLocal=43200;
//   if ((TimeFrameTmp==1440)&&(WeekOrMonth)=="W") TimeFrameLocal=10080;
   
   FicheroTmp=IntegerToString(TimeFrameLocal);
   
   FicheroSalida=StringSubstr(FicheroEntrada,0,7)+FicheroTmp;
      
   return;
}

//+----------------------------------------------------------------------------------+
//+----------------------------------------------------------------------------------+

//+----------------------------------------------------------------------------------+
//+----------------------------------------------------------------------------------+
int CalculaDigitos(string Precio)
{
   int i;
   unsigned u_Punto;
   string Punto;
   
   
   Punto=".";
   u_Punto= StringGetCharacter(Punto,0);
      
   for (i=0; i< StringLen(Precio); i++)
   {
      if (StringGetCharacter(Precio,i)==u_Punto) return(StringLen(Precio)-i-1);
   }
   
   return(2);
}

//+----------------------------------------------------------------------------------+


// Calcula el Tiempo de Apertura de la barra que vamos a Escribir 

void Calcula_StrT_Apertura(string& S, long Tiempo)
{
   string T1,T2,T3;
   
   T3=IntegerToString(Tiempo, 12);
   T1=StringSubstr(T3,0,8);
   T2=StringSubstr(T3,8,4);
   
   S=T1+","+T2;
   
   return;
}
//+----------------------------------------------------------------------------------+


long CalculaT_Apertura(string ST,long TFrame)
{

   long TA_Tmp, Fin;
   string SFin, STTmp;
   datetime DiaTmp;

   // Caso Destino M5
   
   if (TFrame==5)
   {
      SFin=StringSubstr(ST,11,1);
      Fin=StringToInteger(SFin);
      STTmp=StringSubstr(ST,0,11);
      
      if (Fin==0) 
      {
         TA_Tmp = StringToInteger(ST);
         return(TA_Tmp);
      }
      
      if ((Fin>0)&&(Fin<5))  ST=STTmp+"0";
      if ((Fin>=5)&&(Fin<9)) ST=STTmp+"5";     
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);    
   }
   
   
   if (TFrame==15)
   {
      SFin=StringSubstr(ST,10,2);
      Fin=StringToInteger(SFin);
      STTmp=StringSubstr(ST,0,10);
      
      if (Fin==0) 
      {
         TA_Tmp = StringToInteger(ST);
         return(TA_Tmp);
      }
      
      if ((Fin>0)&&(Fin<15))     ST=STTmp+"00";
      if ((Fin>=15)&&(Fin<30))   ST=STTmp+"15"; 
      if ((Fin>=30)&&(Fin<45))   ST=STTmp+"30"; 
      if ((Fin>=46)&&(Fin<=59))  ST=STTmp+"45";     
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);    
   }
   
   if (TFrame==30)
   {
   
      SFin=StringSubstr(ST,10,2);
      Fin=StringToInteger(SFin);
      STTmp=StringSubstr(ST,0,10);
      
      if (Fin==0) 
      {
         TA_Tmp = StringToInteger(ST);
         return(TA_Tmp);
      }
      
      if ((Fin>0)&&(Fin<30))     ST=STTmp+"00"; 
      if ((Fin>=30)&&(Fin<=59))   ST=STTmp+"30";      
      TA_Tmp = StringToInteger(ST);
      return(TA_Tmp);    
   }   
   
   
   if (TFrame==60)
   {

      STTmp=StringSubstr(ST,0,10);
      ST=STTmp+"00";
           
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);    
   }
   
   if (TFrame==240)
   {
 
      SFin=StringSubstr(ST,8,2);
      Fin=StringToInteger(SFin);
      STTmp=StringSubstr(ST,0,8);
      
      if (Fin==0) 
      {
         TA_Tmp = StringToInteger(ST);
         return(TA_Tmp);
      }
      
      if ((Fin>0)&&(Fin<4))     ST=STTmp+"0000"; 
      if ((Fin>=4)&&(Fin<8))    ST=STTmp+"0400";
      if ((Fin>=8)&&(Fin<12))   ST=STTmp+"0800";
      if ((Fin>=12)&&(Fin<16))  ST=STTmp+"1200";
      if ((Fin>=16)&&(Fin<20))  ST=STTmp+"1600";
      if ((Fin>=20)&&(Fin<24))  ST=STTmp+"2000";
     
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);     
   }
   
   
   if ((TFrame==1440))
   {

      STTmp=StringSubstr(ST,0,8);
      ST=STTmp+"0000";
           
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);    
   }

   if ((TFrame==10080))
   {
      STTmp = StringSubstr(ST,0,4)+"."+StringSubstr(ST,4,2)+".";
      STTmp = STTmp+StringSubstr(ST,6,2)+"00:01";
      DiaTmp = StrToTime(STTmp);
      TA_Tmp = StringToInteger(ST)-TimeDayOfWeek(DiaTmp)*10000;
      
      return(TA_Tmp);    
   }

   if ((TFrame==43200))
   {

      STTmp=StringSubstr(ST,0,6);
      ST=STTmp+"010000";
           
      TA_Tmp = StringToInteger(ST);
      
      return(TA_Tmp);    
   }
   
// Hay que añadir los demás TimeFrames   
   TA_Tmp = StringToInteger(ST);      
   return(TA_Tmp);



}


//+----------------------------------------------------------------------------------+
// Ajusta el TimeFrame para seguir el mismo procedimiento que para TimeFrame menor
// o igual que 60
//+----------------------------------------------------------------------------------+

long ActualizaTimeFrame(long Frame)
{
   if (Frame <=60) return (Frame);
   
   if (Frame==240) return (400);
   
   if (Frame==1440) return(2300);
   
   if (Frame==10080) return(69999);
   
   if (Frame==43200) return(320000);
   
   return(0);
   
   
}