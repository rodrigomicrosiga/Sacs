#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PGPER08   �Autor  �Carlos R. Moreira   � Data �  26/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ira gerar a relacao de Salarios                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PGPER08()

	Local aSays     := {}
	Local aButtons  := {}
	Local nOpca     := 0
	Local cCadastro := OemToAnsi("Relacao de Aviso Previo Funcionario")
	Private  cArqTxt
	Private cPerg := "PGPER08"

	PutSx1(cPerg,"01","Data Inicial               ?","","","mv_ch1","D",  8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{{"Data Inicial do processamento "}},{{" "}},{{" "}},"")
	PutSx1(cPerg,"02","Data Final                 ?","","","mv_ch2","D",  8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{{"Data Final de processamento   "}},{{" "}},{{" "}},"")

	aHelpPor :=	{"Define se a exportacao de dados sera consolidada entre empresas"}
	aHelpEsp :=	{}
	aHelpEng :=	{}

	PutSx1( cPerg, 	"03","Consolidas as Empresas  ?","Consolidas as Empresas ?","Consolidas as Empresas ?","mv_ch2","N",1,0,1,"C","","","","",;
	"mv_par03","Nao","","","","Sim","","",;
	"","","","","","","","","",aHelpPor,aHelpEng,aHelpEsp)

	PutSx1(cPerg,"04","C.Custo de               ?","","","mv_ch4","C",  9,0,0,"G","","CTT","","","mv_par04","","","","","","","","","","","","","","","","",{{"C.Custo Inicial "}},{{" "}},{{" "}},"")
	PutSx1(cPerg,"05","C.Custo de               ?","","","mv_ch5","C",  9,0,0,"G","","CTT","","","mv_par05","","","","","","","","","","","","","","","","",{{"C.Custo Final "}},{{" "}},{{" "}},"")

	Pergunte(cPerg,.F.)

	Aadd(aSays, OemToAnsi(" Este programa ira processar o arquivo de tranferencias de Funcionarios "))
	Aadd(aSays, OemToAnsi(" consolidando ou  nao por empresa.        "))

	Aadd(aButtons, { 1, .T., { || nOpca := 1, FechaBatch()  }})
	Aadd(aButtons, { 2, .T., { || FechaBatch() }})
	Aadd(aButtons, { 5, .T., { || Pergunte(cPerg,.T.) }})

	FormBatch(cCadastro, aSays, aButtons)

	If nOpca == 1

		MV_PAR03 := 1

		If MV_PAR03 == 2

			DbSelectArea("SM0")
			aAreaSM0 := GetArea()

			aEmp := U_SelEmp("V")

			RestArea( aAreaSM0 )

			If Len(aEmp) == 0
				MsgStop("Nao houve selecao de nenhuma empresa")
			EndIf
		Else
			aEmp := {}
			Aadd( aEmp, SM0->M0_CODIGO )
		Endif

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
���Programa  �Proc_Arq  �Autor  �Carlos R. Moreira   � Data �  30/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ira gerar a Query de cada empresa e consolidar             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Gtex                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Proc_Arq(cEmp)
	Local aNomArq := {}
	Local aArq := {{"SRA"," "},{"SRE"," "},{"CTT"," "} }

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

	cArquivos := ""

	For nArq := 1 to Len(aArq)
		cArquivos += aArq[nArq,2]+" "+aArq[nArq,1]
		If nArq # Len(aArq)
			cArquivos += ","
		EndIf
	Next

	cQuery := "Select SRA.RA_MAT, SRA.RA_NOME,  "
	cQuery += "       SRA.RA_CC, SRA.RA_DTAVPRE, SRA.RA_DTAVPRF, SRA.RA_TPAVISO,  "

	cQuery += "CTT.CTT_DESC01 From "+ aArq[Ascan(aArq,{|x|x[1] = "SRA" }),2]+" SRA "

	cQuery += "JOIN "+ aArq[Ascan(aArq,{|x|x[1] = "CTT" }),2]+" CTT  ON "
	cQuery += "     CTT.D_E_L_E_T_ <> '*' AND SRA.RA_CC  = CTT.CTT_CUSTO "
	cQuery += "     AND  CTT.CTT_CUSTO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "

	cQuery += "Where SRA.D_E_L_E_T_ <> '*'  AND  "
	cQuery += "      SRA.RA_DTAVPRE BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "

	cQuery += " Order by SRA.RA_NOME  "

	cQuery := ChangeQuery(cQuery)

	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)},"Aguarde gerando o arquivo..")
	TCSetField("QRY","RA_DTAVPRE","D")
	TCSetField("QRY","RA_DTAVPRF","D")


	nTotReg := 0
	QRY->(dbEval({||nTotREG++}))
	QRY->(dbGoTop())

	DbSelectArea("QRY")
	DbGotop()

	ProcRegua(nTotReg)

	While QRY->(!Eof())

		IncProc("Processando o Arquivo de trabalho..Emp: "+cEmp)

		//Necessito gravar somente um registro por empresa
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->EMPRESA := cEmp
		TRB->MAT     := QRY->RA_MAT
		TRB->NOME    := QRY->RA_NOME
		TRB->CC      := QRY->RA_CC
		TRB->DESC_CC := QRY->CTT_DESC01
		TRB->DTAVPRE := QRY->RA_DTAVPRE
		TRB->DTAVPRF := QRY->RA_DTAVPRF 

		Do Case
			Case QRY->RA_TPAVISO == "I"
			TRB->TPAVISO := "Indenizado"
			Case QRY->RA_TPAVISO == "T"
			TRB->TPAVISO := "Trabalhado"
			Case QRY->RA_TPAVISO == "J"
			TRB->TPAVISO := "Justa Causa"
			Case QRY->RA_TPAVISO == "R"
			TRB->TPAVISO := "Resc Ant Con Trab"
			Case QRY->RA_TPAVISO == "E"
			TRB->TPAVISO := "Term Experiencia"
		EndCase        

		MsUnlock()

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
���Programa  �CRIARQTMP �Autor  �Carlos R. Moreira   � Data �  05/30/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o arquivo de trabalho                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Gtex                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CriaArqTmp()
	Local aCampos := {}

	AaDd(aCampos,{"OK"       ,"C",  2,0})
	AaDd(aCampos,{"EMPRESA"  ,"C",  2,0})
	AaDd(aCampos,{"MAT"      ,"C",  6,0})
	AaDd(aCampos,{"NOME"     ,"C", 40,0})

	AaDd(aCampos,{"CC"       ,"C",  9,0})
	AaDd(aCampos,{"DESC_CC"  ,"C", 20,0})
	AaDd(aCampos,{"DTAVPRE"  ,"D",  8,0})
	AaDd(aCampos,{"DTAVPRF"  ,"D",  8,0})
	AaDd(aCampos,{"TPAVISO"  ,"C", 15,0})

	cArqTmp := CriaTrab(aCampos,.T.)

	//��������������������������Ŀ
	//�Cria o arquivo de Trabalho�
	//����������������������������

	DbUseArea(.T.,,cArqTmp,"TRB",.F.,.F.)
	IndRegua("TRB",cArqTmp,"EMPRESA+MAT",,,"Selecionando Registros..." )

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
���Uso       � AP                                                         ���
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

	//AaDD(aBrowse,{"EMPRESA","","Empresa"})
	AaDD(aBrowse,{"MAT","","Matricula"})
	AaDD(aBrowse,{"NOME","","Nome"})
	AaDD(aBrowse,{"CC","","Centro Custo"})
	AaDD(aBrowse,{"DESC_CC","","Descr. Centro Custo"})
	AaDD(aBrowse,{"DTAVPRE","","Av Previo Ini"})
	AaDD(aBrowse,{"DTAVPRF","","Av Previo Fim"})
	AaDD(aBrowse,{"TPAVISO","","Tipo Aviso"})

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

	DEFINE MSDIALOG oDlg1 TITLE "Demostra as Transferencias " From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	//����������������������������������������������������������������������Ŀ
	//� Passagem do parametro aCampos para emular tamb�m a markbrowse para o �
	//� arquivo de trabalho "TRB".                                           �
	//������������������������������������������������������������������������
	oMark := MsSelect():New("TRB","","",aBrowse,@lInverte,@cMarca,{aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]})  //35,3,213,385

	oMark:bMark := {| | fa060disp(cMarca,lInverte)}
	oMark:oBrowse:lhasMark = .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:bAllMark := { || FA060Inverte(cMarca) }

	@ aPosObj[1,1]+10,aPosObj[1,4]-210 Button "&Imprimir"    Size 60,15 Action ImprTransf() of oDlg1 Pixel //Localiza o Dia

	@ aPosObj[1,1]+10,aPosObj[1,4]-140 Button "&Excel"    Size 60,15 Action ExpCons() of oDlg1 Pixel //Localiza o Dia

	@ aPosObj[1,1]+10,aPosObj[1,4]-70 Button "&Fechar"    Size 60,15 Action {||oDlg1:End()} of oDlg1 Pixel //Localiza o Dia

	ACTIVATE MSDIALOG oDlg1 CENTERED //ON INIT LchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||oDlg1:End()},.T.) CENTERED

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

