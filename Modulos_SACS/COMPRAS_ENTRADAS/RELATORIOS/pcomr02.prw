#INCLUDE "RWMAKE.CH"
#Include "Protheus.ch"
#INCLUDE "colors.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOMR02   �Autor  �Carlos R. Moreira   � Data �  27/05/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o relatorio de Analise de Cotacoes                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PCOMR02()
	Local aSays     := {}
	Local aButtons  := {}
	Local nOpca     := 0
	Local cCadastro := OemToAnsi("Relatorio de Analise de Cotacoes")

	Private  cArqTxt
	Private cPerg := "PCOMR02"

	PutSx1(cPerg,"01","Cotacao de                 ?","","","mv_ch1","C",  6,0,0,"G","SC8","","","","mv_par01","","","","","","","","","","","","","","","","",{{"Cliente Inicial "}},{{" "}},{{" "}},"")
	PutSx1(cPerg,"02","Cotacao Ate                ?","","","mv_ch2","C",  6,0,0,"G","SC8","","","","mv_par02","","","","","","","","","","","","","","","","",{{"Cliente Final  "}},{{" "}},{{" "}},"")
	PutSx1(cPerg,"03","Emissao De                 ?","","","mv_ch3","D",  8,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{{"Loja    Inicial "}},{{" "}},{{" "}},"")
	PutSx1(cPerg,"04","Emissao Ate                ?","","","mv_ch4","D",  8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{{"Loja    Final  "}},{{" "}},{{" "}},"")

	aHelpPor :=	{"Define se a exportacao de dados sera consolidada entre empresas"}
	aHelpEsp :=	{}
	aHelpEng :=	{}

	Pergunte(cPerg,.F.)

	Aadd(aSays, OemToAnsi(" Este programa ira gerar um consulta com os fornecedores  "))
	Aadd(aSays, OemToAnsi(" qualificados de acordo com parametros selecionados."))

	Aadd(aButtons, { 1, .T., { || nOpca := 1, FechaBatch()  }})
	Aadd(aButtons, { 2, .T., { || FechaBatch() }})
	Aadd(aButtons, { 5, .T., { || Pergunte(cPerg,.T.) }})

	FormBatch(cCadastro, aSays, aButtons)

	If nOpca == 1
	
		aEmp := {}
		Aadd( aEmp, SM0->M0_CODIGO )

	
		If Len(aEmp) > 0
		
			CriaArqTmp()
		
			For nX := 1 to Len(aEmp)
				Processa( { || Proc_Arq(aEmp[nX]) }, "Processando o arquivo de trabalho .")  //
			Next
		
			Processa({||MostraCons()},"Mostra a Consulta..")
		
			TRB->(DbCloseArea())
		
		EndIf
	
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Proc_Arq  �Autor  �Carlos R Moreira    � Data �  04/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa o arquivo para gerar o arquivo de trabalho        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Proc_Arq(cEmp)
	Local aNomArq := {}
	Local aArq := {{"SA2"," "},{"SC8"," "},{"SB1"," "}}

	cArq   := "sx2"+cEmp+"0"
	cAliasTrb := "sx2trb"

	cPath := GetSrvProfString("Startpath","")
	cArq := cPath+cArq

