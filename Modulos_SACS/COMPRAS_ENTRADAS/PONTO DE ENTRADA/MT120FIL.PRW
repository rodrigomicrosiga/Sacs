#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT120FIL  �Autor  �Eduardo Matias      � Data �  01/20/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada utilizado para filtrar apenas os pedidos  ���
���          � dos grupos que o usuario pertence.                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP11                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION MT120FIL()
Local cRet := ""
Local cCodUser := RetCodUsr()
Local cGrupo := ""
Local cAtivo := ""

If !ExisteSX6("MV_FILGRPC")
	CriarSX6("MV_FILGRPC","C","Filtra pedidos de compra por grupo de usuarios (S/N)?","S")
EndIf 
  
If !ExisteSX6("MV_FILGRUP")
	CriarSX6("MV_FILGRUP","C","Grupos que podem visualizar todos os pedidos de compra. Funciona em conjunto c/MV_FILGRPC","000000/000029/000049")
EndIf 


cAtivo := GetMv("MV_FILGRPC")
//Private aGrupo := UsrRetGrp(RetCodUsr())  

IF cAtivo == "S"
	
	//If Len(aGrupo) = 0
	//	AAdd(aGrupo,"NC")
	//EndIf
	
	IF ! U_grpuser(getmv("MV_FILGRUP"))     // aGrupo[01] $ ("000000/000029")
		
		dbSelectArea("SAJ")
		dbSetOrder(2)
		DbSeek(xFilial("SAJ")+cCodUser)
		While !eof() .AND. cCodUser = AJ_USER
			
			cGrupo += SAJ->AJ_GRCOM+","
			
			dbSkip()
		EndDo
		
		cRet := "C7_GRUPCOM $ ('"+cGrupo+"')"
	EndIf  
	
	
EndIf

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �grpuser   �Autor  �Microsiga           � Data �  09/13/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User function grpuser(cGrupos)
Local _aGrupo  :={}
Local _aRetUser:={}
Local ni       := 0
Local lResult  :=.F.

// Defino a ordem
PswOrder(1) // Ordem de nome
     
// Efetuo a pesquisa, definindo se pesquiso usu�rio ou grupo
If PswSeek(__CUSERID,.T.)

   // Obtenho o resultado conforme vetor
   _aRetUser := PswRet(1)
   _aGrupo   := _aRetUser[1,10]
         
EndIf                        

if !cGrupos == NIL.and.!Empty(cGrupos)  
	
	For ni = 1 to len(_aGrupo)     
           
		If !lResult
			lResult := (_aGrupo[ni]$cGrupos)
		Endif
		
    next ni

Endif
Return lResult