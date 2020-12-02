#INCLUDE "Protheus.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT410BRW     �Autor  �Guilherme Giuliano Data �  12/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para filtrar pedidos do usuario quando o  ���
���          � mesmo estiver no cadastro de permissoes (SZ1)             ���
�������������������������������������������������������������������������͹��
���Uso       � Sacs                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

*****************************************************************************
User function MT410BRW
*****************************************************************************

dbselectarea("SZ1")
dbsetorder(1)
IF dbseek(xFilial("SZ1")+__CUSERID)
	DbSelectArea("SC5")
	Set Filter to SC5->C5_CRIADOR == __CUSERID
ELSE	               
	DbSelectArea("SC5")
ENDIF	

return