//Faco a abertura do SX2 da empresa que ira gerar o arquivo de trabalho
	Use  &(cArq ) alias &(cAliasTrb) New

	If Select( cAliasTRB ) == 0
		MsgAlert("Arquivo nao foi aberto..."+cArq)
		Return
	Else
		DbSetIndex( cArq )
	EndIf

	For nArq := 1 to Len(aArq)
	
		DbSelectArea( cAliasTrb )
		DbSeek( aArq[nArq,1] )
	
		aArq[nArq,2] := (cAliasTrb)->x2_arquivo
	
	Next

	cQuery := " SELECT     SC8.C8_PRODUTO, SC8.C8_QUANT, SC8.C8_PRECO, SC8.C8_TOTAL, SC8.C8_FORNECE, SC8.C8_LOJA, SA2.A2_NREDUZ, "
	cQuery += "                      SB1.B1_DESC "
	cQuery += " FROM "+ aArq[Ascan(aArq,{|x|x[1] = "SC8" }),2]+" SC8 JOIN "
	cQuery +=  aArq[Ascan(aArq,{|x|x[1] = "SA2" }),2]+" SA2 ON "
	cQuery += 	 " SC8.C8_FORNECE = SA2.A2_COD AND SC8.C8_LOJA = SA2.A2_LOJA AND SB1.D_E_L_E_T_ <> '*' JOIN "
	cQuery +=  aArq[Ascan(aArq,{|x|x[1] = "SB1" }),2]+" SB1 ON " 
	cQuery +=	" SC8.C8_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQuery +=  "Where SC8.D_E_L_E_T_ <> '*' AND "
	cQuery += " SC8.C8_EMISSAO BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' AND "
	cQuery += " SC8.C8_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 

	cQuery := ChangeQuery(cQuery)

	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)},"Gerando o arquivo empresa : "+cEmp )
	TCSetField("QRY","C8_EMISSAO","D")

	nTotReg := 0
	QRY->(dbEval({||nTotREG++}))
	QRY->(dbGoTop())

	DbSelectArea("QRY")
	DbGotop()

	ProcRegua(nTotReg)

	While QRY->(!Eof())
	
		IncProc("Processando o Arquivo de trabalho..Emp: "+cEmp)
  
		DbSelectArea("TRB")
		
		RecLock("TRB",.T.)

		TRB->FORNECE  := QRY->A2_COD
		TRB->LOJA     := QRY->A2_LOJA
		TRB->NOME     := QRY->A2_NOME
   
		DbSelectArea("QRY")
		DbSkip()
	
	End

	QRY->(DbCloseArea())


	(cAliasTrb)->(DbCloseArea())

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CONS_NF   �Autor  �Microsiga           � Data �  05/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MostraCons()
	Local aSize     := MsAdvSize(.T.)
	Local aObjects:={},aInfo:={},aPosObj:={}
	Local aCampos := {}

	Local aInfo   :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	aBrowse := {}

	AaDD(aBrowse,{"EMPRESA","","Empresa"})
	AaDD(aBrowse,{"FORNECE","","Fornecedor",""})
	AaDD(aBrowse,{"LOJA","","Loja",""})
	AaDD(aBrowse,{"NOME","","Razao Social",""})
	AaDD(aBrowse,{"NREDUZ","","N.Fantasia",""})
	AaDD(aBrowse,{"CGC","","CNPJ","@R 99.999.999/9999-99"})

	AaDD(aBrowse,{"MCOMPRA","","M.Compra","@E 99,999,999.99"})
	AaDD(aBrowse,{"NROCOM","","Nro Compra","@E 99999"})
		
	AaDD(aBrowse,{"PRICOM","","1o Compra",""})
	AaDD(aBrowse,{"ULTCOM","","Ultima Compra",""})

	AaDD(aBrowse,{"STATUS","","Laudo",""})
	AaDD(aBrowse,{"FATAVA","","Fator Aval","@E 99,999,999.99"})
		
	AaDD(aBrowse,{"DTAVA","","Dt Avaliacao",""})
	AaDD(aBrowse,{"DTVAL","","Dt.Validade",""})

	AaDD(aBrowse,{"MSBLQL","","Bloqueado",""})
	
	AaDD(aBrowse,{"METAV","","Metodo Aval",""})
	
	AaDD(aBrowse,{"INDMELH","","IQ%","@E 999"})
	
	DbSelectArea("TRB")
	DbGoTop()

	cMarca   := GetMark()
	nOpca    :=0
	lInverte := .F.
	oFonte  := TFont():New( "TIMES NEW ROMAN",14.5,22,,.T.,,,,,.F.)

//��������������������������������������������������������������Ŀ
//�Monta a  tela com o tree da origem e com o tree do destino    �
//�resultado da comparacao.                                      �
//����������������������������������������������������������������
//aAdd( aObjects, { 100, 100, .T., .T., .F. } )
//aAdd( aObjects, { 100, 100, .T., .T., .F. } )
//aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
//aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )

	AADD(aObjects,{100,025,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	AAdd( aObjects, { 0, 40, .T., .F. } )

	aPosObj:=MsObjSize(aInfo,aObjects)

	DEFINE MSDIALOG oDlg1 TITLE "Consulta CC - Periodo" From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

//����������������������������������������������������������������������Ŀ
//� Passagem do parametro aCampos para emular tamb�m a markbrowse para o �
//� arquivo de trabalho "TRB".                                           �
//������������������������������������������������������������������������
	oMark := MsSelect():New("TRB","","",aBrowse,@lInverte,@cMarca,{aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]})  //35,3,213,385

	oMark:bMark := {| | fa060disp(cMarca,lInverte)}
	oMark:oBrowse:lhasMark = .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:bAllMark := { || FA060Inverte(cMarca) }

//@ aPosObj[1,1]+10,aPosObj[1,2]+30 Button "&Excel"    Size 60,15 Action ExpCons() of oDlg1 Pixel //Localiza o Dia

	@ aPosObj[3,1]+10,aPosObj[3,2]+520 Button "&Exp Excel"    Size 60,15 Action ExpCons() of oDlg1 Pixel //Localiza o Dia

	@ aPosObj[3,1]+10,aPosObj[3,2]+585 Button "&Imprimir"    Size 60,15 Action ImpCons() of oDlg1 Pixel //Localiza o Dia

	ACTIVATE MSDIALOG oDlg1 ON INIT LchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||oDlg1:End()},.T.) CENTERED

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LchoiceBar� Autor � Pilar S Albaladejo    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra a EnchoiceBar na tela                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LchoiceBar(oDlg,bOk,bCancel,lPesq)
	Local oBar, bSet15, bSet24, lOk
	Local lVolta :=.f.

	DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
	DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemtoAnsi("Calculadora...")
	DEFINE BUTTON RESOURCE "SIMULACAO" OF oBar GROUP ACTION ExpCons() TOOLTIP OemToAnsi("Exporta para Planilha Excel...")    //


	DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP "Ok - <Ctrl-O>"
	SetKEY(15,oBtOk:bAction)
	DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.F.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP OemToAnsi("Cancelar - <Ctrl-X>")  //
	SetKEY(24,oBtCan:bAction)
	oDlg:bSet15 := oBtOk:bAction
	oDlg:bSet24 := oBtCan:bAction
	oBar:bRClicked := {|| AllwaysTrue()}
