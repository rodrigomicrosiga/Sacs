#include "rwmake.ch"
#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103LDV  �Autor  �Carlos R Moreira    � Data �  18/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para trazer a descricao da nota de saida   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT103LDV()
Local aLinha := Paramixb[1]
Local cAlias := ParamIxb[2]

cDescri := Posicione("SD2",3,xFilial("SD2")+(cAlias)->D2_DOC+(cAlias)->D2_SERIE+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA+(cAlias)->D2_COD+(cAlias)->D2_ITEM,"D2_DESCRI")

AAdd( aLinha, { "D1_DESCR", cDescri , Nil })

Return aLinha 