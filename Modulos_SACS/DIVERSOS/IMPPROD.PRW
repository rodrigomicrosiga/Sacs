#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO8     � Autor � AP6 IDE            � Data �  06/04/14   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IMPPROD


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private oGeraTxt


//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Importacao Cadastro de Produto")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
@ 18,018 Say " tros definidos  pelo usuario,  com os registros do arquivo de "
@ 26,018 Say "                                                            "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

Activate Dialog oGeraTxt Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OKGERATXT� Autor � AP5 IDE            � Data �  06/04/14   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa a geracao do arquivo texto.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function OkGeraTxt


//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������

Processa({|| RunCont() },"Processando...")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � AP5 IDE            � Data �  06/04/14   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunCont
private lMsErroAuto := .F.

cAliasTop2 := GetNextAlias()

cQuery2 := " SELECT *   "
cQuery2 += " FROM CADPROD "

dbUseArea(.T., 'TOPCONN',TCGenQry(,,cQuery2),cAliasTop2,.F.,.T.)

dbSelectArea(cAliasTop2)

(cAliasTop2)->(DBGOTOP())




ProcRegua(RecCount()) // Numero de registros a processar

do While !(cAliasTop2)->(EOF())
	
	//���������������������������������������������������������������������Ŀ
	//� Incrementa a regua                                                  �
	//�����������������������������������������������������������������������
	
	IncProc()

	aVetor := {}
	
	aadd(aVetor,{"B1_COD",       (cAliasTop2)->CODIGO ,})
	aadd(aVetor,{"B1_DESC",      (cAliasTop2)->DESCRICAO,})
	aadd(aVetor,{"B1_TIPO",      (cAliasTop2)->TIPO,})
	aadd(aVetor,{"B1_UM",        (cAliasTop2)->UNIDADE,})
	aadd(aVetor,{"B1_LOCPAD",    (cAliasTop2)->LOCAL,})
	aadd(aVetor,{"B1_IPI",       VAL((cAliasTop2)->ALIQIPI),})
	aadd(aVetor,{"B1_GRUPO",     (cAliasTop2)->GRUPO,})
	aadd(aVetor,{"B1_POSIPI",    (cAliasTop2)->POSIPI,})
	aadd(aVetor,{"B1_UCOM",      CTOD(subs((cAliasTop2)->UltCompra,7,2)+"/"+subs((cAliasTop2)->UltCompra,5,2)+"/"+subs((cAliasTop2)->UltCompra,1,4))   ,})
	aadd(aVetor,{"B1_UPRC",      (cAliasTop2)->UltPreco,})
	aadd(aVetor,{"B1_CONTA",      (cAliasTop2)->CONTA,})
	aadd(aVetor,{"B1_ORIGEM",      "0",})	
	
	
	
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
	
	If lMsErroAuto
		
		MostraErro()
		
	ENDIF
	
	
	(cAliasTop2)->(dbSkip())
EndDo


Return
