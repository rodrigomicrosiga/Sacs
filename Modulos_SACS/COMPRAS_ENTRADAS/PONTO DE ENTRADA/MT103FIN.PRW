#include "rwmake.ch"
#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PFINA05  � Autor � Carlos R. Moreira     � Data �29.08.2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ira fazer a aprovacao do Orcamento                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User function MT103FIN()

	local aArea := GetArea()

	Local aLocHead := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
	Local aLocCols := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
	Local lLocRet  := PARAMIXB[3]      // Flag de valida��es anteriores padr�es do sistema.
	// Caso este flag esteja como .T., todas as valida��es
	// anteriores foram aceitas com sucesso, no contr�rio, .F. 
	// indica que alguma valida��o anterior N�O foi aceita. 
	Local _iCount

	Local _nMaxPar := IIF(aLocCols==Nil,0,Len(aLocCols))

	Local nPosVenc := aScan(aLocHead,{|x| alltrim(x[2])=="E2_VENCTO"})
	Local nPosVlr  := aScan(aLocHead,{|x| alltrim(x[2])=="E2_VALOR"})

    If !ExisteSX6("MV_DIAENTR")
		CriarSX6("MV_DIAENTR","N","Determina os qtde minima de dias para a entrada do titulo","3")
	EndIf
    
    nDiasLim := GetMv("MV_DIAENTR")
  
    If Dow(date()) == 6 //Qdo for sexta devera acrescentar + 2 dias 
       nDiasLim += 2  
    EndIf   
    
	For _iCount:= 1 to _nMaxPar
		If lLocRet .And. (aLocCols[_iCount][aScan(aLocHead,{|x| alltrim(x[2])=="E2_VALOR"})]>0  .and. aLocCols[_iCount][aScan(aLocHead,{|x| alltrim(x[2])=="E2_VENCTO"})] <  DataValida((date()+nDiasLim),.T. ))
			Alert(OemToAnsi('Conforme norma da empresa, somente ser� permitida a entrada de documentos com vencimentos a partir de ')+ DTOC(DataValida((date()+nDiasLim),.T. )) )
			lLocRet := .F.
		EndIf
	Next _iCount


	For nX := 1 to _nMaxPar

		If aLocCols[nX,nPosVlr] > 0

			If Dow(aLocCols[nX,nPosVenc]) == 1 .Or. Dow(aLocCols[nX,nPosVenc]) == 7

				MsgStop("Data de Vencimento nao pode ser sabado ou domingo.")

				RestArea(aArea)

				Return .F.

			EndIf    

		EndIf

	Next

	RestArea(aArea)

Return(lLocRet)