Return

Static Function ButtonOff(bSet15,bSet24,lOk)
	DEFAULT lOk := .t.
	IF lOk
		SetKey(15,bSet15)
		SetKey(24,bSet24)
	Endif
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CONS_NF   �Autor  �Microsiga           � Data �  05/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ExpCons()
	Private aDadosExcel := {}

	AaDd(aDadosExcel,{ 	"Fornecedor",;
		"Loja",;
		"Razao Social",;
		"N.Fantasia",;
		"CNPJ",;
		"M.Compra",;
		"Nro Compra",;
		"1o Compra",;
		"Ultima Compra",;
		"Laudo",;
		"Fator Aval",;
		"Dt Avaliacao",;
		"Dt.Validade",;
		"Bloqueado",;
		"Metodo Aval",;
		"IQ%" })




	nCol := Len(aDadosExcel[1])

	DbSelectArea("TRB")
	DbGoTop()

	ProcRegua(RecCount())        // Total de Elementos da regua

	While TRB->(!EOF())
	
		AaDD( aDadosExcel, {	TRB->FORNECE,;
			TRB->LOJA,;
			TRB->NOME,;
			TRB->NREDUZ,;
			Transform(TRB->CGC,"@R 99.999.999/9999-99"),;
			Transform(TRB->MCOMPRA,"@E 99,999,999.99"),;
			Transform(TRB->NROCOM,"@e 99999"),;
			Dtoc(TRB->PRICOM) ,;
			Dtoc(TRB->ULTCOM) ,;
			TRB->STATUS,;
			Transform(TRB->FATAVA,"@E 999.99"),;
			Dtoc(TRB->DTAVA) ,;
			Dtoc(TRB->DTVAL) ,;
			TRB->MSBLQL,;
			TRB->METAV ,;
			Transform(TRB->INDMELH,"@E 999.99") }  )
	
		DbSelectArea("TRB")
		DbSkip()
	
	End

	Processa({||Run_Excel(aDadosExcel,nCol)},"Gerando a Integra��o com o Excel...")

	MsgInfo("Exportacao efetuada com sucesso..")

	TRB->(DbGotop())

Return