Static Function ExpCons()
	Private aDadosExcel := {}

	AaDd(aDadosExcel,{ "Matricula",;
	"Nome",;
	"C.Custo",;
	"Descr. Centro Custo",;
	"Dt. Aviso Ini",;
	"Dt. Aviso Fim",;
	"Tipo Aviso" } )

	nCol := Len(aDadosExcel[1])

	DbSelectArea("TRB")
	DbGoTop()

	ProcRegua(RecCount())        // Total de Elementos da regua

	While TRB->(!EOF())

		AaDD( aDadosExcel, { TRB->MAT,;
		TRB->NOME,;
		TRB->CC,;
		TRB->DESC_CC,;
		Dtoc(TRB->DTAVPRE),;
		Dtoc(TRB->DTAVPRF),;
		TRB->TPAVISO})

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
���Programa  �FGPER03   �Autor  �Microsiga           � Data �  12/22/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImprTransf()
	Local oPrn
	Private oFont, cCode

	oFont  :=  TFont():New( "Arial",,15,,.T.,,,,,.F. )
	oFont3 :=  TFont():New( "Arial",,12,,.t.,,,,,.f. )
	oFont12:=  TFont():New( "Arial",,10,,.t.,,,,,.f. )
	oFont5 :=  TFont():New( "Arial",,10,,.f.,,,,,.f. )
	oFont9 :=  TFont():New( "Arial",, 8,,.T.,,,,,.f. )
	oArialNeg06 :=  TFont():New( "Arial",, 6,,.T.,,,,,.f. )
	oArialNeg07 :=  TFont():New( "Arial",, 7,,.T.,,,,,.f. )

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
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9)
	//oPrn:SetLandscape()

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
			cTitulo := "Relatorio de Aviso Previo de Funcionarios"
			cRod    := "Do periodo de "+Dtoc(MV_PAR01)+" a "+Dtoc(MV_PAR02)
			cNomEmp := SM0->M0_NOMECOM
			aTit    := {cTitulo,cNomEmp,cRod}
			nPag++
			U_CabRel(aTit,2,oPrn,nPag,"")

			CabCons(oPrn)

			lFirst = .F.

		EndIf

		oPrn:Box(nLin,100,nLin+60,2300)

		oPrn:line(nLin, 250,nLin+60, 250)
		oPrn:line(nLin,1000,nLin+60,1000)
		oPrn:line(nLin,1200,nLin+60,1200)
		oPrn:line(nLin,1600,nLin+60,1600)
		oPrn:line(nLin,1800,nLin+60,1800)
		oPrn:line(nLin,2000,nLin+60,2000)

		oPrn:Say(nLin+10,  110,TRB->MAT     ,oFont9 ,100)
		oPrn:Say(nLin+10,  260,TRB->NOME    ,oFont9 ,100)
		oPrn:Say(nLin+10, 1010,TRB->CC      ,oFont9 ,100)
		oPrn:Say(nLin+10, 1210,TRB->DESC_CC ,oFont9 ,100)
		oPrn:Say(nLin+10, 1610,Dtoc(TRB->DTAVPRE) ,oFont9 ,100)
		oPrn:Say(nLin+10, 1810,Dtoc(TRB->DTAVPRF) ,oFont9 ,100)		
		oPrn:Say(nLin+10, 2010,TRB->TPAVISO   ,oFont9 ,100)

		nLin += 60

		If nLin > 2200
			oPrn:EndPage()

			oPrn:StartPage()
			cTitulo := "Relatorio de Aviso Previo de Funcionarios"
			cRod    := "Do periodo de "+Dtoc(MV_PAR01)+" a "+Dtoc(MV_PAR02)
			cNomEmp := SM0->M0_NOMECOM
			aTit    := {cTitulo,cNomEmp,cRod}
			nPag++
			U_CabRel(aTit,2,oPrn,nPag,"")

			CabCons(oPrn)

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

	oPrn:FillRect({nLin,100,nLin+60,2300},oBrush)

	oPrn:Box(nLin,100,nLin+60,2300)

	oPrn:line(nLin, 250,nLin+60, 250)
	oPrn:line(nLin,1000,nLin+60,1000)
	oPrn:line(nLin,1200,nLin+60,1200)
	oPrn:line(nLin,1600,nLin+60,1600)
	oPrn:line(nLin,1800,nLin+60,1800)
	oPrn:line(nLin,2000,nLin+60,2000)

	oPrn:Say(nLin+10,  110,"Matricula"        ,oFont5 ,100)
	oPrn:Say(nLin+10,  260,"Nome"             ,oFont5 ,100)
	oPrn:Say(nLin+10, 1010,"C.Custo"          ,oFont5 ,100)
	oPrn:Say(nLin+10, 1210,"Desc C.Custo "    ,oFont5 ,100)
	oPrn:Say(nLin+10, 1610,"Ini Aviso"        ,oFont5 ,100)
	oPrn:Say(nLin+10, 1810,"Fim Aviso"        ,oFont5 ,100)
	oPrn:Say(nLin+10, 2010,"Tipo Aviso"       ,oFont5 ,100)

	nLin += 60

Return
