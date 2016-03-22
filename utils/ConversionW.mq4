//+------------------------------------------------------------------+
//|                                            ConversionW.mq4 |
//|                        Copyright 2014, JAM                       |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, JAM"
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
   long TimeFrame;
   datetime DeltaTimeFrame;
   
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
   
   datetime T_Apertura, TBarra;
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
         TBarra = ConvierteEnDatetime(DatosNew[C_DTYYYYMMDD]+DatosNew[C_TIME]);
         
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
               linea_escrita=STicker+","+ST_Apertura+DoubleToString(dOpen, Digitos)+",";
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

      linea_escrita=STicker+","+ST_Apertura+DoubleToString(dOpen, Digitos)+",";
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
   
   TimeFrameLocal=0;

   if (TimeFrameTmp==1440) TimeFrameLocal=10080;

   
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

void Calcula_StrT_Apertura(string& S, datetime Tiempo)
{
   string T1,T3;
   
   T3=TimeToStr(Tiempo,TIME_DATE);
   T1=StringSubstr(T3,0,4)+StringSubstr(T3,5,2)+StringSubstr(T3,8,2);
   
   
   S=T1+",000000,";
   
   return;
}
//+----------------------------------------------------------------------------------+


datetime CalculaT_Apertura(string ST,long TFrame)
{

   datetime TA_Tmp;
   string SFin, STTmp;
   datetime DiaTmp;
   datetime var1,var2,var3;
   
   var1=StrToTime("2003.8.12 17:35");
   var2=StrToTime("2003.8.11 17:35");
   
   var3=var1-var2; // esto es un día en datetime

   if ((TFrame==10080))
   {
      STTmp = StringSubstr(ST,0,4)+"."+StringSubstr(ST,4,2)+".";
      STTmp = STTmp+StringSubstr(ST,6,2)+" 00:00";
      DiaTmp = StrToTime(STTmp);
      TA_Tmp = DiaTmp-TimeDayOfWeek(DiaTmp)*var3;
      
      return(TA_Tmp);    
   }

   
// Hay que añadir los demás TimeFrames   
   TA_Tmp = var3;      
   return(TA_Tmp);



}


//+----------------------------------------------------------------------------------+
// Convierte la lectura del fichero en datetime
//+----------------------------------------------------------------------------------+


datetime ConvierteEnDatetime(string ST)
{
   datetime DiaTmp, TA_Tmp;
   string STTmp;
   
   STTmp = StringSubstr(ST,0,4)+"."+StringSubstr(ST,4,2)+".";
   STTmp = STTmp+StringSubstr(ST,6,2)+" 00:00";
   DiaTmp = StrToTime(STTmp);
   TA_Tmp = DiaTmp;   

   return(TA_Tmp);
}

//+----------------------------------------------------------------------------------+
// Ajusta el TimeFrame para seguir el mismo procedimiento que para TimeFrame menor
// o igual que 60
//+----------------------------------------------------------------------------------+

datetime ActualizaTimeFrame(long Frame)
{
   datetime var1,var2,var3;
   
   var1=StrToTime("2003.8.12 17:35");
   var2=StrToTime("2003.8.11 17:35");
   
   var3=var1-var2;
   
   if (Frame==10080) return(7*var3);
     
   return(var1);
   
   
}