Static Function Run_Excel(aDadosExcel,nCol)
	LOCAL cDirDocs   := MsDocPath()
	Local aStru		:= {}
	Local cArquivo := CriaTrab(,.F.)
	Local cPath		:= AllTrim(GetTempPath())
	Local oExcelApp
	Local nHandle
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local nX

	ProcRegua(Len(aDaDosExcel))

	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

	If nHandle > 0
	
	
		For nX := 1 to Len(aDadosExcel)
		
			IncProc("Aguarde! Gerando arquivo de integra��o com Excel...") //
			cBuffer := ""
			For nY := 1 to nCol  //Numero de Colunas do Vetor
			
				cBuffer += aDadosExcel[nX,nY] + ";"
			
			Next
			fWrite(nHandle, cBuffer+cCrLf ) // Pula linha
		
		Next
	
		IncProc("Aguarde! Abrindo o arquivo...") //
	
		fClose(nHandle)
	
		CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )
	
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( 'MsExcel nao instalado' ) //
			Return
		EndIf
	
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert( "Falha na cria��o do arquivo" ) //
	Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CONSSD1   �Autor  �Microsiga           � Data �  05/13/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CriaArqTmp()
	Local aCampos := {}

	AaDd(aCampos,{"OK"       ,"C",  2,0})

	AaDd(aCampos,{"COTACAO"  ,"C",  6,0})
	
	AaDd(aCampos,{"FORNECE"  ,"C",  6,0})
	AaDd(aCampos,{"LOJA"     ,"C",  2,0})
	AaDd(aCampos,{"NOME"     ,"C", 30,0})

	AaDd(aCampos,{"FORNECE1"  ,"C",  6,0})
	AaDd(aCampos,{"LOJA1"     ,"C",  2,0})
	AaDd(aCampos,{"NOME1"     ,"C", 30,0})

	AaDd(aCampos,{"FORNECE2"  ,"C",  6,0})
	AaDd(aCampos,{"LOJA2"     ,"C",  2,0})
	AaDd(aCampos,{"NOME2"     ,"C", 30,0})


	AaDd(aCampos,{"PRODUTO"  ,"C",  2,0})
	AaDd(aCampos,{"DESC"     ,"C", 30,0})
	AaDd(aCampos,{"PRECO"    ,"N", 14,2})
	AaDd(aCampos,{"PRECO1"    ,"N", 14,2})
	AaDd(aCampos,{"PRECO2"    ,"N", 14,2})
	AaDd(aCampos,{"PRCMED"    ,"N", 14,2})
  		
	cArqTmp := CriaTrab(aCampos,.T.)

//��������������������������Ŀ
//�Cria o arquivo de Trabalho�
//����������������������������

	DbUseArea(.T.,,cArqTmp,"TRB",.F.,.F.)
	IndRegua("TRB",cArqTmp,"COTACAO",,,"Selecionando Registros..." )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCons   �Autor  �Carlos R Moreira    � Data �  05/05/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �imprime o relatorio referente a consulta                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpCons()
	Local oPrn
	Private oFont, cCode

	oFont  :=  TFont():New( "Arial",,15,,.T.,,,,,.F. )
	oFont3 :=  TFont():New( "Arial",,12,,.t.,,,,,.f. )
	oFont12:=  TFont():New( "Arial",,10,,.t.,,,,,.f. )
	oFont5 :=  TFont():New( "Arial",,10,,.f.,,,,,.f. )
	oFont9 :=  TFont():New( "Arial",, 8,,.T.,,,,,.f. )
	oArialNeg06 :=  TFont():New( "Arial",, 6,,.T.,,,,,.f. )

	oFont1:= TFont():New( "Times New Roman",,28,,.t.,,,,,.t. )
	oFont2:= TFont():New( "Times New Roman",,14,,.t.,,,,,.f. )
	oFont4:= TFont():New( "Times New Roman",,20,,.t.,,,,,.f. )
	oFont7:= TFont():New( "Times New Roman",,18,,.t.,,,,,.f. )
	oFont11:=TFont():New( "Times New Roman",,10,,.t.,,,,,.t. )

	oFont6:= TFont():New( "HAETTENSCHWEILLER",,10,,.t.,,,,,.f. )

	oFont8:=  TFont():New( "Free 3 of 9",,44,,.t.,,,,,.f. )
	oFont10:= TFont():New( "Free 3 of 9",,38,,.t.,,,,,.f. )
	oFont13:= TFont():New( "Courier New",,10,,.t.,,,,,.f. )

	oBrush  := TBrush():New(,CLR_HGRAY,,)
	oBrush1 := TBrush():New(,CLR_BLUE,,)
	oBrush2 := TBrush():New(,CLR_WHITE,,)

