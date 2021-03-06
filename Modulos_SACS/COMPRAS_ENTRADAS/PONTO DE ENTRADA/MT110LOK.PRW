#INCLUDE "Protheus.ch"
#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M110STTS  �Autor  �Carlos R Moreira    � Data �  26/10/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ira verificar se o produto ira ser revendido                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110LOK()
	Local aArea := GetArea()

	Local nPosPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_PRODUTO"})
	Local nPosTes    := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_TES"})
	Local nPosConta  := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_CONTA"})

//Verifico se o Item nao esta deletado
	If !aCols[n][Len(aCols[n])]

		cRevenda  := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosPrd],"B1_REVENDA")
    
		If cRevenda == "S"
       
			If MsgYesNo("Este item ser� utilizado para Revenda" )
          
				aCols[n,nPosTes]   := "018"
//				aCols[n,nPosConta] := "311101002"

			EndIf
 
        
		EndIf
   
	EndIf
       
	RestArea(aArea)
Return