//��������������������������������������������������������������Ŀ
//� Cria Indice para Gerar o Romaneio                            �
//����������������������������������������������������������������
//cNomArq  := CriaTrab(nil,.f.)
//IndRegua("TRB",cNomArq,"ROMANEI+PEDIDO",,,OemToAnsi("Selecionando Registros..."))	//

	oPrn := TMSPrinter():New()
	oPrn:SetLandscape()
	//oPrn:SetPortrait()
	oPrn:SetPaperSize(9)

	oPrn:Setup()

	lFirst := .t.
	lPri := .T.
	nPag := 0
	nLin := 490
	
	DbSelectArea("TRB")
	DbGotop()
	
	ProcRegua(RecCount())        // Total de Elementos da regua
	
	While TRB->(!EOF())
		
		
		If lFirst
			oPrn:StartPage()
			cTitulo := "Relatorio de Qualificacao de  Fornecedores "
			cRod    := " "
			cNomEmp := SM0->M0_NOMECOM
			aTit    := {cTitulo,cNomEmp,cRod}
			nPag++
			U_CabRel(aTit,1,oPrn,nPag,"")
			
			CabCons(oPrn,1)
			
			lFirst = .F.
			
		EndIf
			
		oPrn:Box(nLin,100,nLin+60,3300)
			
		oPrn:line(nLin, 250,nLin+60, 250)
		oPrn:line(nLin, 550,nLin+60, 550)
   oPrn:line(nLin,1400,nLin+60,1400)
		oPrn:line(nLin,1900,nLin+60,1900)
		oPrn:line(nLin,2100,nLin+60,2100)
		oPrn:line(nLin,2300,nLin+60,2300)		
		oPrn:line(nLin,2500,nLin+60,2500)
		oPrn:line(nLin,2700,nLin+60,2700)
		oPrn:line(nLin,2900,nLin+60,2900)
		oPrn:line(nLin,3200,nLin+60,3200)

		oPrn:Say(nLin+10,  110,TRB->FORNECE+"-"+TRB->LOJA    ,oFont9 ,100)
		oPrn:Say(nLin+10,  260,Transform(TRB->CGC,"@R 99.999.999/9999-99")  ,oFont9 ,100)
		oPrn:Say(nLin+10,  560,TRB->NOME          ,oFont5 ,100)
		oPrn:Say(nLin+10, 1410,TRB->NREDUZ         ,oFont9 ,100)

		oPrn:Say(nLin+10, 1910,Dtoc(TRB->PRICOM)   ,oFont5 ,100)
		oPrn:Say(nLin+10, 2110,Dtoc(TRB->ULTCOM)   ,oFont5 ,100)
		oPrn:Say(nLin+10, 2310,Transform(TRB->FATAVA,"999.99")   ,oFont5 ,100)		
		oPrn:Say(nLin+10, 2510,Dtoc(TRB->DTAVA)   ,oFont5 ,100)
		oPrn:Say(nLin+10, 2710,Dtoc(TRB->DTVAL)   ,oFont5 ,100)
		oPrn:Say(nLin+10, 2910,TRB->METAV         ,oFont9 ,100)
		oPrn:Say(nLin+10, 3210,Transform(TRB->INDMELH,"@E 999.99")   ,oFont9 ,100)
		nLin += 60

		If nLin > 2200
			oPrn:EndPage()
	   
			lFirst := .T.
	      			
		EndIf
			
		DbSelectArea("TRB")
		DbSkip()
			
	End

	If !lFirst
		oPrn:EndPage()
	EndIf

	oPrn:Preview()
	oPrn:End()

	TRB->(DbGoTop())

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CabCons   �Autor  �Carlos R. Moreira   � Data �  19/07/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �monta o cabecalho da consulta                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CabCons(oPrn,nModo)

	nLin := 320

	oPrn:FillRect({nLin,100,nLin+60,3300},oBrush)

	oPrn:Box(nLin,100,nLin+60,3300)
		
	oPrn:line(nLin, 250,nLin+60, 250)
	oPrn:line(nLin, 550,nLin+60, 550)
	oPrn:line(nLin,1400,nLin+60,1400)
	oPrn:line(nLin,1900,nLin+60,1900)
	oPrn:line(nLin,2100,nLin+60,2100)
	oPrn:line(nLin,2300,nLin+60,2300)	
	oPrn:line(nLin,2500,nLin+60,2500)
	oPrn:line(nLin,2700,nLin+60,2700)
	oPrn:line(nLin,2900,nLin+60,2900)
	oPrn:line(nLin,3200,nLin+60,3200)

	oPrn:Say(nLin+10,  110,"Codigo"   ,oFont9 ,100)
	oPrn:Say(nLin+10,  260,"CNPJ/CPF"     ,oFont5 ,100)
	oPrn:Say(nLin+10,  560,"Nome"         ,oFont5 ,100)
	oPrn:Say(nLin+10, 1410,"N.Fantasia"   ,oFont5 ,100)
	oPrn:Say(nLin+10, 1910,"1a Compra"    ,oFont5 ,100)
	oPrn:Say(nLin+10, 2110,"Ult.Compra"   ,oFont5 ,100)
	oPrn:Say(nLin+10, 2310,"Fator Aval"   ,oFont5 ,100)	
	oPrn:Say(nLin+10, 2510,"Dt.Avaliacao" ,oFont5 ,100)
	oPrn:Say(nLin+10, 2710,"Dt Validade"  ,oFont5 ,100)
	oPrn:Say(nLin+10, 2900,"Metodo Aval"  ,oFont5 ,100)
	oPrn:Say(nLin+10, 3220,"IQ%"          ,oFont5 ,100)

	nLin += 60

Return

